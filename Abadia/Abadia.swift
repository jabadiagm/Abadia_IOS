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
    var WaveOut:cWaveOut?
    var AY8910:cAY8912?
    var ComposeContext:CGContext?
    var tempImageView:UIImageView=UIImageView()
    var cga2:CGImage?
    var image2:CGImage?
    
    let Marco=UIImage(imageLiteralResourceName: "Marco.png")
    var CapaMarco:CGLayer?
    var ContextoCapaMarco:CGContext?
    
   
    
    struct TipoPantalla {
        var Ancho:Int //ancho todal de la pantalla, en píxeles
        var Alto:Int //alto total de la pantalla
        var Modo:UInt8 //modo de pantalla de la cga
        var Factor:Float //relación entre el alto total de pantalla y el ancho de la cga
        var AnchoCGA:Int //píxeles que ocupa la anchura de la cga en pantalla
        var AltoCGA:Int //píxeles que ocupa la altura de la cga en pantalla
        //píxeles que ocupa cada uno de los huecos que deja la cga
        //en modo 0 el hueco es menor, pero no se usa
        var AnchoLateral:Int
    }
    var Pantalla:TipoPantalla=TipoPantalla(Ancho: 0, Alto: 0, Modo: 0, Factor:0, AnchoCGA:0, AltoCGA:0, AnchoLateral: 0)
    
    func Init(cCGAController: CGAController, cImageView: UIImageView!,cViewController: UIViewController) {
        //define los objetos necesarios
        cgaController=cCGAController
        imageView=cImageView
        viewController=cViewController
        //arranca en modo 320x200 para poner la presentación
        DefinirModo(Modo:0)
        //se crea el contexto gráfico donde se va a dibujar la cga a escala y los bordes
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width :Int       = Int(viewController!.view.frame.size.width)//*2
        let height :Int          = Int(viewController!.view.frame.size.height)//*2
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ComposeContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        ComposeContext!.interpolationQuality=CGInterpolationQuality.none
        //mueve el origen al punto inferior izquierdo
        ComposeContext!.translateBy(x: CGFloat(width), y: 0)
        //composeContext.scaleBy(x: 1, y: -1)
        ComposeContext!.rotate(by: CGFloat(Double.pi / 2))
        //evita la interpolación para mostrar el pixelado original
        imageView?.layer.magnificationFilter=CALayerContentsFilter.nearest
        

        
    }
    

    
    func DefinirModo(Modo: UInt8) {
        //define las medidas importantes para colocar los elementos gráficos
        //
        //              A     n     c     h     o
        //        ------------------------------------
        //       |      |      AnchoCGA        |      |
        //       |      |                      |      |
        //       |      |                      |      |
        //       |      |                      |      |  Alto
        //       |      |                      |      |
        //       |      |                      |      |
        //        ------------------------------------
        //     AnchoLateral
        //
        //para Apple, el teléfono está en vertical, por lo que heigh es el valor largo
        //la pantalla está compuesta por un UIPictureView que ocupa todo el espacio
        cgaController?.definirModo(Modo: Modo)
        //
        Pantalla=TipoPantalla(Ancho: 0, Alto: 0, Modo: 0, Factor:0, AnchoCGA:0, AltoCGA:0, AnchoLateral: 0)
        Pantalla.Ancho=Int(viewController!.view.frame.size.height)//*2
        Pantalla.Alto=Int(viewController!.view.frame.size.width)//*2
        Pantalla.Modo=Modo
        //en modo 0, la cga ocupa todo su contenido, 320x200
        //en modo 1, la abadía sólo usa una sección de 256x192
        if Modo==0 {
            Pantalla.Factor=Float(Pantalla.Alto)/200
            Pantalla.AnchoCGA=Int(320*Pantalla.Factor)
            Pantalla.AltoCGA=Int(200*Pantalla.Factor)
        } else {
            Pantalla.Factor=Float(Pantalla.Alto)/192
            Pantalla.AnchoCGA=Int(256*Pantalla.Factor)
            Pantalla.AltoCGA=Int(192*Pantalla.Factor)
        }
        Pantalla.AnchoLateral=Int(Float(Pantalla.Ancho-Pantalla.AnchoCGA)/2)
        
        
        if Modo==1 {
            //crea la capa con el marco lateral
            CapaMarco=CGLayer(ComposeContext!, size: CGSize(width:Int(Pantalla.AnchoLateral), height:Int(Pantalla.Alto)), auxiliaryInfo: nil)!
            ContextoCapaMarco=CapaMarco?.context
            //dibuja el marco en su capa
            ContextoCapaMarco!.draw(Marco.cgImage!,in:CGRect(x:0,y:0,width: Pantalla.AnchoLateral,height: Pantalla.Alto))
        }
            

        
    }
    


    
    func RefrescarPantalla() {
        if Pantalla.Modo==0 {
            //cgaController?.DibujarPresentacion()
        } else {
            //cgaController?.DibujarScreenshot()
        }
        let cga=cgaController?.context!.makeImage()
        ComposeContext!.draw(cga!,in:CGRect(x: Int(Pantalla.AnchoLateral)+1,y:0,width: Int(Pantalla.AnchoCGA),height:Int(Pantalla.AltoCGA)))
        //en modo 1 se colocan los marcos en los laterales
        if Pantalla.Modo==1 {
            let marco=UIImage(imageLiteralResourceName: "Marco.png")
            ComposeContext!.draw(marco.cgImage!,in:CGRect(x:0,y:0,width: Int(Pantalla.AnchoLateral),height: Int(Pantalla.Alto)))
            ComposeContext!.draw(marco.cgImage!,in:CGRect(x: Int(Pantalla.Ancho-Pantalla.AnchoLateral),y:0,width: Int(Pantalla.AnchoLateral),height: Int(Pantalla.Alto)))
        }
        let image=ComposeContext!.makeImage()
        imageView?.image=UIImage(cgImage: image!)
    }
 
    func RefrescarPantalla2() {
        //###depuración: dibuja una imagen guardada en la CGA para comprobar la composición
        if Pantalla.Modo==0 {
            cgaController?.DibujarPresentacion()
        } else {
            cgaController?.DibujarScreenshot()
        }
        let cga=cgaController?.context!.makeImage()
        ComposeContext!.draw(cga!,in:CGRect(x: Int(Pantalla.AnchoLateral)+1,y:0,width: Int(Pantalla.AnchoCGA),height:Int(Pantalla.AltoCGA)))
        
        if Pantalla.Modo==1 {
            ComposeContext!.draw(CapaMarco!, at: CGPoint(x:0, y:0))
            ComposeContext!.draw(CapaMarco!, at: CGPoint(x:Int(Pantalla.Ancho-Pantalla.AnchoLateral), y:0))
        }
        let image=ComposeContext!.makeImage()
        imageView?.image=UIImage(cgImage: image!)
        
    }
    
    func InicializarPartida() {
        
    }
    func BuclePrincipal() {
        
    }
    
}

