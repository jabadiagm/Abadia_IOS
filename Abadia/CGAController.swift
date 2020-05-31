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
    var data: UnsafeMutableRawPointer?
    var dataPointer:UnsafeMutablePointer<UInt8>?
    init() {
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width  :Int      = 320
        let height :Int      = 200
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context.interpolationQuality=CGInterpolationQuality.none
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        data = context.data
        dataPointer = data?.assumingMemoryBound(to: UInt8.self)
    }
    
    func drawSomething() {
        let dibujo=UIImage(imageLiteralResourceName: "Screenshot.png")
        context?.move(to: CGPoint.zero)
        context?.addLine(to: CGPoint(x:319,y:0))
        context?.addLine(to: CGPoint(x:319,y:199))
        context?.addLine(to: CGPoint(x:0,y:199))
        context?.addLine(to: CGPoint(x:0,y:0))
        context?.addLine(to: CGPoint(x:319,y:199))
        context?.move(to: CGPoint(x:0,y:199))
        context?.addLine(to: CGPoint(x:319,y:0))
        context?.move(to: CGPoint(x:20,y:0))
        context?.addLine(to: CGPoint(x:20,y:20))
        context?.addLine(to: CGPoint(x:0,y:20))
        context?.move(to: CGPoint(x:32,y:0))
        context?.addLine(to: CGPoint(x:32,y:191))
        context?.addLine(to: CGPoint(x:287,y:191))
        context?.addLine(to: CGPoint(x:287,y:0))
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(red:0,green:0,blue:0,alpha:1.0).cgColor)
        context?.strokePath()
        var puntero:Int=0
        //return()
        for _ in 0 ..< 2000{
            dataPointer![puntero] = 255
            dataPointer![puntero+1] = 0
            dataPointer![puntero+2] = 0
            dataPointer![puntero+3] = 255
            puntero+=8
        }
        context.scaleBy(x: 1, y: -1)
        context.draw(dibujo.cgImage!,in:CGRect(x:32,y:-196,width: 256,height:200))
        context.scaleBy(x: 1, y: -1)
    }

    
    
}
