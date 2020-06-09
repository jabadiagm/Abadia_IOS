//
//  Funciones.swift
//  Funciones
//
//  Created by javier on 02/04/2020.
//  Copyright © 2020 javier abadía. All rights reserved.
//

import Foundation

enum ErroresAbadia:Error {
    case ErrorNoEsperado
}

public func rol8(Value :Int, Shift:UInt8) -> Int {
    var Bit7 :Int
    //var Contador :Int
    var rol8:Int
    rol8 = Value
    for _ in 1...Shift {
        Bit7 = (rol8 & 0x80) >> 7
        rol8 = ((rol8 << 1) & 0xFF) | Bit7
    }
    return rol8
}

public func ror8(Value :Int, Shift:UInt8) -> Int {
    var Bit0 :Int
    //var Contador :Int
    var ror8:Int
    ror8 = Value
    if Shift > 0 {
        for _ in 1...Shift {
            Bit0 = (ror8 & 0x01) << 7
            ror8 = ((ror8 >> 1) & 0xFF) | Bit0
        }
    }
    return ror8
}

public func Leer16(_ Bytes:[UInt8], _ Posicion:Int) -> Int {
    //lee un valor de 16 bits de una cadena de bytes
    return (Int(Bytes[Posicion + 1]) << 8) + Int(Bytes[Posicion])
}

public func Leer16Inv(_ Bytes:[UInt8], _ Posicion:Int) -> Int {
    //lee un valor de 16 bits de una cadena de bytes, en dirección inversa
    return (Int(Bytes[Posicion]) << 8) + Int(Bytes[Posicion+1])
}

public func Leer16Signo(_ Bytes:[UInt8], _ Posicion:Int) -> Int {
    //lee un valor de 16 bits con signo de una cadena de bytes
    var Valor:Int
    Valor = Leer16(Bytes, Posicion)
    if Valor >= 32768 { //complemento a 2
        return Valor - 65536
    } else {
        return Valor
    }
}

public func Leer8Signo(_ Bytes:[UInt8], _ Posicion:Int) -> Int {
    //lee un valor de 16 bits con signo de una cadena de bytes
    var Valor:Int
    Valor = Int(Bytes[Posicion])
    if Valor >= 128 { //complemento a 2
        return Valor - 256
    } else {
        return Valor
    }
}

public func Escribir16(_ Bytes: inout [UInt8], _ Posicion:Int, _ Valor:Int) {
    //escribe un valor de 16 bits de una cadena de bytes
    Bytes[Posicion] = UInt8(Valor & 0xFF)
    Bytes[Posicion + 1] = UInt8((Valor & 0xFF00) >> 8)
}

public func Bytes2AsciiHex( _ Entrada: [UInt8]) -> String {
    //convierte una serie de bytes en una cadena hexadecimal
    //var Contador:Int
    var Cadena:String = ""
    let Limite=Entrada.count-1
    if Limite<=0 {
        return ""
    }
    for Contador:Int in 0..<Entrada.count {
        Cadena+=String(format: "%02X",Entrada[Contador])
        if Contador != Limite {
            Cadena+=" "
        }
    }
    return Cadena
}

public func Byte2AsciiHex(Entrada:UInt8) -> String {
    //convierte un byte en una cadena de texto con el valor hexadecimal
    return String(format: "%02X",Entrada)
}

public func Int2AsciiHex(Entrada:Int, NCaracteres:Int) -> String {
    //convierte un entero en una cadena de texto con el valor hexadecimal del número de caracteres indicado
    var Cadena:String=""
    Cadena = String(format: "%X",Entrada)
    while Cadena.count < NCaracteres {
        Cadena = "0" + Cadena
    }
    return Cadena
}

public func CargarArchivo(NombreArchivo:String, Archivo: inout [UInt8]) { //OK
    let inputStream = InputStream(fileAtPath: NombreArchivo)!
    let fileManager=FileManager.default
    var attr: [FileAttributeKey : Any]=[:]
    if !fileManager.fileExists(atPath: NombreArchivo)  {
        print("Archivo no encontrado") //archivo no encontrado
        return
    }
    do {
        attr=try fileManager.attributesOfItem(atPath: NombreArchivo)
    } catch {
        
    }
    Archivo=[UInt8](repeating: 0, count: attr[FileAttributeKey.size] as! Int)
    inputStream.open()
    inputStream.read(&Archivo, maxLength: Archivo.count)
    inputStream.close()
}

public func CargarArchivo(RutaArchivo:URL, Archivo: inout [UInt8]) { //OK
    let inputStream = InputStream(url: RutaArchivo)!
    let fileManager=FileManager.default
    var attr: [FileAttributeKey : Any]=[:]
    if !fileManager.fileExists(atPath: RutaArchivo.path)  {
        print("Archivo no encontrado") //archivo no encontrado
        return
    }
    do {
        attr=try fileManager.attributesOfItem(atPath: RutaArchivo.path)
    } catch {
        
    }
    Archivo=[UInt8](repeating: 0, count: attr[FileAttributeKey.size] as! Int)
    inputStream.open()
    inputStream.read(&Archivo, maxLength: Archivo.count)
    inputStream.close()
}


public func GuardarArchivo( _ NombreArchivo:String, _ Archivo: [UInt8]) {
    let outputStream = OutputStream(toFileAtPath: NombreArchivo, append: false)!
    outputStream.open()
    let Escritos=outputStream.write( Archivo, maxLength: Archivo.count)
    if Escritos<0 {
        print("failed:", outputStream.streamError?.localizedDescription ?? "Unknown error")
    }
    outputStream.close()
}

public func GuardarArchivo(RutaArchivo:URL, Archivo: [UInt8]) {
    let outputStream = OutputStream(url: RutaArchivo, append: false)!
    outputStream.open()
    let Escritos=outputStream.write( Archivo, maxLength: Archivo.count)
    if Escritos<0 {
        print("failed:", outputStream.streamError?.localizedDescription ?? "Unknown error")
    }
    outputStream.close()
}

/*
 uso de guardararchivo:
 
 let url = getDocumentsDirectory().appendingPathComponent("prueba.txt")
 GuardarArchivo(NombreArchivo: url.path, Archivo: array2)

 alternativa a la cración de archivos sin streams
let data = Data(bytes: array2, count: array2.count)
do {
    try data.write(to: url)
} catch {
    print ("Error")
}
 */

public func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

public func Int2ByteSigno( _ Valor:Int)  -> UInt8 {
    //pasa un entero largo de 32 bits a un byte. si el valor está fuera de límites, da un error
    //un byte sólo puede contener enteros entre 0 y 255
    if Valor < -128 || Valor > 255 {
        print ("Error no esperado en Int2ByteSigno")
        return 0
    }
    if Valor >= 0 {
        return UInt8(Valor)
    } else {
        return UInt8(256 + Valor)
    }
}

public func SignedByte2Int( _ Valor:UInt8) -> Int {
    //pasa un byte con signo entero
    if Valor < 0x80 {
        return Int(Valor)
    } else {
       return Int(Valor) - 256
    }
}

public func LeerByteInt(Valor:Int, NumeroByte:UInt8) -> UInt8 {
    //devuelve el byte indicado de un entero largo
    //el byte menos significativo es el 0
    var Resultado:Int=0
    if NumeroByte > 3  {
        return 0
    }
    switch NumeroByte {
        case 0:
            Resultado = Valor & 0xFF
        case 1:
            Resultado = (Valor & 0xFF00) >> 8
        case 2:
            Resultado = (Valor & 0xFF0000) >> 16
        case 3:
            Resultado = (Valor & (0x7F800000<<1)) >> 24
        default:
            ErrorExtraño()
    }
    return Int2ByteSigno(Resultado)
}

public func Bytes2Int(Byte0:UInt8, Byte1:UInt8) -> Int {
    //devuelve un entero largo con los dos primeros bytes indicados
    return Int(Byte1)<<8 | Int(Byte0)
}

public func FixPath(Path:String) -> String {
    //append "\" at the end of the path, if not present
    var FixPath:String=""
    if Path == "" {
        return ""
    }
    FixPath = Path
    if Path.last != "/" {
        FixPath = FixPath + "/"
    }
    return FixPath
}

public func DirFolder(Folder:URL, FileName:String, Extension:String) -> [URL] {
    //enumerate files in folder and return [URL]
    var DirFolder:[URL]=[]
    var FolderContents:[URL]=[]
    do {
        FolderContents = try FileManager.default.contentsOfDirectory(at: Folder, includingPropertiesForKeys: nil)
    } catch {
        
    }
    //files only
    for Element:URL in FolderContents {
        if !Element.hasDirectoryPath {
            DirFolder.append(Element)
        }
    }
    FolderContents=DirFolder
    DirFolder=[]
    //filter by extension
    if Extension != "" {
        FolderContents=FolderContents.filter{ $0.pathExtension == Extension}
    }
    //filter by name
    if FileName == "" {
        DirFolder=FolderContents
    } else {
        for Element:URL in FolderContents {
            let Name=Element.deletingPathExtension().lastPathComponent
            if FileName==Name {
                DirFolder.append(Element)
            }
        }
    }
    return DirFolder
}

public func CompararArchivos(archivo1:[UInt8], archivo2:[UInt8], Log: inout String,  NombreArchivo1 : String, NombreArchivo2 :String) -> Int {
    //devuelve 0 si los archivos son iguales, y 1 si son diferentes
    var CompararArchivos:Int=0
    var Limite:Int
    var MensajeFinal:String=""
    //var Contador:Int
    var Diferente:Bool=false
    var Linea:String=""
    var NombreArchivo1:String=NombreArchivo1
    var NombreArchivo2:String=NombreArchivo2
    if NombreArchivo1 == "" {
        NombreArchivo1 = "Archivo1"
    }
    if NombreArchivo2 == "" {
        NombreArchivo2 = "Archivo2"
    }
    Log = "Comparando archivos " + NombreArchivo1 + " y " + NombreArchivo2 + "\r\n"
    if archivo1.count > archivo2.count {
        Limite = archivo2.count
        MensajeFinal = NombreArchivo1 + " es mayor que " + NombreArchivo2
    } else if archivo2.count > archivo1.count {
        Limite = archivo1.count
            MensajeFinal = NombreArchivo2 + " es mayor que " + NombreArchivo1
    } else { //'igual duración
        Limite = archivo1.count
        MensajeFinal = ""
    }
    for Contador in 0..<Limite {
        if archivo1[Contador] != archivo2[Contador] {
                Diferente = true
            Linea = Int2AsciiHex(Entrada: Contador, NCaracteres: 8)
            Linea = Linea + ": "
            Linea = Linea + Byte2AsciiHex(Entrada: archivo1[Contador]) + " "
            Linea = Linea + Byte2AsciiHex(Entrada: archivo2[Contador]) + "\r\n"
            Log = Log + Linea
        }
    }
    if MensajeFinal != "" {
        Log = Log + MensajeFinal
    }
    if Diferente {
        CompararArchivos = 1
    } else {
        Log = Log + "No se han encontrado diferencias" + "\r\n"
    }
    return CompararArchivos
}

public func CompararArchivosRuta(RutaArchivo1:URL, RutaArchivo2:URL, Log: inout String) -> Int {
        //devuelve 0 si los archivos son iguales, 1 si son diferentes o inaccesibles
    var archivo1:[UInt8] = []
    var archivo2:[UInt8] = []
    var CompararArchivosRuta:Int=0
    var NombreArchivo1 : String
    var NombreArchivo2 : String
    let fileManager=FileManager.default
    if !fileManager.fileExists(atPath: RutaArchivo1.path) || !fileManager.fileExists(atPath: RutaArchivo2.path) {
        CompararArchivosRuta=1 //archivo no encontrado
        return CompararArchivosRuta
    }
    NombreArchivo1 = RutaArchivo1.lastPathComponent
    NombreArchivo2 = RutaArchivo2.lastPathComponent
    CargarArchivo(RutaArchivo: RutaArchivo1, Archivo: &archivo1)
    CargarArchivo(RutaArchivo: RutaArchivo2, Archivo: &archivo2)
    CompararArchivosRuta = CompararArchivos(archivo1: archivo1, archivo2: archivo2, Log: &Log, NombreArchivo1: NombreArchivo1, NombreArchivo2: NombreArchivo2)
    return CompararArchivosRuta
}

public func PunteroPerteneceTabla( _ Puntero:Int, _ Tabla:[UInt8], _ Origen:Int) -> Bool {
    //devuelve true si el puntero apunta a una posición de la tabla indicada
    if (Puntero - Origen) >= 0 && (Puntero - Origen) < Tabla.count {
        return true
    } else {
        return false
    }
}

public func BGR2RGB(BGR:Int) -> Int {
    //convert vb6 BGR color to RGB
    var BGR2RGB:Int=0
    var Red:Int
    var Green:Int
    var Blue:Int
    Red = (BGR & 0xFF) << 16
    Green = BGR & 0xFF00
    Blue = (BGR & 0xFF0000) >> 16
    BGR2RGB = Red | Green | Blue
    return BGR2RGB
}

public func SetBitArray( _ DataArray: inout [UInt8], _ Pointer:Int, _ NBit:Int) {
    struct Estatico {
        static let Weights:[UInt8] = [1, 2, 4, 8, 16, 32, 64, 128]
    }
    DataArray[Pointer] = DataArray[Pointer] | Estatico.Weights[NBit]
}

public func SetBit( _ Data: inout UInt8, _ NBit:Int) {
    struct Estatico {
        static let Weights:[UInt8] = [1, 2, 4, 8, 16, 32, 64, 128]
    }
    Data = Data | Estatico.Weights[NBit]
}

public func ClearBit( _ Data: inout UInt8, _ NBit:Int) {
    struct Estatico {
        static let Weights:[UInt8] = [0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F]
    }
    Data = Data & Estatico.Weights[NBit]
}

public func ClearBitArray( _ DataArray: inout [UInt8], _ Pointer:Int, _ NBit:Int) {
    struct Estatico {
        static let Weights:[UInt8] = [0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F]
    }
    DataArray[Pointer] = DataArray[Pointer] & Estatico.Weights[NBit]
}

public func LeerBitArray( _ DataArray:[UInt8], _ Pointer:Int, _ NBit:Int) -> Bool {
    struct Estatico {
        static let Weights:[UInt8] = [1, 2, 4, 8, 16, 32, 64, 128]
    }
    if (DataArray[Pointer] & Estatico.Weights[NBit]) != 0 {
        return true
    } else {
        return false
    }
}

public func LeerBitByte(_ Valor:UInt8, _ NBit:Int) -> Bool {
    struct Estatico {
        static let Weights:[UInt8] = [1, 2, 4, 8, 16, 32, 64, 128]
    }
    if (Valor & Estatico.Weights[NBit]) != 0 {
        return true
    } else {
        return false
    }
}

public func IncByteArray( _ DataArray: inout [UInt8], _ Pointer:Int) {
    if DataArray[Pointer] != 0xff {
        DataArray[Pointer] = DataArray[Pointer] + 1
    } else {
        ErrorExtraño()
    }
}

public func DecByteArray( _ DataArray: inout [UInt8], _ Pointer:Int) {
    if DataArray[Pointer] != 0x00 {
        DataArray[Pointer] = DataArray[Pointer] - 1
    } else {
        ErrorExtraño()
    }
}

public func Integer2Nibbles(Value:Int, HighNibble: inout UInt8, LowNibble: inout UInt8) {
    LowNibble = UInt8(Value & 0x000000FF)
    HighNibble = UInt8((Value & 0x0000FF00) >> 8)
}

public func Nibbles2Integer(HighNibble:UInt8, LowNibble:UInt8) -> Int {
    return (Int(HighNibble) << 8) | Int(LowNibble)
}

public func Z80Sub( _ Operando1:UInt8,  _ Operando2:UInt8)->UInt8 {
    //devuelve operando1-operando2 tomando los operandos como números
    //con signo, y devolviendo la representación de un entero
    var Z80Sub:UInt8
    var Op1:Int
    var Op2:Int
    var Res:Int
    if Operando1 < 128 {
        Op1 = Int(Operando1)
    } else {
        Op1 = Int(Operando1) - 256
    }
    if Operando2 < 128 {
        Op2 = Int(Operando2)
    } else {
        Op2 = Int(Operando2) - 256
    }
    Res = Op1 - Op2
    if Res >= 0 {
        Z80Sub = UInt8(Res & 0x000000FF)
    } else {
        Z80Sub = UInt8((Res + 256) & 0x000000FF)
    }
    return Z80Sub
}

public func Z80Add( _ Operando1:UInt8, _ Operando2:UInt8) -> UInt8 {
    //devuelve operanco1+operando2 tomando los operandos como números
    //con signo, y devolviendo la representación de un entero
    var Z80Add:UInt8
    var Op1:Int
    var Op2:Int
    var Res:Int
    if Operando1 < 128 {
        Op1 = Int(Operando1)
    } else {
        Op1 = Int(Operando1) - 256
    }
    if Operando2 < 128 {
        Op2 = Int(Operando2)
    } else {
        Op2 = Int(Operando2) - 256
    }
    Res = Op1 + Op2
    if Res >= 0 {
        Z80Add = UInt8(Res & 0x000000FF)
    } else {
        Z80Add = UInt8((Res + 256) & 0x000000FF)
    }
    return Z80Add
}

public func Z80Inc( _ Valor:UInt8) -> UInt8 {
    //incrementa un byte como lo haría el Z80
    var Z80Inc:UInt8
    var ValorInt:Int
    if Valor < 128 {
        ValorInt = Int(Valor)
    } else {
        ValorInt = Int(Valor) - 256
    }
    ValorInt = ValorInt + 1
    if ValorInt >= 0 {
        Z80Inc = UInt8(ValorInt & 0x000000FF)
    } else {
        Z80Inc = UInt8((ValorInt + 256) & 0x000000FF)
    }
    return Z80Inc
}

public func Z80Dec( _ Valor:UInt8) -> UInt8 {
    //decrementa un byte comolo haría el Z80
    var Z80Dec:UInt8
    if Valor == 0 {
        Z80Dec = 0xFF
    } else {
        Z80Dec = Valor - 1
    }
    return Z80Dec
}

public func Z80Neg( _ Valor:UInt8) -> UInt8 {
    //devuelve el negativo del número. si es 0, devuelve 0
    var Z80Neg:UInt8
    if Valor == 0 {
        Z80Neg = 0
    } else {
        Z80Neg = (Valor ^ 0xFF) + 1
    }
    return Z80Neg
}

func ErrorExtraño() {
    
}
