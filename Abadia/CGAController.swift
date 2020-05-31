//
//  CGAController.swift
//  Abadia
//
//  Created by Phillip LAcebo on 08/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit

class CGAController {
    
    public let context:CGContext!
    init() {
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width :Int           = 320
        let height :Int          = 200
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context.interpolationQuality=CGInterpolationQuality.none
        context.translateBy(x: 0, y: 1136)
        context.scaleBy(x: 1, y: -1)
    }
    
    func drawSomething() {
        context?.move(to: CGPoint.zero)
        context?.addLine(to: CGPoint(x:200,y:500))
        context?.move(to: CGPoint.zero)
        context?.addLine(to: CGPoint(x:500,y:0))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(red:0,green:0,blue:0,alpha:1.0).cgColor)
        context?.strokePath()
    }

    
    
}
