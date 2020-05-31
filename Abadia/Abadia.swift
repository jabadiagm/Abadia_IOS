//
//  Abadia.swift
//  Abadia
//
//  Created by Phillip LAcebo on 07/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit

class Abadia {
    private var nose:Int=0
    var prueba:Bool=true
    var viewController: UIViewController?
    var cgaController:CGAController?
    var imageView: UIImageView?
    func SetObjects(cCGAController: CGAController, cImageView: UIImageView!,cViewController: UIViewController) {
        cgaController=cCGAController
        imageView=cImageView
        viewController=cViewController
    }
    
    func ComposeView() {
        let marco=UIImage(imageLiteralResourceName: "Marco.png")
        var composeContext:CGContext!
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width :Int       = Int(viewController!.view.frame.size.width)*2
        let height :Int          = Int(viewController!.view.frame.size.height)*2
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        composeContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        composeContext.interpolationQuality=CGInterpolationQuality.none
        composeContext.translateBy(x: 667, y: 35)
        //composeContext.scaleBy(x: 1, y: -1)
        composeContext.rotate(by: CGFloat(Double.pi / 2))
        
        
        let cga=cgaController?.context.makeImage()

        composeContext.draw(cga!,in:CGRect(x:0,y:0,width: 1067,height:667))
        composeContext.translateBy(x: -35,y: 27)
        composeContext.draw(marco.cgImage!,in:CGRect(x:0,y:0,width: 142,height:640))
        composeContext.draw(marco.cgImage!,in:CGRect(x:995,y:0,width: 142,height:640))
        let image=composeContext.makeImage()
        imageView?.layer.magnificationFilter=kCAFilterNearest
        imageView?.image=UIImage(cgImage: image!)
    }
    func InicializarPartida() {
        
    }
    func BuclePrincipal() {
        
    }
    
}

