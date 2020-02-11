import UIKit

public class ContainerView: UIView {
    private let darkSideColor: UIColor = UIColor(red: 0.53, green: 0.65, blue: 0.75, alpha: 0.48)
    let brightSideColor: UIColor = .white
    lazy var outerBrightSide: CALayer = .getOuterSide(color: brightSideColor)
    lazy var outerDarkSide: CALayer = .getOuterSide(color: darkSideColor)
    lazy var innerBrightSide: CAShapeLayer = .getInnerSide(color: brightSideColor)
    lazy var innerDarkSide: CAShapeLayer = .getInnerSide(color: darkSideColor.withAlphaComponent(1.0))
    var darkSide: CALayer {
        get {
            let newRadius = CGFloat(radius)
            let size = CGFloat(shadowSize)
            if isConvex {
                outerDarkSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: newRadius).cgPath
                outerDarkSide.shadowOffset = CGSize(width: size / 2, height: size / 4)
                outerDarkSide.shadowRadius = size
                return outerDarkSide
            } else {
                innerDarkSide.path = makeInnerUpperShadowShapePath(rect: bounds, radius: newRadius)
                innerDarkSide.shadowOffset = CGSize(width: -size / 2, height: -size / 4)
                innerDarkSide.shadowRadius = -size
                return innerDarkSide
            }
        }
    }
    var brightSide: CALayer {
        get {
            let newRadius = CGFloat(radius)
            let size = CGFloat(shadowSize)
            if isConvex {
                outerBrightSide.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: newRadius).cgPath
                outerBrightSide.shadowOffset = CGSize(width: -size / 2, height: -size / 4)
                outerBrightSide.shadowRadius = size
                return outerBrightSide
            } else {
                innerBrightSide.path = makeInnerLowerShadowShapePath(rect: bounds, radius: newRadius)
                innerBrightSide.shadowOffset = CGSize(width: size / 2, height: size / 4)
                innerBrightSide.shadowRadius = -size
                return innerBrightSide
            }
        }
    }
    func makeInnerUpperShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = CGPath.makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: -1, y: -1)
        return path.copy(using: &transform)!
    }
    func makeInnerLowerShadowShapePath(rect: CGRect, radius: CGFloat) -> CGPath {
        let path = CGPath.makeInnerShadowShapePathFor(rect: rect, withCornerRadius: radius)
        var transform = CGAffineTransform(translationX: rect.maxX + 1, y: rect.maxY + 1)
        transform = transform.rotated(by: .pi)
        return path.copy(using: &transform)!
    }
    var surface: CALayer = {
        let surface = CALayer()
        surface.backgroundColor =  UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0).cgColor
        return surface
    }()
    var isConvex: Bool {
        get {
            return shadowSize > 0
        }
    }
    public var shadowSize: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    override public var bounds: CGRect {
        didSet {
            surface.frame = layer.bounds
        }
    }
    public var radius: Float = 0 {
        didSet {
            surface.cornerRadius = CGFloat(radius)
            setNeedsLayout()
        }
    }
    private func updateView() {
        layer.sublayers = []
        if isConvex {
            layer.mask = nil
            layer.addSublayer(darkSide)
            layer.addSublayer(brightSide)
            layer.addSublayer(surface)
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(radius)).cgPath
            layer.mask = maskLayer
            layer.addSublayer(surface)
            layer.addSublayer(darkSide)
            layer.addSublayer(brightSide)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        updateView()
    }
}

extension CALayer {
    static func getOuterSide(color: UIColor) -> CALayer {
        let outerSide = CALayer()
        outerSide.shadowColor = color.cgColor
        outerSide.shadowOpacity = 1.0
        outerSide.masksToBounds = false
        return outerSide
    }
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
}
