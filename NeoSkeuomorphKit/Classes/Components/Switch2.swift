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
public class Switch2: UIControl {

    private enum LayoutConfiguration {
        static var switchSize: CGSize {
            return CGSize(width: 144, height: 72)
        }

        static var switchCornerRadius: CGFloat {
            return 12
        }

        static var thumbContainerSize: CGSize {
            return CGSize(width: 78, height: 60)
        }

        static var thumbContainerCornerRadius: CGFloat {
            return 8
        }

        static var thumbContainerToBaseMargin: CGFloat {
            return 7
        }

        // We subtract 4 because the bezel width is 1 and the gap is also 1 from both the top and the bottom
        static var thumbSize: CGSize {
            return CGSize(width: 64, height: 50)
        }
    }

    // MARK: Colors

    /// Color of the base behind the thumb
    public var baseColor = UIColor(red: 227.0/255.0, green: 236.0/255.0, blue: 246.0/255.0, alpha: 1.0) {
        didSet { base.child?.backgroundColor = baseColor }
    }

    /// Color of the container in which the thumb is placed
    public var thumbContainerColor = UIColor(red: 214.0/255.0, green: 224.0/255.0, blue: 235.0/255.0, alpha: 1.0) {
        didSet { thumbContainer.child?.backgroundColor = thumbContainerColor }
    }

    public var labelColor = UIColor(red: 49.0/255.0, green: 69.0/255.0, blue: 106.0/255.0, alpha: 1.0) {
        didSet { label.textColor = labelColor }
    }

    // MARK: State variables

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

    // MARK: Intrinsic Content Size

    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: LayoutConfiguration.switchSize.width,
            height: LayoutConfiguration.switchSize.height
        )
    }

    // MARK: Views and layers

    private let buttonOnImageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 1, right: 0)
    private let buttonOffImageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 1, right: 0)

    private lazy var thumbButtonOnImage = UIImage(
        named: "switchRedButtonOn",
        in: Bundle(for: Self.self),
        compatibleWith: nil
    )

    private lazy var thumbButtonOffImage = UIImage(
        named: "switchRedButtonOff",
        in: Bundle(for: Self.self),
        compatibleWith: nil
    )

    private lazy var thumb: UIImageView = {

        let view = UIImageView(image: thumbButtonOffImage)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false

        return view
    }()

    private lazy var base: ContainerView = {
        let base = ContainerView(child: UIView())

        base.child?.backgroundColor = baseColor
        base.elevation = .custom(elevation: 7)
        base.layer.cornerRadius = LayoutConfiguration.switchCornerRadius
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.child?.isUserInteractionEnabled = false

        return base
    }()

    private lazy var thumbContainer: ContainerView = {
        let thumbContainer = ContainerView(child: UIView())

        thumbContainer.layer.cornerRadius = LayoutConfiguration.thumbContainerCornerRadius
        thumbContainer.child?.backgroundColor = thumbContainerColor
        thumbContainer.elevation = .concaveSlight
        thumbContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbContainer.clipsToBounds = true
        thumbContainer.isUserInteractionEnabled = false
        thumbContainer.child?.isUserInteractionEnabled = false

        return thumbContainer
    }()

    private let onText = "ON"
    private let offText = "OFF"

    private lazy var label: UILabel = {
        let label = UILabel()

        label.font = UIFont(name: "Gilroy", size: UIFont.systemFontSize)!
        label.text = offText
        label.textColor = labelColor
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
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

    // MARK: Public methods

    private let animationDuration = 0.2

    /// Set the state of the switch to On or Off, optionally animating the transition.
    /// - Parameters:
    ///   - isOn: true if the switch should be turned to the On position;
    ///   false if it should be turned to the Off position.
    ///   If the switch is already in the designated position, nothing happens.
    ///   - animated: true to animate the “flipping” of the switch; otherwise false.
    public func setOn(_ isOn: Bool, animated: Bool) {
        layoutIfNeeded()
        _isOn = isOn

        UIView.transition(
            with: thumb,
            duration: animated ? animationDuration : 0,
            options: .transitionCrossDissolve,
            animations: { self.updateThumb() },
            completion: { success in if success { self.updateLabel() } }
        )
    }

    // MARK: Private methods

    /// Change the state to the opposite
    @objc private func toggleOnTouch() {
        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

        // prepare the taptic engine to trigger
        lightImpactFeedbackGenerator.prepare()

        setOn(!isOn, animated: true)

        // trigger the haptic feedback
        lightImpactFeedbackGenerator.impactOccurred()
    }

    private func setUpView() {
        UIFont.loadFonts(for: Bundle(for: Self.self))
        addSubviews()
        layer.cornerRadius = LayoutConfiguration.switchCornerRadius
        addTarget(self, action: #selector(toggleOnTouch), for: .touchUpInside)
        setAutoLayout()
    }

    private func addSubviews() {
        addSubview(base)
        base.child?.addSubview(thumbContainer)
        base.child?.addSubview(label)
        thumbContainer.addSubview(thumb)
    }

    private func setAutoLayout() {
        let switchSize = LayoutConfiguration.switchSize

//        NSLayoutConstraint.activate([
//            widthAnchor.constraint(equalToConstant: switchSize.width),
//            heightAnchor.constraint(equalToConstant: switchSize.height),
//            centerYAnchor.constraint(equalTo: centerYAnchor),
//            centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])
        NSLayoutConstraint.activate([
            base.widthAnchor.constraint(equalToConstant: switchSize.width),
            base.heightAnchor.constraint(equalToConstant: switchSize.height),
            base.centerYAnchor.constraint(equalTo: centerYAnchor),
            base.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            thumbContainer.widthAnchor.constraint(equalToConstant: LayoutConfiguration.thumbContainerSize.width),
            thumbContainer.heightAnchor.constraint(equalToConstant: LayoutConfiguration.thumbContainerSize.height),
            thumbContainer.centerYAnchor.constraint(equalTo: base.centerYAnchor),
            thumbContainer.trailingAnchor.constraint(
                equalTo: base.trailingAnchor,
                constant: -LayoutConfiguration.thumbContainerToBaseMargin
            )
        ])
        NSLayoutConstraint.activate([
            thumb.widthAnchor.constraint(equalToConstant: LayoutConfiguration.thumbSize.width),
            thumb.heightAnchor.constraint(equalToConstant: LayoutConfiguration.thumbSize.height),
            thumb.centerYAnchor.constraint(equalTo: thumbContainer.centerYAnchor),
            thumb.centerXAnchor.constraint(equalTo: thumbContainer.centerXAnchor)
        ])

        let leftGuide = UILayoutGuide()
        let rightGuide = UILayoutGuide()
        base.child?.addLayoutGuide(leftGuide)
        base.child?.addLayoutGuide(rightGuide)
        NSLayoutConstraint.activate([
            leftGuide.leadingAnchor.constraint(equalTo: base.leadingAnchor),
            leftGuide.trailingAnchor.constraint(equalTo: label.leadingAnchor),
            rightGuide.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            rightGuide.trailingAnchor.constraint(equalTo: thumbContainer.leadingAnchor),
            rightGuide.widthAnchor.constraint(equalTo: leftGuide.widthAnchor),
            label.centerYAnchor.constraint(equalTo: base.centerYAnchor),
        ])

        setContentHuggingPriority(.required - 1, for: .horizontal)
        setContentHuggingPriority(.required - 1, for: .vertical)
        setContentCompressionResistancePriority(.required - 1, for: .horizontal)
        setContentCompressionResistancePriority(.required - 1, for: .vertical)
    }

    private func updateVisualState() {
        updateLabel()
        updateThumb()
    }

    private func updateLabel() {
        label.text = isOn ? onText : offText
    }

    private func updateThumb() {
        thumb.image = isOn ? thumbButtonOnImage : thumbButtonOffImage
    }
}
