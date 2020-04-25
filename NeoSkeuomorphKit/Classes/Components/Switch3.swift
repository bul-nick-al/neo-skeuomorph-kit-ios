//
//  Switch.swift
//  NeoSkeuomorphKit
//
//  Created by Николай Булдаков on 22/03/2020.
//

import UIKit

/// The Switch class declares a property and a method to control its on/off state.
/// The API is the same as Apple's own UISwitch with the exeption of its
/// tint colors.
@IBDesignable
// swiftlint:disable:next type_body_length
public class Switch3: UIControl {

    private enum LayoutConfiguration {
        static var switchSize: CGSize {
            return CGSize(width: 80, height: 40)
        }

        // We subtract 4 because the bezel width is 1 and the gap is also 1 from both the top and the bottom
        static var thumbSize: CGSize {
            return CGSize(width: switchSize.height - 4, height: switchSize.height - 4)
        }

        /// Offset of the thumb to from the center
        static var thumbOffset: CGFloat {
            return switchSize.width / 2 - thumbSize.width / 2 - 2
        }

        /// Offset of the thumb to from the center
        static var baseRadius: CGFloat {
            return 12
        }

        static var thumbRadius: CGFloat {
            return 10
        }

        static var fourDotsSize: CGSize {
            return CGSize(width: 16, height: 16)
        }

        static var dotSize: CGSize {
            return CGSize(width: 6, height: 6)
        }

        static var arrowMargin: CGFloat {
            return 13
        }
    }

    // MARK: Colors

    /// color which fills the thumb
    public var thumbTintColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0) {
        didSet { updateThumbColor() }
    }

    /// Color of the base behind the thumb in the `On` state
    public var onTintColor = UIColor(red: 222.0/255.0, green: 232.0/255.0, blue: 242.0/255.0, alpha: 1.0) {
        didSet { base.child?.backgroundColor = onTintColor }
    }

    /// Color of the base behind the thumb in the `Off` state
    public var offTintColor = UIColor(red: 161.0/255.0, green: 184.0/255.0, blue: 207.0/255.0, alpha: 1.0) {
        didSet { thumbContainer.backgroundColor = offTintColor.withAlphaComponent(isOn ? 0.0 : 1.0) }
    }

    /// color of the four dots on the thumb
    public var dotColor = UIColor(red: 214.0/255.0, green: 224.0/255.0, blue: 234.0/255.0, alpha: 1.0) {
        didSet {
            fourDots.subviews.forEach {
                ($0 as? ContainerView<UIView>)?.child?.backgroundColor = dotColor
            }
        }
    }

    /// The companion property of `isOn`.  It is used to separate the
    private var _isOn: Bool = false {
        didSet {
            sendActions(for: .valueChanged)
        }
    }

    /// A Boolean value that determines the off/on state of the switch.
    @IBInspectable public var isOn: Bool {
        get { return _isOn }
        set {
            guard _isOn != newValue else { return }
            _isOn = newValue
            updateVisualState()
        }
    }

    override public var intrinsicContentSize: CGSize {
        let totalWidth = LayoutConfiguration.switchSize.width
        return CGSize(width: totalWidth, height: LayoutConfiguration.switchSize.height)
    }

    private let animationDuration = 0.2

    // MARK: Views and layers

    private lazy var thumb: ContainerView = {
        let thumb = ContainerView(child: UIView())

        thumb.layer.cornerRadius = LayoutConfiguration.thumbRadius
        thumb.elevation = .custom(elevation: 2)
        thumb.upperLeftOuterShadowColor = .clear
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.isUserInteractionEnabled = false
        thumb.child?.backgroundColor = thumbTintColor

        return thumb
    }()

    private lazy var fourDots: UIView = {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))

        let distance: CGFloat = 10.0

        container.addSubview(createDot(
            origin: CGPoint(
                x: 0,
                y: 0)
            )
        )
        container.addSubview(createDot(
            origin: CGPoint(
                x: 0,
                y: distance)
            )
        )
        container.addSubview(createDot(
            origin: CGPoint(
                x: distance,
                y: 0)
            )
        )
        container.addSubview(createDot(
            origin: CGPoint(
                x: distance,
                y: distance)
            )
        )

        container.translatesAutoresizingMaskIntoConstraints = false

        return container
    }()

    private lazy var arrow: UIImageView = {
        let bundle = Bundle(for: Self.self)
        let image = UIImage(named: "arrow", in: bundle, compatibleWith: nil)

        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var base: ContainerView = {
        let base = ContainerView(child: UIView())

        base.child?.backgroundColor = onTintColor
        base.elevation = .custom(elevation: -3)
        base.lowerRightInnerShadowColor = .clear
        base.layer.cornerRadius = LayoutConfiguration.baseRadius
        base.bezelWidth = 1
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false

        return base
    }()

    private lazy var thumbContainer: UIView = {
        let thumbContainer = UIView()

        thumbContainer.layer.cornerRadius = LayoutConfiguration.baseRadius - 1
        thumbContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbContainer.clipsToBounds = true
        thumbContainer.isUserInteractionEnabled = false
        thumbContainer.backgroundColor = offTintColor

        return thumbContainer
    }()

    private lazy var thumbShadow: CALayer = {
        let thumbShadow = CAShapeLayer()

        thumbShadow.path = getShadowPath()
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
    @objc private func toggleOnTouch() {
        triggerHapticEngine()
        setOn(!isOn, animated: true)
    }

    // MARK: View setup

    private func setUpView() {
        addSubviews()
        addTarget(self, action: #selector(toggleOnTouch), for: .touchUpInside)
        // add UIPanGestureRecognizer to recognise swipes
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(trackPan(_:))))
        setAutoLayout()
    }

    private func addSubviews() {
        addSubview(base)
        addSubview(thumbContainer)
        thumbContainer.addSubview(thumb)
        thumb.child?.addSubview(fourDots)
        thumb.child?.layer.addSublayer(thumbShadow)
        base.child?.addSubview(arrow)
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
            arrow.centerYAnchor.constraint(equalTo: base.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: thumb.leadingAnchor, constant: -LayoutConfiguration.arrowMargin)
        ])
        NSLayoutConstraint.activate([
            fourDots.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
            fourDots.centerXAnchor.constraint(equalTo: thumb.centerXAnchor),
            fourDots.widthAnchor.constraint(equalToConstant: LayoutConfiguration.fourDotsSize.width),
            fourDots.heightAnchor.constraint(equalToConstant: LayoutConfiguration.fourDotsSize.height)
        ])
        thumbPositionConstraint.isActive = true

        setContentHuggingPriority(.required - 1, for: .horizontal)
        setContentHuggingPriority(.required - 1, for: .vertical)
        setContentCompressionResistancePriority(.required - 1, for: .horizontal)
        setContentCompressionResistancePriority(.required - 1, for: .vertical)
    }

    private func updateVisualState() {
        thumbPositionConstraint.constant = isOn ? LayoutConfiguration.thumbOffset : -LayoutConfiguration.thumbOffset
        thumbContainer.backgroundColor = isOn ?
            thumbContainer.backgroundColor?.withAlphaComponent(0.0)
            :
            thumbContainer.backgroundColor?.withAlphaComponent(1.0)
    }

    // MARK: Auxiliary

    private func updateThumbColor() {
        thumb.child?.backgroundColor = thumbTintColor
    }

    private func createDot(origin: CGPoint) -> UIView {
        let dot = ContainerView(
            child: UIView(
                frame: CGRect(
                origin: origin,
                size: LayoutConfiguration.dotSize
                )
            )
        )

        dot.backgroundColor = dotColor
        dot.bezelWidth = 1.0
        dot.elevation = .custom(elevation: 1)
        dot.layer.cornerRadius = LayoutConfiguration.dotSize.width / 2
        dot.lowerRightBezelColor = UIColor(red: 178.0/255.0, green: 195.0/255.0, blue: 214.0/255.0, alpha: 1.0)
        return dot
    }

    private func getShadowPath() -> CGPath {
        let radius = LayoutConfiguration.thumbRadius

        let path = UIBezierPath()

        path.addArc(
            withCenter: CGPoint(x: radius, y: LayoutConfiguration.thumbSize.height - radius + 2),
            radius: radius+1,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: false
        )
        path.addLine(
            to: CGPoint(x: LayoutConfiguration.thumbSize.width - radius,
                        y: LayoutConfiguration.thumbSize.height + 3)
        )
        path.addArc(
            withCenter: CGPoint(
                x: LayoutConfiguration.thumbSize.width - radius,
                y: LayoutConfiguration.thumbSize.height - radius + 2),
            radius: radius+1,
            startAngle: .pi / 2,
            endAngle: 0,
            clockwise: false
        )

        return path.cgPath
    }

    // swiftlint:disable:next cyclomatic_complexity
    @objc private func trackPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}

        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview)

        switch gestureRecognizer.state {
        case .changed, .possible, .began:
            // in case of a movement, make the thumb move and change switch's state accordingly

            // calculate how far from the left edge the thumb is (relatively to the most right position)
            // 1 - (current position) / (total length)
            let movementRatio = 1 - (translation.x + LayoutConfiguration.thumbOffset)
                / (2 * LayoutConfiguration.thumbOffset)

            // adjust the base color accrding to thumb's relative position
            thumbContainer.backgroundColor = thumbContainer.backgroundColor?.withAlphaComponent(movementRatio)

            // handle the edge cases, when the thumbs reaches the edges
            if translation.x >= LayoutConfiguration.thumbOffset {
                // if it moved to the right edge, update the state
                // if it was there before, the state has been changed before, don't update
                if thumbPositionConstraint.constant != LayoutConfiguration.thumbOffset {
                    triggerHapticEngine()
                    thumbPositionConstraint.constant = LayoutConfiguration.thumbOffset
                }
            } else if translation.x <= -LayoutConfiguration.thumbOffset {
                // if it moved to the left edge, update the state
                // if it was there before, the state has been changed before, don't update
                if thumbPositionConstraint.constant != -LayoutConfiguration.thumbOffset {
                    triggerHapticEngine()
                    thumbPositionConstraint.constant = -LayoutConfiguration.thumbOffset
                }
            } else {
                // in nothing interesting happened, just move the thumb
                thumbPositionConstraint.constant = translation.x
            }
        case .ended:
            if thumbPositionConstraint.constant != -LayoutConfiguration.thumbOffset
                && thumbPositionConstraint.constant != LayoutConfiguration.thumbOffset {
                triggerHapticEngine()
            }
            // when a pan has ended, complete the movement in case the switch isn't at an edge
            if thumbPositionConstraint.constant > 0 {
                setOn(true, animated: true)
            } else {
                setOn(false, animated: true)
            }
        case .cancelled, .failed:
            // On cancellation, just set to false.
            setOn(false, animated: true)
        @unknown default:
            setOn(false, animated: true)
        }
    }

    private func triggerHapticEngine() {
        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        // prepare the taptic engine to trigger
        lightImpactFeedbackGenerator.prepare()
        // trigger the haptic feedback
        lightImpactFeedbackGenerator.impactOccurred()
    }
}
