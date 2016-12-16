//
//  ControlButtons.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 12/12/2016.
//	Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/*
Play and pause button.
*/
open class PlayPauseButton: UIButton {
	public enum ButtonState {
		case play
		case pause
	}
	
	open override var isSelected: Bool {
		didSet {
			if isSelected == true {
				playPauseLayer.animationDirection = 0
			} else {
				playPauseLayer.animationDirection = 1
			}
		}
	}
	
	open override var tintColor: UIColor! {
		didSet {
			playPauseLayer.color = tintColor
		}
	}
	
	open var buttonState: ButtonState = .play {
		didSet {
			switch buttonState {
			case .play:
				isSelected = true
			default:
				isSelected = false
			}
		}
	}
	
	private let playPauseLayer = PlayPauseLayer()
	
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
		playPauseLayer.frame = bounds.insetBy(dx: (bounds.width / 4.0), dy: (bounds.height / 4.0))
		playPauseLayer.color = tintColor
	}
	
	@objc fileprivate func changeState() {
		isSelected = !isSelected
	}
	
	private func commonInit() {
		playPauseLayer.frame = bounds.insetBy(dx: (bounds.width / 4.0), dy: (bounds.height / 4.0))
		playPauseLayer.color = tintColor
		layer.addSublayer(playPauseLayer)
		
		addTarget(self, action: #selector(changeState), for: .touchUpInside)
	}
}

/*
Next button.
*/
open class NextButton: UIButton {
	override open func draw(_ rect: CGRect) {
		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(tintColor.cgColor)
			
			let frame = bounds.insetBy(dx: bounds.width / 4.0 + 4.0, dy: bounds.height / 4.0 + 4.0)

			context.move(to: frame.origin)
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width * 0.75, y: frame.origin.y + frame.size.height / 2.0))
			context.addLine(to: CGPoint(x: frame.origin.x, y: (frame.origin.y + frame.size.height)))
			context.closePath()
			context.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 3.0)
			context.fillPath()
			
			context.move(to: CGPoint(x: frame.origin.x + frame.size.width * 0.85, y: frame.origin.y))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width * 0.85, y: frame.origin.y + frame.size.height))
			context.closePath()
			context.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 3.0)
			context.fillPath()
		}
	}
}

/*
Previous button.
*/
open class PreviousButton: UIButton {
	override open func draw(_ rect: CGRect) {
		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(tintColor.cgColor)
			
			let frame = bounds.insetBy(dx: bounds.width / 4.0 + 4.0, dy: bounds.height / 4.0 + 4.0)
			
			context.move(to: frame.origin)
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width * 0.15, y: frame.origin.y))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width * 0.15, y: frame.origin.y + frame.size.height))
			context.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
			context.closePath()
			context.setShadow(offset: CGSize(width: -0.5, height: 0.5), blur: 3.0)
			context.fillPath()
			
			context.move(to: CGPoint(x: frame.origin.x + frame.size.width * 0.25, y: frame.origin.y + frame.size.height / 2.0))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
			context.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: (frame.origin.y + frame.size.height)))
			context.closePath()
			context.setShadow(offset: CGSize(width: -0.5, height: 0.5), blur: 3.0)
			context.fillPath()
		}
	}
}
