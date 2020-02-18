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

        var elevationValue: CGFloat {
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

    public let darkSideColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    let brightSideColor = UIColor.white
    lazy private var outerBrightSide = getOuterSide(color: brightSideColor)
    lazy private var outerDarkSide = getOuterSide(color: darkSideColor)
    lazy private var innerBrightSide = getInnerSide(color: brightSideColor)
    lazy private var innerDarkSide = getInnerSide(color: darkSideColor.withAlphaComponent(1.0))
    
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
    
    public var isConvex: Bool {
        get {
            return elevation > 0
        }
    }
    
    /**
     Indicates to what extend the view will look above the surface or carved into the surface
     
     - parameter elevation: positive value for the efffect of levitation and negative value for the effect of being carved
     - warning: for good visibility stick to values from -50 to 50
     */
    public var elevation: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var cornerRadius: Float {
        get {
            return Float(child?.layer.cornerRadius ?? surface.cornerRadius)
        }
        set(value) {
            surface.cornerRadius = CGFloat(value)
            layer.cornerRadius = CGFloat(value)
            child?.layer.cornerRadius = CGFloat(value)
            setNeedsLayout()
        }
    }

    public override var backgroundColor: UIColor? {
        didSet {
            surface.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    lazy private var surface: CALayer = {
        let surface = CALayer()
        surface.backgroundColor = backgroundColor?.cgColor
        return surface
    }()
    
    private func updateDarkSide() {
        if isConvex {
            outerDarkSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            outerDarkSide.shadowOffset = CGSize(width:  elevation / 2, height: elevation / 4)
            outerDarkSide.shadowRadius = elevation
        } else {
            innerDarkSide.path = makeInnerUpperShadowShapePath(rect: bounds, radius: CGFloat(cornerRadius))
            innerDarkSide.shadowOffset = CGSize(width: -elevation / 2, height: -elevation / 4)
            innerDarkSide.shadowRadius = -elevation
        }
    }
    
    private func updateBrightSide() {
        if isConvex {
            outerBrightSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            outerBrightSide.shadowOffset = CGSize(width: -elevation / 2, height: -elevation / 4)
            outerBrightSide.shadowRadius = CGFloat(elevation)
        } else {
            innerBrightSide.path = makeInnerLowerShadowShapePath(rect: bounds, radius: CGFloat(cornerRadius))
            innerBrightSide.shadowOffset = CGSize(width:  elevation / 2, height:  elevation / 4)
            innerBrightSide.shadowRadius = -elevation
        }
    }
    
    private func updateSurface() {
        surface.frame = bounds
        surface.cornerRadius = CGFloat(cornerRadius)
    }
    
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
    
    private func updateView() {
        updateDarkSide()
        updateBrightSide()
        updateSurface()
        if innerBrightSide.isHidden == true && innerDarkSide.isHidden == true {
            layer.mask = nil
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            layer.mask = maskLayer
        }
        if isConvex {
            outerDarkSide.isHidden = false
            outerBrightSide.isHidden = false
            innerBrightSide.isHidden = true
            innerDarkSide.isHidden = true
        } else {
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
