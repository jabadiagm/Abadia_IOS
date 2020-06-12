//
//  DoubleBuffer.swift
//  Abadia
//
//  Created by javier on 02/04/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation

class DoubleBuffer {
    public var Buffer:[Float]
    public var Pointer:Int
    private var BufferSize:Int
    public var IsFull:Bool
    public var Error:Bool
    
    init (BufferSize:Int) {
        self.BufferSize = BufferSize
        Buffer=[Float](repeating:0, count: 2 * BufferSize)
        Pointer=0
        IsFull=false
        Error = false
    }
    
    func Append(Value:Float) {
        if IsFull { return }
        if Pointer>=Buffer.count {
            print("777")
        }
        Buffer[Pointer] = Value
        Pointer = Pointer + 1
        if Pointer == Buffer.count { IsFull = true }
    }
    
    func Clear() {
        //var Counter:Int
        for Counter:Int in 0..<Buffer.count {
            Buffer[Counter] = 0
        }
        Pointer = 0
        IsFull = false
    }
    
    func Shift() {
        //var Counter:Int
        for Counter:Int in 0..<Buffer.count {
            if Counter < (Pointer - BufferSize) {
                Buffer[Counter] = Buffer[Counter + BufferSize]
            } else {
                Buffer[Counter] = 0
            }
        }
        Pointer = Pointer - BufferSize
        if Pointer<0 {
            Pointer=0
            Error = true
            print("666")
        }
        IsFull = false
    }
    
    func GetFreeSpace() -> Int {
        //return the number of bytes to get full
        return 2 * BufferSize - Pointer
    }
    
    
}
