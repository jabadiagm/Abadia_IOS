//
//  Teclado.swift
//  Funciones
//
//  Created by javier on 02/04/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation

public enum EnumAreaTecla:Int {
    case TeclaArriba = 0
    case TeclaAbajo = 1
    case TeclaIzquierda = 2
    case TeclaDerecha = 3
    case TeclaEspacio = 4
    case TeclaTabulador = 5
    case TeclaControl = 6
    case TeclaMayusculas = 7
    case TeclaEnter = 8
    case TeclaSuprimir = 9
    case TeclaEscape = 10
    case TeclaPunto = 11
    case TeclaS = 12
    case TeclaN = 13
    case TeclaQ = 14
    case TeclaR = 15
    case AreaEscenario = 16
    case AreaTextosIzquierda = 17
    case AreaTextosDerecha = 18
    case AreaDepuracion = 19
    case AreaObjetos = 20
}

class Teclado {
    let NumeroTeclas:Int = 21
    lazy var TeclasNivel=[Bool](repeating: false, count: NumeroTeclas) //interesa su estado
    lazy var TeclasFlanco=[Bool](repeating: false, count: NumeroTeclas) //interesa su pulsación
    
    func Inicializar() {
        //borra el estado de las teclas
        //var Contador:Int
        for Contador in 0..<TeclasNivel.count {
            TeclasNivel[Contador] = false
            TeclasFlanco[Contador] = false
        }
    }
    
    func KeyDown( _ Tecla: EnumAreaTecla) {
        TeclasNivel[Tecla.rawValue] = true
        TeclasFlanco[Tecla.rawValue] = true
    }
    
    func KeyUp( _ Tecla: EnumAreaTecla) {
        TeclasNivel[Tecla.rawValue] = false
    }
    
    func TeclaPulsadaNivel ( _ Tecla:EnumAreaTecla) -> Bool {
        //devuelve true si una tecla se mantiene pulsada
        var TeclaPulsadaNivel:Bool
        TeclaPulsadaNivel = TeclasNivel[Tecla.rawValue]
        //TeclasNivel(Tecla) = False '### depuración
        return TeclaPulsadaNivel
    }
    
    func TeclaPulsadaFlanco( _ Tecla:EnumAreaTecla) -> Bool {
        //devuelve true si una tecla ha sido pulsada y no se había llamado todavía a esta función.
        //si se vuelve a llamar, aunque la tecla siga físicamente pulsada, se devolverá false
        var TeclaPulsadaFlanco:Bool
        TeclaPulsadaFlanco = TeclasFlanco[Tecla.rawValue] //devuelve el estado del flanco
        TeclasFlanco[Tecla.rawValue] = false //y lo borra si estaba a true
        return TeclaPulsadaFlanco
    }
    
    func ToquesTerminados () {
        //notifica que todos los toques en la pantalla han terminado o se han cancelado (dedo sale de la pantalla sin levantar)
        //borra el nivel y el flanco sólo de las áreas
        //var Contador:Int
        for Contador in 16..<TeclasNivel.count {
            TeclasNivel[Contador] = false
            TeclasFlanco[Contador] = false
        }
        
    }
    
}
