//
//  CGAController.swift
//  Abadia
//
//  Created by Phillip LAcebo on 08/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit

class CGAController {
    
    public var context:CGContext?
    var data: UnsafeMutableRawPointer?
    var dataPointer:UnsafeMutablePointer<UInt8>?
    var Puntero:Int=0
    var Color:UInt8=255
    public var Modo:UInt8=0
    var Ancho:UInt16=0
    var Alto:UInt16=0
    init() {
        //inicializa los objetos gráficos
        //arranca en 320x200 para pantalla de presentación
        definirModo(Modo:1)
    }
    
    func drawSomething() -> Void {
        if Modo==0 {
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
        } else {
            context?.move(to: CGPoint.zero)
            context?.addLine(to: CGPoint(x:255,y:0))
            context?.addLine(to: CGPoint(x:255,y:191))
            context?.addLine(to: CGPoint(x:0,y:191))
            context?.addLine(to: CGPoint(x:0,y:0))
            context?.addLine(to: CGPoint(x:255,y:191))
            context?.move(to: CGPoint(x:0,y:191))
            context?.addLine(to: CGPoint(x:255,y:0))
            context?.move(to: CGPoint(x:0,y:0))
            context?.addLine(to: CGPoint(x:20,y:20))
            context?.addLine(to: CGPoint(x:0,y:20))

        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(red:0,green:0,blue:0,alpha:1.0).cgColor)
        context?.strokePath()
        var puntero:Int=0
        for _ in 0 ..< 2000{
            dataPointer![puntero] = 255
            dataPointer![puntero+1] = 0
            dataPointer![puntero+2] = 255
            dataPointer![puntero+3] = 0
            dataPointer![puntero+4] = 255
            dataPointer![puntero+5] = 255
            dataPointer![puntero+6] = 0
            dataPointer![puntero+7] = 0
            puntero+=8
        }
        return
    }
    
    func DibujarPresentacion() {
        let dibujo=UIImage(imageLiteralResourceName: "Presentacion.png")
        context!.scaleBy(x: 1, y: -1)
        context!.draw(dibujo.cgImage!,in:CGRect(x:0,y:-200,width: 320,height:200))
        context!.scaleBy(x: 1, y: -1)
    }
    
     func DibujarScreenshot() {
        let dibujo=UIImage(imageLiteralResourceName: "Screenshot.png")
        context!.scaleBy(x: 1, y: -1)
        context!.draw(dibujo.cgImage!,in:CGRect(x:0,y:-192,width: 256,height:192))
        context!.scaleBy(x: 1, y: -1)
     }
    
    func drawNose() -> Void {
        context?.move(to: CGPoint.zero)
        context?.addLine(to: CGPoint(x:319,y:0))
        context?.addLine(to: CGPoint(x:319,y:199))
        context?.addLine(to: CGPoint(x:0,y:199))
        context?.addLine(to: CGPoint(x:0,y:0))
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(red:0,green:0,blue:0,alpha:1.0).cgColor)
        context?.strokePath()
        return
    }
    
    func Nose() {
        dataPointer![Puntero] = 255
        dataPointer![Puntero+1] = Color
        dataPointer![Puntero+2] = 0
        dataPointer![Puntero+3] = 0
        Puntero+=4
        if Puntero>1000 {
            Puntero=0
            if Color==255 {
                Color=0
            } else {
                Color=255
            }
        }
    }
    
    public func definirModo(Modo: UInt8) {
        //Modo 0: 320x200
        //Modo 1: 256x192
        var width  :Int
        var height :Int
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        if Modo==0 {
            width = 320
            height = 200
        } else {
            width = 256
            height = 192
        }
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context!.interpolationQuality=CGInterpolationQuality.none
        context!.translateBy(x: 0, y: CGFloat(height))
        context!.scaleBy(x: 1, y: -1)
        data = context!.data
        dataPointer = data?.assumingMemoryBound(to: UInt8.self)
        self.Modo=Modo
    }
    
    func LLenarPantalla () {
        for Contador in 0...256000 {
            dataPointer![Contador] = 255
        }
    }

    func SeleccionarPaleta(Paleta:UInt32) {
        
    }
    
    func DibujarRectangulo(X1:UInt32, Y1:UInt32, X2:UInt32, Y2:UInt32) {
        
    }
    
    func DibujarRectanguloCGA(X1:UInt32, Y1:UInt32, X2:UInt32, Y2:UInt32, NColor:UInt8) {
        
    }
    
    func DibujarPunto(X:UInt32, Y:UInt32,NColor:UInt8) {
        
    }
    
    func PantallaCGA2PC(PunteroPantalla:UInt32, Color:UInt8) {
        
    }
    

    
}
