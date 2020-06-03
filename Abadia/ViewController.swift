//
//  ViewController.swift
//  Abadia
//
//  Created by Phillip LAcebo on 07/10/2017.
//  Copyright © 2017 Phillip LAcebo. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    let cga:CGA=CGA()
    let ay8910=AY8912(FMuestreo: 44100)
    let teclado=Teclado()
    let waveOut=WaveOut()
    let abadia=Abadia()

    let reloj:StopWatch=StopWatch()
    let reloj2:StopWatch=StopWatch()
    var contador:UInt32=0
    var contador2:UInt32=0
    var fps2:UInt8=0

    
    var bitmapMarco:Bitmap=Bitmap(width: 141, height: 640, color: .black)
    
    private let cgaImageView = UIImageView()
    private let marco1ImageView = UIImageView()
    private let marco2ImageView = UIImageView()
    
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
        //algunos IPad no necesitan marcos
        var DibujarMarcos:Bool
        //un punto pueden ser 2 ó 3 píxeles
        var PixelsPorPunto:UInt8
        //dos tamaños de marco: relación 0.22/0.41
        var MarcoGrande:Bool
    }
    var Pantalla:TipoPantalla?
    
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fija la orientación
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        //define las vistas en la pantalla
        view.addSubview(cgaImageView)
        view.addSubview(marco1ImageView)
        view.addSubview(marco2ImageView)
        //calcula las medidas de las vistas y las coloca
        definirModo(modo: 0)
        //suministra a la abadía los objetos necesarios
        abadia.Init(cga: cga, viewController: self, ay8910: ay8910, teclado: teclado)
        //sincroniza el bucle principal del juego con el refresco de pantalla
        let displayLink = CADisplayLink(target: self, selector: #selector(Tick))
        displayLink.add(to: .current, forMode: .common)
        //inicializa el sonido
        waveOut.Init(Sonido: ay8910)
        //comienza a reproducir el sonido
        waveOut.Reproducir()
        
        var archivo=[UInt8](repeating: 1, count:10)
        archivo[9]=66
        var tabla=[UInt8](repeating: 0, count: 5)
        abadia.CargarTablaArchivo(&archivo, &tabla, 5)
        
    }
    

    //oculta la barra superior del teléfono
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        definirModo(modo: 1)
    }
    
    func definirModo(modo: UInt8) {
        //define las medidas importantes y coloca los elementos gráficos
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
        cga.definirModo(modo: modo)
        //define las medidas principales de la pantalla
        Pantalla=TipoPantalla(Ancho: 0, Alto: 0, Modo: 0, Factor:0, AnchoCGA:0, AltoCGA:0, AnchoLateral: 0, DibujarMarcos: false, PixelsPorPunto: 0, MarcoGrande: false)
        //Iphone 4-8: 2, Iphone X-11: 3
        Pantalla!.PixelsPorPunto = UInt8(UIScreen.main.scale)
        Pantalla!.Ancho=Int(self.view.frame.size.height) * Int(Pantalla!.PixelsPorPunto)
        Pantalla!.Alto=Int(self.view.frame.size.width) * Int(Pantalla!.PixelsPorPunto)
        Pantalla!.Modo=modo
        //en modo 0, la cga ocupa todo su contenido, 320x200
        //en modo 1, la abadía sólo usa una sección de 256x192
        if modo==0 {
            Pantalla!.Factor=Float(Pantalla!.Alto)/200
            Pantalla!.AnchoCGA=Int(320*Pantalla!.Factor)
            Pantalla!.AltoCGA=Int(200*Pantalla!.Factor)
        } else {
            Pantalla!.Factor=Float(Pantalla!.Alto)/192
            Pantalla!.AnchoCGA=Int(256*Pantalla!.Factor)
            Pantalla!.AltoCGA=Int(192*Pantalla!.Factor)
        }
        //tamaño del marco
        Pantalla!.AnchoLateral=Int(Float(Pantalla!.Ancho-Pantalla!.AnchoCGA)/2)
        //según el espacio disponible, se activan los marcos
        if Pantalla!.AnchoLateral < 130 {
            Pantalla!.DibujarMarcos = false
        } else {
            Pantalla!.DibujarMarcos = true
            //Iphone SE-8: AnchoLateral/Alto=0.22  Iphone X-11: AnchoLateral/Alto=0.4
            if Int(Float(Pantalla!.AnchoLateral)*10/Float(Pantalla!.Alto)) == 2 {
                Pantalla!.MarcoGrande=false
            } else {
                Pantalla!.MarcoGrande=true
            }
        }
        //compone las uiimageview
        cgaImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto), width: CGFloat(Pantalla!.Alto)/CGFloat(Pantalla!.PixelsPorPunto), height: CGFloat(Pantalla!.AnchoCGA) / CGFloat(Pantalla!.PixelsPorPunto))
        cgaImageView.backgroundColor = .red
        cgaImageView.isHidden=false
        cgaImageView.layer.magnificationFilter = .nearest
        if Pantalla!.DibujarMarcos == true {
            //cga en el centro, con proporción a 256x192, y marcos laterales
            marco2ImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(Pantalla!.Alto)/CGFloat(Pantalla!.PixelsPorPunto), height: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto))
            marco2ImageView.backgroundColor = .blue
            marco2ImageView.isHidden=false
            marco1ImageView.frame = CGRect(x: 0, y: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto)+CGFloat(Pantalla!.AnchoCGA) / CGFloat(Pantalla!.PixelsPorPunto), width: CGFloat(Pantalla!.Alto)/CGFloat(Pantalla!.PixelsPorPunto), height: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto))
            marco1ImageView.backgroundColor = .blue
            marco1ImageView.isHidden=false
            //coloca la imagen del marco
            let marco=UIImage(imageLiteralResourceName: "Marco.png")
            bitmapMarco=Bitmap(image: marco)!
            marco1ImageView.image=UIImage(bitmap: bitmapMarco)
            marco2ImageView.image=UIImage(bitmap: bitmapMarco)
            //cgaImageView.image=UIImage(bitmap: cga.bitmapModo1)
        } else {
            //cga en el centro, con proporción a 320x200 y sin marcos
            marco1ImageView.isHidden=true
            marco2ImageView.isHidden=true
            //cgaImageView.image=UIImage(bitmap: cga.bitmapModo0)
        }
    }
    
    
    @objc func Tick() {
        reloj.Start()
        abadia.Tick()
        //coloca el bitmap del modo gráfico actual
        if Pantalla!.Modo==0 {
            cgaImageView.image=UIImage(bitmap: cga.bitmapModo0)
        } else {
            cgaImageView.image=UIImage(bitmap: cga.bitmapModo1)
        }
        
        if (contador%2)==1 {

        }
        reloj.Stop()
       
        contador+=1
        if contador>59 {
            //reloj.Start()
            //cgaController.LLenarPantalla()
            //reloj.Stop()
             print (reloj.EllapsedMicroseconds()/1000)
            contador=0
        }
    }
    
  
}
