//
//  ProgressBar.swift
//  NeoSkeuomorphKit
//
//  Created by Николай Булдаков on 02/04/2020.
//

import UIKit

@IBDesignable
public class ProgressBar: UIView {

    private enum LayoutConfiguration {
        static var height: CGFloat {
            return 16
        }

        static var progressIndicatorHeight: CGFloat {
            return height - 3
        }

        static var progressIndicatorRadius: CGFloat {
            return progressIndicatorHeight / 2
        }

        static var progressIndicatorMargin: CGFloat {
            return 2
        }

    }

    // MARK: Colors

    /// Upper left component of the gradient color which fills the thumb
    public var progressBarTintLeftColor = UIColor(red: 236.0/255.0, green: 242.0/255.0, blue: 248.0/255.0, alpha: 1.0) {
        didSet { updateTintColors() }
    }

    /// Lower right component of the gradient color which fills the thumb
    public var progressBarTintRightColor = UIColor(red: 213.0/255.0,
        green: 223.0/255.0,
        blue: 234.0/255.0,
        alpha: 1.0) {
        didSet { updateTintColors() }
    }

    /// Color of the background behind the inidicator
    public var baseColor: UIColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0) {
        didSet { base.child?.backgroundColor = baseColor }
    }

    private var shadowColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    private var indicatorBarInnerShadowColor = UIColor(red: 39/255.0, green: 88/255.0, blue: 126/255.0, alpha: 1.0)

    // MARK: Animation
    private let animationDuration = 0.2
    private var isAnimated = false

    // MARK: Progress
    /// The current progress shown by the receiver.
    @IBInspectable public var progress: Float = 0.0 {
        didSet {
            if progress > 1.0 { progress = 1.0 }
            if progress < 0.0 { progress = 0.0 }
            updateProgressIndicator()
        }
    }

    /// Adjusts the current progress shown by the receiver, optionally animating the change.
    public func setProgress(_ progress: Float, animated: Bool) {
        self.progress = progress
        self.isAnimated = animated
        self.updateProgressIndicator()

        layoutIfNeeded()

        UIView.animate(withDuration: animated ? 0 : 0) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: LayoutConfiguration.height)
    }

    // MARK: Layers and views

    private lazy var base: ContainerView = {
        let baseView = UIView()
        baseView.backgroundColor = baseColor

        let base = ContainerView(child: baseView)

        base.translatesAutoresizingMaskIntoConstraints = false
        base.elevation = .concaveSlight
        base.layer.cornerRadius = LayoutConfiguration.height / 2
        base.layer.masksToBounds = true

        return base
    }()

    /// Displays the current progress
    @objc private lazy var progressIndicator: UIView = {
        let progressIndicator = UIView()

        progressIndicator.layer.shadowOffset = CGSize(width: -1, height: 2)
        progressIndicator.layer.shadowOpacity = 0.8
        progressIndicator.layer.shadowColor = shadowColor.cgColor
        progressIndicator.layer.cornerRadius = LayoutConfiguration.progressIndicatorRadius

        progressIndicator.translatesAutoresizingMaskIntoConstraints = false

        progressIndicator.layer.addSublayer(progressIndicatorSurface)
        progressIndicator.layer.addSublayer(progressIndicatorShadow)

        return progressIndicator
    }()

    /// The inner bottom shadow of `progressIndicator`
    private lazy var progressIndicatorShadow: CAShapeLayer = {
        let progressIndicatorShadow = CAShapeLayer()

        progressIndicatorShadow.fillColor = UIColor.clear.cgColor
        progressIndicatorShadow.lineWidth = 1
        progressIndicatorShadow.strokeColor = UIColor.black.cgColor
        progressIndicatorShadow.shadowColor = indicatorBarInnerShadowColor.cgColor
        progressIndicatorShadow.shadowOpacity = 0.55
        progressIndicatorShadow.shadowRadius = 1
        progressIndicatorShadow.masksToBounds = true
        progressIndicatorShadow.shadowOffset = CGSize(width: 0, height: -1)
        progressIndicatorShadow.cornerRadius = LayoutConfiguration.progressIndicatorRadius

        return progressIndicatorShadow
    }()

    /// Gradient surface of `progressIndicator`
    private lazy var progressIndicatorSurface: CAGradientLayer = {
        let progressIndicatorSurface = CAGradientLayer()

        progressIndicatorSurface.masksToBounds = false
        progressIndicatorSurface.cornerRadius = LayoutConfiguration.progressIndicatorRadius
        progressIndicatorSurface.colors = [progressBarTintLeftColor.cgColor, progressBarTintRightColor.cgColor]
        progressIndicatorSurface.locations = [-0.3, 1.5]
        progressIndicatorSurface.startPoint = CGPoint(x: 0, y: 0.5)
        progressIndicatorSurface.endPoint = CGPoint(x: 1, y: 0.5)

        return progressIndicatorSurface
    }()

    /// Defines the width of `progressIndicator` to display the `progress`
    private lazy var progressIndicatorWidthConstraint: NSLayoutConstraint = {
        let constraint = progressIndicator.widthAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        return constraint
    }()

    // MARK: Auxiliary
    private func getInnerShadowPath() -> CGPath {
        let radius = LayoutConfiguration.progressIndicatorRadius
        let path = UIBezierPath()

        path.addArc(
            withCenter: CGPoint(x: radius, y: radius),
            radius: radius+1,
            startAngle: .pi,
            endAngle: .pi/2,
            clockwise: false
        )

        path.addLine(to: CGPoint(x: progressIndicator.bounds.width - radius, y: 2 * radius + 1) )

        path.addArc(
            withCenter: CGPoint(x: progressIndicator.bounds.width - radius, y: radius),
            radius: radius+1,
            startAngle: .pi/2,
            endAngle: 0,
            clockwise: false
        )

        return path.cgPath
    }

    func animatePathChange(for layer: CAShapeLayer, toPath: CGPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = self.isAnimated ? self.animationDuration : 0
        animation.fromValue = layer.path
        animation.toValue = toPath
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        progressIndicatorShadow.add(animation, forKey: "path")
    }

    // MARK: KVO

    /*
     progressIndicator's width is defined by progressIndicatorWidthConstraint, however the sublayers
     of its layer should also be updated when the width changes. KVO is used here for this reason
     */

    private var kvoToken: NSKeyValueObservation?

    private func setKvo() {
        kvoToken = progressIndicator.observe(\.bounds, options: .new) { (_, _) in

            let path = self.getInnerShadowPath()

            // Change and animate path shadow
            self.animatePathChange(for: self.progressIndicatorShadow, toPath: path)
            self.progressIndicatorShadow.path = path

            // Change and animate surface's and shadow's frames and animate
            CATransaction.begin()
            CATransaction.setAnimationDuration(self.isAnimated ? self.animationDuration : 0)

            // updating the gradient surface
            self.progressIndicatorSurface.frame = CGRect(
                x: 0,
                y: 0,
                width: self.progressIndicator.bounds.width,
                height: LayoutConfiguration.progressIndicatorHeight
            )

            // updating the inner shadow frame
            self.progressIndicatorShadow.frame = CGRect(
                x: 0,
                y: 0,
                width: self.progressIndicator.bounds.width,
                height: LayoutConfiguration.progressIndicatorHeight
            )

            CATransaction.commit()

            self.isAnimated = false
        }
    }

    // MARK: Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }

    // MARK: Setup and update
    private func setUpView() {
        setKvo()
        addSubviews()
        setLayout()
    }

    private func addSubviews() {
        addSubview(base)
        base.addSubview(progressIndicator)
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            base.heightAnchor.constraint(equalToConstant: LayoutConfiguration.height),
            base.centerYAnchor.constraint(equalTo: centerYAnchor),
            base.leadingAnchor.constraint(equalTo: leadingAnchor),
            base.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            progressIndicator.topAnchor.constraint(
                equalTo: base.topAnchor,
                constant: LayoutConfiguration.progressIndicatorMargin
            ),
            progressIndicator.leadingAnchor.constraint(
                equalTo: base.leadingAnchor,
                constant: LayoutConfiguration.progressIndicatorMargin
            ),
            progressIndicator.heightAnchor.constraint(equalToConstant: LayoutConfiguration.progressIndicatorHeight),
        ])
    }

    /* progressIndicatorWidthConstraint's multiplier property is read-only, that's why we
       remove the old constraint and create a new one to update the progressIndicator */
    private func updateProgressIndicator() {
        progressIndicatorWidthConstraint.isActive = false

        progressIndicatorWidthConstraint = progressIndicator
            .widthAnchor.constraint(
                equalTo: base.widthAnchor,
                multiplier: CGFloat(progress),
                // to account the fact that the inicator has a margin of 2 point to each side of the base
                constant: -(2 * LayoutConfiguration.progressIndicatorMargin) * CGFloat(progress)
        )

        progressIndicatorWidthConstraint.isActive = true

    }

    private func updateTintColors() {
        progressIndicatorSurface.colors = [progressBarTintLeftColor.cgColor, progressBarTintRightColor.cgColor]
    }

    deinit {
        // stop the observation
        kvoToken?.invalidate()
    }
}
