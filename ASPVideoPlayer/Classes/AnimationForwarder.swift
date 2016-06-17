//
//  AnimationForwarder.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

public class AnimationForwarder: UIView {
    
    private weak var backingView: UIView?
    
    public convenience init(view: UIView) {
        self.init()
        backingView = view
    }
    
    public override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        return backingView?.actionForLayer(layer, forKey: event)
    }
}
