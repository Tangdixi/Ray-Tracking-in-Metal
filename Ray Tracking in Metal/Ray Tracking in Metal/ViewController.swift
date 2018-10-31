//
//  ViewController.swift
//  Ray Tracking in Metal
//
//  Created by 汤迪希 on 2018/10/31.
//  Copyright © 2018 DC. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let metalView = view as? MTKView else {
            fatalError("Metal is not supported in this device")
        }
        canvas = Canvas(metalView)
    }
}

