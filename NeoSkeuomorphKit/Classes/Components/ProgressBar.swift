//
//  ProgressBar.swift
//  NeoSkeuomorphKit
//
//  Created by Николай Булдаков on 02/04/2020.
//

import UIKit

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

    }

    private var baseColor: UIColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    private var shadowColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    private var indicatorBarInnerShadowColor = UIColor(red: 39/255.0, green: 88/255.0, blue: 126/255.0, alpha: 1.0)
    /// Upper left component of the gradient color which fills the thumb
    public var progressBarTintLeftColor = UIColor(red: 236.0/255.0, green: 242.0/255.0, blue: 248.0/255.0, alpha: 1.0) {
        didSet { }
    }
    public var progress: Float = 0.0 {
        didSet {
            if progress > 1.0 { progress = 1.0 }
            if progress < 0.0 { progress = 0.0 }
            updateProgressIndicator()
        }
    }

    private var progressIndicatorWidth: CGFloat {
        return frame.width > 4 ? (frame.width - 4) * CGFloat(progress) : 0
    }

    /// Lower right component of the gradient color which fills the thumb
    public var progressBarTintRightColor = UIColor(
        red: 213.0/255.0,
        green: 223.0/255.0,
        blue: 234.0/255.0,
        alpha: 1.0) {
        didSet { }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: LayoutConfiguration.height)
    }

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

    private lazy var progressIndicator: UIView = {
        let progressIndicator = UIView()

        progressIndicator.layer.shadowOffset = CGSize(width: -1, height: 2)
        progressIndicator.layer.shadowOpacity = 0.8
        progressIndicator.layer.shadowColor = shadowColor.cgColor

        progressIndicator.layer.cornerRadius = LayoutConfiguration.progressIndicatorRadius

        progressIndicator.translatesAutoresizingMaskIntoConstraints = false

        return progressIndicator
    }()

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

    private lazy var progressIndicatorSurface: CAGradientLayer = {
        let progressIndicatorSurface = CAGradientLayer()

        progressIndicatorSurface.masksToBounds = false
        progressIndicatorSurface.colors = [progressBarTintLeftColor.cgColor, progressBarTintRightColor.cgColor]
        progressIndicatorSurface.locations = [-0.3, 1.5]
        progressIndicatorSurface.startPoint = CGPoint(x: 0, y: 0.5)
        progressIndicatorSurface.endPoint = CGPoint(x: 1, y: 0.5)
        progressIndicatorSurface.cornerRadius = LayoutConfiguration.progressIndicatorRadius

        return progressIndicatorSurface
    }()

    private lazy var progressIndicatorWidthConstraint: NSLayoutConstraint = {
        let constraint = progressIndicator.widthAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        return constraint
    }()

    private func updateProgressIndicator() {
        progressIndicatorShadow.path = getInnerShadowPath()

        progressIndicatorWidthConstraint.constant = progressIndicatorWidth
        progressIndicatorSurface.frame = CGRect(
            x: 0,
            y: 0,
            width: progressIndicator.bounds.width,
            height: LayoutConfiguration.progressIndicatorHeight
        )

        progressIndicatorShadow.frame = CGRect(
            x: 0,
            y: 0,
            width: progressIndicator.bounds.width,
            height: LayoutConfiguration.progressIndicatorHeight
        )
    }

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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
        addSubview(base)
        base.addSubview(progressIndicator)
        progressIndicator.layer.addSublayer(progressIndicatorSurface)
        progressIndicator.layer.addSublayer(progressIndicatorShadow)

        NSLayoutConstraint.activate([
            base.heightAnchor.constraint(equalToConstant: LayoutConfiguration.height),
            base.centerYAnchor.constraint(equalTo: centerYAnchor),
            base.leadingAnchor.constraint(equalTo: leadingAnchor),
            base.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            progressIndicator.topAnchor.constraint(equalTo: base.topAnchor, constant: 2),
            progressIndicator.leadingAnchor.constraint(equalTo: base.leadingAnchor, constant: 2),
            progressIndicator.heightAnchor.constraint(equalToConstant: LayoutConfiguration.progressIndicatorHeight),
        ])
    }

    public override func layoutSubviews() {
        updateProgressIndicator()
    }
}
