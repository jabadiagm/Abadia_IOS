//
//  Senoidal.swift
//  Abadia
//
//  Created by javier on 18/04/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation

class Senoidal: Reproducible {

    
    var Amplitud:Float=0
    var Intervalo:Float=0
    var Frecuencia:Float=0
    var Tiempo:Float=0
    let PI:Float = 3.1415926536
    var TiempoLimite:Float=0
      
    func DefinirSenoidal(Ampli: Float, Interv:Float, Frec:Float) {
        Amplitud = Ampli
        Intervalo = Interv
        Frecuencia = Frec
        Tiempo = 0
        //tiempo para 1000 ondas
        TiempoLimite=2000/Frec
    }
    
    func Senoidal8() -> UInt8 {
        var Valor: Float
        Valor = Amplitud * sinf(2 * PI * Frecuencia * Tiempo) + 128
        if Valor > 255 { Valor = 255 }
        if Valor < 0  { Valor = 0 }
        Tiempo = Tiempo + Intervalo
        return UInt8(Valor)
    }
    
    func SenoidalF() -> Float {
        if Tiempo >= TiempoLimite {
            Tiempo -= TiempoLimite
        }
        let Valor = Amplitud * sinf(2 * PI * Frecuencia * Tiempo)
        Tiempo = Tiempo + Intervalo
        return Valor
    }
 
    func Reproducir() -> Float {
        return SenoidalF()
    }
    
}
