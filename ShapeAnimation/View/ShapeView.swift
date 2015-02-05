//
//  ShapeView.swift
//  ShapeAnimation
//
//  Created by Zhang Yungui on 15/1/20.
//  Copyright (c) 2015 github.com/rhcad. All rights reserved.
//

import SwiftGraphics

//! View class which contains vector shape layers.
public class ShapeView : UIView {
    
    public var style:PaintStyle = {
        var style = PaintStyle.defaultStyle
        style.lineCap = kCGLineCapButt
        style.lineJoin = kCGLineJoinRound
        return style
        }()
    public var gradient = Gradient()
    
    public func addSublayer(layer:CALayer, frame:CGRect) {
        layer.frame = frame
        layer.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(layer)
    }
    
    public func addShapeLayer(path:CGPath) -> CAShapeLayer {
        let frame = path.boundingBox
        var xf    = CGAffineTransform(translation:-frame.origin)
        let layer = CAShapeLayer()
        
        layer.path = frame.isEmpty ? path : CGPathCreateCopyByTransformingPath(path, &xf)
        self.addSublayer(layer, frame:frame)
        layer.apply(style)
        layer.apply(gradient)
        
        return layer
    }
    
    override public func removeFromSuperview() {
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                layer.removeLayer()
            }
        }
        super.removeFromSuperview()
    }
    
    private var lastBounds = CGRect.zeroRect
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        lastBounds = self.layer.bounds
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        if lastBounds != bounds && self.layer.sublayers != nil {
            for layer in self.layer.sublayers {
                if let layer = layer as? CALayer {
                    if layer.frame == lastBounds {
                        layer.frame = bounds
                    }
                }
            }
            lastBounds = bounds
        }
    }
}

public extension CALayer {
    
    public func removeLayer() {
        gradientLayer?.removeAllAnimations()
        gradientLayer = nil
        self.removeAllAnimations()
        self.removeFromSuperlayer()
    }
}

public extension ShapeView {
    
    public func addCircleLayer(center c:CGPoint, radius:CGFloat) -> CAShapeLayer {
        return addShapeLayer(CGPathCreateWithEllipseInRect(CGRect(center:c, radius:radius), nil))
    }
    
    public func addRegularPolygonLayer(nside:Int, center:CGPoint, radius:CGFloat) -> CAShapeLayer {
        return addLinesLayer(RegularPolygon(nside:nside, center:center, radius:radius).points, closed:true)
    }
    
    public func addLinesLayer(points:[CGPoint], closed:Bool = false) -> CAShapeLayer {
        return addShapeLayer(Path(vertices:points, closed:closed).cgPath)
    }
    
}

public extension CAShapeLayer {
    
    //! The path used to create this layer initially and mapped to the parent layer's coordinate systems.
    public var transformedPath:CGPath {
        get {
            var xf = CGAffineTransform(translation:frame.origin)
            return CGPathCreateCopyByTransformingPath(path, &xf)
        }
        set(v) {
            frame = v.boundingBox
            var xf = CGAffineTransform(translation:-frame.origin)
            path = CGPathCreateCopyByTransformingPath(v, &xf)
        }
    }
    
}
