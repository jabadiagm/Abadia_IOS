//
//  ProcesadorEntrada.swift
//  Abadia
//
//  Created by javier on 23/05/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation
import UIKit
import Funciones

class ProcesadorEntrada {
    var teclado:Teclado
    var abadia:Abadia
    var view:UIView
    
    //teclas procesadas por este objeto
    let teclas: [EnumAreaTecla] = [.TeclaArriba, .TeclaAbajo, .TeclaIzquierda, .TeclaDerecha, .AreaDepuracion, .AreaEscenario, .AreaObjetos, .AreaTextosDerecha, .AreaTextosIzquierda]
    lazy var estadoAnterior: [Bool]=[Bool] (repeating: false, count: teclas.count)
    
    init(view: UIView, teclado: Teclado, abadia: Abadia) {
        self.view = view
        self.teclado = teclado
        self.abadia = abadia
    }
    
    /*
    public func actualizarTeclado (touches: Set<UITouch>) {
        
        struct Estatico {
            static var contador:Int = 0
        }

        Estatico.contador+=1
        if Estatico.contador == 5 {
            let nose = 1
        }
        
        var estadoActual: [Bool] = []
        let teclasPulsadas: [EnumAreaTecla] = leerTeclas(touches)
        
        for tecla in teclas {
            if teclasPulsadas.contains(tecla) {
                estadoActual.append(true)
            } else {
                estadoActual.append(false)
            }
        }
        for contador in 0..<teclas.count {
            if estadoAnterior[contador] == false && estadoActual[contador] == true {
                teclado.KeyDown(teclas[contador])
            } else  if estadoAnterior[contador] == true && estadoActual[contador] == false {
                  teclado.KeyUp(teclas[contador])
            }
        }
        estadoAnterior = estadoActual
        
       print("toque")
    } */
    
    public func touchesBegan (touches: Set<UITouch>) {
        let teclasPulsadas: [EnumAreaTecla] = leerTeclas(touches)
        for tecla in teclasPulsadas {
            teclado.KeyDown(tecla)
        }
    }
    
    public func touchesEnded (touches: Set<UITouch>) {
        let teclasPulsadas: [EnumAreaTecla] = leerTeclas(touches)
        for tecla in teclasPulsadas {
            //print("KeyUp\(tecla)")
            teclado.KeyUp(tecla)
        }
    }
    
    private func leerTeclas( _ touches: Set<UITouch>) -> [EnumAreaTecla] {
        var result: [EnumAreaTecla] = []
        for touch in touches {
            result.append ( pixeles2Area(coordenadas2Pixeles(touch.location(in: view))))
        }
        return result
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
    
    @objc  public func izquierdaDerecha (_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            if gestureRecognizer.direction == .down {
                teclado.KeyDown(.TeclaIzquierda)
                teclado.KeyUp(.TeclaIzquierda)
                //print( "izquierda")
            } else if gestureRecognizer.direction == .up {
                teclado.KeyDown(.TeclaDerecha)
                teclado.KeyUp(.TeclaDerecha)
                //print( "derecha")
            }
            
        }
    }
    
    public func pixeles2Area ( _ posicion: CGPoint) -> EnumAreaTecla {
        if posicion.x < -128 && posicion.y > 150 {
            return.TeclaArriba
        } else if posicion.x > 128 && posicion.y > 150 {
            return.TeclaAbajo
        } else  if posicion.x > 118  && posicion.y < 20 {
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
                    return .AreaObjetos
                }
                
            } else {
                if posicion.x > 96 {
                    return .TeclaDerecha
                } else if posicion.x > 63 {
                    return .TeclaIzquierda
                } else {
                    return .AreaObjetos
                }
            }
        } else {
            if posicion.x < -128 && posicion.y < 20 { //zona de pruebas
                abadia.TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x02
                abadia.TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x26
                abadia.TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x69
                abadia.TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0x18

                abadia.TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036] = 0x26
                abadia.TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036] = 0x6B
                abadia.TablaCaracteristicasPersonajes_3036[0x3045 + 4 - 0x3036] = 0x18
                SetBitArray(&abadia.TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7)
                SetBitArray(&abadia.TablaObjetosPersonajes_2DEC, abadia.ObjetosGuillermo_2DEF - 0x2DEC, 6)
                abadia.GenerarNumeroEspejo_562E()
            }
            return .AreaEscenario
            
            
            
        }
    }
    
    
}
