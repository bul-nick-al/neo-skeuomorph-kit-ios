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
public class ContainerView: UIView {

    public enum Elevation {
        case convexHigh
        case convexMedium
        case convexLow
        case convexSlightly
        case flat
        case concaveSlightly
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
            case .convexSlightly:
                return 5
            case .flat:
                return 0
            case .concaveSlightly:
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
    public let darkSideColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    let brightSideColor = UIColor.white

// MARK: Layers
    lazy private var outerBrightSide = getOuterSide(color: brightSideColor)
    lazy private var outerDarkSide = getOuterSide(color: darkSideColor)
    lazy private var innerBrightSide = getInnerSide(color: brightSideColor)
    lazy private var innerDarkSide = getInnerSide(color: darkSideColor.withAlphaComponent(1.0))

    lazy private var surface: CALayer = {
        let surface = CALayer()
        surface.backgroundColor = backgroundColor?.cgColor
        return surface
    }()

    weak public var child: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let child = child {
                layer.addSublayer(outerBrightSide)
                layer.addSublayer(outerDarkSide)
                layer.addSublayer(surface)
                addSubview(child)
                layer.addSublayer(innerDarkSide)
                layer.addSublayer(innerBrightSide)
                // make the child be the same size as its parent
                child.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    child.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    child.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    child.topAnchor.constraint(equalTo: self.topAnchor),
                    child.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    child.widthAnchor.constraint(equalTo: widthAnchor)
                ])
            }
            setNeedsLayout()
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

    public override var backgroundColor: UIColor? {
        didSet {
            surface.backgroundColor = backgroundColor?.cgColor
        }
    }

// MARK: Auxiliary
    /**
     Get a layer to be used as the outer side of a container view
     
     - parameter color: the color of the shadow this layer will have.
     */
    private func getOuterSide(color: UIColor) -> CALayer {
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
    private func getInnerSide(color: UIColor) -> CAShapeLayer {
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
        path.addArc(center: CGPoint(x: radius, y: height - radius), radius: radius, startAngle: 3/4 * .pi,
                    endAngle: .pi, clockwise: false)
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi,
                    endAngle: 3/2 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: 3/2 * .pi,
                    endAngle: 7/4 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: width - radius, y: radius), radius: radius + 10, startAngle: 7/4 * .pi,
                    endAngle: 3/2 * .pi, clockwise: true)
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius + 10, startAngle: 3/2 * .pi,
                    endAngle: .pi, clockwise: true)
        path.addArc(center: CGPoint(x: radius, y: height - radius), radius: radius + 10, startAngle: .pi,
                    endAngle: 3/4 * .pi, clockwise: true)
        return path
    }

    private func makeCorneredRect(rect: CGRect, withCornerRadius radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let height = rect.height
        let width = rect.width
        path.addArc(center: CGPoint(x: radius, y: height - radius), radius: radius, startAngle: 1/2 * .pi,
                    endAngle: .pi, clockwise: false)
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi,
                    endAngle: 3/2 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: 3/2 * .pi,
                    endAngle: 2 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: width - radius, y: height - radius), radius: radius, startAngle: 2 * .pi,
                    endAngle: 2.5 * .pi, clockwise: false)
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

// MARK: CALayerDeledate
    public override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        // if layer's corner radius changes, update the layout
        if event == "cornerRadius" {
            setNeedsLayout()
        }
        return super.action(for: layer, forKey: event)
    }

// MARK: Updating functions
    private func updateDarkSide() {
        if isConvex {
            outerDarkSide.shadowPath = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            outerDarkSide.shadowOffset = CGSize(width: elevation.elevationValue / 2,
                                                height: elevation.elevationValue / 4)
            outerDarkSide.shadowRadius = elevation.elevationValue
        } else {
            innerDarkSide.path = makeInnerUpperShadowShapePath(rect: bounds, radius: layer.cornerRadius)
            innerDarkSide.shadowOffset = CGSize(width: -elevation.elevationValue / 2,
                                                height: -elevation.elevationValue / 4)
            innerDarkSide.shadowRadius = -elevation.elevationValue
        }
    }

    private func updateBrightSide() {
        if isConvex {
            outerBrightSide.shadowPath = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            outerBrightSide.shadowOffset = CGSize(width: -elevation.elevationValue / 2,
                                                  height: -elevation.elevationValue / 4)
            outerBrightSide.shadowRadius = CGFloat(elevation.elevationValue)
        } else {
            innerBrightSide.path = makeInnerLowerShadowShapePath(rect: bounds, radius: layer.cornerRadius)
            innerBrightSide.shadowOffset = CGSize(width: elevation.elevationValue / 2,
                                                  height: elevation.elevationValue / 4)
            innerBrightSide.shadowRadius = -elevation.elevationValue
        }
    }

    private func updateSurface() {
        surface.frame = bounds
        surface.cornerRadius = layer.cornerRadius
    }

    private func updateView() {
        updateDarkSide()
        updateBrightSide()
        updateSurface()
        child?.layer.cornerRadius = layer.cornerRadius
        if isConvex {
            outerDarkSide.isHidden = false
            outerBrightSide.isHidden = false
            innerBrightSide.isHidden = true
            innerDarkSide.isHidden = true
            // to make sure that once the mask is removed
            // users won't see the layers disappearing with animation
            innerDarkSide.removeAllAnimations()
            innerBrightSide.removeAllAnimations()
            layer.mask = nil
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = makeCorneredRect(rect: bounds, withCornerRadius: layer.cornerRadius)
            layer.mask = maskLayer
            outerDarkSide.isHidden = true
            outerBrightSide.isHidden = true
            innerBrightSide.isHidden = false
            innerDarkSide.isHidden = false
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
}
