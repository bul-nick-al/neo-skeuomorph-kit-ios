//
//  Switch.swift
//  NeoSkeuomorphKit
//
//  Created by Николай Булдаков on 22/03/2020.
//

import UIKit

/// The Switch class declares a property and a method to control its on/off state.
/// The API is the same as Apple's own UISwitch with the exeption of its
/// tint colors. It also has a small indicator to its right side. The  `onTintColor` defines the color
/// of the indicator in the `On` state.
@IBDesignable
public class Switch: UIControl {

    private enum LayoutConfiguration {
        static var switchSize: CGSize {
            return CGSize(width: 51, height: 31)
        }

        // We subtract 4 because the bezel width is 1 and the gap is also 1 from both the top and the bottom
        static var thumbSize: CGSize {
            return CGSize(width: switchSize.height - 4, height: switchSize.height - 4)
        }

        static var indicatorMargin: CGFloat {
            return 8.0
        }

        /// Offset of the thumb to from the center
        static var thumbOffset: CGFloat {
            return switchSize.width / 2 - thumbSize.width / 2 - 2
        }
    }

    // MARK: Colors

    /// Color of the indicator when the switch is turned on
    public var onTintColor: UIColor? {
        didSet {
            guard let onTintColor = onTintColor else { return }
            indicator.onTintColor = onTintColor
        }
    }

    /// Upper left component of the gradient color which fills the thumb
    public var thumbTintUpperLeftColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0) {
        didSet { updateThumbColors() }
    }

    /// Lower right component of the gradient color which fills the thumb
    public var thumbTintLowerRightColor = UIColor.white {
        didSet { updateThumbColors() }
    }

    /// Color of the base behind the thumb
    public var baseColor = UIColor(red: 222.0/255.0, green: 232.0/255.0, blue: 242.0/255.0, alpha: 1.0) {
        didSet { base.child?.backgroundColor = baseColor }
    }

    /// The companion property of `isOn`.  It is used to separate the
    private var _isOn: Bool = false

    /// A Boolean value that determines the off/on state of the switch.
    @IBInspectable public var isOn: Bool {
        get { return _isOn }
        set {
            guard _isOn != newValue else { return }
            updateVisualState()
        }
    }

    override public var intrinsicContentSize: CGSize {
        let totalWidth = LayoutConfiguration.switchSize.width + LayoutConfiguration.indicatorMargin
            + indicator.intrinsicContentSize.width
        return CGSize(width: totalWidth, height: LayoutConfiguration.switchSize.height)
    }

    private let animationDuration = 0.2

    // MARK: Views and layers
    private let indicator: IndicatorView = {
        let indicator = IndicatorView()

        indicator.isOn = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false

        return indicator
    }()

    private lazy var thumb: ContainerView = {
        let thumb = ContainerView(child: UIView())

        thumb.layer.cornerRadius = LayoutConfiguration.thumbSize.width / 2
        thumb.elevation = .custom(elevation: 2)
        thumb.upperLeftOuterShadowColor = .clear
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.isUserInteractionEnabled = false

        return thumb
    }()

    private lazy var base: ContainerView = {
        let base = ContainerView(child: UIView())

        base.child?.backgroundColor = baseColor
        base.elevation = .custom(elevation: -3)
        base.lowerRightInnerShadowColor = .clear
        base.layer.cornerRadius = LayoutConfiguration.switchSize.height / 2
        base.bezelWidth = 1
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false

        return base
    }()

    private lazy var thumbContainer: UIView = {
        let thumbContainer = UIView()

        thumbContainer.layer.cornerRadius = LayoutConfiguration.switchSize.height / 2
        thumbContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbContainer.clipsToBounds = true
        thumbContainer.isUserInteractionEnabled = false

        return thumbContainer
    }()

    private lazy var thumbSurface: CAGradientLayer = {
        let thumbSurface = CAGradientLayer()

        thumbSurface.masksToBounds = false
        thumbSurface.colors = [thumbTintUpperLeftColor.cgColor, thumbTintLowerRightColor.cgColor]
        thumbSurface.locations = [-0.3, 1.5]
        thumbSurface.startPoint = CGPoint(x: 0, y: 0)
        thumbSurface.endPoint = CGPoint(x: 1, y: 1)
        thumbSurface.frame = CGRect(origin: CGPoint.zero, size: LayoutConfiguration.thumbSize)

        return thumbSurface
    }()
    private lazy var thumbShadow: CALayer = {
        let radius = LayoutConfiguration.thumbSize.width / 2

        let path = UIBezierPath()

        path.addArc(
            withCenter: CGPoint(x: radius, y: radius+2),
            radius: radius+1,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )

        let thumbShadow = CAShapeLayer()

        thumbShadow.path = path.cgPath
        thumbShadow.fillColor = UIColor.clear.cgColor
        thumbShadow.lineWidth = 1
        thumbShadow.strokeColor = UIColor.black.cgColor
        thumbShadow.shadowOpacity = 0.25
        thumbShadow.shadowRadius = 0.5

        return thumbShadow
    }()

    private lazy var thumbPositionConstraint: NSLayoutConstraint = {
        let constraint = thumb.centerXAnchor.constraint(
            equalTo: base.centerXAnchor,
            constant: -LayoutConfiguration.thumbOffset
        )
        return constraint
    }()

    // MARK: Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }

    /// Set the state of the switch to On or Off, optionally animating the transition.
    /// - Parameters:
    ///   - isOn: true if the switch should be turned to the On position;
    ///   false if it should be turned to the Off position.
    ///   If the switch is already in the designated position, nothing happens.
    ///   - animated: true to animate the “flipping” of the switch; otherwise false.
    public func setOn(_ isOn: Bool, animated: Bool) {
        layoutIfNeeded()
        _isOn = isOn
        UIView.animate(withDuration: animated ? animationDuration : 0) { [weak self] in
            guard let self = self else { return }
            self.updateVisualState()
            self.layoutIfNeeded()
        }
    }

    /// Change the state to the opposite
    @objc private func toggle() {
        setOn(!isOn, animated: true)
    }

    private func setUpView() {
        addSubviews()
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        setAutoLayout()
    }

    private func addSubviews() {
        addSubview(base)
        addSubview(thumbContainer)
        thumbContainer.addSubview(thumb)
        thumb.child?.layer.addSublayer(thumbSurface)
        thumb.child?.layer.addSublayer(thumbShadow)
        addSubview(indicator)
    }

    private func setAutoLayout() {
        let switchSize = LayoutConfiguration.switchSize
        NSLayoutConstraint.activate([
            base.widthAnchor.constraint(equalToConstant: switchSize.width),
            base.heightAnchor.constraint(equalToConstant: switchSize.height),
            base.centerYAnchor.constraint(equalTo: centerYAnchor),
            base.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            thumbContainer.widthAnchor.constraint(equalToConstant: switchSize.width - 2),
            thumbContainer.heightAnchor.constraint(equalToConstant: switchSize.height - 2),
            thumbContainer.centerYAnchor.constraint(equalTo: base.centerYAnchor),
            thumbContainer.centerXAnchor.constraint(equalTo: base.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            thumb.widthAnchor.constraint(equalToConstant: LayoutConfiguration.thumbSize.width),
            thumb.heightAnchor.constraint(equalToConstant: LayoutConfiguration.thumbSize.height),
            thumb.centerYAnchor.constraint(equalTo: base.child!.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(
                equalTo: base.trailingAnchor,
                constant: LayoutConfiguration.indicatorMargin
            ),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        thumbPositionConstraint.isActive = true

        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    private func updateVisualState() {
        thumbPositionConstraint.constant = isOn ? LayoutConfiguration.thumbOffset : -LayoutConfiguration.thumbOffset
        indicator.isOn = isOn
    }

    private func updateThumbColors() {
        thumbSurface.colors = [thumbTintUpperLeftColor.cgColor, thumbTintLowerRightColor.cgColor]
    }
}

/// A small indicator that imitates an LED light
public class IndicatorView: ContainerView<UIView> {

    private enum LayoutConfiguration {
        static var size: CGSize {
            return CGSize(width: 8, height: 8)
        }
    }

    /// Color in the  **On** state
    public var onTintColor: UIColor = .green {
        didSet {
            updateTintColor()
        }
    }
    /// Color in the  **Off** state
    public var offTinrColor: UIColor = UIColor(red: 175.0/255.0, green: 192.0/255.0, blue: 210.0/255.0, alpha: 1.0) {
        didSet {
            updateTintColor()
        }
    }

    /// A Boolean value that determines the off/on state of the indicator.
    public var isOn: Bool = false {
        didSet {
            updateTintColor()
        }
    }

    public override var intrinsicContentSize: CGSize {
        return LayoutConfiguration.size
    }

    // MARK: Initializers

    public override init(frame: CGRect) {
        super.init(frame: CGRect(origin: CGPoint.zero, size: LayoutConfiguration.size))
        setUpView()
        setUpPriorities()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
        setUpPriorities()
    }

    private func setUpView() {
        // The stroke line of the indicator has the opposite reflection
        swap(&upperLeftBezelColor, &lowerRightBezelColor)
        swap(&upperLeftInnerShadowColor, &lowerRightInnerShadowColor)

        child = UIView()
        updateTintColor()

        // There is no white shadow in the indicator
        upperLeftInnerShadowColor = .clear
        bezelWidth = 1
        elevation = .custom(elevation: -1)

        layer.cornerRadius = LayoutConfiguration.size.width / 2
    }

    private func setUpPriorities() {
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    private func updateTintColor() {
        child?.backgroundColor = isOn ? onTintColor : offTinrColor
    }
}
