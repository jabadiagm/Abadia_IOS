//
//  ViewController.swift
//  Abadia
//
//  Created by javier abadía on 07/10/2017.
//  Copyright © 2017 javier abadía. All rights reserved.
//

import UIKit
import AVFoundation
import Funciones


class ViewController: UIViewController {
    let cga:CGA=CGA()
    
    let teclado=Teclado()
    let senoidal:Senoidal=Senoidal()
    let ay8910=AY8912(FMuestreo: WaveOut.WAVE_FREQ)
    //lazy var waveOut=WaveOut(Sonido: senoidal)
    lazy var waveOut=WaveOut(Sonido: ay8910)
    let abadia=Abadia()

    let reloj:StopWatch=StopWatch()
    let reloj2:StopWatch=StopWatch()
    var contador:UInt32=0
    var contador2:UInt32=0
    var fps2:UInt8=0
    
    private let joystickRadius: Double = 100

    
    var bitmapMarco:Bitmap=Bitmap(width: 141, height: 640, color: .black)
    
    private let cgaImageView = UIImageView()
    private let marco1ImageView = UIImageView()
    private let marco2ImageView = UIImageView()
    
    private let panGesture = UIPanGestureRecognizer()
    private let tapGesture = UITapGestureRecognizer()
    
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
        //evita el apagado de pantalla
        UIApplication.shared.isIdleTimerDisabled = true
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
        
        //gestores de eventos
        view.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        //view.addGestureRecognizer(tapGesture)
        //tapGesture.addTarget(self, action: #selector(procesadorToques))
        //tapGesture.delegate = self
        
        //inicializa el sonido
        senoidal.DefinirSenoidal(Ampli: 0.5, Interv: 1/Float(WaveOut.WAVE_FREQ), Frec: 1000)
        //waveOut.Init(Sonido: ay8910)
        //comienza a reproducir el sonido
        waveOut.Abrir()
        
        
        let seconds = 2.0//Time To Delay
        let when = DispatchTime.now() + seconds
        
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.waveOut.Reproducir()
        }
        
        /*
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
            self.waveOut.Parar()
            print("Parado")
        }
  
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6.0) {
            self.waveOut.Reproducir()
            print("Reproduciendo")
        }

        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8.0) {
          self.waveOut.Parar()
          print("Parado")
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0) {
          self.waveOut.Reproducir()
          print("Reproduciendo")
        }
 */
        
        //detecta la activación/desactivación para activar/desactivar el sonido
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(audioRouteChangeListener), name: AVAudioSession.routeChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(audioConfigurationChangeListener), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: nil)
        
        var array1:[UInt8]=[0x30, 0x30, 0x30, 0x30, 0x30]
        var array2:[UInt8]=[0x31, 0x31, 0x31, 0x31, 0x31]
        let rgb=BGR2RGB(BGR: 0x112233)
        /*
        for _ in 0...20 {
            let nose=Int(round(Float.random(in: 0...1)))
            print(nose)
        }*/

        /*
        ay8910.EscribirRegistro(NumeroRegistro: 0, ValorRegistro: 168)
        //ay8910.EscribirRegistro(NumeroRegistro: 1, ValorRegistro: 0)
        //ay8910.EscribirRegistro(NumeroRegistro: 2, ValorRegistro: 0x10)
        //ay8910.EscribirRegistro(NumeroRegistro: 4, ValorRegistro: 0x4)
        //AY38910.EscribirRegistro(6, 16)
        ay8910.EscribirRegistro(NumeroRegistro: 7, ValorRegistro: 0)
        ay8910.EscribirRegistro(NumeroRegistro: 8, ValorRegistro: 16)
        //ay8910.EscribirRegistro(NumeroRegistro: 9, ValorRegistro: 15)
        ay8910.EscribirRegistro(NumeroRegistro: 11, ValorRegistro: 25)
        ay8910.EscribirRegistro(NumeroRegistro: 12, ValorRegistro: 8)
        ay8910.EscribirRegistro(NumeroRegistro: 13, ValorRegistro: 8)
        ay8910.EscribirRegistro(NumeroRegistro: 14, ValorRegistro: 6)
 */
        var Contador:Int=0
        var nose2:UInt8=0
        /*
        while true {
            nose2=UInt8(256*ay8910.Reproducir())
            Contador+=1
            if nose2 != 0 {
                print("777")
            }
        }
        */
        
        
    }
    
    
    @objc func appMovedToBackground() {
        waveOut.Parar()
        print ("Parado Background")
        //waveOut.Cerrar()
        
    }
    
    @objc func appMovedToForeground() {
        //waveOut.Reconectar()
        //waveOut.Abrir()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.waveOut.Reproducir()
            print("Foreground Reproduciendo")
        }
        
    }
    
    @objc func audioRouteChangeListener() {
        print("Auriculares")
        //waveOut.Parar()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.waveOut.Reproducir()
            print("Reproduciendo")
        }

    }
    
    @objc func audioConfigurationChangeListener() {
        
        /*
        print("AVAudioEngineChange")
        sleep(1)
        waveOut.Pausar()
        print("Pausado")
        sleep(1)
        waveOut.Parar()
        print("Parado")
        


        sleep(1)
        
        waveOut.Reconectar()
        print("Reconectar")
        waveOut.Abrir()
        //waveOut.Reproducir()
         */
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.waveOut.Reproducir()
            print("Reproduciendo")
        }
        
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
        print("touch begin")
        for touch in touches {
            let tecla = pixeles2Area(coordenadas2Pixeles(touch.location(in: view)))
            teclado.KeyDown(tecla)
        }
        //abadia.CambioPantalla_2DB8 = true
        //abadia.PunteroPantallaActual_156A = abadia.BuscarHabitacionProvisional(NumeroPantalla: abadia.NumeroHabitacion)
        //abadia.HabitacionOscura_156C = false
        //abadia.NumeroHabitacion+=1
        return
        if waveOut.Reproduciendo {
            waveOut.Parar()
            print("Touch: Parado")
        } else {
            print("Touch: Reproduciendo")
            waveOut.Reproducir()
        }
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        teclado.ToquesTerminados()
        print("touch cancel")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let tecla = pixeles2Area(coordenadas2Pixeles(touch.location(in: view)))
            print (tecla)
            teclado.KeyUp(tecla)
        }
    }
    
    func coordenadas2Pixeles( _ posicion: CGPoint) -> CGPoint {
        var scale:CGFloat
        var pixelY:CGFloat
        var pixelX:CGFloat
        scale = 192 / view.frame.size.width
        pixelX = (view.frame.size.height / 2 - posicion.y) * scale
        pixelY = posicion.x * scale
        return CGPoint(x: pixelX, y: pixelY)
    }
    
    func pixeles2Area ( _ posicion: CGPoint) -> EnumAreaTecla {
        if posicion.x > 118  && posicion.y < 20 {
            return .AreaDepuracion
        } else if posicion.y >= 160 && posicion.y <= 172{
            if posicion.x > 0 && posicion.x < 32 {
                return .AreaTextosDerecha
            } else if posicion.x < 0 && -posicion.x < 32 {
                return .AreaTextosIzquierda
            } else {
                return .AreaEscenario
            }
        } else if posicion.y > 172 {
            if posicion.x<0 {
                if posicion.x < -96 {
                    return .TeclaArriba
                } else if posicion.x < -63 {
                    return .TeclaAbajo
                } else {
                    return .AreaEscenario
                }
                
            } else {
                if posicion.x > 96 {
                    return .TeclaDerecha
                } else if posicion.x > 63 {
                    return .TeclaIzquierda
                } else {
                    return .AreaEscenario
                }
            }
        } else {
            return .AreaEscenario
        }
    }
    
    private var inputVector: Vector {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            var vector = Vector(x: -Double(translation.y), y: -Double(translation.x))
            vector /= max(joystickRadius, vector.length)
            panGesture.setTranslation(CGPoint(
                x: -vector.y * joystickRadius,
                y: -vector.x * joystickRadius
            ), in: view)
            return vector
        default:
            return Vector(x: 0, y: 0)
        }
    }
    
    func joystick2Teclas() -> [EnumAreaTecla] {
        let limite: Double = 0.3
        var resultado:[EnumAreaTecla]=[]
        if inputVector.y > limite {
            resultado.append(EnumAreaTecla.TeclaArriba)
        }
        if inputVector.x > limite {
            resultado.append(EnumAreaTecla.TeclaDerecha)
        }
        if inputVector.x < -limite {
            resultado.append(EnumAreaTecla.TeclaIzquierda)
        }
        if inputVector.y < -limite {
            resultado.append(EnumAreaTecla.TeclaAbajo)
        }
        return resultado
    }
    
    func procesarJoystick() {
        struct Estatico {
            static var anterior: [Bool]=[false, false, false, false]
            static let cursores: [EnumAreaTecla] = [.TeclaArriba, .TeclaAbajo, .TeclaIzquierda, .TeclaDerecha]
        }
        var actual: [Bool] = []
        let cursoresPulsados: [EnumAreaTecla] = joystick2Teclas()
        for tecla in Estatico.cursores {
            if cursoresPulsados.contains(tecla) {
                actual.append(true)
            } else {
                actual.append(false)
            }
        }
        for contador in 0..<actual.count {
            if Estatico.anterior[contador] == false && actual[contador] == true {
                teclado.KeyDown(Estatico.cursores[contador])
            } else  if Estatico.anterior[contador] == true && actual[contador] == false {
                  teclado.KeyUp(Estatico.cursores[contador])
              }
        }
        Estatico.anterior = actual
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
        self.view.backgroundColor = .black
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
        cgaImageView.backgroundColor = .black
        cgaImageView.isHidden=false
        cgaImageView.layer.magnificationFilter = .nearest
        if Pantalla!.DibujarMarcos == true {
            //cga en el centro, con proporción a 256x192, y marcos laterales
            marco2ImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(Pantalla!.Alto)/CGFloat(Pantalla!.PixelsPorPunto), height: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto))
            marco2ImageView.backgroundColor = .black
            marco2ImageView.isHidden=false
            marco1ImageView.frame = CGRect(x: 0, y: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto)+CGFloat(Pantalla!.AnchoCGA) / CGFloat(Pantalla!.PixelsPorPunto), width: CGFloat(Pantalla!.Alto)/CGFloat(Pantalla!.PixelsPorPunto), height: CGFloat(Pantalla!.AnchoLateral) / CGFloat(Pantalla!.PixelsPorPunto))
            marco1ImageView.backgroundColor = .black
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
        if !reloj.Active {
            reloj.Start()
        }
        procesarJoystick()
        
        if (contador%2)==1 {
            abadia.Tick()
            //coloca el bitmap del modo gráfico actual
            if Pantalla!.Modo==0 {
                cgaImageView.image=UIImage(bitmap: cga.bitmapModo0)
            } else {
                cgaImageView.image=UIImage(bitmap: cga.bitmapModo1)
            }

        }
        if reloj.EllapsedMilliseconds() > 100 {
            reloj.Start()
            //print(inputVector)
            let teclas=joystick2Teclas()
            if teclas.count > 0 { print (teclas) }
            
        }
       
        contador+=1
        if contador>59 {
            //reloj.Start()
            //cgaController.LLenarPantalla()
            //reloj.Stop()
            //print (reloj.EllapsedMicroseconds()/1000)
            contador=0
        }
    }
 
  
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
