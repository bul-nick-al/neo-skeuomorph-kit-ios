import UIKit

/**
 # Example of usage
 ```
 let childView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 280))
 childView.backgroundColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0)
 childView.layer.cornerRadius = 40
 
 let myCont = ContainerView( )
 myCont.child = childView
 myCont.elevation = 5
 
 view.addSubview(myCont)
 ```
 */
@IBDesignable
// swiftlint:disable:next type_body_length
public class ContainerView<ChildView>: UIView where ChildView: UIView {

    /**
     Represents the elevation of a container view.
     Cases that start with "convex" will create a levetating effect above the surface
     Cases starting concave will make a view look bending inwards the surface
     */
    public enum Elevation {
        case convexHigh
        case convexMedium
        case convexLow
        case convexSlight
        case flat
        case concaveSlight
        case concaveLow
        case concaveMedium
        case concaveHigh
        case custom(elevation: CGFloat)

        public var elevationValue: CGFloat {
            switch self {
            case .convexHigh:
                return 50
            case .convexMedium:
                return 30
            case .convexLow:
                return 15
            case .convexSlight:
                return 5
            case .flat:
                return 0
            case .concaveSlight:
                return -5
            case .concaveLow:
                return -15
            case .concaveMedium:
                return -30
            case .concaveHigh:
                return -50
            case .custom(let elevation):
                return elevation
            }
        }
    }

    // MARK: Colors
    public var lowerRightOuterShadowColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48) {
        didSet {
            outerLowerRightShadow.shadowColor = lowerRightOuterShadowColor.cgColor
        }
    }

    public var upperLeftOuterShadowColor = UIColor.white {
        didSet {
            outerUpperLeftShadow.shadowColor = upperLeftOuterShadowColor.cgColor
        }
    }

    public var lowerRightInnerShadowColor = UIColor.white {
        didSet {
            innerLowerRightShadow.shadowColor = lowerRightInnerShadowColor.cgColor
        }
    }

    public var upperLeftInnerShadowColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48) {
        didSet {
            innerUpperLeftShadow.shadowColor = upperLeftInnerShadowColor.cgColor
        }
    }

    public var lowerRightBezelColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48) {
        didSet {
            (bezelLine as? CAGradientLayer)?.colors =
                [upperLeftBezelColor.cgColor, lowerRightBezelColor.withAlphaComponent(1.0).cgColor]
        }
    }

    public var upperLeftBezelColor = UIColor.white {
        didSet {
            (bezelLine as? CAGradientLayer)?.colors =
                [upperLeftBezelColor.cgColor, lowerRightBezelColor.withAlphaComponent(1.0).cgColor]
        }
    }

    // MARK: Properties
    public var isConvex: Bool {
        get {
            return elevation.elevationValue > 0
        }
    }

    /**
     Indicates to what extend the view will look above the surface or carved into the surface

     - parameter elevation: positive value for the efffect of levitation and negative value
     for the effect of being carved
     - warning: for good visibility stick to values from -50 to 50
     */
    public var elevation: Elevation = .flat {
        didSet {
            setNeedsLayout()
        }
    }

    // Width of the line that goes around a container view. Use only non negative values.
    public var bezelWidth: Float = 0 {
        didSet {
            bezelWidth = abs(bezelWidth)
            setNeedsLayout()
        }
    }

    public override var backgroundColor: UIColor? {
        didSet {
            surface.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var child: ChildView? {
        didSet {
            oldValue?.removeFromSuperview()

            guard let child = child else { return }

            layer.addSublayer(outerUpperLeftShadow)
            layer.masksToBounds = false
            layer.addSublayer(outerLowerRightShadow)
            layer.addSublayer(surface)

            addSubview(child)

            layer.addSublayer(innerUpperLeftShadow)
            layer.addSublayer(innerLowerRightShadow)
            layer.addSublayer(bezelLine)

            // make the child be the same size as its parent
            child.translatesAutoresizingMaskIntoConstraints = false

            // make the child stick to the edges of the container
            setChildConstraints()
        }
    }

    // MARK: Layers
    lazy private var outerUpperLeftShadow = getOuterShadow(color: upperLeftOuterShadowColor)
    lazy private var outerLowerRightShadow = getOuterShadow(color: lowerRightOuterShadowColor)
    lazy private var innerUpperLeftShadow = getInnerShadow(color: upperLeftInnerShadowColor.withAlphaComponent(1.0))
    lazy private var innerLowerRightShadow = getInnerShadow(color: lowerRightInnerShadowColor)

    lazy private var surface: CALayer = {
        let surface = CALayer()
        surface.backgroundColor = backgroundColor?.cgColor
        return surface
    }()

    lazy private var bezelLine: CALayer = {
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.lineCap = .round
        let layer = CAGradientLayer()
        layer.masksToBounds = false
        layer.colors = [upperLeftBezelColor.cgColor, lowerRightBezelColor.withAlphaComponent(1.0).cgColor]
        layer.locations = [0.4, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.mask = mask
        return layer
    }()

    // MARK: Initializers
    public convenience init(child: ChildView) {
        defer { self.child = child }
        self.init(frame: child.frame)
    }

    // MARK: Lifecycle methods
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }

    // MARK: CALayerDeledate
    //We use this to be notified whenever the corner radius of layer changes
    public override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        // if layer's corner radius changes, update the layout
        if event == "cornerRadius" {
            setNeedsLayout()
        }
        return super.action(for: layer, forKey: event)
    }

    // MARK: Constraints

    private func setChildConstraints() {
        guard let child = child else { return }
        NSLayoutConstraint.activate([
            child.trailingAnchor.constraint(equalTo: trailingAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.topAnchor.constraint(equalTo: topAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor),
            child.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }

    // MARK: Auxiliary
    /**
     Get a layer to be used as the outer side of a container view
     
     - parameter color: the color of the shadow this layer will have.
     */
    private func getOuterShadow(color: UIColor) -> CALayer {
        let outerSide = CALayer()
        outerSide.shadowColor = color.cgColor
        outerSide.shadowOpacity = 1.0
        outerSide.masksToBounds = false
        return outerSide
    }

    /**
    Get a layer to be used as the inner side of a container view
    
    - parameter color: the color of the shadow this layer will have.
    */
    private func getInnerShadow(color: UIColor) -> CAShapeLayer {
        let innerSide = CAShapeLayer()
        innerSide.fillRule = .evenOdd
        innerSide.fillColor = color.cgColor
        innerSide.shadowColor = color.cgColor
        innerSide.shadowOpacity = 1.0
        innerSide.masksToBounds = false
        return innerSide
    }

    /**
     This method creates a thick path in the shape of two adjacent sides of a round rectangle
     - parameter rect: the rectangle.
     - parameter radius: the radius of the rounded corners.
     - returns: the path.
     
     # Shape #
     ```
        _______
      //       \\
     //
     ||
     ||
     ||
     \\
     ```
    */
    private func makeInnerShadowShapePathFor(rect: CGRect, withCornerRadius radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let height = rect.height + 1
        let width = rect.width + 1
        path.addArc(
            center: CGPoint(x: radius, y: height - radius),
            radius: radius,
            startAngle: 3/4 * .pi,
            endAngle: .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .pi,
            endAngle: 3/2 * .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width - radius, y: radius),
            radius: radius,
            startAngle: 3/2 * .pi,
            endAngle: 7/4 * .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width - radius, y: radius),
            radius: radius + 10,
            startAngle: 7/4 * .pi,
            endAngle: 3/2 * .pi,
            clockwise: true
        )
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius + 10,
            startAngle: 3/2 * .pi,
            endAngle: .pi,
            clockwise: true
        )
        path.addArc(
            center: CGPoint(x: radius, y: height - radius),
            radius: radius + 10,
            startAngle: .pi,
            endAngle: 3/4 * .pi,
            clockwise: true
        )
        return path
    }

    private func makeCorneredRect(rect: CGRect, withCornerRadius radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let height = rect.height
        let width = rect.width
        path.addArc(
            center: CGPoint(x: radius, y: height - radius),
            radius: radius,
            startAngle: 1/2 * .pi,
            endAngle: .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .pi,
            endAngle: 3/2 * .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width - radius, y: radius),
            radius: radius,
            startAngle: 3/2 * .pi,
            endAngle: 2 * .pi,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width - radius, y: height - radius),
            radius: radius,
            startAngle: 2 * .pi,
            endAngle: 2.5 * .pi,
            clockwise: false)
        path.addLine(to: CGPoint(x: radius, y: height))
        return path
    }

    /**
    Make a path of a think ractangular with rounded corners. Thickness grows inside

    - Parameters:
        - rect: rectangular bounds
        - radius: corner radius
        - lineWidth: how think the rect should be
    */
    private func makeThickCorneredRect(rect: CGRect, withCornerRadius radius: CGFloat, lineWidth: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let innnerRadius = radius < lineWidth ? 0 : radius - lineWidth
        path.addPath(makeCorneredRect(rect: rect, withCornerRadius: radius))
        var transform  = CGAffineTransform(translationX: lineWidth, y: lineWidth)
        path.addPath(makeCorneredRect(
            rect: rect.insetBy(dx: lineWidth, dy: lineWidth),
            withCornerRadius: innnerRadius).copy(using: &transform)!
        )
        return path
    }

    private func makeInnerUpperShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: -1, y: -1)
        return path.copy(using: &transform)!
    }

    private func makeInnerLowerShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: rect.maxX + 1, y: rect.maxY + 1)
        transform = transform.rotated(by: .pi)
        return path.copy(using: &transform)!
    }

    // MARK: Updating functions
    private func bezelStrokeLine() {
        let path = makeThickCorneredRect(
            rect: bounds,
            withCornerRadius: layer.cornerRadius,
            lineWidth: CGFloat(bezelWidth)
        )
        bezelLine.frame = bounds
        (bezelLine.mask as? CAShapeLayer)?.path = path
    }

    /**
    This method sets the dark shadow of the container depending on whether
    the container is convex or not and also depending on bounds and elevation
    */
    private func updateDarkShadow() {
        if isConvex {
            outerLowerRightShadow.frame = bounds
            outerLowerRightShadow.shadowPath = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            outerLowerRightShadow.shadowOffset = CGSize(
                width: elevation.elevationValue / 2,
                height: elevation.elevationValue / 4
            )
            outerLowerRightShadow.shadowRadius = elevation.elevationValue
        } else {
            innerUpperLeftShadow.frame = bounds
            innerUpperLeftShadow.path = makeInnerUpperShadowShapePath(rect: bounds, radius: layer.cornerRadius)
            innerUpperLeftShadow.shadowOffset = CGSize(
                width: -elevation.elevationValue / 2,
                height: -elevation.elevationValue / 4
            )
            innerUpperLeftShadow.shadowRadius = -elevation.elevationValue
        }
    }

    /**
     This method sets the bright shadow of the container depending on whether
     the container is convex or not and also depending on bounds and elevation
     */
    private func updateBrightShadow() {
        if isConvex {
            outerUpperLeftShadow.frame = bounds
            outerUpperLeftShadow.shadowPath = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            outerUpperLeftShadow.shadowOffset = CGSize(
                width: -elevation.elevationValue / 2,
                height: -elevation.elevationValue / 4
            )
            outerUpperLeftShadow.shadowRadius = CGFloat(elevation.elevationValue)
        } else {
            innerLowerRightShadow.frame = bounds
            innerLowerRightShadow.path = makeInnerLowerShadowShapePath(rect: bounds, radius: layer.cornerRadius)
            innerLowerRightShadow.shadowOffset = CGSize(
                width: elevation.elevationValue / 2,
                height: elevation.elevationValue / 4
            )
            innerLowerRightShadow.shadowRadius = -elevation.elevationValue
        }
    }

    private func updateSurface() {
        surface.frame = bounds
        surface.cornerRadius = layer.cornerRadius
    }

    private func updateView() {
        updateDarkShadow()
        updateBrightShadow()
        updateSurface()
        bezelStrokeLine()
        child?.layer.cornerRadius = layer.cornerRadius
        if isConvex {
            outerLowerRightShadow.isHidden = false
            outerUpperLeftShadow.isHidden = false
            innerLowerRightShadow.isHidden = true
            innerUpperLeftShadow.isHidden = true
            // to make sure that once the mask is removed
            // users won't see the layers disappearing with animation
            innerUpperLeftShadow.removeAllAnimations()
            innerLowerRightShadow.removeAllAnimations()
            layer.mask = nil
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            layer.mask = maskLayer
            outerLowerRightShadow.isHidden = true
            outerUpperLeftShadow.isHidden = true
            innerLowerRightShadow.isHidden = false
            innerUpperLeftShadow.isHidden = false
        }
    }
}
