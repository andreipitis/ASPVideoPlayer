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
    
    open var buttonState: ButtonState {
        set {
            switch newValue {
            case .large:
                isSelected = false
            default:
                isSelected = true
            }
        }
        get {
            return isSelected == true ? .small : .large
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
        isSelected = !isSelected
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
internal class ResizeLayer: AnimateableLayer {
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
}
