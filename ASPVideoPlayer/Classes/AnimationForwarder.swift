//
//  AnimationForwarder.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/**
 Internal class used to forward the layer actions from the backing view to a layer.
 It should be used as the delegate of a layer.
 */
internal class AnimationForwarder: UIView {

    fileprivate weak var backingView: UIView?
    
    internal convenience init(view: UIView) {
        self.init()
        backingView = view
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return backingView?.action(for: layer, forKey: event)
    }
}
