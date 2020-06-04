//
//  Abadia.swift
//  Abadia
//
//  Created by javier abadía on 07/10/2017.
//  Copyright © 2017 javier abadía. All rights reserved.
//

import UIKit
import Funciones

class Abadia {
    //objetos exteriores necesarios
    var viewController: ViewController?
    var cga:CGA?
    var ay8910:AY8912?
    var teclado:Teclado?
    
    //variables públicas del módulo
    public var FPS:UInt32=0

    //variables y objetos privados del módulo
    private let Reloj:StopWatch=StopWatch()
    private let RelojFPS:StopWatch=StopWatch()
    private var SiguienteTickTiempoms:Int32 = 100
    private var SiguienteTickNombreFuncion:String = "Iniciar"
    private var CancelarTareaSonido:Bool=false
    private var TareaSonidoActiva:Bool=false
    private var CambiarPaletaColores:UInt8 = 0xFF
    private var Parado:Bool=false
    private var Thread1:Thread?
    private var PunteroPantallaGlobal :Int=0 //posición actual dentro de la pantalla mientras se procesa
    private var PunteroPilaCamino :Int=0
    private var InvertirDireccionesGeneracionBloques :Bool=false
    private var Pila=[Int](repeating: 0, count: 100)
    private var PunteroPila :Int=0
    
    //tablas del juego
    public var TablaBugDejarObjetos_0000=[UInt8](repeating: 0, count: 0x100) //primeros 256 bytes del juego, usados por error en la rutina de dejar objetos
    public var TablaBufferAlturas_01C0=[UInt8](repeating: 0, count: 0x240) //576 bytes (24x24) = (4 + 16 + 4)x2  RAM
    public var TablaPosicionesAlternativas_0593:[UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF] //buffer de posiciones alternativas. Cada posición ocupa 3 bytes: x, y, z+orientación. sin byte final  RAM
    public var TablaConexionesHabitaciones_05CD=[UInt8](repeating: 0, count: 0x130) //tablas con las conexiones de las habitaciones de las plantas
    public var TablaDestinos_0C8A=[UInt8](repeating: 0, count: 0x10) //tabla para marcar las posiciones a las que debe ir el personaje para cambiar de habitación ROM
    public var TablaDatosSonidos_0F96=[UInt8](repeating: 0, count: 0x68) //variables y tablas relacionadas con los sonidos
    public var TablaTonosNotasVoces_1388=[UInt8](repeating: 0, count: 0x01E2) //1388-1569. tono base de las notas para las voces, envolventes y cambios de volumen para las voces, datos de iniciación de la voz para el canal 3. RAM
    private var TablaBloquesPantallas_156D=[UInt8](repeating: 0, count: 0xc0) //ROM
    //Dim DatosTilesBloques_1693(&H92) As Byte
    private var TablaCaracteristicasMaterial_1693=[UInt8](repeating: 0, count: 0x925)
    private var VariablesBloques_1FCD=[UInt8](repeating: 0, count: 0x13)
    private var TablaRutinasConstruccionBloques_1FE0=[UInt8](repeating: 0, count: 0x38) //no se usa
    private var TablaHabitaciones_2255=[UInt8](repeating: 0, count: 0x100) //(realmente empieza en 0x2265 porque en Y = 0 no hay nada)
    private var TablaAvancePersonaje4Tiles_284D=[UInt8](repeating: 0, count: 32)
    private var TablaAvancePersonaje1Tile_286D=[UInt8](repeating: 0, count: 32)
    private var TablaPunterosPersonajes_2BAE=[UInt8](repeating: 0, count: 0x3e) //tabla con datos para mover los personajes
    public var BufferAuxiliar_2D68:[UInt8] = [0x01, 0x23, 0x3E, 0x20, 0x12, 0x13, 0x78, 0x04, 0xB9, 0x38] //buffer auxiliar con copia de los datos del personaje
    public var TablaVariablesEspejo_2D8D=[UInt8](repeating: 0, count: 10) //variables auxiliares para hacer el efecto espejo
    private var TablaVariablesAuxiliares_2D8D=[UInt8](repeating: 0, count: 0x38) //2d8d-2dd8. variables auxiliares de algunas rutinas
    public var BufferAuxiliar_2DC5=[Int16](repeating: 0, count: 0x10) //buffer auxiliar para el cálculo de las alturas a los movimientos usado en 27cb
    private var TablaPermisosPuertas_2DD9=[UInt8](repeating: 0, count: 19) //copiado en 0x122-0x131. puertas a las que pueden entrar los personajes
    private var CopiaTablaPermisosPuertas_2DD9=[UInt8](repeating: 0, count: 19)
    public var TablaObjetosPersonajes_2DEC=[UInt8](repeating: 0, count: 0x2b) //2dec-2e16. RAM. copiado en 0x132-0x154. objetos de los personajes
    private var CopiaTablaObjetosPersonajes_2DEC=[UInt8](repeating: 0, count: 0x2b)
    public var TablaSprites_2E17=[UInt8](repeating: 0, count: 0x1CD) //2e17-2fe3    .sprites de los personajes, puertas y objetos
    private var TablaDatosPuertas_2FE4=[UInt8](repeating: 0, count: 0x24) //2fe4-3007. datos de las puertas del juego. 5 bytes por entrada
    private var CopiaTablaDatosPuertas_2FE4=[UInt8](repeating: 0, count: 0x24)
    public var TablaPosicionObjetos_3008=[UInt8](repeating: 0, count: 0x2E) //posición de los objetos del juego 5 bytes por entrada
    private var CopiaTablaPosicionObjetos_3008=[UInt8](repeating: 0, count: 0x2E)
    public var TablaCaracteristicasPersonajes_3036=[UInt8](repeating: 0, count: 0x5A)
    private var TablaPunterosCarasMonjes_3097=[UInt8](repeating: 0, count: 0x8)
    private var TablaDesplazamientoAnimacion_309F=[UInt8](repeating: 0, count: 0x100) //tabla para el cálculo del desplazamiento según la animación de una entidad del juego
    private var TablaAnimacionPersonajes_319F=[UInt8](repeating: 0, count: 0x60)
    private var DatosAlturaEspejoCerrado_34DB=[UInt8](repeating: 0, count: 5) //34db-34df. datos de altura si el espejo está cerrado
    public var TablaSimbolos_38E2:[UInt8] = [0xC0, 0xBF, 0xBB, 0xBD, 0xBC]
    private var TablaAccesoHabitaciones_3C67=[UInt8](repeating: 0, count: 0x1E)
    public var TablaVariablesLogica_3C85=[UInt8](repeating: 0, count: 0x98) //3c85-3d1c
    private var TablaPunterosVariablesScript_3D1D=[UInt8](repeating: 0, count: 0x82) //tabla de asociación de constantes a direcciones de memoria importantes para el programa (usado por el sistema de script) ROM
    public var TablaDistanciaPersonajes_3D9F=[UInt8](repeating: 0, count: 0x10) //tabla de valores para el computo de la distancia entre personajes, indexada según la orientación del personaje.
    private var DatosHabitaciones_4000=[UInt8](repeating: 0, count: 0x232A)
    public var TablaComandos_440C=[UInt8](repeating: 0, count: 0x1D) //tabla de longitudes de comandos según la orientación+tabla de comandos para girar+tabla de comandos si el personaje sube en altura+tabla de comandos si el personaje baja en altura+tabla de comandos si el personaje no cambia de altura
    public var TablaOrientacionesAdsoGuillermo_461F=[UInt8](repeating: 0, count: 0x20) //tabla de orientaciones a probar para moverse en un determinado sentido
    private var TablaPunterosTrajesMonjes_48C8=[UInt8](repeating: 0, count: 0x20)
    private var TablaPatronRellenoLuz_48E8=[UInt8](repeating: 0, count: 0x20)
    private var TablaAlturasPantallas_4A00=[UInt8](repeating: 0, count: 0xA20)
    private var TablaEtapasDia_4F7A=[UInt8](repeating: 0, count: 0x73) //4F7A-4FEC. tabla de duración de las etapas del día para cada día y periodo del día 4FA7:tabla usada para rellenar el número del día en el marcador 4FBC:tabla de los nombres de los momentos del día
    public var TablaNotasOctavasFrases_5659=[UInt8](repeating: 0, count: 0x38) //tabla de octavas y notas para las frases del juego. ROM
    private var DatosMarcador_6328=[UInt8](repeating: 0, count: 0x800) //datos del marcador (de 0x6328 a 0x6b27)
    private var PunterosCaracteresPergamino_680C=[UInt8](repeating: 0, count: 0xBA)
    private var DatosCaracteresPergamino_6947=[UInt8](repeating: 0, count: 0x9B9)
    private var TilesAbadia_6D00=[UInt8](repeating: 0, count: 0x2000)
    private var TextoPergaminoPresentacion_7300=[UInt8](repeating: 0, count: 0x58A)
    private var DatosGraficosPergamino_788A=[UInt8](repeating: 0, count: 0x600)
    private var TablaMusicaPergamino_8000=[UInt8](repeating: 0, count: 0x300)
    public var TablaDatosPergaminoFinal_8000=[UInt8](repeating: 0, count: 0x14D8) //música y texto del pergamino final
    private var TablaRellenoBugTiles_8D00=[UInt8](repeating: 0, count: 0x80)
    private var BufferTiles_8D80=[UInt8](repeating: 0, count: 0x780)
    private var BufferSprites_9500=[UInt8](repeating: 0, count: 0x800)
    public var TablaBufferAlturas_96F4=[UInt8](repeating: 0, count: 0x240) //576 bytes (24x24) = (4 + 16 + 4)x2  RAM
    private var TablasAndOr_9D00=[UInt8](repeating: 0, count: 0x400)
    private var TablaFlipX_A100=[UInt8](repeating: 0, count: 0x100)
    public var BufferComandosMonjes_A200=[UInt8](repeating: 0, count: 0x100) //buffer de comandos de los movimientos de los monjes y adso
    private var TablaGraficosObjetos_A300=[UInt8](repeating: 0, count: 0x859) //gráficos de guillermo, adso y las puertas
    private var DatosMonjes_AB59=[UInt8](repeating: 0, count: 0x8A7) //gráficos de los movimientos de los monjes ab59-ae2d normal, ae2e-b102 flipx, 0xb103-0xb3ff caras y trajes
    //Dim TablaCarasTrajesMonjes_B103(&H2FC) As Byte 'caras y trajes de los monjes
    public var TablaCaracteresPalabrasFrases_B400=[UInt8](repeating: 0, count: 0x0C00) //ROM b400-bfff
    private var TablaPresentacion_C000=[UInt8](repeating: 0, count: 0x3FD0) //pantalla de presentación del juego con el monje
    private var PantallaCGA=[UInt8](repeating: 0, count: 0x4000)

    //variables del juego
    public var  PunteroAlternativaActual_05A3:Int=0 //puntero a la alternativa que está probando buscando caminos
    private var ContadorAnimacionGuillermo_0990:UInt8=0 //contador de la animación de guillermo ###pendiente: quitar? sólo se usa en 098a
    private var PintarPantalla_0DFD:Bool=false //usada en las rutinas de las puertas indicando que pinta la pantalla
    private var RedibujarPuerta_0DFF:Bool=false //indica que se redibuje el sprite
    private var TempoMusica_1086:UInt8=0
    public var HabitacionOscura_156C:Bool=false //lee si es una habitación iluminada
    public var PunteroPantallaActual_156A:Int=0 //dirección de los datos de inicio de la pantalla actual
    private var PunteroPlantaActual_23EF:Int=0x2255 //dirección del mapa de la planta
    private var OrientacionPantalla_2481:UInt8=0
    private var VelocidadPasosGuillermo_2618:UInt8=0
    public var MinimaPosicionYVisible_279D:UInt8=0 //mínima posición y visible en pantalla
    public var MinimaPosicionXVisible_27A9:UInt8=0 //mínima posición x visible en pantalla
    public var MinimaAlturaVisible_27BA:UInt8=0 //mínima altura visible en pantalla
    private var EstadoGuillermo_288F:UInt8=0
    private var AjustePosicionYSpriteGuillermo_28B1:UInt8=0
    public var PunteroRutinaFlipPersonaje_2A59:Int=0 //rutina a la que llamar si hay que flipear los gráficos
    public var PunteroTablaAnimacionesPersonaje_2A84:Int=0 //dirección de la tabla de animaciones para el personaje
    private var LimiteInferiorVisibleX_2AE1:UInt8=0 //limite inferior visible de X
    private var LimiteInferiorVisibleY_2AEB:UInt8=0 //limite inferior visible de y
    private var AlturaBasePlantaActual_2AF9:UInt8=0 //altura base de la planta
    private var RutinaCambioCoordenadas_2B01:Int=0 //rutina que cambia el sistema de coordenadas dependiendo de la orientación de la pantalla
    private var ModificarPosicionSpritePantalla_2B2F:Bool=false //true para modificar la posición del sprite en pantalla dentro de 0x2ADD
    private var ContadorInterrupcion_2D4B:UInt8=0 //contador que se incrementa en la interrupción
    //datos del personaje al que sigue la cámara
    public var PosicionXPersonajeActual_2D75:UInt8=0 //posición en x del personaje que se muestra en pantalla
    public var PosicionYPersonajeActual_2D76:UInt8=0 //posición en y del personaje que se muestra en pantalla
    public var PosicionZPersonajeActual_2D77:UInt8=0 //posición en z del personaje que se muestra en pantalla
    public var PuertasFlipeadas_2D78:Bool=true //indica si se flipearon los gráficos de las puertas
    private var Obsequium_2D7F:UInt8=0x1F //energía (obsequium)
    private var NumeroDia_2D80:UInt8=1 //número de día (del 1 al 7)
    private var MomentoDia_2D81:UInt8=4 //momento del día 0=noche, 1=prima,2=tercia,4=nona,5=vísperas,6=completas
    private var PunteroProximaHoraDia_2D82:Int=0x4FBC //puntero a la próxima hora del día
    private var PunteroTablaDesplazamientoAnimacion_2D84:Int=0x309F //dirección de la tabla para el cálculo del desplazamiento según la animación de una entidad del juego para la orientación de la pantalla actual
    public var TiempoRestanteMomentoDia_2D86:Int=0x0DAC //cantidad de tiempo a esperar para que avance el momento del día (siempre y cuando sea distinto de cero)
    private var PunteroDatosPersonajeActual_2D88:Int = 0x3036 //puntero a los datos del personaje actual que se sigue la cámara
    public var PunteroBufferAlturas_2D8A :Int = 0x01C0 //puntero al buffer de alturas de la pantalla actual (buffer de 576 (24*24) bytes)
    private var HabitacionEspejoCerrada_2D8C :Bool=false //si vale true indica que no se ha abierto el espejo
    public var PunteroCaracteresPantalla_2D97 :Int=0 //dirección para poner caracteres en pantalla
    public var CaracteresPendientesFrase_2D9B :UInt8=0 //caracteres que quedan por decir en la frase actual
    public var PunteroPalabraMarcador_2D9C :Int=0 //dirección al texto que se está poniendo en el marcador
    public var PunteroFraseActual_2D9E :Int=0 //dirección de los datos de la frase que está siendo reproducida
    public var PalabraTerminada_2DA0 :Bool=false //indica que ha terminado la palabra
    public var ReproduciendoFrase_2DA1 :Bool=false //indica si está reproduciendo una frase
    public var ReproduciendoFrase_2DA2 :Bool=false //indica si está reproduciendo una frase
    private var ScrollCambioMomentoDia_2DA5 :UInt8=0 //posiciones para realizar el scroll del cambio del momento del día
    private var CaminoEncontrado_2DA9 :Bool=false //indica que  se ha encontrado un camino en este paso por el bucle principal
    public var ContadorMovimientosFrustrados_2DAA :UInt8=0
    private var PuertaRequiereFlip_2DAF :Bool=false //si la puerta necesita gráficos flipeados o no
    public var PosicionOrigen_2DB2 :Int=0 //posición de origen durante el cálculo de caminos
    public var PosicionDestino_2DB4 :Int=0 //posición de destino durante el cálculo de caminos
    public var ResultadoBusqueda_2DB6 :UInt8=0
    private var CambioPantalla_2DB8 :Bool=false //indica que ha habido un cambio de pantalla
    public var AlturaBasePlantaActual_2DBA :UInt8=0 //altura base de la planta en la que está el personaje de la rejilla ###en 2af9 hay otra
    private var NumeroRomanoHabitacionEspejo_2DBC :UInt8=0 //si es != 0, contiene el número romano generado para el enigma de la habitación del espejo
    private var NumeroPantallaActual_2DBD :UInt8=0 //pantalla del personaje al que sigue la cámara
    public var Bonus1_2DBE :Int=0 //bonus conseguidos
    public var Bonus2_2DBF :Int=0 //bonus conseguidos
    private var MovimientoRealizado_2DC1 :Bool=false //indica que ha habido movimiento
    private var PunteroDatosAlturaHabitacionEspejo_34D9 :Int=0
    private var PunteroHabitacionEspejo_34E0 :Int = 0
    //3c85-3d1c: variables usadas por la lógica
    public let ObjetosGuillermo_2DEF:Int = 0x2DEF //apunta a TablaObjetosPersonajes_2DEC
    private let LamparaAdso_2DF3 = 0x2DF3 //apunta a TablaObjetosPersonajes_2DEC. indica si adso tiene la lámpara
    public let ObjetosAdso_2DF6 = 0x2DF6 //apunta a TablaObjetosPersonajes_2DEC
    public let ObjetosMalaquias_2DFA = 0x2DFA
    private let ObjetosMalaquias_2DFD = 0x2DFD //apunta a TablaObjetosPersonajes_2DEC
    private let MascaraObjetosMalaquias_2DFF = 0x2DFF //apunta a TablaObjetosPersonajes_2DEC. máscara con los objetos que puede coger malaquías
    public let ObjetosAbad_2E04 = 0x2E04 //apunta a TablaObjetosPersonajes_2DEC
    private let MascaraObjetosAbad_2E06 = 0x2E06 //apunta a TablaObjetosPersonajes_2DEC
    private let ObjetosBerengario_2E0B = 0x2E0B //apunta a TablaObjetosPersonajes_2DEC
    private let MascaraObjetosBerengarioBernardo_2E0D = 0x2E0D //apunta a TablaObjetosPersonajes_2DEC. máscara con los objetos que puede coger berengario/bernardo gui
    private let ObjetosJorge_2E13 = 0x2E12 //apunta a TablaObjetosPersonajes_2DEC
    private let Puerta1_2FFE = 0x2FFE //apunta a TablaDatosPuertas_2FE4. número y estado de la puerta 1 que cierra el paso al ala izquierda de la abadía
    private let Puerta2_3003 = 0x3003 //apunta a TablaDatosPuertas_2FE4. número y estado de la puerta 2 que cierra el paso al ala izquierda de la abadía
    private let ContadorLeyendoLibroSinGuantes_3C85 = 0x3C85 //contador del tiempo que está leyendo el libro sin guantes
    private let TiempoUsoLampara_3C87 = 0x3C87 //contador de uso de la lámpara
    private let LamparaEncendida_3C8B = 0x3C8B //indica que la lámpara se está usando
    private let NocheAcabandose_3C8C = 0x3C8C //si se está acabando la noche, se pone a 1. En otro caso, se pone a 0
    private let EstadoLampara_3C8D = 0x3C8D
    private let ContadorTiempoOscuras_3C8E = 0x3C8E //contador del tiempo que pueden ir a oscuras
    private let PersonajeSeguidoPorCamara_3C8F = 0x3C8F //personaje al que sigue la cámara
    private let EstadoPergamino_3C90 = 0x3C90 //1:indica que el pergamino lo tiene el abad en su habitación o está detrás de la habitación del espejo. 0:si guillermo tiene el pergamino
    private let LamparaEnCocina_3C91 = 0x3C91
    public let PersonajeSeguidoPorCamaraReposo_3C92 = 0x3C92 //personaje al que sigue la cámara si se está sin pulsar las teclas un rato
    private let ContadorReposo_3C93 = 0x3C93 //contador que se incrementa si no pulsamos los cursores
    private let BerengarioChivato_3C94 = 0x3C94 //indica que berengario le ha dicho al abad que guillermo ha cogido el pergamino
    private let MomentoDiaUltimasAcciones_3C95 = 0x3C95 //indica el momento del día de las últimas acciones ejecutadas
    public let MonjesListos_3C96 = 0x3C96 //indica si están listos para empezar la misa/la comida
    private let GuillermoMuerto_3C97 = 0x3C97 //1 si guillermo está muerto
    private let Contador_3C98 = 0x3C98 //contador para usos varios
    private let ContadorRespuestaSN_3C99 = 0x3C99 //contador del tiempo de respuesta de guillermo a la pregunta de adso de dormir
    private let AvanzarMomentoDia_3C9A = 0x3C9A //indica si hay que avanzar el momento del día
    private let GuillermoBienColocado_3C9B = 0x3C9B //indica si guillermo está en su sitio en el refectorio o en misa
    private let PersonajeNoquiereMoverse_3C9C = 0x3C9C //el personaje no tiene que ir a ninguna parte
    private let ValorAleatorio_3C9D = 0x3C9D //valor aleatorio obtenido de los movimientos de adso
    private let ContadorGuillermoDesobedeciendo_3C9E = 0x3C9E //cuanto tiempo está guillermo en el scriptorium sin obedecer
    private let JorgeOBernardoActivo_3CA1 = 0x3CA1 //indica que jorge o bernardo gui están activos para la rutina de pensar de berengario
    private let MalaquiasMuriendose_3CA2 = 0x3CA2 //indica si malaquías está muerto o muriéndose
    private let JorgeActivo_3CA3 = 0x3CA3 //indica que jorge está activo para la rutina de pensar de severino
    private let GuillermoAvisadoLibro_3CA4 = 0x3CA4 //indica que Severino ha avisado a Guillermo de la presencia del libro, o que guillermo ha perdido la oportunidad por no estar el quinto día en el ala izquierda de la abadía
    private let EstadosVarios_3CA5 = 0x3CA5 //bit7: berengario no ha llegado a su puesto de trabajo. bit6:malaquías ofrece visita scriptorium. bit4:berengario ha dicho que aquí trabajan los mejores copistas de occidente.bit 3: berengario ha enseñado el sitio de venancio. bit2: severino se ha presentado. bit1: severino va a su celda.bit0: el abad ha sido advertido de que guillermo ha cogido el pergamino
    private let PuertasAbribles_3CA6 = 0x3CA6 //máscara para las puertas donde cada bit indica que puerta se comprueba si se abre
    private let InvestigacionNoTerminada_3CA7 = 0x3CA7 //si es 0, indica que se ha completado la investigación
    private let DondeEstaMalaquias_3CA8 = 0x3CA8 //a dónde ha llegado malaquías
    private let EstadoMalaquias_3CA9 = 0x3CA9 //estado de malaquías
    private let DondeVaMalaquias_3CAA = 0x3CAA //a dónde va malaquías
    public let DondeEstaAbad_3CC6:Int = 0x3CC6 //a dónde ha llegado el abad
    private let EstadoAbad_3CC7 = 0x3CC7 //estado del abad
    private let DondeVaAbad_3CC8 = 0x3CC8 //a dónde va el abad
    private let DondeEsta_Berengario_3CE7 = 0x3CE7 //a donde ha llegado berengario
    private let EstadoBerengario_3CE8 = 0x3CE8 //estado de berengario
    private let DondeVa_Berengario_3CE9 = 0x3CE9 //a dónde va berengario
    private let DondeEstaSeverino_3CFF = 0x3CFF //a dónde ha llegado severino
    private let EstadoSeverino_3D00 = 0x3D00 //estado de severino
    private let DondeVaSeverino_3D01 = 0x3D01 //a dónde va severino
    private let DondeEstaAdso_3D11 = 0x3D11 //a dónde ha llegado adso
    private let EstadoAdso_3D12 = 0x3D12 //estado de adso
    private let DondeVaAdso_3D13 = 0x3D13 //a dónde va adso
    public var  NumeroFrase_3F0E :UInt8=0 //frase dependiente del estado del personaje
    private var MalaquiasAscendiendo_4384 :Bool=false //indica que malaquías está ascendiendo mientras se está muriendo
    public var  PunteroTablaConexiones_440A :Int = 0x05CD //dirección de la tabla de conexiones de la planta en la que está el personaje
    private var SpriteLuzAdsoX_4B89 :UInt8=0 //posición x del sprite de adso dentro del tile
    private var SpriteLuzAdsoX_4BB5 :UInt8=0 //4 - (posición x del sprite de adso & 0x03)
    private var SpriteLuzTipoRelleno_4B6B :UInt8=0 //bytes a rellenar (tile/ tile y medio)
    private var SpriteLuzTipoRelleno_4BD1 :UInt8=0 //bytes a rellenar (tile y medio / tile)
    private var SpriteLuzFlip_4BA0 :Bool=false //true si los gráficos de adso están flipeados
    private var SpritesPilaProcesados_4D85 :Bool=false //false si no ha terminado de procesar los sprites de la pila. true: limpia el bit 7 de (ix+0) del buffer de tiles (si es una posición válida del buffer)
    public var AlturaPersonajeCoger_5167 :UInt8=0 //altura del personaje que coge un objeto
    public var PosicionXPersonajeCoger_516E :UInt8=0 //posición x del personaje que coge un objeto + 2*desplazamiento en x según orientación
    public var PosicionYPersonajeCoger_5173 :UInt8=0 //posición y del personaje que coge un objeto + 2*desplazamiento en y según orientación
    public var PunteroEspejo_5483 :Int=0 //puntero a la tabla de variables del espejo
    private var PosicionPergaminoY_680A :Int=0
    private var PosicionPergaminoX_680B :Int=0

    func Init(cga: CGA, viewController: ViewController, ay8910: AY8912, teclado:Teclado) {
        //define los objetos necesarios
        self.cga=cga
        self.viewController=viewController
        self.ay8910=ay8910
        self.teclado=teclado
    }
    
    public func CargarTablaArchivo(_ Archivo: inout [UInt8],_ Tabla: inout [UInt8],_ Puntero:Int) { //OK
        //rellena la tabla con los datos del archivo desde la posición indicada
        //Dim Contador As Integer
        for Contador:Int in 0..<Tabla.count {
            Tabla[Contador] = Archivo[Puntero + Contador]
        }
    }
    
    public func CargarArchivo(NombreArchivo:String, Archivo: inout [UInt8]) { //OK
        let inputStream = InputStream(fileAtPath: NombreArchivo)!
        inputStream.open()
        inputStream.read(&Archivo, maxLength: Archivo.count)
        inputStream.close()
    }
    
    public func CargarDatos() {
        var Ruta:String=""
        var Abadia0=[UInt8](repeating: 0, count: 16384)
        var Abadia1=[UInt8](repeating: 0, count: 16384)
        var Abadia2=[UInt8](repeating: 0, count: 16384)
        var Abadia3=[UInt8](repeating: 0, count: 16384)
        var Abadia7=[UInt8](repeating: 0, count: 16384)
        var Abadia8=[UInt8](repeating: 0, count: 16384)
        var BugDejarObjeto=[UInt8](repeating: 0, count: 256)

        //BugDejarObjeto.bin
        Ruta=Bundle.main.path(forResource: "BugDejarObjeto", ofType: "bin")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &BugDejarObjeto)
        CargarTablaArchivo(&BugDejarObjeto, &TablaBugDejarObjetos_0000, 0x0000)
        
        //abadia0.bin
        Ruta=Bundle.main.path(forResource: "ABADIA0", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia0)
        CargarTablaArchivo(&Abadia0, &TablaPresentacion_C000, 0)
        
        //abadia1.bin
        Ruta=Bundle.main.path(forResource: "ABADIA1", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia1)
        CargarTablaArchivo(&Abadia1, &TablaConexionesHabitaciones_05CD, 0x05CD)
        CargarTablaArchivo(&Abadia1, &TablaDestinos_0C8A, 0x0C8A)
        CargarTablaArchivo(&Abadia1, &TablaDatosSonidos_0F96, 0x0F96)
        CargarTablaArchivo(&Abadia1, &TablaTonosNotasVoces_1388, 0x1388)
        CargarTablaArchivo(&Abadia1, &TablaBloquesPantallas_156D, 0x156D)
        CargarTablaArchivo(&Abadia1, &TablaRutinasConstruccionBloques_1FE0, 0x1FE0)
        //CargarTablaArchivo ( Archivo, DatosTilesBloques_1693, &H1693
        CargarTablaArchivo(&Abadia1, &TablaCaracteristicasMaterial_1693, 0x1693)
        CargarTablaArchivo(&Abadia1, &TablaHabitaciones_2255, 0x2255)
        CargarTablaArchivo(&Abadia1, &TablaAvancePersonaje4Tiles_284D, 0x284D)
        CargarTablaArchivo(&Abadia1, &TablaAvancePersonaje1Tile_286D, 0x286D)
        CargarTablaArchivo(&Abadia1, &TablaPunterosPersonajes_2BAE, 0x2BAE)
        CargarTablaArchivo(&Abadia1, &TablaVariablesAuxiliares_2D8D, 0x2D8D)
        CargarTablaArchivo(&Abadia1, &TablaPermisosPuertas_2DD9, 0x2DD9)
        CargarTablaArchivo(&Abadia1, &TablaObjetosPersonajes_2DEC, 0x2DEC)
        CargarTablaArchivo(&Abadia1, &TablaSprites_2E17, 0x2E17)
        CargarTablaArchivo(&Abadia1, &TablaDatosPuertas_2FE4, 0x2FE4)
        CargarTablaArchivo(&Abadia1, &TablaPosicionObjetos_3008, 0x3008)
        CargarTablaArchivo(&Abadia1, &TablaCaracteristicasPersonajes_3036, 0x3036)
        CargarTablaArchivo(&Abadia1, &TablaPunterosCarasMonjes_3097, 0x3097)
        CargarTablaArchivo(&Abadia1, &TablaDesplazamientoAnimacion_309F, 0x309F)
        CargarTablaArchivo(&Abadia1, &TablaAnimacionPersonajes_319F, 0x319F)
        CargarTablaArchivo(&Abadia1, &DatosAlturaEspejoCerrado_34DB, 0x34DB)
        CargarTablaArchivo(&Abadia1, &TablaAccesoHabitaciones_3C67, 0x3C67)
        CargarTablaArchivo(&Abadia1, &TablaVariablesLogica_3C85, 0x3C85)
        //CargarTablaArchivo(Abadia1, TablaPosicionesPredefinidasMalaquias_3CA8, &H3CA8)
        //CargarTablaArchivo(Abadia1, TablaPosicionesPredefinidasAbad_3CC6, &H3CC6)
        //CargarTablaArchivo(Abadia1, TablaPosicionesPredefinidasBerengario_3CE7, &H3CE7)
        //CargarTablaArchivo(Abadia1, TablaPosicionesPredefinidasSeverino_3CFF, &H3CFF)
        //CargarTablaArchivo(Abadia1, TablaPosicionesPredefinidasAdso_3D11, &H3D11)
        CargarTablaArchivo(&Abadia1, &TablaPunterosVariablesScript_3D1D, 0x3D1D)
        CargarTablaArchivo(&Abadia1, &TablaDistanciaPersonajes_3D9F, 0x3D9F)

        //abadia2.bin
        Ruta=Bundle.main.path(forResource: "ABADIA2", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia2)
        CargarTablaArchivo(&Abadia2, &TablaComandos_440C, 0x040C)
        CargarTablaArchivo(&Abadia2, &TablaOrientacionesAdsoGuillermo_461F, 0x061F)
        CargarTablaArchivo(&Abadia2, &TablaPunterosTrajesMonjes_48C8, 0x8C8)
        CargarTablaArchivo(&Abadia2, &TablaPatronRellenoLuz_48E8, 0x8E8)
        CargarTablaArchivo(&Abadia2, &TablaEtapasDia_4F7A, 0xF7A)
        CargarTablaArchivo(&Abadia2, &TablaNotasOctavasFrases_5659, 0x1659)
        CargarTablaArchivo(&Abadia2, &PunterosCaracteresPergamino_680C, 0x280C)
        CargarTablaArchivo(&Abadia2, &DatosCaracteresPergamino_6947, 0x2947)
        CargarTablaArchivo(&Abadia2, &TextoPergaminoPresentacion_7300, 0x3300)
        CargarTablaArchivo(&Abadia2, &DatosGraficosPergamino_788A, 0x388A)

        //abadia3.bin
        Ruta=Bundle.main.path(forResource: "ABADIA3", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia3)
        CargarTablaArchivo(&Abadia3, &TilesAbadia_6D00, 0x300)
        CargarTablaArchivo(&Abadia3, &TablaMusicaPergamino_8000, 0)
        CargarTablaArchivo(&Abadia3, &TablaRellenoBugTiles_8D00, 0xD00)
        CargarTablaArchivo(&Abadia3, &BufferSprites_9500, 0x1500)
        CargarTablaArchivo(&Abadia3, &TablaGraficosObjetos_A300, 0x2300)
        CargarTablaArchivo(&Abadia3, &DatosMonjes_AB59, 0x2B59)
        CargarTablaArchivo(&Abadia3, &TablaCaracteresPalabrasFrases_B400, 0x3400)
        //CargarTablaArchivo ( Archivo, TablaCarasTrajesMonjes_B103, &H3103)

        //abadia7.bin -> alturas de las pantallas
        Ruta=Bundle.main.path(forResource: "ABADIA7", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia7)
        CargarTablaArchivo(&Abadia7, &TablaAlturasPantallas_4A00, 0xA00)

        //abadia8.bin -> datos de las pantallas
        Ruta=Bundle.main.path(forResource: "ABADIA8", ofType: "BIN")!
        CargarArchivo(NombreArchivo: Ruta, Archivo: &Abadia8)
        CargarTablaArchivo(&Abadia8, &DatosHabitaciones_4000, 0) //0x0000-0x2237 datos sobre los bloques que forman las pantallas
        CargarTablaArchivo(&Abadia8, &DatosMarcador_6328, 0x2328) //datos del marcador (de 0x6328 a 0x6b27)
        CargarTablaArchivo(&Abadia8, &TablaDatosPergaminoFinal_8000, 0x2B28) //música y texto del pergamino final
    }
    
    func Tick() {
        if !RelojFPS.Active {
            RelojFPS.Start()
        }
        LeerBitArray()
        if cga?.modo==1 {
            for contadorY in 0...50 {
                for contadorX in 0...50 {
                    cga?.bitmapModo1.pset(x: contadorX, y: contadorY, color: .red)
                }
            }
        }
        
        
        SiguienteTickTiempoms = SiguienteTickTiempoms - Int32(Reloj.EllapsedMilliseconds())
        Reloj.Start()

        if SiguienteTickTiempoms > 0 {
            return
        }
        
        switch SiguienteTickNombreFuncion {
            case "Iniciar":
                Iniciar()
            case "DibujarPresentacion":
                DibujarPresentacion()
            case  "DibujarTextosPergamino_6725":
                DibujarTextosPergamino_6725(PunteroTextoPergaminoIX: 0)
            case "InicializarJuego_249A_c":
                InicializarJuego_249A_c()
            case "DibujarCaracterPergamino_6781":
                DibujarCaracterPergamino_6781()
            case "ImprimirRetornoCarroPergamino_67DE":
                ImprimirRetornoCarroPergamino_67DE()
            case  "PasarPaginaPergamino_67F0":
                PasarPaginaPergamino_67F0()
            case  "PasarPaginaPergamino_6697":
                PasarPaginaPergamino_6697()
            case  "InicializarPartida_2509":
                InicializarPartida_2509()
            case  "InicializarPartida_2509_b":
                InicializarPartida_2509_b()
            case  "DibujarPantalla_4EB2":
                DibujarPantalla_4EB2()
            case  "MostrarResultadoJuego_42E7_b":
                MostrarResultadoJuego_42E7_b()
            case  "BuclePrincipal_25B7":
                BuclePrincipal_25B7()
                CalcularFPS()
            case  "BuclePrincipal_25B7_PantallaDibujada":
                BuclePrincipal_25B7_PantallaDibujada()
            case  "DibujarPergaminoFinal_3868":
                DibujarPergaminoFinal_3868()
            case  "ActualizarDiaMarcador_5559":
                ActualizarDiaMarcador_5559(Dia: 0)
            case  "DibujarEspiral_3F7F":
                DibujarEspiral_3F7F(Mascara: 0)
            case  "DibujarEspiral_3F6B":
                DibujarEspiral_3F6B()
            case  "BuclePrincipal_25B7_EspiralDibujada":
                BuclePrincipal_25B7_EspiralDibujada()

            default:
                ErrorExtraño()
            
        }
        
    }
    
    func SiguienteTick(Tiempoms: Int32, NombreFuncion: String) {
        //define el tiempo que debe dormir la tarea principal, y a qué función
        //hay que llamar cuando termine ese tiempo
        SiguienteTickTiempoms = Tiempoms
        SiguienteTickNombreFuncion = NombreFuncion
    }
    
    func Iniciar() {
        CargarDatos()
        SiguienteTick(Tiempoms: 10, NombreFuncion: "BuclePrincipal_25B7")
        ArrancarTareaSonido()
    }
    
    func  ArrancarTareaSonido() { //ok
        CancelarTareaSonido = false
        Thread1 = Thread(target:self, selector:#selector(TareaSonido), object:nil)
        Thread1!.start()
    }
    
    @objc func TareaSonido() { //ok
        struct estatico {
            static var contador:UInt32=0
        }
        let reloj=StopWatch()
        reloj.Start()
        TareaSonidoActiva = true
        repeat {
            if ContadorInterrupcion_2D4B == 0xFF {
                ContadorInterrupcion_2D4B = 0
            } else {
                ContadorInterrupcion_2D4B+=1
            }
            ActualizarSonidos_1060()
            usleep(2000)
 
            estatico.contador+=1
            if reloj.EllapsedMilliseconds() >= 1000 {
                reloj.Start()
                print ("Sonidos:\(estatico.contador)")
                estatico.contador = 0
            }
            
        } while CancelarTareaSonido==false
        TareaSonidoActiva = false
    }
    
    func DibujarTextosPergamino_6725(PunteroTextoPergaminoIX:UInt32) {
        
    }
    
    func InicializarJuego_249A_c() {
        
    }
    
    func DibujarCaracterPergamino_6781() {
        
    }
    
    func ImprimirRetornoCarroPergamino_67DE() {
        
    }
    
    func PasarPaginaPergamino_67F0() {
        
    }
    
    func PasarPaginaPergamino_6697() {
        
    }
    
    func InicializarPartida_2509() {
        
    }
    
    func InicializarPartida_2509_b() {
        
    }
    
    func DibujarPantalla_4EB2() {
        
    }
    
    func MostrarResultadoJuego_42E7_b() {
        
    }
    
    func BuclePrincipal_25B7() {
        ContadorInterrupcion_2D4B=1
    }
    
    func CalcularFPS() {
        //cada vez que se pasa por el buble principal se incrementa el contador de fotogramas
        //cuando haya pasado un segundo desde el anterior ciclo, el valor del contador son los FPS
        struct Estatico {
            static var Contador:UInt32=0
        }
        Estatico.Contador+=1
        if RelojFPS.EllapsedMilliseconds() >= 1000 {
            RelojFPS.Start()
            FPS = Estatico.Contador
            Estatico.Contador = 0
            print ("FPS:\(FPS)")
        }
    }
    
    func BuclePrincipal_25B7_PantallaDibujada() {
        
    }
    
    func DibujarPergaminoFinal_3868() {
        
    }
    
    func ActualizarDiaMarcador_5559(Dia: UInt8) {
        
    }
    
    func DibujarEspiral_3F7F(Mascara: UInt8) {
        
    }
    
    func DibujarEspiral_3F6B() {
        
    }
    
    func BuclePrincipal_25B7_EspiralDibujada() {
        
    }
    
    func ErrorExtraño() {
        
    }
    
    func DibujarPresentacion() {
        
    }
    
    func InicializarPartida() {
        
    }
    func BuclePrincipal() {
        
    }
    
    func ActualizarSonidos_1060() {
        
    }
    
    
    //byref = inout
    func swapTwoInts(_ a: inout Int, _ b: inout Int) {
        let temporaryA = a
        a = b
        b = temporaryA
    }

    
}

