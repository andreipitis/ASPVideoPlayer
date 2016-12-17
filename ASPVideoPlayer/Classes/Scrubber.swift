//
//  Scrubber.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 27/10/2016.
//	Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

internal class ScrubberThumb: CALayer {
	var highlighted = false
	weak var scrubber: Scrubber?
}

open class Scrubber: UIControl {
	
	//MARK: - Private Variables and Constants -
	
	private var previousLocation = CGPoint()
	private let trackLayer = CALayer()
	private let trackFillLayer = CALayer()
	private let thumbLayer = ScrubberThumb()
	
	//MARK: - Public Variables -
	
	/*
	Sets the minimum value of the scrubber. Defaults to 0.0 .
	*/
	open var minimumValue: CGFloat = 0.0  {
		didSet {
			updateFrames()
		}
	}
	
	/*
	Sets the maximum value of the scrubber. Defaults to 1.0 .
	*/
	open var maximumValue: CGFloat = 1.0  {
		didSet {
			updateFrames()
		}
	}
	
	/*
	The current value of the scrubber.
	*/
	open var value: CGFloat = 0.0  {
		didSet {
			if thumbLayer.highlighted == false {
				let clampedValue = clamp(value, lower: minimumValue, upper: maximumValue)
				let positionX = rangeMap(clampedValue, min: minimumValue, max: maximumValue, newMin: bounds.origin.x + thumbWidth / 2.0, newMax: bounds.size.width - thumbWidth / 2.0)
				previousLocation = CGPoint(x: positionX, y: 0.0)
			}
			
			updateFrames()
			
		}
	}
	
	/*
	The height of the track. Defaults to 6.0 .
	*/
	open var trackHeight: CGFloat = 6.0  {
		didSet {
			updateFrames()
		}
	}
	
	/*
	Sets the color of the unfilled part of the track.
	*/
	open var trackColor = UIColor.white.withAlphaComponent(0.3).cgColor  {
		didSet {
			trackLayer.backgroundColor = trackColor
			trackLayer.setNeedsDisplay()
		}
	}
	
	/*
	Sets the color of the filled part of the track.
	*/
	open var trackFillColor = UIColor.white.cgColor  {
		didSet {
			trackFillLayer.backgroundColor = trackFillColor
			trackFillLayer.setNeedsDisplay()
		}
	}
	
	/*
	Sets the color of thumb.
	*/
	open var thumbColor = UIColor.white.cgColor  {
		didSet {
			thumbLayer.backgroundColor = thumbColor
			thumbLayer.setNeedsDisplay()
		}
	}
	
	/*
	Sets the width of the track.
	*/
	open var thumbWidth: CGFloat = 12.0  {
		didSet {
			updateFrames()
		}
	}
	
	/*
	Sets the color of the thumb and track.
	*/
	open override var tintColor: UIColor! {
		didSet {
			thumbColor = tintColor.cgColor
			trackFillColor = tintColor.cgColor
		}
	}
	
	//MARK: - Superclass methods -
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override open var frame: CGRect {
		didSet {
			updateFrames()
		}
	}
	
	override open func layoutSubviews() {
		value = value + 0.0
		updateFrames()
	}
	
	//MARK: - UIControl methods -
	
	override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		previousLocation = thumbLayer.position
		
		let extendedFrame = thumbLayer.frame.insetBy(dx: -thumbWidth * 1.5, dy: -thumbWidth * 1.5)
		if extendedFrame.contains(touch.location(in: self)) {
			sendActions(for: .touchDown)
			thumbLayer.highlighted = true
			thumbWidth = 20.0
		}
		return thumbLayer.highlighted
	}
	
	override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		
		let clampedX = clamp(location.x, lower: bounds.origin.x + thumbWidth / 3.5, upper: bounds.size.width - thumbWidth / 3.5)
		let deltaLocation = CGPoint(x: clampedX, y: location.y)
		let deltaValue = rangeMap(deltaLocation.x, min: bounds.origin.x + thumbWidth / 3.5, max: bounds.size.width - thumbWidth / 3.5, newMin: minimumValue, newMax: maximumValue)
		
		previousLocation = deltaLocation
		
		if thumbLayer.highlighted {
			value = deltaValue
			sendActions(for: .valueChanged)
		}
		
		return thumbLayer.highlighted
	}
	
	override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		thumbLayer.highlighted = false
		thumbWidth = 12.0
		
		sendActions(for: .touchUpInside)
	}
	
	open override func cancelTracking(with event: UIEvent?) {
		thumbLayer.highlighted = false
		thumbWidth = 12.0
		
		sendActions(for: .touchCancel)
	}
	
	//MARK: - Private Methods -
	
	private func commonInit() {
		thumbLayer.scrubber = self
		
		trackLayer.backgroundColor = trackColor
		layer.addSublayer(trackLayer)
		
		trackFillLayer.backgroundColor = trackFillColor
		layer.addSublayer(trackFillLayer)
		
		thumbLayer.backgroundColor = thumbColor
		thumbLayer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
		thumbLayer.borderWidth = 0.5
		thumbLayer.shadowColor = UIColor.black.cgColor
		thumbLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
		thumbLayer.shadowOpacity = 0.35
		thumbLayer.shadowRadius = 2.0
		layer.addSublayer(thumbLayer)
		
		updateFrames()
	}
	
	private func updateFrames() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		trackLayer.frame = CGRect(x: 0.0, y: bounds.height / 2.0, width: bounds.width, height: trackHeight)
		trackLayer.cornerRadius = trackHeight / 2.0
		trackLayer.setNeedsDisplay()
		
		let thumbCenter = CGPoint(x: previousLocation.x - thumbWidth / 2.0, y: bounds.midY)
		let thumbSize = thumbWidth * 1.0
		thumbLayer.frame = CGRect(x: thumbCenter.x, y: trackLayer.frame.midY - thumbSize / 2.0 , width: thumbSize, height: thumbSize)
		thumbLayer.cornerRadius = thumbSize / 2.0
		thumbLayer.setNeedsDisplay()
		
		trackFillLayer.frame = CGRect(origin: trackLayer.frame.origin, size: CGSize(width: thumbCenter.x + thumbSize, height: trackHeight))
		trackFillLayer.cornerRadius = trackHeight / 2.0
		trackFillLayer.setNeedsDisplay()
		
		CATransaction.commit()
	}
}
