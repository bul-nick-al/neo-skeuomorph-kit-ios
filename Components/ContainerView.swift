import UIKit

public class ContainerView: UIView {
    let darkSideColor: UIColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    let brightSideColor: UIColor = .white
    lazy private var outerBrightSide: CALayer = .getOuterSide(color: brightSideColor)
    lazy private var outerDarkSide: CALayer = .getOuterSide(color: darkSideColor)
    lazy private var innerBrightSide: CAShapeLayer = .getInnerSide(color: brightSideColor)
    lazy private var innerDarkSide: CAShapeLayer = .getInnerSide(color: darkSideColor.withAlphaComponent(1.0))
    var isConvex: Bool {
        get {
            return elevation > 0
        }
    }
    public var elevation: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public var cornerRadius: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public override var backgroundColor: UIColor? {
        didSet {
            surface.backgroundColor = backgroundColor?.cgColor
        }
    }
    var surface: CALayer = {
        let surface = CALayer()
        surface.backgroundColor =  UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0).cgColor
        return surface
    }()
    private var darkSide: CALayer {
        get {
            if isConvex {
                outerDarkSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: cornerRadius.cgFloat).cgPath
                outerDarkSide.shadowOffset = CGSize(width: elevation.cgFloat / 2, height: elevation.cgFloat / 4)
                outerDarkSide.shadowRadius = elevation.cgFloat
                return outerDarkSide
            } else {
                innerDarkSide.path = CGPath.makeInnerUpperShadowShapePath(rect: bounds, radius: cornerRadius.cgFloat)
                innerDarkSide.shadowOffset = CGSize(width: -elevation.cgFloat / 2, height: -elevation.cgFloat / 4)
                innerDarkSide.shadowRadius = -elevation.cgFloat
                return innerDarkSide
            }
        }
    }
    private var brightSide: CALayer {
        get {
            if isConvex {
                outerBrightSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: cornerRadius.cgFloat).cgPath
                outerBrightSide.shadowOffset = CGSize(width: -elevation.cgFloat / 2, height: -elevation.cgFloat / 4)
                outerBrightSide.shadowRadius = elevation.cgFloat
                return outerBrightSide
            } else {
                innerBrightSide.path = CGPath.makeInnerLowerShadowShapePath(rect: bounds, radius: cornerRadius.cgFloat)
                innerBrightSide.shadowOffset = CGSize(width: elevation.cgFloat / 2, height: elevation.cgFloat / 4)
                innerBrightSide.shadowRadius = -elevation.cgFloat
                return innerBrightSide
            }
        }
    }
    private func updateView() {
        surface.frame = bounds
        surface.cornerRadius = CGFloat(cornerRadius)
        layer.sublayers = []
        if isConvex {
            layer.mask = nil
            layer.addSublayer(darkSide)
            layer.addSublayer(brightSide)
            layer.addSublayer(surface)
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            layer.mask = maskLayer
            layer.addSublayer(surface)
            layer.addSublayer(darkSide)
            layer.addSublayer(brightSide)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
}

extension CALayer {
    /**
     Get a layer to be used as the outer side of a container view
     
     - parameter color: the color of the shadow this layer will have.
     */
    static func getOuterSide(color: UIColor) -> CALayer {
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
    static func getInnerSide(color: UIColor) -> CAShapeLayer {
        let innerSide = CAShapeLayer()
        innerSide.fillRule = .evenOdd
        innerSide.fillColor = color.cgColor
        innerSide.shadowColor = color.cgColor
        innerSide.shadowOpacity = 1.0
        innerSide.masksToBounds = false
        return innerSide
    }
}

extension CGPath {
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
    static func makeInnerShadowShapePathFor(rect: CGRect, withCornerRadius radius: CGFloat) -> CGPath {
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
    static func makeInnerUpperShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = CGPath.makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: -1, y: -1)
        return path.copy(using: &transform)!
    }
    static func makeInnerLowerShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = CGPath.makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: rect.maxX + 1, y: rect.maxY + 1)
        transform = transform.rotated(by: .pi)
        return path.copy(using: &transform)!
    }
}
extension Float {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
