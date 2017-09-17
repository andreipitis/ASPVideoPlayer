//
//  ResizeButton.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 10/06/2017.
//

import UIKit

open class ResizeButton: UIButton {
    public enum ButtonState {
        case large
        case small
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected == true {
                resizeLayer.animationDirection = 0.0
            } else {
                resizeLayer.animationDirection = 1.0
            }
        }
    }
    
    open override var tintColor: UIColor! {
        didSet {
            resizeLayer.color = tintColor
        }
    }
    
    open var buttonState: ButtonState = .large {
        didSet {
            switch buttonState {
            case .large:
                isSelected = false
            default:
                isSelected = true
            }
        }
    }
    
    private let resizeLayer = ResizeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        resizeLayer.frame = bounds.insetBy(dx: 4.0, dy: 4.0)
        resizeLayer.color = tintColor
    }
    
    @objc fileprivate func changeState() {
        if isSelected == true {
            buttonState = .large
        } else {
            buttonState = .small
        }
    }
    
    private func commonInit() {
        resizeLayer.frame = bounds.insetBy(dx: 4.0, dy: 4.0)
        resizeLayer.color = tintColor
        layer.addSublayer(resizeLayer)
        
        addTarget(self, action: #selector(changeState), for: .touchUpInside)
    }
}

/*
 Internal class used for the resize animation on the ResizeButton.
 */
internal class ResizeLayer: CALayer {
    @NSManaged public var animationDirection: CGFloat
    
    public var color: UIColor = .black
    
    public override init() {
        super.init()
        contentsScale = UIScreen.main.scale
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        animationDirection = 1.0
        CATransaction.commit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        
        if let layer = layer as? ResizeLayer {
            animationDirection = layer.animationDirection
            color = layer.color
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(in context: CGContext) {
        super.draw(in: context)
        
        context.setLineWidth(3.0)
        context.setStrokeColor(color.cgColor)

        let spacing: CGFloat = bounds.height / 4.0 - (bounds.height / 4.0 - bounds.height / 4.0 * animationDirection)
        
        let itemHeight: CGFloat = bounds.height / 2.0 - spacing / 2.0
        let itemWidth: CGFloat = bounds.width / 2.0 - spacing / 2.0

        context.move(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y))
        context.addLine(to: CGPoint(x: bounds.origin.x + itemWidth, y: bounds.origin.y))
        context.move(to: CGPoint(x: bounds.origin.x + itemWidth + spacing, y: bounds.origin.y))
        
        context.addLine(to: CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y))
        context.addLine(to: CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + itemHeight))
        context.move(to: CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + itemHeight + spacing))
        
        context.addLine(to: CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + bounds.height))
        context.addLine(to: CGPoint(x: bounds.origin.x + itemWidth + spacing, y: bounds.origin.y + bounds.height))
        
        context.move(to: CGPoint(x: bounds.origin.x + itemWidth, y: bounds.origin.y + bounds.height))
        context.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.height))
        context.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y + itemHeight + spacing))

        context.move(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y + itemHeight))
        context.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y))
        
        context.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 3.0)
        context.strokePath()
    }
    
    open override func action(forKey event: String) -> CAAction? {
        if event == "animationDirection" {
            let basicAnimation = CABasicAnimation(keyPath: event)
            basicAnimation.fromValue = animationDirection
            basicAnimation.toValue = 1.0 - animationDirection
            basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            basicAnimation.duration = 0.25
            
            return basicAnimation
        }
        
        return super.action(forKey: event)
    }
    
    open override class func needsDisplay(forKey key: String) -> Bool {
        if key == "animationDirection" || key == "color" {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
}
