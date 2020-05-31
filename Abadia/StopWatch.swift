//
//  StopWatch.swift
//  Vacio2
//
//  Created by javier on 14/03/2020.
//  Copyright © 2020 javier. All rights reserved.
//

import Foundation

class StopWatch
{
    var StartTime:DispatchTime
    var StopTime:DispatchTime
    var Active:Bool
    var ValidData:Bool //
    //var Start:
    init() {
        StartTime=DispatchTime(uptimeNanoseconds: 0)
        StopTime=DispatchTime(uptimeNanoseconds: 0)
        Active=false
        ValidData=false
    }
    
    func Start() {
        StartTime=DispatchTime.now()
        Active=true
        ValidData=true
    }
    
    func Stop() {
        if !Active {
            return
        }
        if ValidData {
            StopTime=DispatchTime.now()
            Active=false
        }
    }
    
    func EllapsedMicroseconds() -> UInt64 {
        var MeasurementTime:DispatchTime
        var ElapsedTime:UInt64
        if !ValidData {
            return 0
        }
        if Active {
            MeasurementTime=DispatchTime.now()
        } else {
            MeasurementTime=StopTime
        }
        ElapsedTime=MeasurementTime.uptimeNanoseconds-StartTime.uptimeNanoseconds
        return ElapsedTime/1000
    }
    
}
