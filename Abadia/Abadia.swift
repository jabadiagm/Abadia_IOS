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
    public var NumeroHabitacion:Int=0
    
    //objetos exteriores necesarios
    var viewController: ViewController?
    var cga:CGA?
    var ay8910:AY8912?
    var teclado:Teclado?
    
    //variables públicas del módulo
    public var FPS:Int = 0 //fotogramas por segundo
    public var FPSSonido:Int = 0 //número de ciclos por segundo de la tarea de sonido
    public var depuracion:Depuracion=Depuracion()
    public var Check:Bool=false //true para hacer una pasada por el bucle principal, ajustando la posición y orientación de guillermo, y guardando las tablas en disco
    public var Pintar:Bool=false

    //variables y objetos privados del módulo
    private let Reloj:StopWatch=StopWatch()
    private let RelojFPS:StopWatch=StopWatch()
    private let RelojSonido:StopWatch=StopWatch()
    private var SiguienteTickTiempoms:Int32 = 100
    private var SiguienteTickNombreFuncion:String = "Iniciar"
    private var CancelarTareaSonido:Bool=false
    private var TareaSonidoActiva:Bool=false
    private var CambiarPaletaColores:UInt8 = 0xFF
    private var Parado:Bool=false
    private var CheckPantalla:String=""
    private var CheckOrientacion:UInt8=0
    private var CheckX:UInt8=0
    private var CheckY:UInt8=0
    private var CheckZ:UInt8=0
    private var CheckEscaleras:UInt8=0
    private var CheckRuta:String=""
    private var Thread1:Thread?
    private var PunteroPantallaGlobal :Int=0 //posición actual dentro de la pantalla mientras se procesa
    private var PunteroPilaCamino :Int=0
    private var InvertirDireccionesGeneracionBloques:Bool = false
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
    public var BufferAuxiliar_2DC5=[Int](repeating: 0, count: 0x10) //buffer auxiliar para el cálculo de las alturas a los movimientos usado en 27cb
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
    public var CambioPantalla_2DB8 :Bool=false //indica que ha habido un cambio de pantalla
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
    
    private enum EnumIncremento {
        case IncSumarX
        case IncRestarX
        case IncRestarY
    }

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
    

    public func CargarDatos() {
        var Ruta:String=""
        var Abadia0:[UInt8]=[] //(repeating: 0, count: 16384)
        var Abadia1:[UInt8]=[] //(repeating: 0, count: 16384)
        var Abadia2:[UInt8]=[] //(repeating: 0, count: 16384)
        var Abadia3:[UInt8]=[] //(repeating: 0, count: 16384)
        var Abadia7:[UInt8]=[] //(repeating: 0, count: 16384)
        var Abadia8:[UInt8]=[] //(repeating: 0, count: 16384)
        var BugDejarObjeto:[UInt8]=[] //(repeating: 0, count: 256)

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
                DibujarTextosPergamino_6725(0)
            case "InicializarJuego_249A_c":
                InicializarJuego_249A_c()
            case "DibujarCaracterPergamino_6781":
                DibujarCaracterPergamino_6781(PunteroCaracter_: 0, Color_: 0)
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
        //arranca el juego
        depuracion = Depuracion()
        //CargarDatos()
        //SiguienteTick(Tiempoms: 10, NombreFuncion: "BuclePrincipal_25B7")
        
        /*if !depuracion.QuitarSonido {
            ArrancarTareaSonido()
        } */
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.TempoMusica_1086 = 11
            self.ReproducirSonidoPergamino()
            
            //self.TempoMusica_1086 = 6
            //self.ReproducirSonidoMelodia_1007()
            //self.ReproducirSonidoPuertaSeverino_102A()
            //self.ReproducirSonidoAbrir_101B()
            //self.ReproducirSonidoCerrar_1016()
            //self.ReproducirSonidoCampanas_100C()
            //self.ReproducirSonidoCampanillas_1011()
            //self.ReproducirSonidoCoger_1025()
            //self.ReproducirPasos_1002()

            //self.TempoMusica_1086 = 8
            //self.ReproducirSonidoPergaminoFinal()
            
            print("Foreground Reproduciendo")
            
        }
        cga?.InicializarPantalla()
        InicializarJuego_249A()
        //DibujarPresentacion()
    }
    
    public func Parar() {
        //TmTick.Enabled = False
        Reloj.Stop()
        RelojFPS.Stop()
        PararTareaSonido()
        Parado = true
    }

    public func Continuar() {
        //TmTick.Enabled = True
        Reloj.Start()
        RelojFPS.Start()
        Parado = false
    }
    
    func  ArrancarTareaSonido() { //ok
        CancelarTareaSonido = false
        Thread1 = Thread(target:self, selector:#selector(TareaSonido), object:nil)
        Thread1!.start()
    }
    
    @objc func TareaSonido() { //ok
        struct estatico {
            static var contador:Int = 0
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
                FPSSonido=estatico.contador
                //print ("Sonidos:\(FPSSonido)")
                estatico.contador = 0
            }
            
        } while CancelarTareaSonido==false
        TareaSonidoActiva = false
    }
    
    public func CheckDefinir(NumeroPantalla:UInt8, Orientacion:UInt8, X:UInt8, Y:UInt8, Z:UInt8, Escaleras:UInt8, RutaCheck:String) {
        //guarda las variables del modo check para hacer un bucle y guardar las tablas
        var Pantalla:String
        Check = true
        Pantalla = String(format: "%02X", NumeroPantalla)
        CheckPantalla = Pantalla
        CheckOrientacion = Orientacion
        CheckX = X
        CheckY = Y
        CheckZ = Z
        CheckEscaleras = Escaleras
        CheckRuta = RutaCheck
    }
   
    func MostrarResultadoJuego_42E7_b() {
        
    }
   
    func BuclePrincipal_25B7_anterior() {
        ContadorInterrupcion_2D4B=1
    }
    
    func CalcularFPS() {
        //cada vez que se pasa por el buble principal se incrementa el contador de fotogramas
        //cuando haya pasado un segundo desde el anterior ciclo, el valor del contador son los FPS
        struct Estatico {
            static var Contador:Int = 0
        }
        Estatico.Contador+=1
        if RelojFPS.EllapsedMilliseconds() >= 1000 {
            RelojFPS.Start()
            FPS = Estatico.Contador
            Estatico.Contador = 0
            //print ("FPS:\(FPS)")
        }
    }
    
    
    func DibujarPergaminoFinal_3868() {
        
    }
    
    func DibujarEspiral_3F7F(Mascara: UInt8) {
        
    }
    
    func DibujarEspiral_3F6B() {
        
    }
    
   
    func ErrorExtraño() {
        
    }
    
    
    func ComprobarQREspejo_3311() {
        
    }
    
    func ActualizarVariablesTiempo_55B6() {
        
    }
    
    func MostrarResultadoJuego_42E7() -> Bool {
        return false
    }
    
    func ComprobarSaludGuillermo_42AC() {
        
    }
    
    func EjecutarAccionesMomentoDia_3EEA() {
        SiguienteTickNombreFuncion="BuclePrincipal_25B7"
    }
    
    func AjustarCamara_Bonus_41D6() {
        
    }
    
    func CogerDejarObjetos_5096() {
        
    }
    
    func AbrirCerrarPuertas_0D67() {
        
    }
    
    func EjecutarComportamientoPersonajes_2664() {
        
    }
    
    func FlipearGraficosPuertas_0E66() {
        
    }
    
    func ComprobarEfectoEspejo_5374() {
        
    }
    
    func DescartarMovimientosPensados_08BE( _ dato:Int) {
        
    }
    
    func EjecutarComportamientoPersonaje_2C3A( _ dato1:Int, _ dato2:Int ) {
        
    }

    //tercia-------------------------------------------------------------------------------------
    
    //funciones relacionadas con el sonido
    

    public func EscribirRegistroValorPSG_134E( _ RegistroA:UInt8, _ ValorC:UInt8) {
        //; escribe al registro número 'a' del PSG el valor 'c'
        //; a = número de registro
        //; c = valor a escribir
        ay8910!.EscribirRegistro(NumeroRegistro: Int(RegistroA), ValorRegistro: Int(ValorC))
    }

public func EscribirDatosSonido_10D0( _ PunteroDatosSonidosIX:Int) {
        //escribe los datos del canal apuntado por ix en el PSG
        //estructura de TablaDatosSonidos_0F96:
        //0x0f96 máscara que indica en qué canales están activos los tonos y el generador de ruido
        //0x0f97 copia de la máscara que indica en qué canales están activos los tonos y el generador de ruido

        //0x0f98 contador que se va decrementando y al llegar a 0 actualiza las notas

        //0x0f99 periodo de la envolvente (byte bajo) relacionado con lo leido en 0x0a-0x0b + 0x0c
        //0x0f9a periodo de la envolvente (byte alto) relacionado con lo leido en 0x0a-0x0b + 0x0c
        //0x0f9b tipo de envolvente relacionado con lo leido en 0x0a-0x0b + 0x0c (solo guarda 4 lsb)

        //0x0f9c periodo del generador de ruido (solo se usan los últimos 5 bits)

        //0x0f9d-0x0fe4 tabla con los datos de generación de cada canal de sonido (registros de PSG + entrada del canal). estructura de una entrada:
        //    0x00-0x01: dirección de la nota musical actual
        //        primer Byte
        //            bits 0 - 3: nota(si es 0x0f es un caso especial)
        //        bits 4 - 6: octava
        //        bit 7: indica si se activa el generador de ruido
        //        segundo Byte: duración de la nota
        //    0x02: duración de la nota
        //    0x03-0x04: tono de la nota
        //    0x05-0x06: dirección con los datos del tono base de las notas
        //        si encuentra 0x7f: contadores al maximo y no cambia el tono de las notas (entrada de 1 byte)
        //        si encuentra 0x80: reinicia el índice en la tabla y sigue procesando (entrada de 1 byte)
        //        si el bit más significativo está activo: actualiza el tipo de envolvente, su periodo y el nuevo contador (entrada de 4 bytes)
        //        en otro caso: actualiza los contadores y el tono base (entrada de 3 bytes)
        //    0x07: volumen de la nota actual
        //    0x08: segundo contador que se va decrementando sólo cuando 0x11 es 0, y cuando llega a 0 se pueden producir cambios en frecuencia base de las notas generadas
        //    0x09: indice en tabla 0x05-0x06
        //    0x0a-0x0b: dirección con los datos que producen cambios en el volumen y el generador de envolventes
        //        si encuentra 0x7f: contadores al maximo y no cambia el volumen de las notas (entrada de 1 byte)
        //        si encuentra 0x80: reinicia el índice en la tabla y sigue procesando (entrada de 1 byte)
        //        en otro caso: actualiza los contadores y el volumen base (entrada de 3 bytes)
        //    0x0c: indice en tabla 0x0a-0x0b
        //    0x0d: segundo contador que se va decrementando sólo cuando 0x12 es 0, y cuando llega a 0 se pueden producir cambios en el volumen y el generador de envolventes
        //    0x0e: registro principal de control
        //                bit 0 = si es 1 indica que el canal de música está activo y hay que procesarlo
        //                bit 1 = si es 0 no se activa el generador de ruido
        //                bit 2 = si es 1 no entra a la sección de actualización de envolventes y modificación del tono de las notas
        //                bit 3 = si es 1, hay que actualizar el periodo del generador de ruido
        //                bit 4 = si vale 0 se usa el volumen de 0x07, en otro caso se deja en manos del generador de envolventes
        //                bit 5 = cuando vale 1 hay que fijar el volumen o las envolventes
        //                bit 6 = si vale 1 indica si se actualiza la frecuencia de la nota en el PSG
        //                bit 7 = si vale 1 indica q se leyo 0x0f y no una nota?
        //    0x0f: valor al que poner el contador 0x11 cuando llega a 0
        //    0x10: valor al que poner el contador 0x12 cuando llega a 0
        //    0x11: contador que se va decrementando y al llegar a 0 se pueden producir cambios en la frecuencia base de las notas generadas
        //    0x12: contador que se va decrementando y al llegar a 0 se pueden producir cambios en el volumen y el generador de envolventes
        //    0x13: valor para el cambio del tono de las notas
        //    0x14: incremento de volumen
        //    0x15: registro
        //0x16: no usado???
        //    0x17: no usado???

        var RegistroControlL:UInt8
        var FrecuenciaC:UInt8=0
        var AmplitudC:UInt8=0
        var EnvolventeC:UInt8=0
        var MezcladorC:UInt8=0
        var RegistroA:UInt8=0

        //lee el registro de control
        RegistroControlL = TablaDatosSonidos_0F96[PunteroDatosSonidosIX + 0x0E - 0x0F96]
        //si el canal no está activo, sale
    if !LeerBitByte(RegistroControlL, 0) { return }
        //si no hay que actualizar las notas ni las envolventes, sale
        if LeerBitByte(RegistroControlL, 2) { return }
        if LeerBitByte(RegistroControlL, 7) { return }
        //10DC
        if LeerBitByte(RegistroControlL, 6) {
            //10E0
            //si el bit 6 = 1, escribir frecuencia de la nota en el PSG
            //lee la frecuencia de la nota (parte inferior)
            FrecuenciaC = TablaDatosSonidos_0F96[PunteroDatosSonidosIX + 0x03 - 0x0F96]
            //lee el registro del PSG a escribir (frecuencia del canal (8 bits inferiores))
            RegistroA = TablaDatosSonidos_0F96[PunteroDatosSonidosIX - 0x03 - 0x0F96]
            //escribe al registro número 'a' del PSG el valor 'c'
            EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
            //10E9
            //lee la frecuencia de la nota (parte superior)
            FrecuenciaC = TablaDatosSonidos_0F96[PunteroDatosSonidosIX + 0x04 - 0x0F96]
            //registro del PSG a escribir (frecuencia del canal (4 bits superiores))
            RegistroA = RegistroA + 1
            EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
        }
        //10F3
        if LeerBitByte(RegistroControlL, 5) {
            //si el bit 5 = 1, escribir volumen o envolvente deseada
            //10F7
            if LeerBitByte(RegistroControlL, 4) == false {
                //si el bit 4 vale 0 se usa el volumen de 0x07
                //10FB
                //lee el registro del PSG a escribir (amplitud))
                RegistroA = TablaDatosSonidos_0F96[PunteroDatosSonidosIX - 0x02 - 0x0F96]
                //lee el volumen
                AmplitudC = TablaDatosSonidos_0F96[PunteroDatosSonidosIX + 0x07 - 0x0F96]
                //escribe en el PSG el nuevo volumen
                EscribirRegistroValorPSG_134E(RegistroA, AmplitudC)
            } else {
                //si el bit 4 != 0, se generan envolventes para el volumen
                //1106
                //lee el byte bajo del periodo de la envolvente
                FrecuenciaC = TablaDatosSonidos_0F96[0x0F99 - 0x0F96]
                //registro PSG del control de envolventes
                RegistroA = 0x0B
                EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
                //110F
                //lee el byte alto del periodo de la envolvente
                FrecuenciaC = TablaDatosSonidos_0F96[0x0F9A - 0x0F96]
                RegistroA = 0x0C
                //escribe el nuevo periodo de la envolvente (en unidades de 128 microsegundos)
                EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
                //1118
                //lee el tipo de envolvente y lo escribe en el PSG
                EnvolventeC = TablaDatosSonidos_0F96[0x0F9B - 0x0F96]
                RegistroA = 0x0D
                EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
                //1121
                //lee el registro del PSG a escribir (amplitud))
                RegistroA = TablaDatosSonidos_0F96[PunteroDatosSonidosIX - 0x02 - 0x0F96]
                //deja el volumen en manos del generador de envolventes
                AmplitudC = 0x10
                EscribirRegistroValorPSG_134E(RegistroA, AmplitudC)
            }
        }
        //1129
        MezcladorC = 7
        if LeerBitByte(RegistroControlL, 1) != false {
            //si el bit 1 de 0x0e es 1, activa el generador de ruido
            //112F
            MezcladorC = 0x3F
            if LeerBitByte(RegistroControlL, 3) != false {
                //si el bit 3 de 0x0e es 1 actualizar el periodo del generador de ruido
                //1135
                //fija el periodo del generador de ruido
                FrecuenciaC = TablaDatosSonidos_0F96[0x0F9C - 0x0F96]
                RegistroA = 6
                EscribirRegistroValorPSG_134E(RegistroA, FrecuenciaC)
            }
        }
        //1140
        //se hace un AND con los bits que representan al canal
        MezcladorC = MezcladorC & TablaDatosSonidos_0F96[PunteroDatosSonidosIX - 0x01 - 0x0F96]
        //actualiza la configuración del generador de ruido
        TablaDatosSonidos_0F96[0x0F96 - 0x0F96] = TablaDatosSonidos_0F96[0x0F96 - 0x0F96] ^ MezcladorC
    }

    public func IniciarCanal_104F( _ PunteroCanalIX:Int, _ PunteroDatosSonidoHL:Int) {
        //rellena parte de la entrada seleccionada
        //activa el sonido
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x0E - 0x0F96] = 5
        //guarda la dirección de los datos de la música
        Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0 - 0x0F96, PunteroDatosSonidoHL)
        //fija la duración de la nota
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] = 1
    }


    public func LeerByteTablaSonidos( _ PunteroHL:Int) -> UInt8 {
        if PunteroHL < 0x8000 { //tabla de sonidos
            return TablaTonosNotasVoces_1388[PunteroHL - 0x1388]
        } else { //tabla de melodía del pergamino
            return TablaMusicaPergamino_8000[PunteroHL - 0x8000]
        }
    }

    public func LeerEnvolventeVolumen_129B( _ PunteroCanalIX:Int) {
        //lee valores de la tabla de envolventes y volumen base y actualiza los registros
        var PunteroSonidoHL:Int = 0
        var ValorA:UInt8=0
        while true {
            PunteroSonidoHL = Leer16(TablaDatosSonidos_0F96, PunteroCanalIX + 0x0A - 0x0F96) + Int(TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96])
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            if ValorA == 0x7F {
                //12AC
                //contadores al máximo y sin modificar el volumen de las notas
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] = 0xFF
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x10 - 0x0F96] = 0xFF
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x0D - 0x0F96] = 0xFF
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x14 - 0x0F96] = 0
                return
            }
            //12BC
            if ValorA != 0x80 { break }
            //12C0
            //reinicia el índice en la tabla y sigue procesando
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96] = 0
        }
        //12C6
        if LeerBitByte(ValorA, 7) != false {
            //actualiza el periodo y tipo de envolvente
            //12CA
            ValorA = ValorA & 0x0F
            //actualiza el tipo de envolvente
            TablaDatosSonidos_0F96[0x0F9B - 0x0F96] = ValorA
            PunteroSonidoHL = PunteroSonidoHL + 1
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            //actualiza el periodo de la envolvente
            TablaDatosSonidos_0F96[0x0F99 - 0x0F96] = ValorA
            //12D4
            PunteroSonidoHL = PunteroSonidoHL + 1
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            TablaDatosSonidos_0F96[0x0F9A - 0x0F96] = ValorA
            //12D9
            PunteroSonidoHL = PunteroSonidoHL + 1
            //lee el nuevo contador
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] = ValorA
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x0D - 0x0F96] = 1
            //deja el volumen en manos del generador de envolventes
            SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E, 4)
            //avanza el índice de la tabla en 4
            ValorA = TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96] + 4
        } else {
            //12ED
            //actualiza el segundo contador
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x0D - 0x0F96] = ValorA
            PunteroSonidoHL = PunteroSonidoHL + 1
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            //actualiza el volumen base
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x14 - 0x0F96] = ValorA
            PunteroSonidoHL = PunteroSonidoHL + 1
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            //actualiza el primer contador y su límite
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x10 - 0x0F96] = ValorA
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] = ValorA
            //avanza el índice de la tabla en 3
            ValorA = TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96] + 3
        }
        //1302
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96] = ValorA
    }

    public func ActualizarEnvolventeVolumen_1275( _ PunteroCanalIX:Int) {
        //comprueba si hay que actualizar la generación de envolventes y el volumen
        var VolumenA:UInt8=0
        DecByteArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x12 - 0x0F96)
        if TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] != 0 { return }
        DecByteArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0D - 0x0F96)
        if TablaDatosSonidos_0F96[PunteroCanalIX + 0x0D - 0x0F96] == 0 {
            //actualiza unos registros de envolventes y el volumen
            LeerEnvolventeVolumen_129B(PunteroCanalIX)
        }
        //127F
        //indica que hay que fijar las envolventes y el volumen
        SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 5)
        //vuelve a cargar el contador para la generación de envolventes y modificación de volumen
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] = TablaDatosSonidos_0F96[PunteroCanalIX + 0x10 - 0x0F96]
        //si se está usando el generador de envolventes, sale
        if LeerBitArray(TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 4) != false { return }
        //128E
        //lee el volumen de la nota
        VolumenA = TablaDatosSonidos_0F96[PunteroCanalIX + 0x07 - 0x0F96]
        //le suma el incremento de volumen
        if TablaDatosSonidos_0F96[PunteroCanalIX + 0x14 - 0x0F96] != 0xFF {
            VolumenA = VolumenA + TablaDatosSonidos_0F96[PunteroCanalIX + 0x14 - 0x0F96]
        } else {
            VolumenA = VolumenA - 1
        }

        //limita al máximo valor posible
        VolumenA = VolumenA & 0x0F
        //actualiza el volumen de la nota
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x07 - 0x0F96] = VolumenA
    }

    public func ActualizarTono_1231( _ PunteroCanalIX:Int) {
        //comprueba si hay que actualizar el tono base de las notas
        var PunteroSonidoHL:Int = 0
        var ValorA:UInt8=0
        //lee el índice de la tabla y la dirección de los datos
        while true {
            PunteroSonidoHL = Leer16(TablaDatosSonidos_0F96, PunteroCanalIX + 0x05 - 0x0F96) + Int(TablaDatosSonidos_0F96[PunteroCanalIX + 0x09 - 0x0F96])
            ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
            if ValorA == 0x7F {
                //1242
                //contadores al máximo
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x11 - 0x0F96] = 0xFF
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x0F - 0x0F96] = 0xFF
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x08 - 0x0F96] = 0xFF
                //no se modifica el tono de las notas
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x13 - 0x0F96] = 0
                return
            }
            //1252
            if ValorA != 0x80 { break }
            //1256
            //limpia el índice de la tabla y vuelve a procesar los datos a partir de esa dirección
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x09 - 0x0F96] = 0
        }
        //125C
        //en otro caso actualiza los valores
        //actualiza el contador de cambios
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x08 - 0x0F96] = ValorA
        PunteroSonidoHL = PunteroSonidoHL + 1
        ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
        //actualiza la modificación de tono
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x13 - 0x0F96] = ValorA
        PunteroSonidoHL = PunteroSonidoHL + 1
        ValorA = LeerByteTablaSonidos(PunteroSonidoHL)
        //inicia el contador principal y su límite
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x0F - 0x0F96] = ValorA
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x11 - 0x0F96] = ValorA
        //apunta a la siguiente entrada de la tabla
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x09 - 0x0F96] = TablaDatosSonidos_0F96[PunteroCanalIX + 0x09 - 0x0F96] + 3
    }

    public func GuardarNotaCanal2_131B( _ PunteroSonidoBC:Int) {
        //graba una nueva dirección de notas en el canal 2 y la activa
        //graba una nueva dirección de notas en el canal 2
        Escribir16(&TablaDatosSonidos_0F96, 0x0FB8 - 0x0F96, PunteroSonidoBC)
        //+ 0x0e = 5
        TablaDatosSonidos_0F96[0x0FC6 - 0x0F96] = 5
        //pone una duración de nota de 1 unidad
        TablaDatosSonidos_0F96[0x0FBA - 0x0F96] = 1
    }

    public func GuardarNotaCanal3_132A( _ PunteroSonidoBC:Int) {
        //graba una nueva dirección de notas en el canal 3 y la activa
        //graba una nueva dirección de notas en el canal 3
        Escribir16(&TablaDatosSonidos_0F96, 0x0FD0 - 0x0F96, PunteroSonidoBC)
        //y activa el canal 3
        TablaDatosSonidos_0F96[0x0FDE - 0x0F96] = 5
        //pone una duración de nota de 1 unidad
        TablaDatosSonidos_0F96[0x0FD2 - 0x0F96] = 1
    }

    public func GuardarTono_1339( _ PunteroSonidoBC:Int, _ PunteroCanalIX:Int) {
        //graba una nueva dirección de tono base de las notas
        //guarda lo leido en la tabla de cambios del tono base
        Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x05 - 0x0F96, PunteroSonidoBC)
    }

    public func HacerNadaSonido_1347() {
        //no hace nada
    }

    public func GuardarVolumen_1340( _ PunteroSonidoBC:Int, _ PunteroCanalIX:Int) {
        //graba una nueva dirección de cambios en el volumen y el generador de envolventes
        //guarda lo leido en la tabla de cambios en el volumen y el generador de envolventes
        Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0A - 0x0F96, PunteroSonidoBC)
    }

public func CambiarDireccionMusica_1318( _ PunteroSonidoDE: inout Int, _ PunteroSonidoBC:Int) {
        //cambia de por bc (cambia a otra posición de la tabla de música)
        PunteroSonidoDE = PunteroSonidoBC
    }

public func ProcesarCanalSonido_114C( _ PunteroCanalIX:Int) {
        //procesa un canal de sonido
        var ValorA:UInt8=0
        var ValorB:UInt8=0
        var ValorC:UInt8=0
        var NotaC:UInt8=0
        var ValorBC:Int = 0
        var ValorAInt:Int = 0
        var PunteroSonidoDE:Int = 0
        var PunteroSonidoHL:Int = 0
        ValorA = TablaDatosSonidos_0F96[PunteroCanalIX + 0x0E - 0x0F96]
        //comprueba si la entrada esta activa
        //si no es así sale
        if LeerBitByte(ValorA, 0) == false { return }
        //(10000111) ignora los bits que no interesan y actualiza el valor
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x0E - 0x0F96] = ValorA & 0x87
        //carga el tempo. si es igual a 0 procesa la parte de actualización de tonos
        if TablaDatosSonidos_0F96[0x0F98 - 0x0F96] == 0 {
            //115E
            //decrementa la duración de la nota actual
            TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] = TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] - 1
            if TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] == 0 {
                //1164
                //si ha concluido
                //marca entrada para ser procesada
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x0E - 0x0F96] = 1
                //carga en de la dirección de la última nota
                PunteroSonidoDE = Leer16(TablaDatosSonidos_0F96, PunteroCanalIX + 0x00 - 0x0F96)
                //1173
                //compara el byte leido con los comandos posibles
                bucle: while true {
                    ValorA = LeerByteTablaSonidos(PunteroSonidoDE)
                    if ValorA == 0xFE || ValorA == 0xFD || ValorA == 0xFB || ValorA == 0xFC || ValorA == 0xFA || ValorA == 0xF9 {
                        //1180
                        ValorC = LeerByteTablaSonidos(PunteroSonidoDE + 1)
                        ValorB = LeerByteTablaSonidos(PunteroSonidoDE + 2)
                        PunteroSonidoDE = PunteroSonidoDE + 3
                        ValorBC = Nibbles2Integer(HighNibble: ValorB, LowNibble: ValorC)
                    }
                    //; tabla de 6 entradas(relacionada con 0x114c y tablas 0x0fac)
                    //; formato
                    //    Byte 1: patron a buscar
                    //    bytes 2 y 3: dirección a la que saltar si se encuentra el patrón
                    //1306:           FE 131B -> graba una nueva dirección de notas en el canal 2 y la activa
                    //        FD 132A -> graba una nueva dirección de notas en el canal 3 y la activa
                    //        FB 1339 -> graba una nueva dirección de tono base de las notas
                    //        FC 1347 -> no hace nada
                    //        FA 1340 -> graba una nueva dirección de cambios en el volumen y el generador de envolventes
                    //        F9 1318 -> cambia de por bc (cambia a otra posición de la tabla de música)
                    switch ValorA {
                        case 0xFE:
                            GuardarNotaCanal2_131B(ValorBC)
                        case 0xFD:
                            GuardarNotaCanal3_132A(ValorBC)
                        case 0xFB:
                            GuardarTono_1339(ValorBC, PunteroCanalIX)
                        case 0xFC:
                            HacerNadaSonido_1347()
                        case 0xFA:
                            GuardarVolumen_1340(ValorBC, PunteroCanalIX)
                        case 0xF9:
                            CambiarDireccionMusica_1318(&PunteroSonidoDE, ValorBC)
                        default:
                            break bucle
                    }
                }
                //118d
                //aquí llega después de procesar los comandos
                if ValorA == 0xFF {
                    //118F
                    //si a = 0xff, terminan las notas
                    //marca el canal como no activo
                    TablaDatosSonidos_0F96[PunteroCanalIX + 0x0E - 0x0F96] = 0
                    return
                }
                //1196
                //sigue procesando la entrada
                PunteroSonidoHL = PunteroSonidoDE
                //pone valores para que se produzcan cambios en la generación de envolventes, el volumen y en la frecuencia base
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x11 - 0x0F96] = 1
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x08 - 0x0F96] = 1
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x12 - 0x0F96] = 1
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x0D - 0x0F96] = 1
                //inicia los índices en las tablas de generación de envolventes y de frecuencia base
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x0C - 0x0F96] = 0
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x09 - 0x0F96] = 0
                //lee el primer byte de los datos (nota + octava)
                NotaC = LeerByteTablaSonidos(PunteroSonidoHL)
                //guarda el segundo byte de los datos (duración de la nota)
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] = LeerByteTablaSonidos(PunteroSonidoHL + 1)
                PunteroSonidoHL = PunteroSonidoHL + 2
                if LeerBitByte(NotaC, 7) == true {
                    //11B7
                    //si el bit 7 del primer byte = 1, se activa el generador de ruido
                    //se lee el periodo del generador de ruido y se guarda
                    TablaDatosSonidos_0F96[0xF9C - 0x0F96] = LeerByteTablaSonidos(PunteroSonidoHL)
                    //activa los bits 1 y 3 (generador de ruido y actualización de periodo de ruido)
                    SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 1)
                    SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 3)
                    PunteroSonidoHL = PunteroSonidoHL + 1
                }
                //11C4
                //pone el volumen del canal a 0
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x07 - 0x0F96] = 0
                //guarda la dirección actual de notas
                Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x00 - 0x0F96, PunteroSonidoHL)
                //activa el bit 7 por si se el byte uno no contiene una nota
                SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 7)
                //11D2
                //si el byte leido & 0x0f = 0x0f, sale
                ValorA = NotaC & 0x0F
                if ValorA == 0x0F { return }
                //11D8
                //desactiva el bit 7 de 0x0e
                ClearBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 7)
                //11DC
                //si se llega hasta aquí, en a hay una nota de la escala cromática
                //ajusta entrada en tabla de tonos de las notas
                //de = tono de la nota
                PunteroSonidoDE = Leer16(TablaDatosSonidos_0F96, 0x0FE5 + 2 * Int(ValorA) - 0x0F96)
                //se queda con los 4 bits más significativos del primer byte leido
                ValorA = NotaC >> 4
                //obtiene la octava de la nota
                ValorA = ValorA & 0x07
                //hl = hl / (2 ^ a) (ajusta el tono de la octava)
                PunteroSonidoHL = PunteroSonidoDE >> ValorA
                //11F1
                //guarda el resultado
                Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x03 - 0x0F96, PunteroSonidoHL)
            }
        }
        //11F7
        //sale si lo que leyó no era una nota
        if LeerBitArray(TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 7) != false { return }
        //sale si no hay que actualizar envolventes ni el volumen
        if LeerBitArray(TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 2) != false { return }
        //1201
        //actualiza unos registros (comprueba si hay que actualizar la generación de envolventes y el volumen)
        ActualizarEnvolventeVolumen_1275(PunteroCanalIX)
        //decrementa el contador y si no es 0, sale
        DecByteArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x11 - 0x0F96)
        if TablaDatosSonidos_0F96[PunteroCanalIX + 0x11 - 0x0F96] != 0 { return }
        //1208
        DecByteArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x08 - 0x0F96)
        if TablaDatosSonidos_0F96[PunteroCanalIX + 0x08 - 0x0F96] == 0 {
            //actualiza unos registros (comprueba si hay que actualizar el tono base de las notas)
            ActualizarTono_1231(PunteroCanalIX)
        }
        //120E
        //reinicia  los contadores
        TablaDatosSonidos_0F96[PunteroCanalIX + 0x11 - 0x0F96] = TablaDatosSonidos_0F96[PunteroCanalIX + 0x0F - 0x0F96]
        //obtiene la modificación del tono
        ValorA = TablaDatosSonidos_0F96[PunteroCanalIX + 0x13 - 0x0F96]
        ValorAInt = SignedByte2Int(ValorA)
        //hl = frecuencia de la nota
        PunteroSonidoHL = Leer16(TablaDatosSonidos_0F96, PunteroCanalIX + 0x03 - 0x0F96)
        PunteroSonidoHL = PunteroSonidoHL + ValorAInt
        //actualiza la frecuencia de la nota
        Escribir16(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x03 - 0x0F96, PunteroSonidoHL)
        //indica que hay que cambiar la frecuencia del PSG
        SetBitArray(&TablaDatosSonidos_0F96, PunteroCanalIX + 0x0E - 0x0F96, 6)
    }

    public func ActualizarSonidos_1060() {
        //actualiza la música si fuera necesario
        var ValorA:UInt8=0
        var Limite:Float
        //si ninguna de las 3 entradas tenían activo el bit 0, finaliza la interrupcion
        if ((TablaDatosSonidos_0F96[0x0FAE - 0x0F96] | TablaDatosSonidos_0F96[0x0FC6 - 0x0F96] | TablaDatosSonidos_0F96[0x0FDE - 0x0F96]) & 0x01) == 0 {
            RelojSonido.Stop()
            return
        }
        if RelojSonido.Active == false { RelojSonido.Start()}
        Limite = Float(TempoMusica_1086) * 3.45  //ms
        if Float(RelojSonido.EllapsedMicroseconds()/1000) > Limite {
            ValorA = 0
            RelojSonido.Start()
        } else {
            ValorA = TempoMusica_1086 //- TempoMusica_1086 * RelojSonido.ElapsedMilliseconds / Limite + 1
        }
        //1079
        //rutina que actualiza la música (según valga 0x0f98, el tempo es mayor o menor)
        //ValorA = TablaDatosSonidos_0F96[&H0F98 - &H0F96)
        //decrementa el tempo de la música, pero lo mantiene entre 0 y [0x1086]
        if ValorA == 0 {
            //ValorA = TempoMusica_1086
        } else {
            //ValorA = ValorA - 1
        }

        TablaDatosSonidos_0F96[0x0F98 - 0x0F96] = ValorA
        //108A
        //activa los tonos y el generador de ruido para todos los canales
        TablaDatosSonidos_0F96[0x0F96 - 0x0F96] = 0x3F
        //procesa la primera entrada de sonido
        ProcesarCanalSonido_114C(0x0FA0)
        //procesa la segunda entrada de sonido
        ProcesarCanalSonido_114C(0x0FB8)
        //procesa la tercera entrada de sonido
        ProcesarCanalSonido_114C(0x0FD0)
        //10A4
        //escribe los datos del canal 0 en el PSG
        EscribirDatosSonido_10D0(0x0FA0)
        //escribe los datos del canal 1 en el PSG
        EscribirDatosSonido_10D0(0x0FB8)
        //escribe los datos del canal 2 en el PSG
        EscribirDatosSonido_10D0(0x0FD0)
        //10B9
        //si la máscara no ha cambiado, sale
        if TablaDatosSonidos_0F96[0x0F96 - 0x0F96] == TablaDatosSonidos_0F96[0x0F97 - 0x0F96] { return }
        //10C0
        //si la máscara ha cambiado, fija el estado de los canales
        //copia la máscara para evitar fijar el estado si no hay modificaciones
        TablaDatosSonidos_0F96[0x0F97 - 0x0F96] = TablaDatosSonidos_0F96[0x0F96 - 0x0F96]
        //escribe en el PSG en qué canales están activos los tonos y el generador de ruido
        EscribirRegistroValorPSG_134E(7, TablaDatosSonidos_0F96[0x0F96 - 0x0F96])
    }

    public func Interrupcion_2D48() {
        //no usar.sustituida por tm_tick
    }

    public func ReproducirSonidoMelodia_1007() {
        //apunta al registro de control del canal 3
        if TablaDatosSonidos_0F96[0x0FD0 + 0x0E - 0x0F96] != 0 { return }
        IniciarCanal_104F(0x0FD0, 0x13FE)
    }


    public func ReproducirSonidoPuertaSeverino_102A() {
        IniciarCanal_104F(0x0FB8, 0x1550)
    }

    public func ReproducirSonidoAbrir_101B() {
        //sonido ??? por el canal 2
        //apunta a la entrada 2
        IniciarCanal_104F(0x0FB8, 0x14E7)
    }

    public func ReproducirSonidoCerrar_1016() {
        //sonido ??? por el canal 2
        //apunta a la entrada 2
        IniciarCanal_104F(0x0FB8, 0x1560)
    }

    public func ReproducirSonidoCampanas_100C() {
        //sonido ??? por el canal 1
        IniciarCanal_104F(0x0FA0, 0x14F3)
    }

    public func ReproducirSonidoCampanillas_1011() {
        //sonido de campanas después de la espiral cuadrada por el canal 1
        IniciarCanal_104F(0x0FA0, 0x14BA)
    }

    public func ReproducirSonidoCoger_1025() {
        IniciarCanal_104F(0x0FB8, 0x149F)
    }

    public func ReproducirSonidoDejar_102F() {
        IniciarCanal_104F(0x0FB8, 0x14A8)
    }

    public func ReproducirSonidoCogerDejar_5088(ObjetosAntesA:UInt8, ObjetosDespuesC:UInt8) {
        if ((ObjetosAntesA ^ ObjetosDespuesC) & ObjetosDespuesC) == 0 {
            //se ha dejado un objeto
            ReproducirSonidoDejar_102F()
        } else {
            //se ha cogido un objeto
            ReproducirSonidoCoger_1025()
        }
    }

    public func ReproducirPasos_1002() {
        //sonido de guillermo moviéndose por el canal 3
        IniciarCanal_104F(0x0FD0, 0x1496)
    }

    public func ReproducirSonidoAbrirEspejoCanal1_0FFD() {
        //sonido ??? por el canal 1
        IniciarCanal_104F(0x0FA0, 0x1480)
    }

    public func ReproducirSonidoVoz_1020() {
        //apunta a los datos de inicialización y al canal 3
        IniciarCanal_104F(0x0FD0, 0x14B1)
    }

    public func ReproducirSonidoPergamino() {
        IniciarCanal_104F(0x0FA0, 0x8000) // inicializa la tabla del sonido y habilita las interrupciones
    }

    public func ReproducirSonidoPergaminoFinal() {
        //los datos del pergamino inicial y final tienen la misma dirección pero están en
        //distintos bancos de memoria. Como del manuscrito final no se va a ningún otro
        //sitio, se sobreescriben los datos del manuscrito inicial
        var Contador:Int = 0
        for Contador in 0x000...0x2FF {
            TablaMusicaPergamino_8000[Contador] = TablaDatosPergaminoFinal_8000[Contador]
        }
        IniciarCanal_104F(0x0FA0, 0x8000)
    }


    public func ApagarSonido_1376() {
        //para la generación de sonido
        TablaDatosSonidos_0F96[0x0FAE - 0x0F96] = 0x84
        TablaDatosSonidos_0F96[0x0FC6 - 0x0F96] = 0x84
        TablaDatosSonidos_0F96[0x0FDE - 0x0F96] = 0x84
        //0011 1111 (apaga los 3 canales de sonido), registro 7 (PSG enable)
        EscribirRegistroValorPSG_134E(7, 0x3F)
    }

    public func PararTareaSonido() {
        CancelarTareaSonido = true
        while true {
            usleep(1000)
            if TareaSonidoActiva == false { break }
            usleep(1000)
        }
    }

    

    //tercia-------------------------------------------------------------------------------------
    
    
    //sexta--------------------------------------------------------------------------------------
    
    public func DibujarPresentacion() {
        //coloca en pantalla la imagen de presentación, usando el orden
        //de líneas del original
        struct Estatico {
            static var Estado:UInt8 = 0
            static var ContadorBanco:Int = 7
        }
        switch Estatico.Estado {
            case 0:
                cga!.SeleccionarPaleta(0)
                cga!.DibujarRectangulo(0, 0, 319, 199, 6) //fondo azul oscuro
                cga!.SeleccionarPaleta(4)
                Estatico.Estado = 1
                SiguienteTick(Tiempoms: 2500, NombreFuncion: "DibujarPresentacion")
            case 1:
                cga!.DibujarRectangulo(0, 0, 319, 199, 0) //fondo rosa
                Estatico.Estado = 2
                Estatico.ContadorBanco = 7
                SiguienteTick(Tiempoms: 1200, NombreFuncion: "DibujarPresentacion")
            case 2:
                DibujarBancoPresentacion(Estatico.ContadorBanco)
                Estatico.ContadorBanco = Estatico.ContadorBanco - 1
                if Estatico.ContadorBanco < 0 { Estatico.Estado = 3 }
                SiguienteTick(Tiempoms: 100, NombreFuncion: "DibujarPresentacion")
            case 3:
                Estatico.Estado = 4
                SiguienteTick(Tiempoms: 5000, NombreFuncion: "DibujarPresentacion")
            case 4:
                Estatico.Estado = 0
                Estatico.ContadorBanco = 7
                cga!.DibujarRectangulo(0, 0, 319, 199, 1) //fondo negro
                cga!.SeleccionarPaleta(0) //paleta negra
                //ModPantalla.DibujarRectangulo(0, 0, 319, 199, 0) //fondo rosa
                //SeleccionarPaleta(1)
                InicializarJuego_249A_b()
            default:
                break
        }
    }

    public func DibujarBancoPresentacion( _ NumeroBanco:Int) {
        //coloca el banco de memoria de video indicado en la pantalla
        //var ContadorLineas:Int
        //var ContadorLinea:Int
        var PunteroPantalla:Int
        var X:Int
        var Y:Int
        var Pixel:UInt8
        var Colores:[UInt8]=[0,0]
        for ContadorLineas in stride(from: 24, to: -1, by: -1) {// 24 To 0 Step -1
            for ContadorLinea in stride(from: 79, to: -1, by: -1) { // 79 To 0 Step -1
                if ContadorLineas==0 {
                    let parar=true
                }
                PunteroPantalla = ContadorLinea + ContadorLineas * 0x50 + NumeroBanco * 0x800
                X = ContadorLinea * 4
                Y = ContadorLineas * 8 + NumeroBanco
                Pixel = TablaPresentacion_C000[PunteroPantalla]
                //If Pixel = &HF0 Then Stop
                Colores = LeerColoresModo0(Pixel)
                cga!.DibujarPunto(X, Y, Int(Colores[0]))
                cga!.DibujarPunto(X + 1, Y, Int(Colores[0]))
                cga!.DibujarPunto(X + 2, Y, Int(Colores[1]))
                cga!.DibujarPunto(X + 3, Y, Int(Colores[1]))
            }
        }
    }

    private func LeerColoresModo0( _ Pixel:UInt8) -> [UInt8] {
        //extrae la información de color de un pixel del modo 0 (160x200)
        var Resultado:[UInt8]=[0,0]
        var _Pixel:UInt8
        _Pixel=Pixel
        Resultado[0] = LeerColorPixel0Modo0(_Pixel)
        _Pixel = _Pixel << 1
        Resultado[1] = LeerColorPixel0Modo0(_Pixel)
        return Resultado
    }

    private func LeerColorPixel0Modo0( _ Pixel:UInt8) -> UInt8 {
        //    bit 7     |    bit 6      |      bit 5    |     bit 4     |     bit 3     |     bit 2     |     bit 1     |    bit 0
        //Pixel 0(bit 0)|pixel 1 (bit 0)|pixel 0 (bit 2)|pixel 1 (bit 2)|pixel 0 (bit 1)|pixel 1 (bit 1)|pixel 0 (bit 3)|pixel 1 (bit 3)
        var NColor:UInt8=0
        if (Pixel & 0x80) != 0 { NColor = NColor | 1 }
        if (Pixel & 0x08) != 0 { NColor = NColor | 2 }
        if (Pixel & 0x20) != 0 { NColor = NColor | 4 }
        if (Pixel & 0x02) != 0 { NColor = NColor | 8 }
        return NColor
    }

    public func InicializarJuego_249A() {
        if !Check {
            depuracion=Depuracion()
        } else {
            depuracion.Check()
        }
        //inicio real del programa
        //DeshabilitarInterrupcion()
        CargarDatos()
        if !Check {
            Reloj.Start()
            RelojFPS.Start()
        }

        if !depuracion.SaltarPresentacion {
            DibujarPresentacion()
        } else {
            SiguienteTick(Tiempoms: 5000, NombreFuncion: "BuclePrincipal_25B7")
            InicializarJuego_249A_b()
        }
    }
  
    func InicializarJuego_249A_b() {
        //segunda parte de la inicialización. separado para poder usar las funciones asíncronas
        struct Estatico {
            static var Inicializado_00FE:Bool=false
        }
        //ModPantalla.SeleccionarPaleta(2)
        if !Estatico.Inicializado_00FE || Check == true { //comprueba si es la primera vez que llega aquí
            Estatico.Inicializado_00FE = true
            teclado!.Inicializar()
            viewController?.definirModo(modo: 1) //fija el modo 0 (320x200 4 colores)
            //cga!.definirModo(modo: 1)
            cga!.SeleccionarPaleta(0) //pone una paleta de colores negra
            //InicializarInterrupcion //coloca el código a ejecutar al producirse una interrupción ###pendiente
            //24DD
            //cambia un valor relacionado con el tempo de la música
            TempoMusica_1086 = 0x0B
            if !Check {
                if !depuracion.QuitarSonido {
                    ArrancarTareaSonido()
                }
                ReproducirSonidoPergamino()
            }
            //DeshabilitarInterrupcion()
            if !depuracion.SaltarPergamino {
                DibujarPergaminoIntroduccion_659D(0x7300) //dibuja el Pergamino y cuenta la introducción. De aquí vuelve al pulsar espacio
            } else {
                InicializarJuego_249A_c()
            }
        }
    }
    
    public func InicializarJuego_249A_c() {
        //tercera parte de la inicialización. separado para poder usar los retardos
        //DeshabilitarInterrupcion()
        ApagarSonido_1376() //apaga el sonido
        cga!.SeleccionarPaleta(0)  //pone los colores de la paleta a negro
        Limpiar40LineasInferioresPantalla_2712()
        CopiarVariables_37B6() //copia cosas de muchos sitios en 0x0103-0x01a9 (pq??z)
        RellenarTablaFlipX_3A61()
        CerrarEspejo_3A7E()
        GenerarTablasAndOr_3AD1()
        InicializarPartida_2509()
    }

    public func InicializarPartida_2509() {
        //aquí ya se ha completado la inicialización de datos para el juego
        //ahora realiza la inicialización para poder empezar a jugar una partida
        //DeshabilitarInterrupcion()
        ApagarSonido_1376() //apaga el sonido
        //LeerEstadoTeclas_32BC ###pendiente 'lee el estado de las teclas y lo guarda en los buffers de teclado
        if TeclaPulsadaNivel_3482(0x2F) {  //mientras no se suelte el espacio, espera
            SiguienteTick(Tiempoms: 100, NombreFuncion: "InicializarPartida_2509")
        } else {
            SiguienteTick(Tiempoms: 100, NombreFuncion: "InicializarPartida_2509_b")
        }
        if Check {
            InicializarPartida_2509_b()
        }
    }
 
    public func InicializarPartida_2509_b_anterior() {
        //var NumeroHabitacion:Int = 0x00
        Pintar = true
        cga!.SeleccionarPaleta(2)
        cga!.DibujarRectangulo(0, 0, 319, 160, 0)
        PunteroPantallaActual_156A = BuscarHabitacionProvisional(NumeroPantalla: NumeroHabitacion)
        HabitacionOscura_156C = false
        Check = true
        DibujarPantalla_19D8()
    }
    
    public func InicializarPartida_2509_b() {
        var Contador:Int
        InicializarVariables_381E()
        DibujarAreaJuego_275C() //dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
        DibujarMarcador_272C()
        //2520
        TempoMusica_1086 = 6 //coloca el nuevo tempo de la música ###pendiente ajustar
        //ColocarVectorInterrupcion()
        VelocidadPasosGuillermo_2618 = 36
        //254e
        TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] = 0x88 //coloca la posición inicial de guillermo
        TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036] = 0xA8 //coloca la posición inicial de guillermo
        TablaCaracteristicasPersonajes_3036[0x3047 - 0x3036] = 0x88 - 2 //coloca la posición inicial de adso
        TablaCaracteristicasPersonajes_3036[0x3048 - 0x3036] = 0xA8 + 2 //coloca la posición inicial de adso
        TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] = 0 //coloca la altura inicial de guillermo
        TablaCaracteristicasPersonajes_3036[0x3049 - 0x3036] = 0 //coloca la altura inicial de adso
        for Contador in 0...0x2D4 {//apunta a los gráficos de los movimientos de los monjes
            DatosMonjes_AB59[0x2D5 + Contador] = DatosMonjes_AB59[Contador] //copia 0xab59-0xae2d a 0xae2e-0xb102
        }
        //obtiene en 0xae2e-0xb102 los gráficos de los monjes flipeados con respecto a x
        GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: 0xAE2E - 0xAB59, AnchoC: 5, NGraficosB: 0x91) //gráficos de 5 bytes de ancho, 0x91 bloques de 5 bytes (= 0x2d5)
        InicializarEspejo_34B0() //inicia la habitación del espejo y las variables relacionadas con el espejo
        InicializarDiaMomento_54D2() //inicia el día y el momento del día en el que se está
        //257A
        //habilita los comandos cuando procese el comportamiento
        BufferComandosMonjes_A200[0xA2C0 - 0xA200] = 0x10 //inicia el comando de adso
        BufferComandosMonjes_A200[0xA200 - 0xA200] = 0x10 //inicia el comando de malaquías
        BufferComandosMonjes_A200[0xA230 - 0xA200] = 0x10 //inicia el comando del abad
        BufferComandosMonjes_A200[0xA260 - 0xA200] = 0x10 //inicia el comando de berengario
        BufferComandosMonjes_A200[0xA290 - 0xA200] = 0x10 //inicia el comando de severino
        //258B
        ContadorInterrupcion_2D4B = 0 //resetea el contador de la interrupción
        PintarPantalla_0DFD = true //añadido para que corresponda con lo que hace realmente
        //For Contador = 0 To UBound(BufferSprites_9500)
        //    BufferSprites_9500(Contador) = 0xFF //rellena el buffer de sprites con un relleno para depuración
        //Next
        InicializarPartida_258F()
    }
    
    public func InicializarPartida_258F() {
        //segunda parte de la inicialización. cuando carga una partida también se llega aquí
        //DeshabilitarInterrupcion()
        PosicionXPersonajeActual_2D75 = 0 //inicia la pantalla en la que está el personaje
        EstadoGuillermo_288F = 0 //inicia el estado de guillermo
        AjustePosicionYSpriteGuillermo_28B1 = 2
        //DibujarAreaJuego_275C 'dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
        ApagarSonido_1376() //apaga el sonido
        InicializarEspejo_34B9() //inicia la habitación del espejo
        DibujarObjetosMarcador_51D4() //dibuja los objetos que tenemos en el marcador
        FijarPaletaMomentoDia_54DF() //fija la paleta según el momento del día, muestra el número de día y avanza el momento del día
        DecrementarObsequium_55D3(Decremento: 0) //decrementa el obsequium 0 unidades
        LimpiarZonaFrasesMarcador_5001() //limpia la parte del marcador donde se muestran las frases
        if !Check {
            BuclePrincipal_25B7() //el bucle principal del juego empieza aquí
        } else {
            BuclePrincipal_Check()
        }
    }
    
    public func DireccionSiguienteLinea_3A4D_68F2( _ PunteroPantallaHL:Int) -> Int {
        //devuelve la dirección de la siguiente línea de pantalla
        var Puntero:Int
        Puntero = PunteroPantallaHL + 0x800 //pasa al siguiente banco
        if Puntero > 0x3FFF {
            Puntero = PunteroPantallaHL & 0x7FF
            Puntero = Puntero + 0x50
        }
        //pasa a la siguiente línea y ajusta para que esté en el rango 0xc000-0xffff
        return Puntero
    }
    
    public func TeclaPulsadaNivel_3482( _ CodigoTecla:UInt8) -> Bool {
        //comprueba si se está pulsando la tecla con el código indicado. si no está siedo pulsada, devuelve true
        return teclado!.TeclaPulsadaNivel(TraducirCodigoTecla(CodigoTecla))
    }
    
    public func TraducirCodigoTecla( _ CodigoTecla:UInt8) -> EnumAreaTecla {
        switch  CodigoTecla {
            case 0x0:
                return .TeclaArriba
            case 0x2:
                return .TeclaAbajo
            case 0x8:
                return .TeclaIzquierda
            case 0x1:
                return .TeclaDerecha
            case 0x2F:
                return .AreaEscenario
            case 0x44:
                return .TeclaTabulador
            case 0x17:
                return .TeclaControl
            case 0x15:
                return .TeclaMayusculas
            case 0x6:
                return .AreaDepuracion
            case 0x4F:
                return .TeclaSuprimir
            case 0x42:
                return .TeclaEscape
            case 0x7:
                return .TeclaPunto
            case 0x3C:
                return .AreaTextosIzquierda
            case 0x2E:
                return .AreaTextosDerecha
            case 0x43:
                return .TeclaQ
            case 0x32:
                return .TeclaR
            default:
                return .TeclaPunto
        }
    }
    
    public func DibujarPergaminoIntroduccion_659D( _ PunteroTextoPergaminoIX:Int) {
        //dibuja el pergamino
        cga!.SeleccionarPaleta(1) //coloca la paleta negra
        DibujarPergamino_65AF() //dibuja el pergamino
        cga!.SeleccionarPaleta(1) //coloca la paleta del pergamino
        DibujarTextosPergamino_6725(PunteroTextoPergaminoIX) //dibuja los textos en el Pergamino mientras no se pulse el espacio
    }


    public func DibujarPergamino_65AF() {
        var Contador:Int
        //var Linea:Int
        var Relleno:Int
        var Puntero:Int
        for Contador in 0...0x3FFF {//limpia la memoria de video
            PantallaCGA[Contador] = 0
        }
        cga!.DibujarRectanguloCGA(X1: 0, Y1: 0, X2: 319, Y2: 199, NColor: 0)

        //deja un rectángulo de 192 pixels de ancho en el medio de la pantalla, el resto limpio
        Contador = 0
        for Linea in 1...200  {//número de líneas a rellenar
            for Relleno in 0...15 {//16, ancho de los rellenos
                //&HF0=240, valor con el que rellenar
                PantallaCGA[Contador + Relleno] = 0xF0 //apunta al relleno por la izquierda
                cga!.PantallaCGA2PC(PunteroPantalla: Contador + Relleno, Color: 0xF0)
                PantallaCGA[Contador + 0x40 + Relleno] = 0xF0 //apunta al relleno por la derecha. 0x40=64, salto entre rellenos
                cga!.PantallaCGA2PC(PunteroPantalla: Contador + Relleno + 0x40, Color: 0xF0)
            } //completa 16 bytes (64 pixels)
            Contador = DireccionSiguienteLinea_3A4D_68F2(Contador) //pasa a la siguiente línea de pantalla
        } //repite para 200 lineas
        //limpia las 8 líneas de debajo de la pantalla
        Contador = 0x780  //apunta a una línea (la octava empezando por abajo)
        for Linea in 0...7 {//repetir para 8 líneas
            for Relleno in 1...0x4F {
                PantallaCGA[Contador + Relleno] = PantallaCGA[Contador] //copia lo que hay en la primera posición de la línea para el resto de pixels de la línea
                cga!.PantallaCGA2PC(PunteroPantalla: Contador + Relleno, Color: PantallaCGA[Contador])
            }
            Contador = DireccionSiguienteLinea_3A4D_68F2(Contador) //avanza hl 0x0800 bytes y si llega al final, pasa a la siguiente línea (+0x50)
        }
        PunteroPantallaGlobal = CalcularDesplazamientoPantalla_68C7(32, 0) //calcula el desplazamiento en pantalla
        DibujarParteSuperiorInferiorPergamino_661B(PunteroPantalla: PunteroPantallaGlobal, PunteroDatos: 0x788A - 0x788A) //dibuja la parte superior del pergamino
        PunteroPantallaGlobal = CalcularDesplazamientoPantalla_68C7(218, 0) //calcula el desplazamiento en pantalla
        DibujarParteDerechaIzquierdaPergamino_662E(PunteroPantalla: PunteroPantallaGlobal, PunteroDatos: 0x7A0A - 0x788A) //dibuja la parte derecha del pergamino
        PunteroPantallaGlobal = CalcularDesplazamientoPantalla_68C7(32, 0) //calcula el desplazamiento en pantalla
        DibujarParteDerechaIzquierdaPergamino_662E(PunteroPantalla: PunteroPantallaGlobal, PunteroDatos: 0x7B8A - 0x788A) //dibuja la parte derecha del pergamino
        PunteroPantallaGlobal = CalcularDesplazamientoPantalla_68C7(32, 184) //calcula el desplazamiento en pantalla
        DibujarParteSuperiorInferiorPergamino_661B(PunteroPantalla: PunteroPantallaGlobal, PunteroDatos: 0x7D0A - 0x788A) //dibuja la parte superior del pergamino

    }

    public func CalcularDesplazamientoPantalla_68C7( _ X:Int, _ Y:Int) -> Int {
        //dados X,Y (coordenadas en pixels), calcula el desplazamiento correspondiente en pantalla
        //el valor calculado se hace partiendo de la coordenada x multiplo de 4 más cercana y sumandole 32 pixels a la derecha
        var Valor1:Int
        var Valor2:Int
        var Valor3:Int
        Valor1 = X >> 2 //l / 4 (cada 4 pixels = 1 byte)
        Valor2 = Y & 0xF8 //obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
        Valor2 = Valor2 * 10 //dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
        Valor3 = Y & 7 //3 bits menos significativos en y (para calcular al banco de VRAM al que va)
        Valor3 = Valor3 << 3
        Valor3 = (Valor3 << 8) | Valor2 //completa el cálculo del banco
        Valor3 = Valor3 + Valor1 //suma el desplazamiento en x
        return Valor3 + 8 //ajusta para que salga 32 pixels más a la derecha
    }

    public func DibujarParteSuperiorInferiorPergamino_661B(PunteroPantalla:Int, PunteroDatos:Int) {
        //rellena la parte superior (o inferior del pergamino)
        //var Linea:Int
        //var Contador:Int
        var PunteroPantallaAnterior:Int
        var PunteroPantalla:Int=PunteroPantalla
        var PunteroDatos:Int=PunteroDatos
        PunteroPantallaAnterior = PunteroPantalla
        for Contador in 1...48 { //48 bytes (= 192 pixels a rellenar)
            for Linea in 0...7 {//8 líneas de alto
                PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + Linea]
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + Linea])
                PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
            }
            PunteroDatos = PunteroDatos + 8
            PunteroPantalla = PunteroPantallaAnterior + Contador
        }
    }

    public func DibujarParteDerechaIzquierdaPergamino_662E( PunteroPantalla:Int,  PunteroDatos:Int) {
        //rellena la parte superior (o inferior del pergamino)
        //var Linea:Int
        //var Contador:Int
        var PunteroPantalla:Int=PunteroPantalla
        var PunteroDatos:Int=PunteroDatos
        for Contador in 1...192 {//192 líneas
            PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos])
            PantallaCGA[PunteroPantalla + 1] = DatosGraficosPergamino_788A[PunteroDatos + 1]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + 1, Color: DatosGraficosPergamino_788A[PunteroDatos + 1])
            PunteroDatos = PunteroDatos + 2
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        }
    }


    public func LeerCaracterPergamino( _ PunteroTextoPergaminoIX:Int) -> UInt8 {
        if PunteroTextoPergaminoIX < 0x8330 {
            //pergamino de presentación
            return TextoPergaminoPresentacion_7300[PunteroTextoPergaminoIX - 0x7300]
        } else {
            //pergamino final
            return TablaDatosPergaminoFinal_8000[PunteroTextoPergaminoIX - 0x8000]
        }
    }


    public func DibujarTextosPergamino_6725( _ PunteroTextoPergaminoIX:Int) {
        //dibuja los textos en el Pergamino mientras no se pulse el espacio
        struct Estatico {
            static var PunteroDatosPergamino:Int=0
            static var PergaminoFinal:Bool=false
            static var Estado:UInt8 = 0
        }

        var Caracter:UInt8 //caracter a imprimir
        var ColorLetra_67C0:UInt8
        var PunteroCaracter:Int
        
        if Estatico.Estado == 0 {
            if PunteroTextoPergaminoIX == 0x8330 {
                Estatico.PergaminoFinal = true //el pergamino final no tiene salida
            }
            Estatico.PunteroDatosPergamino = PunteroTextoPergaminoIX
            PosicionPergaminoY_680A = 16
            PosicionPergaminoX_680B = 44
            Estatico.Estado = 1
            SiguienteTick(Tiempoms: 100, NombreFuncion: "DibujarTextosPergamino_6725")
            return
        } else {
            //LeerEstadoTeclas_32BC ###pendiente 'lee el estado de las teclas
            if TeclaPulsadaNivel_3482(0x2F) {
                //reinicia las variables estáticas

                PosicionPergaminoY_680A = 16
                PosicionPergaminoX_680B = 44
                Estatico.Estado = 0
                if !Estatico.PergaminoFinal {
                    SiguienteTick(Tiempoms: 100, NombreFuncion: "InicializarJuego_249A_c") //###pendiente 'comprueba si se pulsó el espacio
                } else {
                    SiguienteTick(Tiempoms: 100, NombreFuncion: "DibujarPergaminoFinal_3868") //el pergamino final no tiene salida
                }
                return
            }
            //673A
            Caracter = LeerCaracterPergamino(Estatico.PunteroDatosPergamino) //lee el caracter a imprimir
            //Caracter = TablaTextoPergaminoFinal_8330(PunteroDatosPergamino)
            //si ha encontrado el carácter de fin de pergamino (0x1A), espera a que se pulse espacio para terminar
            if Caracter != 0x1A {
                Estatico.PunteroDatosPergamino = Estatico.PunteroDatosPergamino + 1 //apunta al siguiente carácter
                
                switch Caracter {
                    case 0xD: //salto de línea
                        ImprimirRetornoCarroPergamino_67DE()
                    case 0x20: //espacio
                        ImprimirEspacioPergamino_67CD(Hueco: 0xA, X: &PosicionPergaminoX_680B)//espera un poco y avanza la posición en 10 pixels
                    case 0xA:  //avanzar una página. dibuja el triángulo
                        PasarPaginaPergamino_67F0()
                    default:
                        if (Caracter & 0x60) == 0x40 {
                            ColorLetra_67C0 = 0xFF //mayúsculas en rojo
                        } else {
                            ColorLetra_67C0 = 0xF //minúsculas en negro
                        }
                        PunteroCaracter = Int(Caracter) - 0x20 //solo tiene caracteres a partir de 0x20
                        PunteroCaracter = 2 * PunteroCaracter //cada entrada ocupa 2 bytes
                        //PunteroCaracter = PunterosCaracteresPergamino_680C[PunteroCaracter] + 256 * PunterosCaracteresPergamino_680C[PunteroCaracter + 1]
                        PunteroCaracter = Bytes2Int(Byte0: PunterosCaracteresPergamino_680C[PunteroCaracter], Byte1: PunterosCaracteresPergamino_680C[PunteroCaracter + 1])
                        DibujarCaracterPergamino_6781(PunteroCaracter_: PunteroCaracter, Color_: ColorLetra_67C0)
                }

            }





        }
    }


    public func ImprimirRetornoCarroPergamino_67DE() {
        struct Estatico {
            static var Estado:UInt8 = 0
        }
        
        if Estatico.Estado == 0 {
            SiguienteTick(Tiempoms: 600, NombreFuncion: "ImprimirRetornoCarroPergamino_67DE") //espera un rato (aprox. 600 ms)
            Estatico.Estado = 1
            return
        } else {
            Estatico.Estado = 0
        }
        //calcula la posición de la siguiente línea
        PosicionPergaminoX_680B = 0x2C
        PosicionPergaminoY_680A = PosicionPergaminoY_680A + 0x10
        SiguienteTick(Tiempoms: 20, NombreFuncion: "DibujarTextosPergamino_6725")
        if PosicionPergaminoY_680A > 0xA4 { PasarPaginaPergamino_67F0()} //se ha llegado a fin de hoja?
    }


    public func DibujarTrianguloRectanguloPergamino_6906(PixelX:Int, PixelY:Int, Lado:Int) {
        //dibuja un triángulo rectángulo con los catetos paralelos a los ejes de coordenadas y de longitud Lado
        var PunteroPantalla:Int
        var RellenoTriangular_6943:[UInt8]=[0,0,0,0]
        var Aux:Int=0
        var Distancia:Int //separación en bytes entre la parte derecha y la izquierda del triángulo
        //var ContadorLado:Int
        //var Linea:Int
        var PunteroRelleno:Int
        var Valor_6932:UInt8
        var PunteroPantallaAnterior:Int
        RellenoTriangular_6943[0] = 0xF0
        RellenoTriangular_6943[1] = 0xE0
        RellenoTriangular_6943[2] = 0xC0
        RellenoTriangular_6943[3] = 0x80
        PunteroPantalla = CalcularDesplazamientoPantalla_68C7(PixelX, PixelY)
        Distancia = 0
        for ContadorLado in stride(from: Lado, through: 1, by: -1) { // Lado To 1 Step -1
            for Linea in stride (from: 4, through: 1, by: -1) { //} 4 To 1 Step -1
                Aux = 0
                PunteroPantallaAnterior = PunteroPantalla
                PunteroRelleno = Linea - 1
                Valor_6932 = RellenoTriangular_6943[PunteroRelleno]
                while true {
                    if Distancia == Aux {
                        DibujarTrianguloRectanguloPergamino_Parte2(Valor: Valor_6932, PunteroPantalla: &PunteroPantalla, PunteroPantallaAnterior: PunteroPantallaAnterior, Incremento: 0)
                        break
                    } else {
                        PantallaCGA[PunteroPantalla] = 0xF0
                        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: 0xF0)
                        if ContadorLado > 1 {
                            DibujarTrianguloRectanguloPergamino_Parte2(Valor: Valor_6932, PunteroPantalla: &PunteroPantalla, PunteroPantallaAnterior: PunteroPantallaAnterior, Incremento: Distancia)
                            break
                        }
                        Aux = Aux + 1
                        PunteroPantalla = PunteroPantalla + 1
                    }
                }
            }
            Aux = Aux + 1
            Distancia = Distancia + 1
        }
    }

    public func DibujarTrianguloRectanguloPergamino_Parte2(Valor:UInt8, PunteroPantalla: inout Int, PunteroPantallaAnterior:Int, Incremento:Int) {
        PunteroPantalla = PunteroPantalla + Incremento
        PantallaCGA[PunteroPantalla] = Valor
        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: Valor)
        PunteroPantalla = PunteroPantalla + 1
        PantallaCGA[PunteroPantalla] = 0
        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: 0)
        PunteroPantalla = PunteroPantallaAnterior
        PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
    }

    public func PasarPaginaPergamino_67F0() {
        struct Estatico {
            static var Estado:UInt8 = 0
        }
        
        if Estatico.Estado == 0 {
            Estatico.Estado = 1
            SiguienteTick(Tiempoms: 3 * 655, NombreFuncion: "PasarPaginaPergamino_67F0") //(aprox. 655 ms), repite 3 veces los retardos
            return
        } else {
            Estatico.Estado = 0
        }
        PosicionPergaminoX_680B = 0x2C //reinicia la posición al principio de la línea
        PosicionPergaminoY_680A = 0x10 //reinicia la posición al principio de la línea
        PasarPaginaPergamino_6697() //pasa de hoja
    }

    public func PasarPaginaPergamino_6697() {
        struct Estatico {
            static var Linea:Int=0
            static var X:Int=0
            static var Y:Int=0
            static var TamañoTriangulo:Int=0
            static var Contador:Int=0
            static var Estado:UInt8 = 0
        }

        var PunteroPantalla:Int
        var PunteroDatos:Int
        switch Estatico.Estado {
            case 0:
                Estatico.TamañoTriangulo = 3
                Estatico.Linea = 0
                Estatico.Contador = 0
                Estatico.X = 211 - 4 * Estatico.Linea //(00, 211) -> posición de inicio
                Estatico.Y = 0
                Estatico.Estado = 1
                PasarPaginaPergamino_6697()
            case 1:
                DibujarTrianguloRectanguloPergamino_6906(PixelX: Estatico.X, PixelY: Estatico.Y, Lado: Estatico.TamañoTriangulo) //dibuja un triángulo rectángulo de lado TamañoTriangulo
                Estatico.Estado = 2
                SiguienteTick(Tiempoms: 20, NombreFuncion: "PasarPaginaPergamino_6697") //pequeño retardo (20 ms)
            case 2:
                //limpia la parte superior y derecha del borde del pergamino que ha sido borrada
                LimpiarParteSuperiorDerechaPergamino_663E(PixelX: Estatico.X, PixelY: Estatico.Y, LadoTriangulo: Estatico.TamañoTriangulo)
                Estatico.X = Estatico.X - 4
                Estatico.TamañoTriangulo = Estatico.TamañoTriangulo + 1
                Estatico.Linea = Estatico.Linea + 1
                if Estatico.Linea > 0x2C { //repite para 45 líneas
                    Estatico.Estado = 3
                } else {
                    Estatico.Estado = 1
                }
                PasarPaginaPergamino_6697()
            case 3:
                LimpiarParteSuperiorDerechaPergamino_663E(PixelX: Estatico.X, PixelY: Estatico.Y, LadoTriangulo: Estatico.TamañoTriangulo)
                Estatico.X = 32 //(32, 4) -> posición de inicio
                Estatico.Y = 4
                Estatico.TamañoTriangulo = 0x2F
                Estatico.Contador = 0
                Estatico.Estado = 4
                PasarPaginaPergamino_6697()
            case 4:
                DibujarTrianguloRectanguloPergamino_6906(PixelX: Estatico.X, PixelY: Estatico.Y, Lado: Estatico.TamañoTriangulo) //dibuja un triángulo rectángulo de lado TamañoTriangulo
                Estatico.Estado = 5
                SiguienteTick(Tiempoms: 20, NombreFuncion: "PasarPaginaPergamino_6697") //pequeño retardo (20 ms)
            case 5:
                PunteroPantalla = CalcularDesplazamientoPantalla_68C7(Estatico.X, Estatico.Y) // - 4)
                PunteroDatos = 2 * Estatico.Y + 0x7B8A - 0x788A //desplazamiento de los datos borrados de la parte izquierda del pergamino
                for Linea in 0...3  { //4 líneas de alto //###estaba usando la variables estática Linea. comprobar
                    PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea]
                    cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea])
                    PantallaCGA[PunteroPantalla + 1] = DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea + 1]
                    cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + 1, Color: DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea + 1])
                    PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
                }
                LimpiarParteInferiorPergamino_6705(TamañoTriangulo: Estatico.TamañoTriangulo)
                Estatico.Y = Estatico.Y + 4
                Estatico.TamañoTriangulo = Estatico.TamañoTriangulo - 1
                Estatico.Contador = Estatico.Contador + 1
                if Estatico.Contador > 0x2D { //repite 46 veces
                    Estatico.Estado = 6
                } else {
                    Estatico.Estado = 4
                }
                PasarPaginaPergamino_6697()
            case 6:
                LimpiarParteInferiorPergamino_6705(TamañoTriangulo: Estatico.TamañoTriangulo)
                LimpiarParteInferiorPergamino_6705(TamañoTriangulo: 0)
                Estatico.Estado = 0
                SiguienteTick(Tiempoms: 20, NombreFuncion: "DibujarTextosPergamino_6725")
            default:
                break
        }


    }


    public func LimpiarParteSuperiorDerechaPergamino_663E(PixelX:Int, PixelY:Int, LadoTriangulo:Int) {
        var PunteroDatos:Int
        var PunteroPantalla:Int
        var PunteroPantallaAnterior:Int
        var NumeroPixel:Int //número de pixel después del triángulo en la parte superior del pergamino
        var Linea:Int
        var XBorde:Int //coordenadas del borde derecho a restaurar
        var YBorde:Int
        NumeroPixel = 0x30 - LadoTriangulo //halla la parte del pergamino que falta por procesar
        NumeroPixel = NumeroPixel * 4 //pasa a pixels
        PunteroDatos = NumeroPixel * 2
        PunteroPantalla = CalcularDesplazamientoPantalla_68C7(PixelX + 4, PixelY) //pasa la posición actual a dirección de VRAM
        PunteroPantallaAnterior = PunteroPantalla
        for Linea in 0...7 { //8 líneas de alto
            PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + Linea]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + Linea])
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        } //completa las 8 líneas
        PunteroPantalla = PunteroPantallaAnterior //recupera la posición actual
        PunteroPantalla = PunteroPantalla + 1 //avanza 4 pixels en x
        for Linea in 8...15 {//copia los siguientes 4 pixels de otras 8 líneas
            PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + Linea]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + Linea])
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        } //completa las 8 líneas
        YBorde = (LadoTriangulo - 3) * 4
        XBorde = 0xDA //x = pixel 218
        PunteroDatos = 2 * YBorde + 0x7A0A - 0x788A
        PunteroPantalla = CalcularDesplazamientoPantalla_68C7(XBorde, YBorde) //pasa la posición actual a dirección de VRAM
        for Linea in 0...7 {//8 líneas de alto
            PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea])
            PantallaCGA[PunteroPantalla + 1] = DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea + 1]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + 1, Color: DatosGraficosPergamino_788A[PunteroDatos + 2 * Linea + 1])
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        } //completa las 8 líneas
    }

    public func LimpiarParteInferiorPergamino_6705(TamañoTriangulo:Int) {
        //restaura la parte inferior del pergamino modificada por lado TamañoTriangulo
        var PunteroDatos:Int
        var PunteroPantalla:Int
        var X:Int
        var Y:Int
        //var Contador:Int
        X = 0x20 + 4 * TamañoTriangulo
        Y = 0xB8 //y = 184
        PunteroPantalla = CalcularDesplazamientoPantalla_68C7(X, Y) //calcula el desplazamiento de las coordenadas en pantalla
        PunteroDatos = 4 * TamañoTriangulo * 2 + 0x7D0A - 0x788A //desplazamiento de los datos borrados de la parte inferior del pergamino
        for Contador in 0...7 {//8 líneas
            PantallaCGA[PunteroPantalla] = DatosGraficosPergamino_788A[PunteroDatos + Contador]
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: DatosGraficosPergamino_788A[PunteroDatos + Contador])
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        }

    }

    public func ImprimirEspacioPergamino_67CD( Hueco:Int, X: inout Int) {
        //añade un hueco del tamaño indicado, en píxeles
        X = X + Int(Hueco)
        SiguienteTick(Tiempoms: 30, NombreFuncion: "DibujarTextosPergamino_6725") //espera un poco (aprox. 30 ms)
    }

    public func DibujarCaracterPergamino_6781(PunteroCaracter_:Int = 0, Color_:UInt8) {
        //dibuja un carácter en el pergamino
        struct Estatico {
            static var Estado:UInt8 = 0
            static var PunteroCaracter:Int=0
            static var Color:UInt8=0
        }
        var Valor:Int //dato del carácter
        var AvanceX:Int
        var AvanceY:Int
        var PunteroPantalla:Int
        var Pixel:UInt8
        var InversaMascaraAND:UInt8
        var MascaraOr:UInt8
        var MascaraAnd:UInt8
        switch Estatico.Estado {
            case 0:
                Estatico.PunteroCaracter = PunteroCaracter_
                Estatico.Color = Color_
                Estatico.Estado = 1
            case 1:
                Estatico.Estado = 2
            case 2:
                Estatico.Estado = 3
            case 3:
                Estatico.Estado = 4
            case 4:
                Estatico.Estado = 5
            case 5:
                Estatico.Estado = 1
            default:
                break
        }
        Valor = Int(DatosCaracteresPergamino_6947[Estatico.PunteroCaracter - 0x6947])
        Estatico.PunteroCaracter = Estatico.PunteroCaracter + 1
        if (Valor & 0xF0) == 0xF0 { //si es el último byte del carácter
            Estatico.Estado = 0
            ImprimirEspacioPergamino_67CD(Hueco: Valor & 0xF, X: &PosicionPergaminoX_680B) //imprime un espacio y sale al bucle para imprimir más caracteres
            return
        }
        AvanceX = Valor & 0xF //avanza la posición x según los 4 bits menos significativos del byte leido de dibujo del caracter
        AvanceY = (Valor >> 4) & 0xF //avanza la posición y según los 4 bits más significativos del byte leido de dibujo del caracter
        PunteroPantalla = CalcularDesplazamientoPantalla_68C7(PosicionPergaminoX_680B + AvanceX, PosicionPergaminoY_680A + AvanceY) //calcula el desplazamiento de las coordenadas en pantalla
        Pixel = UInt8((PosicionPergaminoX_680B + AvanceX) & 0x3)        //se queda con los 2 bits menos significativos de la posición para saber que pixel pintar
        MascaraAnd = UInt8(ror8(Value: 0x88, Shift: Pixel) & 0xff)
        InversaMascaraAND = MascaraAnd ^ 0xFF
        MascaraOr = InversaMascaraAND & PantallaCGA[PunteroPantalla] //obtiene el valor del resto de pixels de la pantalla
        PantallaCGA[PunteroPantalla] = (Estatico.Color & MascaraAnd) | MascaraOr //combina con los pixels de pantalla. actualiza la memoria de video con el nuevo pixel
        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: (Estatico.Color & MascaraAnd) | MascaraOr)
        if Estatico.Estado <= 4 || depuracion.QuitarRetardos {
            DibujarCaracterPergamino_6781(PunteroCaracter_: 0, Color_: 0)
        } else {
            SiguienteTick(Tiempoms: 8, NombreFuncion: "DibujarCaracterPergamino_6781") //pequeño retardo (aprox. 8 ms)
        }
    }
    
    public func CopiarTabla(TablaOrigen: [UInt8], TablaDestino: inout [UInt8]) {
        //var Contador:Int
        for Contador in 0..<TablaOrigen.count {
            TablaDestino[Contador] = TablaOrigen[Contador]
        }
    }

    public func DibujarPantalla_19D8() {
        //dibuja la pantalla que hay en el buffer de tiles
        var ColorFondo:UInt8
        if !HabitacionOscura_156C {
            ColorFondo = 0  //color de fondo = azul
        } else {
            ColorFondo = 0xFF //color de fondo = negro
        }
        LimpiarRejilla_1A70(ColorFondo: ColorFondo) //limpia la rejilla y rellena un rectángulo de 256x160 a partir de (32, 0) con el color de fondo
        PunteroPantallaGlobal = PunteroPantallaActual_156A + 1 //avanza el byte de longitud
        GenerarEscenario_1A0A() //genera el escenerio y lo proyecta a la rejilla
        //si es una habitación iluminada, dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
        if !HabitacionOscura_156C {
            if !Check {
                DibujarPantalla_4EB2() //dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
            } else {
                DibujarPantalla_4EB2_check() //función sin retardos
            }
        } else {
            SiguienteTick(Tiempoms: 20, NombreFuncion: "BuclePrincipal_25B7_PantallaDibujada")
        }
    }

    public func LimpiarRejilla_1A70(ColorFondo:UInt8) {
        //limpia la rejilla y rellena en pantalla un rectángulo de 256x160 a partir de (32, 0) con el color indicado
        var Contador:Int
        for Contador in 0..<BufferTiles_8D80.count {
            BufferTiles_8D80[Contador] = 0 //limpia 0x8d80-0x94ff
        }
        //rellena un rectángulo de 160 de alto por 256 de ancho a partir de la posición (32, 0) con a
        PintarAreaJuego_1A7D(ColorFondo: ColorFondo)
    }

    public func PintarAreaJuego_1A7D(ColorFondo:UInt8) {
        //rellena un rectángulo de 160 de alto por 256 de ancho a partir de la posición (32, 0) con ColorFondo
        PunteroPantallaGlobal = 0x8    //posición (32, 0)
        for Linea in 1...160 {
            for Columna in 0...63 { //rellena 64 bytes (256 pixels)
                PantallaCGA[PunteroPantallaGlobal + Columna] = ColorFondo
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaGlobal + Columna, Color: ColorFondo)
            }
            PunteroPantallaGlobal = DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaGlobal)
        }
    }

    public func DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL:Int) -> Int {
        //devuelve la dirección de la siguiente línea de pantalla
        var Puntero:Int
        Puntero = PunteroPantallaHL + 0x800 //pasa al siguiente banco
        if Puntero > 0x3FFF {
            Puntero = PunteroPantallaHL & 0x7FF
            Puntero = Puntero + 0x50
        }
        //pasa a la siguiente línea y ajusta para que esté en el rango 0xc000-0xffff
        return Puntero
    }

    public func GenerarEscenario_1A0A() {
        //genera el escenerio con los datos de abadia8 y lo proyecta a la rejilla
        //lee la entrada de abadia8 con un bloque de construcción de la pantalla y llama a 0x1bbc
        var Bloque:Int
        var Byte1:UInt8
        var Byte2:UInt8
        var Byte3:UInt8
        var X:UInt8 //pos en x del elemento (sistema de coordenadas del buffer de tiles)
        var nX:UInt8 //longitud del elemento en x
        var Y:UInt8 //pos en y del elemento (sistema de coordenadas del buffer de tiles)
        var nY:UInt8 //longitud del elemento en y
        var PunteroCaracteristicasBloque:Int //puntero a las caracterísitcas del bloque
        var PunteroTilesBloque:Int //puntero del material a los tiles que forman el bloque
        var PunteroRutinasBloque:Int //puntero al resto de características del material
        var salir:Bool=false
        var BloqueHex:String
        var Eva:Int
        //PunteroPantalla = 2445

        while true { //provisional
            Pintar = true
            Bloque = Int(DatosHabitaciones_4000[PunteroPantallaGlobal])
            BloqueHex = String(format: "02%X",Bloque) //  Hex$(Bloque)
            //    Eva = Eva + 1
            //    If Eva = CInt(frmPrincipal.TxNbloque.Text) {
            //        Pintar = True
            //        EvaY CInt(frmPrincipal.TxDeltaX.Text), CInt(frmPrincipal.TxDeltaY.Text), CInt(frmPrincipal.TxProfundidad.Text)
            //        'LoveY CInt(frmPrincipal.TxDeltaX.Text), CInt(frmPrincipal.TxDeltaY.Text), CInt(frmPrincipal.TxProfundidad.Text)
            //        DatosHabitaciones_4000(PunteroPantalla + 3) = 255
            //        salir = True
            //        'Stop
            //    End If
            //1A0D
            if Bloque == 255 { return } //0xff indica el fin de pantalla
            //Bloque = Bloque And 0xFE& 'desprecia el bit inferior para indexar
            //1A10
            PunteroCaracteristicasBloque = Leer16(TablaBloquesPantallas_156D, Bloque & 0xFE) //desprecia el bit inferior para indexar
            //1A21
            Byte1 = DatosHabitaciones_4000[PunteroPantallaGlobal + 1]
            //1A24
            X = Byte1 & 0x1F //pos en x del elemento (sistema de coordenadas del buffer de tiles)
            //1A28
            nX = (Byte1 >> 5) & 0x7 //longitud del elemento en x
            //1A2F
            Byte2 = DatosHabitaciones_4000[PunteroPantallaGlobal + 2]
            //1A32
            Y = Byte2 & 0x1F //pos en y del elemento (sistema de coordenadas del buffer de tiles)
            //1A36
            nY = (Byte2 >> 5) & 0x7 //longitud del elemento en y
            //1A3D
            VariablesBloques_1FCD[0x1FDE - 0x1FCD] = 0 //inicia a (0, 0) la posición del bloque en la rejilla (sistema de coordenadas local de la rejilla)
            VariablesBloques_1FCD[0x1FDF - 0x1FCD] = 0 //inicia a (0, 0) la posición del bloque en la rejilla (sistema de coordenadas local de la rejilla)
            //1A47
            PunteroPantallaGlobal = PunteroPantallaGlobal + 3
            if (Bloque % 2) == 0 {
                Byte3 = 0xFF //la entrada es de 3 bytes
            } else {
                //1A53
                Byte3 = DatosHabitaciones_4000[PunteroPantallaGlobal]
                PunteroPantallaGlobal = PunteroPantallaGlobal + 1
            }
            //1A58
            VariablesBloques_1FCD[0x1FDD - 0x1FCD] = Byte3
            PunteroTilesBloque = Leer16(TablaCaracteristicasMaterial_1693, PunteroCaracteristicasBloque - 0x1693)
            PunteroRutinasBloque = PunteroCaracteristicasBloque + 2
            //1A69
            ConstruirBloque_1BBC(X, nX, Y, nY, Byte3, PunteroTilesBloque, PunteroRutinasBloque, true)
            if salir { return }
            Pintar = false
        }
    }

    public func DibujarPantalla_4EB2_check() {
        //dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
        var PunteroPantalla:Int
        var PunteroRejilla:Int
        var NAbajo:Int //nº de posiciones a dibujar hacia abajo
        var NArriba:Int //nº de posiciones a dibujar hacia arriba
        var NDerecha:Int //nº de posiciones a dibujar hacia la derecha
        var NIzquierda:Int  //nº de posiciones a dibujar hacia la izquierda
        var NTiles:Int //nº de posiciones a dibujar
        var DistanciaRejilla:Int //distancia entre elementos consecutivos en la rejilla. cambia si se dibuja en vertical o en horizontal
        var DistanciaPantalla:Int //distancia entre elementos consecutivos en la pantalla. cambia si se dibuja en vertical o en horizontal
        PunteroPantalla = 0x2A4  //(144, 64) coordenadas de pantalla
        PunteroRejilla = 0x90AA //(7, 8) coordenadas de rejilla
        NAbajo = 4 //inicialmente dibuja 4 posiciones verticales hacia abajo
        NArriba = 5 //inicialmente dibuja 5 posiciones verticales hacia arriba
        NDerecha = 1 //inicialmente dibuja 1 posición horizontal hacia la derecha
        NIzquierda = 2 //inicialmente dibuja 2 posiciones horizontal hacia la izquierda
        //4ECB
        while true {
            if NAbajo >= 20 { return }//si dibuja más de 20 posiciones verticales, sale
            NTiles = NAbajo
            NAbajo = NAbajo + 2 //en la próxima iteración dibujará 2 posiciones verticales más hacia abajo
            DistanciaRejilla = 0x60 //tamaño entre líneas de la rejilla
            DistanciaPantalla = 0x50 //tamaño entre líneas en la memoria de vídeo
            DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &PunteroRejilla, &PunteroPantalla) //dibuja posiciones verticales de la rejilla en la memoria de video
            //ModPantalla.Refrescar()
            NTiles = NDerecha
            NDerecha = NDerecha + 2 //en la próxima iteración dibujará 2 posiciones horizontales más hacia la derecha
            DistanciaRejilla = 6 //tamaño entre posiciones x de la rejilla
            DistanciaPantalla = 4 //tamaño entre cada 16 pixels en la memoria de video
            DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &PunteroRejilla, &PunteroPantalla) //dibuja posiciones horizontales de la rejilla en la memoria de video
            //ModPantalla.Refrescar()
            NTiles = NArriba
            NArriba = NArriba + 2 //en la próxima iteración dibujará 2 posiciones verticales más hacia arriba
            DistanciaRejilla = -0x60 //valor para volver a la línea anterior de la rejilla
            DistanciaPantalla = -0x50 //valor para volver a la línea anterior de la pantalla
            DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &PunteroRejilla, &PunteroPantalla) //dibuja  posiciones verticales de la rejilla en la memoria de video
            //ModPantalla.Refrescar()
            NTiles = NIzquierda
            NIzquierda = NIzquierda + 2 //en la próxima iteración dibujará 2 posiciones horizontales más hacia la izquierda
            DistanciaRejilla = -6 //valor para volver a la anterior posicion x de la rejilla
            DistanciaPantalla = -4 //valor para volver a la anterior posicion x de la pantalla
            DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &PunteroRejilla, &PunteroPantalla) // dibuja posiciones horizontales de la rejilla en la memoria de video
            //ModPantalla.Refrescar()
        } //repite hasta que se termine
    }

    public func DibujarPantalla_4EB2() {
        //dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
        struct Estatico {
            static var PunteroPantalla:Int=0
            static var PunteroRejilla:Int=0
            static var NAbajo:Int=0 //nº de posiciones a dibujar hacia abajo
            static var NArriba:Int=0 //nº de posiciones a dibujar hacia arriba
            static var NDerecha:Int=0 //nº de posiciones a dibujar hacia la derecha
            static var NIzquierda:Int=0  //nº de posiciones a dibujar hacia la izquierda
            static var Estado:UInt8 = 0
        }

        var NTiles:Int //nº de posiciones a dibujar
        var DistanciaRejilla:Int //distancia entre elementos consecutivos en la rejilla. cambia si se dibuja en vertical o en horizontal
        var DistanciaPantalla:Int //distancia entre elementos consecutivos en la pantalla. cambia si se dibuja en vertical o en horizontal
        switch Estatico.Estado {
            case 0:
                Estatico.PunteroPantalla = 0x2A4  //(144, 64) coordenadas de pantalla
                Estatico.PunteroRejilla = 0x90AA //(7, 8) coordenadas de rejilla
                Estatico.NAbajo = 4 //inicialmente dibuja 4 posiciones verticales hacia abajo
                Estatico.NArriba = 5 //inicialmente dibuja 5 posiciones verticales hacia arriba
                Estatico.NDerecha = 1 //inicialmente dibuja 1 posición horizontal hacia la derecha
                Estatico.NIzquierda = 2 //inicialmente dibuja 2 posiciones horizontal hacia la izquierda
                Estatico.Estado = 1
                DibujarPantalla_4EB2()
            case 1:
                //4ECB
                if Estatico.NAbajo >= 20 { //si dibuja más de 20 posiciones verticales, sale
                    Estatico.Estado = 0
                    SiguienteTick(Tiempoms: 20, NombreFuncion: "BuclePrincipal_25B7_PantallaDibujada")
                    return
                }
                NTiles = Estatico.NAbajo
                Estatico.NAbajo = Estatico.NAbajo + 2 //en la próxima iteración dibujará 2 posiciones verticales más hacia abajo
                DistanciaRejilla = 0x60 //tamaño entre líneas de la rejilla
                DistanciaPantalla = 0x50 //tamaño entre líneas en la memoria de vídeo
                DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &Estatico.PunteroRejilla, &Estatico.PunteroPantalla) //dibuja posiciones verticales de la rejilla en la memoria de video
                NTiles = Estatico.NDerecha
                Estatico.NDerecha = Estatico.NDerecha + 2 //en la próxima iteración dibujará 2 posiciones horizontales más hacia la derecha
                DistanciaRejilla = 6 //tamaño entre posiciones x de la rejilla
                DistanciaPantalla = 4 //tamaño entre cada 16 pixels en la memoria de video
                DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &Estatico.PunteroRejilla, &Estatico.PunteroPantalla) //dibuja posiciones horizontales de la rejilla en la memoria de video
                NTiles = Estatico.NArriba
                Estatico.NArriba = Estatico.NArriba + 2 //en la próxima iteración dibujará 2 posiciones verticales más hacia arriba
                DistanciaRejilla = -0x60 //valor para volver a la línea anterior de la rejilla
                DistanciaPantalla = -0x50 //valor para volver a la línea anterior de la pantalla
                DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &Estatico.PunteroRejilla, &Estatico.PunteroPantalla) //dibuja  posiciones verticales de la rejilla en la memoria de video
                NTiles = Estatico.NIzquierda
                Estatico.NIzquierda = Estatico.NIzquierda + 2 //en la próxima iteración dibujará 2 posiciones horizontales más hacia la izquierda
                DistanciaRejilla = -6 //valor para volver a la anterior posicion x de la rejilla
                DistanciaPantalla = -4 //valor para volver a la anterior posicion x de la pantalla
                DibujarTiles_4F18(NTiles, DistanciaRejilla, DistanciaPantalla, &Estatico.PunteroRejilla, &Estatico.PunteroPantalla) // dibuja posiciones horizontales de la rejilla en la memoria de video
                SiguienteTick(Tiempoms: 20, NombreFuncion: "DibujarPantalla_4EB2") //repite hasta que se termine
            default:
                break
        }
    }

    public func DibujarTiles_4F18( _ NTiles:Int,  _ DistanciaRejilla:Int,  _ DistanciaPantalla:Int,  _ PunteroRejilla: inout Int,  _ PunteroPantalla: inout Int) {
        //dibuja NTiles posiciones horizontales o verticales de la rejilla en la memoria de video
        //NTiles = número de posiciones a dibujar
        //DistanciaRejilla = tamaño entre posiciones de la rejilla
        //DistanciaPantalla = tamaño entre posiciones en la memoria de vídeo
        //PunteroRejilla = posición en el buffer
        //PunteroPantalla = posición en la memoria de vídeo
        var Contador:Int
        var NumeroTile:UInt8
        for Contador in 1...NTiles {//número de posiciones a dibujar
            NumeroTile = BufferTiles_8D80[PunteroRejilla + 2 - 0x8D80] //lee el número de gráfico a dibujar (fondo)
            if NumeroTile != 0 {
                DibujarTile_4F3D(NumeroTile, PunteroPantalla) //copia un gráfico 16x8 a la memoria de video, combinandolo con lo que había
            }
            NumeroTile = BufferTiles_8D80[PunteroRejilla + 5 - 0x8D80] //lee el número de gráfico a dibujar (fondo)
            if NumeroTile != 0 {
                DibujarTile_4F3D(NumeroTile, PunteroPantalla) //copia un gráfico 16x8 a la memoria de video, combinandolo con lo que había
            }
            PunteroRejilla = PunteroRejilla + DistanciaRejilla
            PunteroPantalla = PunteroPantalla + DistanciaPantalla
        }
    }

    public func DibujarTile_4F3D( _ NumeroTile:UInt8, _ PunteroPantalla:Int) {
        //copia el gráfico NumeroTile (16x8) en la memoria de video (PunteroPantalla), combinandolo con lo que había
        //NumeroTile = bits 7-0: número de gráfico. El bit 7 = indica qué color sirve de máscara (el 2 o el 1)
        //PunteroPantalla = posición en la memoria de video
        var PunteroTile:Int //apunta al gráfico correspondiente
        var PunteroAndOr:Int = 0 //valor de la tabla AND/OR
        var ValorAND:UInt8
        var ValorOR:UInt8
        var ValorGrafico:UInt8
        var ValorPantalla:UInt8
        //var Linea:Int
        //var Columna:Int
        PunteroTile = 32 * Int(NumeroTile) //dirección del gráfico
        if (NumeroTile & 0x80) != 0 { //dependiendo del bit 7 escoge una tabla AND y OR
            PunteroAndOr = 0x200
        }
        for Linea in 0...7 { //8 pixels de alto
            for Columna in 0...3 {//4 bytes de ancho (16 pixels)
                ValorGrafico = TilesAbadia_6D00[PunteroTile + 4 * Linea + Columna] //lee un byte del gráfico
                ValorOR = TablasAndOr_9D00[PunteroAndOr + Int(ValorGrafico)] //valor de la tabla OR
                ValorAND = TablasAndOr_9D00[PunteroAndOr + 0x100 + Int(ValorGrafico)] //valor de la tabla AND
                ValorPantalla = PantallaCGA[PunteroPantalla + Columna + Linea * 0x800]
                ValorPantalla = ValorPantalla & ValorAND
                ValorPantalla = ValorPantalla | ValorOR
                PantallaCGA[PunteroPantalla + Columna + Linea * 0x800] = ValorPantalla
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Columna + Linea * 0x800, Color: ValorPantalla)
            }
        }
    }

    public func BuscarHabitacionProvisional(NumeroPantalla:Int) -> Int {
        //devuelve el puntero al primer byte de la habitación indicada
        var Contador:Int=0
        var Puntero:Int
        Puntero = 0
        while true {
            if Contador >= NumeroPantalla {
                return Puntero
            }
            Contador = Contador + 1
            Puntero = Puntero + Int(DatosHabitaciones_4000[Puntero])
        }
    }

    public func ConstruirBloque_1BBC(_ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ Altura:UInt8, _ PunteroTilesBloque:Int, _ PunteroRutinasBloque:Int, _ ActualizarVariablesTiles:Bool) {
        //inicia el buffer para la construcción del bloque actual y evalua los parámetros de construcción del bloque
        //var Contador:Int
        if ActualizarVariablesTiles {
            for Contador in 0...11 {
                VariablesBloques_1FCD[Contador + 2] = TablaCaracteristicasMaterial_1693[PunteroTilesBloque - 0x1693 + Contador] //1FCF = buffer de destino
            }
        }
        TransformarPosicionBloqueCoordenadasRejilla_1FB8(X, Y, Altura)
        GenerarBloque_2018(X, nX, Y, nY, PunteroRutinasBloque)
    }
    public func TransformarPosicionBloqueCoordenadasRejilla_1FB8( _ X:UInt8, _ Y:UInt8, _ Altura:UInt8) {
        var Xr:Int
        var Yr:Int
        //si la entrada es de 4 bytes, transforma la posición del bloque a coordenadas de la rejilla
        // las ecuaciones de cambio de sistema de coordenadas son:
        // mapa de tiles -> rejilla
        // Xrejilla = Ymapa + Xmapa - 15
        // Yrejilla = Ymapa - Xmapa + 16
        // rejilla -> mapa de tiles
        // Xmapa = Xrejilla - Ymapa + 15
        // Ymapa = Yrejilla + Xmapa - 16
        // de esta forma los datos de la rejilla se almacenan en el mapa de tiles de forma que la conversión a la pantalla es directa
        if Altura == 0xFF { return }
        Xr = Int(Y) + Int(X) + Int(Altura >> 1) - 15
        Yr = Int(Y) - Int(X) + Int(Altura >> 1) + 16
        if Xr < 0 {
            Xr = Xr + 256
        }
        if Yr < 0 {
            Yr = Yr + 256
        }
        VariablesBloques_1FCD[0x1FDE - 0x1FCD] = UInt8(Xr)
        VariablesBloques_1FCD[0x1FDF - 0x1FCD] = UInt8(Yr)
        //comprobar
    }

    public func GenerarBloque_2018( _ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ PunteroRutinasBloque:Int) {
        //inicia el proceso de interpretación los bytes de construcción de bloques
        VariablesBloques_1FCD[0x1FDB - 0x1FCD] = nX
        VariablesBloques_1FCD[0x1FDC - 0x1FCD] = nY
        EvaluarDatosBloque_201E(X, nX, Y, nY, PunteroRutinasBloque)
    }

    public func EvaluarDatosBloque_201E( _ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ PunteroRutinasBloque:Int) {
        //evalúa los datos de construcción del bloque
        //x = pos inicial del bloque en y (sistema de coordenadas del buffer de tiles)
        //y = pos inicial del bloque en x (sistema de coordenadas del buffer de tiles)
        //ny = lgtud del elemento en y
        //nx = lgtud del elemento en x
        //PunteroRutinasBloque = puntero a los datos de construcción del bloque
        struct Estatico {
            static var TerminarEvaluacion:Bool=false
        }
        var PunteroRutinasBloque: Int = PunteroRutinasBloque
        var X:UInt8 = X
        var Y:UInt8 = Y
        var Rutina:String
        var DatosBloque:String
        Estatico.TerminarEvaluacion = false
        while true {
            DatosBloque = Bytes2AsciiHex(VariablesBloques_1FCD)
            Rutina = String(format: "%02X", TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693])
            PunteroRutinasBloque = PunteroRutinasBloque + 1
            switch Rutina {
                case "E4": //interpreta otro bloque sin modificar los valores de los tiles a usar, y cambiando el sentido de las x
                    Rutina_E4_21AA(X, nX, Y, nY, &PunteroRutinasBloque)
                case "E5": //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
                    Rutina_E9_218D()
                case "E6": //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
                    Rutina_E9_218D()
                case "E7": //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
                    Rutina_E9_218D()
                case "E8": //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
                    Rutina_E9_218D()
                case "E9": //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
                    Rutina_E9_218D()
                case "EA": //cambia el puntero a los datos de construcción del bloque con la primera dirección leida en los datos
                    Rutina_EA_21A1(X, nX, Y, nY, PunteroRutinasBloque)
                case "EB":
                    break
                case "EC": //interpreta otro bloque modificando los valores de los tiles a usar
                    Rutina_EC_21B4(X, nX, Y, nY, &PunteroRutinasBloque, true)
                case "ED":
                    break
                case "EE":
                    break
                case "EF": //incrementa la longitud del bloque en x en el buffer de construcción del bloque
                    Rutina_EF_2071(PunteroRutinasBloque)
                case "F0": //incrementa la longitud del bloque en y en el buffer de construcción del bloque
                    Rutina_F0_2077(PunteroRutinasBloque)
                case "F1": //modifica la posición en x con la expresión leida
                    Rutina_F1_2066(&X, PunteroRutinasBloque)
                case "F2": //modifica la posición en y con la expresión leida
                    Rutina_F2_205B(&Y, PunteroRutinasBloque)
                case "F3": //cambia la posición de x (x--)
                    Rutina_F3_2058(&X)
                case "F4": //cambia la posición de Y (y--)
                    Rutina_F4_2055(&Y)
                case "F5": //cambia la posición de x (x++)
                    Rutina_F5_2052(&X)
                case "F6": //cambia la posición de Y (y++)
                    Rutina_F6_204F(&Y)
                case "F7": // modifica una posición del buffer de construcción del bloque con una expresión calculada
                    Rutina_F7_2141(nX, &PunteroRutinasBloque)
                case "F8": //pinta el tile indicado por X,Y con el siguiente byte leido y cambia la posición de X,Y (x++) ó x-- si hay inversión
                    Rutina_F8_20F5(&X, &Y, PunteroRutinasBloque)
                case "F9": //pinta el tile indicado por X,Y con el siguiente byte leido y cambia la posición de X,Y (y--)
                    Rutina_F9_20E7(&X, &Y, &PunteroRutinasBloque)
                case "FA": //recupera la longitud y si no es 0, vuelve a saltar a procesar las instrucciones desde la dirección que se guardó. En otro caso, limpia la pila y continúa
                    Rutina_FA_20D7(&PunteroRutinasBloque)
                case "FB": //recupera de la pila la posición almacenada en el buffer de tiles
                    Rutina_FB_20D3(&X, &Y)
                case "FC": //guarda en la pila la posición actual en el buffer de tiles
                    Rutina_FC_20CF(X, Y)
                case "FD": //guarda en la pila la longitud del bloque en y? y la posición actual de los datos de construcción del bloque
                    Rutina_FD_209E(&PunteroRutinasBloque)
                case "FE": //guarda en la pila la longitud del bloque en x? y la posición actual de los datos de construcción del bloque
                    Rutina_FE_2091(&PunteroRutinasBloque)
                case "FF": //si se cambiaron las coordenadas x (x = -x), deshace el cambio
                    Rutina_FF_2032()
                    Estatico.TerminarEvaluacion = true
                    return //recupera la dirección del siguiente bloque a procesar
                default:
                    break
            }
            if Estatico.TerminarEvaluacion {
                if Rutina == "EC" || Rutina == "E4" {
                    Estatico.TerminarEvaluacion = false
                } else {
                    return
                }
            }
        }
    }

    public func Rutina_FF_2032() {
        //si se cambiaron las coordenadas x (x = -x), marca para deshacer el cambio la siguiente vez que pase por aquí
        if VariablesBloques_1FCD[0x1FCE - 0x1FCD] != 0 {
            VariablesBloques_1FCD[0x1FCE - 0x1FCD] = 0 //borra el indicador, pero mantiene InvertirDireccionesGeneracionBloques a true hasta la siguiente vez
        } else {
            InvertirDireccionesGeneracionBloques = false
        }
    }

    public func Rutina_F7_2141( _ nX:UInt8, _ PunteroRutinasBloque: inout Int) {
        //modifica la posición del buffer de construcción del bloque (indicada en el primer byte)
        //con una expresión calculada (indicada por los siguientes de bytes)
        //0x61 = 0x1fcf datos de materiales 1
        //0x62 = 0x1fd0 datos de materiales 2
        //0x63 = 0x1fd1 datos de materiales 3
        //0x64 = 0x1fd2 datos de materiales 4
        //0x65 = 0x1fd3 datos de materiales 5
        //0x66 = 0x1fd4 datos de materiales 6
        //0x67 = 0x1fd5 datos de materiales 7
        //0x68 = 0x1fd6 datos de materiales 8
        //0x69 = 0x1fd7 datos de materiales 9
        //0x6a = 0x1fd8 datos de materiales 10
        //0x6b = 0x1fd9 datos de materiales 11
        //0x6c = 0x1fda datos de materiales 12
        //0x6d = 0x1fdb longitud de elemento en x
        //0x6e = 0x1fdc longitud de elemento en y
        //0x6f = 0x1fdd 0xff ó altura
        //0x70 = 0x1fde posición x del bloque en la rejilla
        //0x71 = 0x1fdf posición y del bloque en la rejilla
        var Registro:UInt8
        var Valor:UInt8
        var PunteroRegistro:Int = 0
        var Resultado:Int
        var ValorAnterior:UInt8
        var PunteroRegistroGuardado:Int
        Registro = TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693]
        LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloque, &PunteroRegistro) //lee una posición del buffer de construcción del bloque y guarda en PunteroRegistro la dirección accedida
        PunteroRegistroGuardado = PunteroRegistro //guarda la dirección del buffer obtenida en la rutina anterior
        Valor = LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloque, &PunteroRegistro) // valor inicial
        Resultado = EvaluarExpresionContruccionBloque_2166(Int(Valor), &PunteroRutinasBloque, PunteroRegistro)
        if Resultado < 0  { Resultado = Resultado + 256 }
        PunteroRegistro = PunteroRegistroGuardado //recupera la dirección obtenida con el primer byte
        if Registro >= 0x70 { //si accede a la posición Y del bloque en la rejilla. por qué con 0x70 no hace lo mismo?
            ValorAnterior = VariablesBloques_1FCD[PunteroRegistro - 0x1FCD]
            if ValorAnterior == 0 { return }
            if Resultado < 0 || Resultado > 100 { Resultado = 0 } //ajusta el valor a grabar entre 0x00 y 0x64 (0 y 100). en otro caso lo pone a 0
        }
        VariablesBloques_1FCD[PunteroRegistro - 0x1FCD] = UInt8(Resultado) //actualiza el valor calculado
        //nX = CByte(Resultado)
    }

    public func LeerPosicionBufferConstruccionBloque_2214( _ PunteroRutinasBloque: inout Int, _ PunteroRegistro: inout Int) -> UInt8 {
        //lee un byte de los datos de construcción del bloque, avanzando el puntero.
        //Si leyó un dato del buffer de construcción del bloque,
        //a la salida, PunteroRegistro apuntará a dicho registro
        //si el byte leido es < 0x60, es un valor y lo devuelve
        //si el byte leido es 0x82, sale devolviendo el siguiente byte
        //en otro caso, es una operación de lectura de registro de las características del bloque
        var Valor:UInt8
        Valor = TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693] //lee el byte actual e incrementa el puntero
        PunteroRutinasBloque = PunteroRutinasBloque + 1
        return LeerRegistroBufferConstruccionBloque_2219(Valor, &PunteroRegistro, &PunteroRutinasBloque)

    }

    public func LeerRegistroBufferConstruccionBloque_2219( _ Registro:UInt8, _ PunteroRegistro: inout Int, _ PunteroRutinasBloque: inout Int) -> UInt8 {
        //lee un byte de los datos de construcción del bloque, avanzando el puntero.
        //Si leyó un dato del buffer de construcción del bloque,
        //a la salida, PunteroRegistro apuntará a dicho registro
        //si el byte leido es < 0x60, es un valor y lo devuelve
        //si el byte leido es 0x82, sale devolviendo el siguiente byte
        //en otro caso, es una operación de lectura de registro de las características del bloque
        var Registro:UInt8 = Registro
        var LeerRegistroBufferConstruccionBloque_2219:UInt8
        PunteroRegistro = 0x1FCF //apunta al buffer de datos sobre la textura
        if Registro < 0x60 {
            return Registro
        } else {
            if Registro == 0x82 {
                LeerRegistroBufferConstruccionBloque_2219 = TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693] //lee el byte actual e incrementa el puntero
                PunteroRutinasBloque = PunteroRutinasBloque + 1
                return LeerRegistroBufferConstruccionBloque_2219
            } else {
                if Registro >= 0x70 && InvertirDireccionesGeneracionBloques { Registro = Registro ^ 0x1 }
                LeerRegistroBufferConstruccionBloque_2219 = VariablesBloques_1FCD[Int(Registro) - 0x61 + 2] //0x61=índice en el buffer de construcción del bloque
                PunteroRegistro = PunteroRegistro + Int(Registro) - 0x61
                return LeerRegistroBufferConstruccionBloque_2219
            }
        }
    }

    public func EvaluarExpresionContruccionBloque_2166( _ Operando1:Int, _ PunteroRutinasBloque: inout Int, _ PunteroRegistro:Int) -> Int {
        //modifica c con sumas de valores o registros y cambios de signo
        //leidos de los datos de la construcción del bloque
        var PunteroRegistro:Int = PunteroRegistro
        var Valor:UInt8
        var Operando2:Int
        Valor = TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693]
        if Valor >= 0xC8 {
            return Operando1
        }
        if Valor == 0x84 { //si es 0x84, avanza el puntero y niega el byte leido
            PunteroRutinasBloque = PunteroRutinasBloque + 1
            return EvaluarExpresionContruccionBloque_2166(-Operando1, &PunteroRutinasBloque, PunteroRegistro)
        }
        //si llega aquí es porque accede a un registro o es un valor inmediato
        Operando2 = Int(LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloque, &PunteroRegistro)) //obtiene el siguiente byte
        if Operando2 >= 128 { Operando2 = Operando2 - 256 }
        return EvaluarExpresionContruccionBloque_2166(Operando1 + Operando2, &PunteroRutinasBloque, PunteroRegistro)
    }

    public func Rutina_E4_21AA( _ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ PunteroRutinasBloque: inout Int) {
        //interpreta otro bloque sin modificar los valores de los tiles a usar, y cambiando el sentido de las x
        VariablesBloques_1FCD[0x1FCE - 0x1FCD] = 1
        //InvertirDireccionesGeneracionBloques = True 'marca que se realizó un cambio en las operaciones que trabajan con coordenadas x en los tiles
        Rutina_EC_21B4(X, nX, Y, nY, &PunteroRutinasBloque, false)
        //InvertirDireccionesGeneracionBloques = False
    }

    public func Rutina_E9_218D() {
        //cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
        InvertirDireccionesGeneracionBloques = true
    }

    public func Rutina_EA_21A1( _ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ PunteroRutinasBloque:Int) {
        var PunteroRutinasBloque:Int = PunteroRutinasBloque
        var AnteriorPunteroRutinasBloque:Int
        AnteriorPunteroRutinasBloque = PunteroRutinasBloque
        PunteroRutinasBloque = Leer16(TablaCaracteristicasMaterial_1693, PunteroRutinasBloque - 0x1693)
        EvaluarDatosBloque_201E(X, nX, Y, nY, PunteroRutinasBloque)
        PunteroRutinasBloque = AnteriorPunteroRutinasBloque
    }

    public func Rutina_EC_21B4( _ X:UInt8, _ nX:UInt8, _ Y:UInt8, _ nY:UInt8, _ PunteroRutinasBloque: inout Int, _ ActualizarVariablesTiles:Bool) {
        //interpreta otro bloque modificando (o nó) los valores de los tiles a usar
        var X:UInt8 = X
        var Y:UInt8 = Y
        var nX:UInt8=nX
        var nY:UInt8=nY
        var InvertirDireccionesGeneracionBloquesAntiguo:Bool
        var PunteroCaracteristicasBloque:Int
        var PunteroTilesBloque:Int
        var PunteroRutinasBloqueAnterior:Int
        var Altura:UInt8
        PunteroRutinasBloqueAnterior = PunteroRutinasBloque + 2 //dirección para continuar con el proceso
        PunteroCaracteristicasBloque = Leer16(TablaCaracteristicasMaterial_1693, PunteroRutinasBloque - 0x1693)
        PunteroTilesBloque = Leer16(TablaCaracteristicasMaterial_1693, PunteroCaracteristicasBloque - 0x1693)
        PunteroRutinasBloque = PunteroCaracteristicasBloque + 2
        InvertirDireccionesGeneracionBloquesAntiguo = InvertirDireccionesGeneracionBloques //obtiene las instrucciones que se usan para tratar las x
        Push(Int(X))
        Push(Int(Y))
        Push(Int(VariablesBloques_1FCD[0x1FDE - 0x1FCD])) //obtiene las posiciones en el sistema de coordenadas de la rejilla y los guarda en pila
        Push(Int(VariablesBloques_1FCD[0x1FDF - 0x1FCD])) //obtiene las posiciones en el sistema de coordenadas de la rejilla y los guarda en pila
        Push(Int(VariablesBloques_1FCD[0x1FDB - 0x1FCD])) //obtiene los parámetros para la construcción del bloque y los guarda en pila
        nX = VariablesBloques_1FCD[0x1FDB - 0x1FCD]
        nY = VariablesBloques_1FCD[0x1FDC - 0x1FCD]
        Push(Int(VariablesBloques_1FCD[0x1FDC - 0x1FCD]))  //obtiene los parámetros para la construcción del bloque y los guarda en pila
        Altura = VariablesBloques_1FCD[0x1FDD - 0x1FCD]
        Push(Int(Altura)) //obtiene el parámetro dependiente del byte 4 y lo guarda en pila
        ConstruirBloque_1BBC(X, nX, Y, nY, Altura, PunteroTilesBloque, PunteroRutinasBloque, ActualizarVariablesTiles)
        PunteroRutinasBloque = PunteroRutinasBloqueAnterior //restaura la dirección de los datos de la rutina actual
        VariablesBloques_1FCD[0x1FDD - 0x1FCD] = UInt8(Pop())
        VariablesBloques_1FCD[0x1FDC - 0x1FCD] = UInt8(Pop())
        VariablesBloques_1FCD[0x1FDB - 0x1FCD] = UInt8(Pop())
        VariablesBloques_1FCD[0x1FDF - 0x1FCD] = UInt8(Pop())
        VariablesBloques_1FCD[0x1FDE - 0x1FCD] = UInt8(Pop())
        Y = UInt8(Pop())
        X = UInt8(Pop())
        InvertirDireccionesGeneracionBloques = InvertirDireccionesGeneracionBloquesAntiguo
    }

    public func Rutina_EF_2071( _ PunteroRutinasBloque:Int) {
        //incrementa la longitud del bloque en x
        IncrementarRegistroConstruccionBloque_2087(0x6E, 1, PunteroRutinasBloque)
    }

    public func Rutina_F0_2077( _ PunteroRutinasBloque:Int) {
        //incrementa la longitud del bloque en y
        IncrementarRegistroConstruccionBloque_2087(0x6D, 1, PunteroRutinasBloque)
    }

    public func Rutina_F1_2066( _ X: inout UInt8, _ PunteroRutinasBloque:Int) {
        //modifica la posición en x con la expresión leida
        var PunteroRutinasBloque = PunteroRutinasBloque
        var Valor:UInt8
        var Resultado:Int
        var PunteroRegistro:Int = 0
        Valor = LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloque, &PunteroRegistro) // lee un valor inmediato o un registro
        Resultado = EvaluarExpresionContruccionBloque_2166(Int(Valor), &PunteroRutinasBloque, PunteroRegistro)
        X = UInt8(Int(X) + Resultado)
    }

    public func Rutina_F2_205B( _ Y: inout UInt8, _ PunteroRutinasBloque:Int) {
        //modifica la posición en y con la expresión leida
        var PunteroRutinasBloque:Int = PunteroRutinasBloque
        var Valor:UInt8
        var Resultado:Int
        var PunteroRegistro:Int = 0
        Valor = LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloque, &PunteroRegistro) // lee un valor inmediato o un registro
        Resultado = EvaluarExpresionContruccionBloque_2166(Int(Valor), &PunteroRutinasBloque, PunteroRegistro)
        if Int(Int(Y) + Resultado) >= 256 {
            Y = UInt8(Int(Y) + Resultado - 256)
        } else {
            Y = UInt8(Int(Y) + Resultado)
        }
    }

    public func Rutina_F3_2058( _ X: inout UInt8) {
        //cambia la posición de x (x--)
        if !InvertirDireccionesGeneracionBloques {
            if X == 0 {
                X = 255
            } else {
                X = X - 1
            }
        } else {
            X = X + 1
        }
    }

    public func Rutina_F4_2055( _ Y: inout UInt8) {
        //cambia la posición de Y (y--)
        if Y == 0 {
            Y = 255
        } else {
            Y = Y - 1
        }
    }

    public func Rutina_F5_2052( _ X: inout UInt8) {
        //cambia la posición de x (x++)
        if !InvertirDireccionesGeneracionBloques {
            X = X + 1
        } else {
            X = X - 1
        }
    }

    public func Rutina_F6_204F( _ Y: inout UInt8) {
        //cambia la posición de Y (y++)
        if Y == 255 {
            Y = 0
        } else {
            Y = Y + 1
        }
    }

    public func Rutina_F8_20F5( _ X: inout UInt8, _ Y: inout UInt8, _ PunteroRutinasBloque:Int) {
        //pinta el tile indicado por X,Y con el siguiente byte leido y cambia la posición de X,Y (x++) ó x-- si hay inversión
        var PunteroRutinasBloque:Int = PunteroRutinasBloque
        if !InvertirDireccionesGeneracionBloques {
            PintarTileBuffer_20FC(&X, &Y, EnumIncremento.IncSumarX, &PunteroRutinasBloque)
        } else {
            PintarTileBuffer_20FC(&X, &Y, EnumIncremento.IncRestarX, &PunteroRutinasBloque)
        }
    }

    public func Rutina_F9_20E7( _ X: inout UInt8, _ Y: inout UInt8, _ PunteroRutinasBloque: inout Int) {
        //pinta el tile indicado por X,Y con el siguiente byte leido y cambia la posición de X,Y (y--)
        PintarTileBuffer_20FC(&X, &Y, EnumIncremento.IncRestarY, &PunteroRutinasBloque)
    }

    public func Rutina_FA_20D7( _ PunteroRutinasBloque: inout Int) {
        //recupera la longitud y si no es 0, vuelve a saltar a procesar las instrucciones desde la dirección que se guardó.
        //En otro caso, limpia la pila y continúa
        var Longitud:Int
        Longitud = Pop() //recupera de la pila la longitud del bloque (bien sea en x o en y)
        Longitud = Longitud - 1 //decrementa la longitud
        if Longitud == 0 { //si se ha terminado la longitud, saca el otro valor de la pila y salta
            Pop() //recupera la posición actual de los datos de construcción del bloque
        } else { //en otro caso, recupera los datos de la secuencia, guarda la posición decrementada y vuelve a procesar el bloque
            PunteroRutinasBloque = Pop()
            Push(PunteroRutinasBloque)
            Push(Longitud)
        }
    }

    public func Rutina_FB_20D3( _ X: inout UInt8, _ Y: inout UInt8) {
        //recupera de la pila la posición almacenada en el buffer de tiles
        Y = UInt8(Pop())
        X = UInt8(Pop())
    }

    public func Rutina_FC_20CF( _ X:UInt8,  _ Y:UInt8) {
        //guarda en la pila la posición actual en el buffer de tiles
        Push(Int(X))
        Push(Int(Y))
    }

    public func Rutina_FE_2091( _ PunteroRutinasBloque: inout Int) {
        //guarda en la pila la longitud del bloque en x? y la posición actual de los datos de construcción del bloque
        var Registro:UInt8
        var PunteroRegistro:Int = 0
        Registro = LeerRegistroBufferConstruccionBloque_2219(0x6D, &PunteroRegistro, &PunteroRutinasBloque)
        if Registro != 0 { //si es != 0, sigue procesando el material, en otro caso salta símbolos hasta que se acaben los datos de construcción
            Push(PunteroRutinasBloque)
            Push(Int(Registro))
            return
        }
        //si el bucle no se ejecuta, se salta los comandos intermedios
        SaltarComandosIntermedios_20A5(&PunteroRutinasBloque)
    }

    public func Rutina_FD_209E( _ PunteroRutinasBloque: inout Int) {
        //guarda en la pila la longitud del bloque en y? y la posición actual de los datos de construcción del bloque
        var Registro:UInt8
        var PunteroRegistro:Int = 0
        Registro = LeerRegistroBufferConstruccionBloque_2219(0x6E, &PunteroRegistro, &PunteroRutinasBloque)
        if Registro != 0 { //si es != 0, sigue procesando el material, en otro caso salta símbolos hasta que se acaben los datos de construcción
            Push(PunteroRutinasBloque)
            Push(Int(Registro))
            return
        }
        //si el bucle no se ejecuta, se salta los comandos intermedios
        SaltarComandosIntermedios_20A5(&PunteroRutinasBloque)
    }

    public func IncrementarRegistroConstruccionBloque_2087( _ Registro:UInt8, _ Incremento:Int, _ PunteroRutinasBloque:Int) {
        //modifica el registro del buffer de construcción del bloque, sumándole el valor indicado
        var PunteroRutinasBloque:Int = PunteroRutinasBloque
        var PunteroRegistro:Int = 0
        LeerRegistroBufferConstruccionBloque_2219(Registro, &PunteroRegistro, &PunteroRutinasBloque)
        VariablesBloques_1FCD[Int(Registro) - 0x61 + 2] = Z80Add(VariablesBloques_1FCD[Int(Registro) - 0x61 + 2] , UInt8(Incremento)) //0x61=índice en el buffer de construcción del bloque
    }

    public func SaltarComandosIntermedios_20A5( _ PunteroRutinasBloque: inout Int) {
        //si el bucle while no se ejecuta, se salta los comandos intermedios
        var NBucles:Int //contador de bucles
        var Valor:UInt8
        NBucles = 1 //inicialmente estamos dentro de un while
        while true {
            Valor = TablaCaracteristicasMaterial_1693[PunteroRutinasBloque - 0x1693]
            if Valor == 0x82 { //si es 0x82 (marcador), avanza de 2 en 2
                PunteroRutinasBloque = PunteroRutinasBloque + 2
            } else { //en otro caso, de 1 en 1
                PunteroRutinasBloque = PunteroRutinasBloque + 1
            }
            if Valor == 0xFE || Valor == 0xFD || Valor == 0xE8 || Valor == 0xE7 { //si encuentra 0xfe y 0xfd (nuevo while) o 0xe8 y 0xe7 (parcheadas???), sigue avanzando
                NBucles = NBucles + 1
            } else { //sigue pasando hasta encontrar un fin while
                if Valor == 0xFA { NBucles = NBucles - 1 }
                if NBucles == 0 { return } //repite hasta que se llegue al fin del primer bucle
            }
        }
    }

    public func Push( _ Valor:Int) {
        Pila[PunteroPila] = Valor
        PunteroPila = PunteroPila + 1
        if PunteroPila >= Pila.count {
            print("Error no esperado en Push")
            while true {}
        }
    }

    public func Pop() -> Int {
        var Pop:Int
        if PunteroPila == 0 {
            print("Error no esperado en Pop")
            while true {}
        }
        PunteroPila = PunteroPila - 1
        Pop = Pila[PunteroPila]
        Pila[PunteroPila] = 0
        return Pop
    }

    private func PintarTileBuffer_20FC( _ X: inout UInt8, _ Y: inout UInt8, _ Incremento:EnumIncremento, _ PunteroRutinasBloqueIX: inout Int) {
        //lee un byte del buffer de construcción del bloque que indica el número de tile, lee el siguiente byte y lo pinta en X,Y, modificando X,Y
        //si el siguiente byte >= 0xc8, pinta y sale
        //si el siguiente byte leido es 0x80 dibuja el tile en X,Y, actualiza las coordenadas y sigue procesando
        //si el siguiente byte leido es 0x81, dibuja el tile en X,Y y sigue procesando
        //si es otra cosa != 0x00, dibuja el tile en X,Y, actualiza las coordenadas las veces que haya leido, mira a ver si salta un byte y sale
        //si es otra cosa = 0x00, mira a ver si salta un byte y sale
        var Valor1:UInt8
        var Valor2:UInt8
        var PunteroRegistro:Int = 0
        var Nveces:Int
        Valor1 = LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloqueIX, &PunteroRegistro) //lee una posición del buffer de construcción del bloque o un operando
        Valor2 = TablaCaracteristicasMaterial_1693[PunteroRutinasBloqueIX - 0x1693] //lee el siguiente byte de los datos de construcción
        if Valor2 >= 0xC8 { //si es >= 0xc8, pinta, cambia X,Y según la operación y saleX,Y es visible, y si es así, actualiza el buffer de tiles
            PintarTileBuffer_1633(X, Y, Valor1, PunteroRutinasBloqueIX)
            //If Not InvertirDireccionesGeneracionBloques {
            AplicarIncrementoXY(&X, &Y, Incremento)
            //Else
            //    AplicarIncrementoXY X, Y, InvertirIncremento(Incremento)
            //End If
            return
        }
        PunteroRutinasBloqueIX = PunteroRutinasBloqueIX + 1
        if Valor2 == 0x80 { //dibuja el tile en X, Y, actualiza las coordenadas y sigue procesando
            PintarTileBuffer_1633(X, Y, Valor1, PunteroRutinasBloqueIX)
            AplicarIncrementoXY(&X, &Y, Incremento)
            PintarTileBuffer_20FC(&X, &Y, Incremento, &PunteroRutinasBloqueIX)
            return
        }
        if Valor2 == 0x81 { //dibuja el tile en X, Y  y sigue procesando
            PintarTileBuffer_1633(X, Y, Valor1, PunteroRutinasBloqueIX)
            PintarTileBuffer_20FC(&X, &Y, Incremento, &PunteroRutinasBloqueIX)
            return
        }
        //aquí llega si el byte leido no es 0x80 ni 0x81
        Nveces = Int(LeerPosicionBufferConstruccionBloque_2214(&PunteroRutinasBloqueIX, &PunteroRegistro)) //número de veces que realizar la operación
        if Nveces > 0 {
            repeat { //si lo leido es != 0, pinta  y realiza la operación nveces
                PintarTileBuffer_1633(X, Y, Valor1, PunteroRutinasBloqueIX)
                AplicarIncrementoXY(&X, &Y, Incremento)
                Nveces = Nveces - 1
            } while Nveces > 0
        }
        Valor2 = TablaCaracteristicasMaterial_1693[PunteroRutinasBloqueIX - 0x1693] //lee el siguiente byte de los datos de construcción
        if Valor2 >= 0xC8 { return }
        PunteroRutinasBloqueIX = PunteroRutinasBloqueIX + 1
        PintarTileBuffer_20FC(&X, &Y, Incremento, &PunteroRutinasBloqueIX) //salta y sigue procesando
    }

    private func AplicarIncrementoXY( _ X: inout UInt8, _ Y: inout UInt8, _ Incremento:EnumIncremento) {
        //cambia X,Y según la operación
        switch Incremento {
            case EnumIncremento.IncSumarX:
                if X == 255 {
                    X = 0
                } else {
                    X = X + 1
                }
            case EnumIncremento.IncRestarX:
                if X == 0 {
                    X = 255
                } else {
                    X = X - 1
                }
            case EnumIncremento.IncRestarY:
                if Y == 0 {
                    Y = 255
                } else {
                    Y = Y - 1
                }
        }
    }

    private func AplicarIncrementoReversibleXY(X: inout UInt8, Y: inout UInt8, Incremento:EnumIncremento) {
        //cambia X,Y según la operación, pero invierte la dirección si InvertirDireccionesGeneracionBloques=true
        if (Incremento == EnumIncremento.IncSumarX && !InvertirDireccionesGeneracionBloques) || (Incremento == EnumIncremento.IncRestarX && InvertirDireccionesGeneracionBloques) {
            if X == 255 {
                X = 0
            } else {
                X = X + 1
            }
            return
        }
        if (Incremento == EnumIncremento.IncRestarX && !InvertirDireccionesGeneracionBloques) || (Incremento == EnumIncremento.IncSumarX && InvertirDireccionesGeneracionBloques) {
            if X == 0 {
                X = 255
            } else {
                X = X - 1
            }
        }
        if Incremento == EnumIncremento.IncRestarY {
            if Y == 0 {
                Y = 255
            } else {
                Y = Y - 1
            }
        }
    }

    private func InvertirIncremento( _ Incremento: inout EnumIncremento) -> EnumIncremento {
        //devuelve la operación contraria
        var InvertirIncremento:EnumIncremento
        if Incremento == EnumIncremento.IncRestarX {
            InvertirIncremento = EnumIncremento.IncSumarX
        } else if Incremento == EnumIncremento.IncSumarX {
            InvertirIncremento = EnumIncremento.IncRestarX
        } else {
            InvertirIncremento = Incremento //Y no se ve afectada por la inversión
        }
        return InvertirIncremento
    }

    public func PintarTileBuffer_1633( _ X:UInt8, _ Y:UInt8, _ Tile:UInt8, _ PunteroRutinasBloqueIX:Int) {
        //comprueba si el tile indicado por X,Y es visible, y si es así, actualiza el tile mostrado en esta posición y los datos de profundidad asociados
        //Y = pos en y usando el sistema de coordenadas del buffer de tiles
        //X = pos en x usando el sistema de coordenadas del buffer de tiles
        //Tile = número de tile a poner
        //PunteroRutinasBloque = puntero a los datos de construcción del bloque
        var Xr:Int //coordenadas de la rejilla
        var Yr:Int
        var PunteroBufferTiles:Int
        var ProfundidadAnteriorX:UInt8
        var ProfundidadAnteriorY:UInt8
        var TileAnterior:UInt8
        var ProfundidadNuevaX:UInt8
        var ProfundidadNuevaY:UInt8
        //el buffer de tiles es de 16x20, aunque la rejilla es de 32x36. La parte de la rejilla que se mapea en el buffer de tiles es la central
        //(quitandole 8 unidades a la izquierda, derecha arriba y abajo)
        Yr = Int(Y) - 8 //traslada la posición y 8 unidades hacia arriba para tener la coordenada en el origen
        if Yr >= 20 || Yr < 0 { return }
        Xr = Int(X) - 8
        if Xr >= 16 || Xr < 0 { return }
        //1641
        PunteroBufferTiles = 96 * Yr + 6 * Xr
        //graba los datos del tile que hay en PunteroBufferTiles, según lo que valgan las coordenadas de profundidad actual y Tile (tile a escribir)
        //si ya se había proyectado un tile antes, el nuevo tiene mayor prioridad sobre el viejo
        //PunteroBufferTiles = puntero a los datos del tile actual en el buffer de tiles
        //Tile = número de tile a poner
        //166e
        ProfundidadAnteriorX = BufferTiles_8D80[PunteroBufferTiles + 3]
        ProfundidadAnteriorY = BufferTiles_8D80[PunteroBufferTiles + 4]
        TileAnterior = BufferTiles_8D80[PunteroBufferTiles + 5] //tile anterior con mayor prioridad
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 2] = TileAnterior }//(el tile anterior pasa a tener ahora menor prioridad)
        ProfundidadNuevaX = VariablesBloques_1FCD[0x1FDE - 0x1FCD]
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 3] = ProfundidadNuevaX }//nueva profundidad del tile en la rejilla (sistema de coordenadas local de la rejilla)
        ProfundidadNuevaY = VariablesBloques_1FCD[0x1FDF - 0x1FCD]
        if ProfundidadNuevaX < ProfundidadAnteriorX {
            if ProfundidadNuevaY < ProfundidadAnteriorY {
                ProfundidadAnteriorX = ProfundidadNuevaX
                ProfundidadAnteriorY = ProfundidadNuevaY
            }
        }
        //1689
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 4] = ProfundidadNuevaY }//nueva profundidad del tile en la rejilla (sistema de coordenadas local de la rejilla)
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 0] = ProfundidadAnteriorX }//vieja profundidad en X, modificado por anterior
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 1] = ProfundidadAnteriorY }//vieja profundidad en y, modificado por anterior
        if Pintar { BufferTiles_8D80[PunteroBufferTiles + 5] = Tile }
    }

    public func GenerarTablasAndOr_3AD1() {
        //genera 4 tablas de 0x100 bytes para el manejo de pixels mediante operaciones AND y OR
        //TablasAndOr
        var Puntero:Int = 0
        //var Contador:Int
        var a:Int
        var d:Int
        var e:Int
        for Contador in 0...255 {
            a = Contador                        //ld   a,c      ; a = b7 b6 b5 b4 b3 b2 b1 b0
            a = a & 0xF0                        //and  $F0      ; a = b7 b6 b5 b4 0 0 0 0
            d = a                               //ld   d,a      ; d = b7 b6 b5 b4 0 0 0 0
            a = Contador                        //ld   a,c      ; a = b7 b6 b5 b4 b3 b2 b1 b0
            a = ror8(Value: a, Shift: 1)        //rrca          ; a = b0 b7 b6 b5 b4 b3 b2 b1
            a = ror8(Value: a, Shift: 1)        //rrca          ; a = b1 b0 b7 b6 b5 b4 b3 b2
            a = ror8(Value: a, Shift: 1)        //rrca          ; a = b2 b1 b0 b7 b6 b5 b4 b3
            a = ror8(Value: a, Shift: 1)        //rrca          ; a = b3 b2 b1 b0 b7 b6 b5 b4
            e = a                               //ld   e,a      ; e = b3 b2 b1 b0 b7 b6 b5 b4
            a = a & Contador                    //and  c        ; a = b3&b7 b2&b6 b1&b5 b0&b4 b3&b7 b2&b6 b1&b5 b0&b4
            a = a & 0xF                         //and  $0F      ; a = 0 0 0 0 b3&b7 b2&b6 b1&b5 b0&b4
            a = a | d                           //or   d        ; a = b7 b6 b5 b4 b3&b7 b2&b6 b1&b5 b0&b4
            TablasAndOr_9D00[Puntero] = UInt8(a)//ld   (bc),a   ; graba pixel i = (Pi1&Pi0 Pi0) (0->0, 1->1, 2->0, 3->3)

            Puntero = Puntero + 256             //inc  b        ; apunta a la siguiente tabla
            a = e                               //ld   a,e      ; a = b3 b2 b1 b0 b7 b6 b5 b4
            a = a ^ Contador                    //xor  c        ; a = b3^b7 b2^b6 b1^b5 b0^b4 b3^b7 b2^b6 b1^b5 b0^b4
            a = a & Contador                    //and  c        ; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
            a = a & 0xF                         //and  $0F      ; a = 0 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
            d = a                               //ld   d,a      ; d = 0 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
            a = a << 1                          //add  a,a      ; a = 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0
            a = a << 1                          //add  a,a      ; a = 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0
            a = a << 1                          //add  a,a      ; a = 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0 0
            a = a << 1                          //add  a,a      ; a = (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0 0 0
            a = a | d                           //or   d        ; a = (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 (b7^b3)&b3 (b6^b2)&b2 (b5^b1)&b1 (b0^b4)&b0
            TablasAndOr_9D00[Puntero] = UInt8(a)//ld   (bc),a   ; graba pixel i = ((Pi1^Pi0)&Pi1 (Pi1^Pi0)&Pi1) (0->0, 1->0, 2->3, 3->0)

            Puntero = Puntero + 256             //inc  b        ; apunta a la siguiente tabla
            a = Contador                        //ld   a,c      ; a = b7 b6 b5 b4 b3 b2 b1 b0
            a = a & 0xF                         //and  $0F      ; a = 0 0 0 0 b3 b2 b1 b0
            d = a                               //ld   d,a      ; d = 0 0 0 0 b3 b2 b1 b0
            a = e                               //ld   a,e      ; a = b3 b2 b1 b0 b7 b6 b5 b4
            a = a & Contador                    //and  c        ; a = b3&b7 b2&b6 b1&b5 b0&b4 b3&b7 b2&b6 b1&b5 b0&b4
            a = a & 0xF0                        //and  $F0      ; a = b3&b7 b2&b6 b1&b5 b0&b4 0 0 0 0
            a = a | d                           //or   d        ; a = b3&b7 b2&b6 b1&b5 b0&b4 b3 b2 b1 b0
            TablasAndOr_9D00[Puntero] = UInt8(a) //ld   (bc),a   ; graba pixel i = (Pi1 Pi1&Pi0) (0->0, 1->0, 2->2, 3->3)

            Puntero = Puntero + 256             //inc  b        ; apunta a la siguiente tabla
            a = e                               //ld   a,e      ; a = b3 b2 b1 b0 b7 b6 b5 b4
            a = a ^ Contador                    //xor  c        ; a = b3^b7 b2^b6 b1^b5 b0^b4 b7^b3 b6^b2 b5^b1 b4^b0
            a = a & Contador                    //and  c        ; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b7^b3)&b3 (b6^b2)&b2 (b5^b1)&b1 (b4^b0)&b0
            a = a & 0xF0                        //and  $F0      ; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0 0
            d = a                               //ld   d,a      ; d = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0 0
            a = a >> 1                          //srl  a        ; a = 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0
            a = a >> 1                          //srl  a        ; a = 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0
            a = a >> 1                          //srl  a        ; a = 0 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0
            a = a >> 1                          //srl  a        ; a = 0 0 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4
            a = a | d                           //or   d        ; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4
            TablasAndOr_9D00[Puntero] = UInt8(a)//ld   (bc),a   ; graba pixel i = ((Pi1^Pi0)&Pi0 (Pi1^Pi0)&Pi0) (0->0, 1->3, 2->0, 3->0)
            Puntero = Puntero - 767 //; apunta a la tabla inicial
        }
    }

    public func Limpiar40LineasInferioresPantalla_2712() {
        var Banco:Int
        var PunteroPantalla:Int
        var Contador:Int
        PunteroPantalla = 0x640 //apunta a memoria de video
        for Banco in 1...8 {//repite el proceso para 8 bancos
            for Contador in 0...0x18F {//5 líneas
                PantallaCGA[PunteroPantalla + Contador] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Contador, Color: 0xFF)
            }
            PunteroPantalla = PunteroPantalla + 0x800 //apunta al siguiente banco
        }
    }
 
    public func CopiarVariables_37B6() {
        CopiarTabla(TablaOrigen: TablaPermisosPuertas_2DD9, TablaDestino: &CopiaTablaPermisosPuertas_2DD9) //puertas a las que pueden entrar los personajes
        CopiarTabla(TablaOrigen: TablaObjetosPersonajes_2DEC, TablaDestino: &CopiaTablaObjetosPersonajes_2DEC) //objetos de los personajes
        CopiarTabla(TablaOrigen: TablaDatosPuertas_2FE4, TablaDestino: &CopiaTablaDatosPuertas_2FE4) //datos de las puertas del juego
        CopiarTabla(TablaOrigen: TablaPosicionObjetos_3008, TablaDestino: &CopiaTablaPosicionObjetos_3008) //posición de los objetos
    }
    
    public func RellenarTablaFlipX_3A61() {
        //crea una tabla para hacer flip en x a 4 pixels
        //var Contador:Int
        //var Contador2:Int
        var NibbleSuperior:UInt8
        var NibbleInferior:UInt8
        var AcarreoI:UInt8 //acarreo por la izquierda
        var AcarreoD:UInt8 //acarreo por la derecha

        for Contador in 0...0xFF {
            NibbleSuperior = UInt8(Contador & 0xF0)
            NibbleInferior = UInt8(Contador & 0xF)
            if (NibbleSuperior & 0x80) != 0 {
                AcarreoI = 0x80
            } else {
                AcarreoI = 0
            }
            NibbleSuperior = UInt8(rol8(Value: Int(NibbleSuperior & 0x7F), Shift: 1))
            for Contador2 in 1...4 {
                if (NibbleInferior & 0x1) != 0 {
                    AcarreoD = 1
                } else {
                    AcarreoD = 0
                }
                NibbleInferior = UInt8(ror8(Value: Int(NibbleInferior & 0xFE), Shift: 1)) | AcarreoI
                if (NibbleSuperior & 0x80) != 0 {
                    AcarreoI = 0x80
                } else {
                    AcarreoI = 0
                }
                NibbleSuperior = UInt8(rol8(Value: Int(NibbleSuperior & 0x7F), Shift: 1)) | AcarreoD
            }
            TablaFlipX_A100[Contador] = NibbleSuperior | NibbleInferior
        }
    }

    public func CerrarEspejo_3A7E() {
        //obtiene la dirección en donde está la altura del espejo, obtiene la dirección del bloque
        //que forma el espejo y si estaba abierto, lo cierra
        var PunteroEspejo:Int
        var Valor:UInt8
        //var Contador:Int
        PunteroEspejo = 0x5086 //apunta a datos de altura de la planta 2
        while true {
            Valor = TablaAlturasPantallas_4A00[PunteroEspejo - 0x4A00]
            if Valor == 0xFF  { break } //0xff indica el final
            if (Valor & 0x8) != 0 { PunteroEspejo = PunteroEspejo + 1 }//incrementa la dirección 4 o 5 bytes dependiendo del bit 3
            PunteroEspejo = PunteroEspejo + 4
        }
        PunteroDatosAlturaHabitacionEspejo_34D9 = PunteroEspejo //guarda el puntero de fin de tabla (que apunta a los datos de la habitación del espejo)
        PunteroEspejo = 0x4000 //apunta a los datos de bloques de la pantallas
        for Contador in 1...0x72 {//114 pantallas
            Valor = DatosHabitaciones_4000[PunteroEspejo - 0x4000] //lee el número de bytes de la pantalla
            PunteroEspejo = PunteroEspejo + Int(Valor)
        }
        //PunteroEspejo apunta a la habitación del espejo
        for Contador in 0...255 {//hasta 256 bloques
            Valor = DatosHabitaciones_4000[PunteroEspejo - 0x4000] //lee un byte de la habitación del espejo
            PunteroEspejo = PunteroEspejo + 1
            if Valor == 0x1F { //si es 0x1f, lee los 2 bytes siguientes
                if DatosHabitaciones_4000[PunteroEspejo - 0x4000] == 0xAA && DatosHabitaciones_4000[PunteroEspejo + 1 - 0x4000] == 0x51 {
                    //si llega aquí, los datos de la habitación indican que el espejo está abierto
                    PunteroEspejo = PunteroEspejo + 1
                    DatosHabitaciones_4000[PunteroEspejo - 0x4000] = 0x11 //por lo que modifica la habitación para que el espejo se cierre
                    PunteroHabitacionEspejo_34E0 = PunteroEspejo //guarda el desplazamiento de la pantalla del espejo
                }
            }
        }
    }
    
    
    
    
    public func BuclePrincipal_25B7() {
        struct Estatico {
            static var Inicializado:Bool = false
        }
        var PunteroPersonajeHL:Int
        
        //el bucle principal del juego empieza aquí
        if !Estatico.Inicializado {
            //el abad una posición a la derecha para dejar paso
            //TablaCaracteristicasPersonajes_3036(0x3063 + 2 - 0x3036) = 0x89
            //guillermo en el espejo
            //TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x02
            //TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x26
            //TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x69
            //TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0x18
            //adso
            //TablaCaracteristicasPersonajes_3036(0x3045 + 2 - 0x3036) = 0x8D
            //TablaCaracteristicasPersonajes_3036(0x3045 + 3 - 0x3036) = 0x85
            //TablaCaracteristicasPersonajes_3036(0x3045 + 4 - 0x3036) = 0x2
            Estatico.Inicializado = true
        }

        Parado = false
        //Do
        ContadorAnimacionGuillermo_0990 = TablaCaracteristicasPersonajes_3036[0x3036 - 0x3036] //obtiene el contador de la animación de guillermo
        //25BE
        //comprueba si se pulsó QR en la habitación del espejo y actúa en consecuencia
        ComprobarQREspejo_3311()
        //25CF
        //comprueba si hay que modificar las variables relacionadas con el tiempo (momento del día, combustible de la lámpara, etc)
        ActualizarVariablesTiempo_55B6()
        //25d5
        //si se ha completado el juego, deja que arranque la secuencia del pergamino final
        if MostrarResultadoJuego_42E7() == true { return }
        //25D8
        ComprobarSaludGuillermo_42AC()
        //25DB
        //si no se ha completado el scroll del cambio del momento del día, lo avanza un paso
        AvanzarScrollMomentoDia_5499()
        //25DE
        //obtiene el estado de las voces, y ejecuta unas acciones dependiendo del momento del día
        EjecutarAccionesMomentoDia_3EEA()

        if SiguienteTickNombreFuncion != "BuclePrincipal_25B7" {
            return
        }


        //25E1
        //comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
        AjustarCamara_Bonus_41D6()
        //25e4
        ComprobarCambioPantalla_2355() //comprueba si el personaje que se muestra ha cambiado de pantalla y si es así hace muchas cosas
        //25E7
        if CambioPantalla_2DB8 {
            DibujarPantalla_19D8() //si hay que redibujar la pantalla
            return //DibujarPantalla_19D8 tiene retardos, hay que salir del bucle
            PintarPantalla_0DFD = true //modifica una instrucción de las rutinas de las puertas indicando que pinta la pantalla
        } else {
            PintarPantalla_0DFD = false
        }
        //25f5
        //comprueba si guillermo y adso cogen o dejan algún objeto
        CogerDejarObjetos_5096()
        //25f8
        //comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites de las puertas en consecuencia
        AbrirCerrarPuertas_0D67()

        //25fb
        PunteroPersonajeHL = 0x2BAE //hl apunta a la tabla de guillermo
        //25fe
        ActualizarDatosPersonaje_291D(PunteroPersonajeHL) //comprueba si guillermo puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        //2601
        EjecutarComportamientoPersonajes_2664() //mueve a adso y los monjes

        //2604
        CambioPantalla_2DB8 = false //indica que no hay que redibujar la pantalla
        CaminoEncontrado_2DA9 = false //indica que no se ha encontrado ningún camino
        //260b
        ModificarCaracteristicasSpriteLuz_26A3() //modifica las características del sprite de la luz si puede ser usada por adso
        //260e
        FlipearGraficosPuertas_0E66() //comprueba si tiene que flipear los gráficos de las puertas y si es así, lo hace
        //2611
        //comprueba si tiene que reflejar los gráficos en el espejo
        ComprobarEfectoEspejo_5374()
        //2614
        if ContadorInterrupcion_2D4B > VelocidadPasosGuillermo_2618 {
            //si guillermo se está moviendo, pone un sonido
            if (TablaCaracteristicasPersonajes_3036[0] & 0x01) != 0 {
                ReproducirPasos_1002()
            }
            //resetea el contador de la interrupción
            ContadorInterrupcion_2D4B = 0
        }

        //2627
        DibujarSprites_2674() //dibuja los sprites

        //ActualizarVariablesFormulario()

        if SiguienteTickNombreFuncion == "BuclePrincipal_25B7" {
            if depuracion.QuitarRetardos {
                SiguienteTick(Tiempoms: 5, NombreFuncion: "BuclePrincipal_25B7")
            } else {
                SiguienteTick(Tiempoms: 100, NombreFuncion: "BuclePrincipal_25B7")
            }
        }
        //2632
        //Loop
        //Parado = True
        //Exit Sub

    }

    public func BuclePrincipal_25B7_EspiralDibujada() {
        //llamada después de dibujar la espiral
        var PunteroPersonajeHL:Int
        //25E1
        //comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
        AjustarCamara_Bonus_41D6()
        //25e4
        ComprobarCambioPantalla_2355() //comprueba si el personaje que se muestra ha cambiado de pantalla y si es así hace muchas cosas
        //25E7
        if CambioPantalla_2DB8 {
            DibujarPantalla_19D8() //si hay que redibujar la pantalla
            return //DibujarPantalla_19D8 tiene retardos, hay que salir del bucle
            PintarPantalla_0DFD = true //modifica una instrucción de las rutinas de las puertas indicando que pinta la pantalla
        } else {
            PintarPantalla_0DFD = false
        }
        //25f5
        //comprueba si guillermo y adso cogen o dejan algún objeto
        CogerDejarObjetos_5096()
        //25f8
        //comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites de las puertas en consecuencia
        AbrirCerrarPuertas_0D67()

        //25fb
        PunteroPersonajeHL = 0x2BAE //hl apunta a la tabla de guillermo
        //25fe
        ActualizarDatosPersonaje_291D(PunteroPersonajeHL) //comprueba si guillermo puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        //2601
        EjecutarComportamientoPersonajes_2664() //mueve a adso y los monjes

        //2604
        CambioPantalla_2DB8 = false //indica que no hay que redibujar la pantalla
        CaminoEncontrado_2DA9 = false //indica que no se ha encontrado ningún camino
        //260b
        ModificarCaracteristicasSpriteLuz_26A3() //modifica las características del sprite de la luz si puede ser usada por adso
        //260e
        FlipearGraficosPuertas_0E66() //comprueba si tiene que flipear los gráficos de las puertas y si es así, lo hace
        //2611
        //comprueba si tiene que reflejar los gráficos en el espejo
        ComprobarEfectoEspejo_5374()
        //2614
        if ContadorInterrupcion_2D4B > VelocidadPasosGuillermo_2618 {
            //si guillermo se está moviendo, pone un sonido
            if (TablaCaracteristicasPersonajes_3036[0] & 0x01) != 0 {
                ReproducirPasos_1002()
            }
            //resetea el contador de la interrupción
            ContadorInterrupcion_2D4B = 0
        }

        //2627
        DibujarSprites_2674() //dibuja los sprites

        //ActualizarVariablesFormulario()

        if SiguienteTickNombreFuncion == "BuclePrincipal_25B7" {
            if depuracion.QuitarRetardos {
                SiguienteTick(Tiempoms: 5, NombreFuncion: "BuclePrincipal_25B7")
            } else {
                SiguienteTick(Tiempoms: 100, NombreFuncion: "BuclePrincipal_25B7")
            }
        }
        //2632
        //Loop
        //Parado = True
        //Exit Sub

    }

    public func BuclePrincipal_25B7_PantallaDibujada() {
        var PunteroPersonajeHL:Int
        //llamado cuando se acaba de dibujar la pantalla. termina el bucle principal
        PintarPantalla_0DFD = true //modifica una instrucción de las rutinas de las puertas indicando que pinta la pantalla
        PunteroPersonajeHL = 0x2BAE //hl apunta a la tabla de guillermo
        //25f8
        AbrirCerrarPuertas_0D67()
        //25fe
        ActualizarDatosPersonaje_291D(PunteroPersonajeHL) //comprueba si guillermo puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        //2601
        EjecutarComportamientoPersonajes_2664() //mueve a adso y los monjes
        //2604
        CambioPantalla_2DB8 = false //indica que no hay que redibujar la pantalla
        CaminoEncontrado_2DA9 = false //indica que no se ha encontrado ningún camino
        //260b
        ModificarCaracteristicasSpriteLuz_26A3() //modifica las características del sprite de la luz si puede ser usada por adso
        //260e
        FlipearGraficosPuertas_0E66() //comprueba si tiene que flipear los gráficos de las puertas y si es así, lo hace
        //2627
        DibujarSprites_2674() //dibuja los sprites
        //ModPantalla.Refrescar()
        SiguienteTick(Tiempoms: 100, NombreFuncion: "BuclePrincipal_25B7")
    }

    public func BuclePrincipal_Check() {
        var PunteroPersonajeHL:Int
        //el bucle principal del juego empieza aquí

        //coloca a Guillermo en posición
        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = CheckOrientacion
        TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = CheckX
        TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = CheckY
        TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = CheckZ
        TablaCaracteristicasPersonajes_3036[0x3036 + 5 - 0x3036] = CheckEscaleras

        Parado = false

        //contenido del bucle principal
        ContadorAnimacionGuillermo_0990 = TablaCaracteristicasPersonajes_3036[0x3036 - 0x3036] //obtiene el contador de la animación de guillermo
        //25e4
        ComprobarCambioPantalla_2355() //comprueba si el personaje que se muestra ha cambiado de pantalla y si es así hace muchas cosas
        //25E7
        if CambioPantalla_2DB8 {
            DibujarPantalla_19D8() //si hay que redibujar la pantalla
            PintarPantalla_0DFD = true //modifica una instrucción de las rutinas de las puertas indicando que pinta la pantalla

        } else {
            PintarPantalla_0DFD = false
        }
        PunteroPersonajeHL = 0x2BAE //hl apunta a la tabla de guillermo
        //25fe
        ActualizarDatosPersonaje_291D(PunteroPersonajeHL) //comprueba si guillermo puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        //2604
        CambioPantalla_2DB8 = false //indica que no hay que redibujar la pantalla
        //260b
        ModificarCaracteristicasSpriteLuz_26A3() //modifica las características del sprite de la luz si puede ser usada por adso
        //2627
        DibujarSprites_2674() //dibuja los sprites
        //ModPantalla.Refrescar()
        //FrmPrincipal.TxOrientacion.Text = Hex$(TablaCaracteristicasPersonajes_3036(1))
        //FrmPrincipal.TxX.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036(2))
        //FrmPrincipal.TxY.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036(3))
        //FrmPrincipal.TxZ.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036(4))
        //FrmPrincipal.TxEscaleras.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036(5))
        //2632
        Parado = true
        Check = false
        GuardarArchivo(CheckRuta + CheckPantalla + ".alt", TablaBufferAlturas_01C0) //0x23F
        GuardarArchivo(CheckRuta + CheckPantalla + ".til", BufferTiles_8D80) //0x77f
        GuardarArchivo(CheckRuta + CheckPantalla + ".tsp", TablaSprites_2E17) //0x1CC
        GuardarArchivo(CheckRuta + CheckPantalla + ".pue", TablaDatosPuertas_2FE4) //0x23
        GuardarArchivo(CheckRuta + CheckPantalla + ".obj", TablaPosicionObjetos_3008) //0x2D
        GuardarArchivo(CheckRuta + CheckPantalla + ".per", TablaCaracteristicasPersonajes_3036) //0x59
        GuardarArchivo(CheckRuta + CheckPantalla + ".ani", TablaAnimacionPersonajes_319F) //0x5F
        GuardarArchivo(CheckRuta + CheckPantalla + ".bsp", BufferSprites_9500) //0x7FF
        GuardarArchivo(CheckRuta + CheckPantalla + ".gra", TablaGraficosObjetos_A300) //0x858
        GuardarArchivo(CheckRuta + CheckPantalla + ".mon", DatosMonjes_AB59) //0x8A6
        GuardarArchivo(CheckRuta + CheckPantalla + ".cga", PantallaCGA) //0x2000
    }

    public func InicializarVariables_381E() {
        //inicia la memoria
        var Contador:Int
        var Puntero:Int
        var Valor:UInt8
        for Contador in 0...(0x20 - 1) {//limpia 0x3c85-0x3ca4 (los datos de la lógica)
            TablaVariablesLogica_3C85[Contador] = 0
        }
        for Contador in 0..<TablaVariablesAuxiliares_2D8D.count {
            TablaVariablesAuxiliares_2D8D[Contador] = 0
        }
        //###pendiente: ver qué se hace con esta tabla: TablaVariablesAuxiliares_2D8D. por ahora son variables sueltas,
        //y habra que inicializarlas
        RestaurarVariables_37B9() //copia cosas de 0x0103-0x01a9 a muchos sitios (nota: al inicializar se hizo la operación inversa)
        Puntero = 0x2E17 //apunta a la tabla con datos de los sprites
        Contador = 0x14 //cada sprite ocupa 20 bytes
        while true {
            Valor = TablaSprites_2E17[Puntero - 0x2E17]
            if Valor == 0xFF { break }
            TablaSprites_2E17[Puntero - 0x2E17] = 0xFE //pone todos los sprites como no visibles
            Puntero = Puntero + Contador
        }
        Puntero = 0x3036 //apunta a la tabla de características de los personajes
        for Contador in 0...5 {//6 entradas
            TablaCaracteristicasPersonajes_3036[Puntero - 0x3036] = 0 //pone a 0 el contador de la animación del personaje
            TablaCaracteristicasPersonajes_3036[Puntero + 1 - 0x3036] = 0 //fija la orientación del personaje mirando a +x
            TablaCaracteristicasPersonajes_3036[Puntero + 5 - 0x3036] = 0 //inicialmente el personaje ocupa 4 posiciones
            TablaCaracteristicasPersonajes_3036[Puntero + 9 - 0x3036] = 0 //indica que no hay movimientos del personaje que procesar
            TablaCaracteristicasPersonajes_3036[Puntero + 0xA - 0x3036] = 0xFD //acción que se está ejecutando actualmente
            TablaCaracteristicasPersonajes_3036[Puntero + 0xB - 0x3036] = 0 //inicia el índice en la tabla de comandos de movimiento
            Puntero = Puntero + 0xF //cada entrada ocupa 15 bytes
        }
    }
    
    public func RestaurarVariables_37B9() {
        TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] = 0xEF // máscara para las puertas donde cada bit indica que puerta se comprueba si se abre
        TablaVariablesLogica_3C85[InvestigacionNoTerminada_3CA7 - 0x3C85] = 2 //no se ha completado lainvestigación
        TablaVariablesLogica_3C85[0x3CA8 - 0x3C85] = 0xFA //TablaPosicionesPredefinidasMalaquias_3CA8(0) = 0xFA
        TablaVariablesLogica_3C85[0x3CA8 + 1 - 0x3C85] = 0 //TablaPosicionesPredefinidasMalaquias_3CA8(1) = 0
        TablaVariablesLogica_3C85[0x3CA8 + 2 - 0x3C85] = 0 //TablaPosicionesPredefinidasMalaquias_3CA8(2) = 0
        TablaVariablesLogica_3C85[0x3CC6 - 0x3C85] = 0xFA //TablaPosicionesPredefinidasAbad_3CC6(0) = 0xFA
        TablaVariablesLogica_3C85[0x3CC6 + 1 - 0x3C85] = 0 //TablaPosicionesPredefinidasAbad_3CC6(1) = 0
        TablaVariablesLogica_3C85[0x3CC6 + 2 - 0x3C85] = 0 //TablaPosicionesPredefinidasAbad_3CC6(2) = 0
        TablaVariablesLogica_3C85[0x3CE7 - 0x3C85] = 0xFA //TablaPosicionesPredefinidasBerengario_3CE7(0) = 0xFA
        TablaVariablesLogica_3C85[0x3CE7 + 1 - 0x3C85] = 0 //TablaPosicionesPredefinidasBerengario_3CE7(1) = 0
        TablaVariablesLogica_3C85[0x3CE7 + 2 - 0x3C85] = 0 //TablaPosicionesPredefinidasBerengario_3CE7(2) = 0
        TablaVariablesLogica_3C85[0x3CFF - 0x3C85] = 0xFA //TablaPosicionesPredefinidasSeverino_3CFF(0) = 0xFA
        TablaVariablesLogica_3C85[0x3CFF + 1 - 0x3C85] = 0 //TablaPosicionesPredefinidasSeverino_3CFF(1) = 0
        TablaVariablesLogica_3C85[0x3CFF + 2 - 0x3C85] = 0 //TablaPosicionesPredefinidasSeverino_3CFF(2) = 0
        TablaVariablesLogica_3C85[0x3D11 - 0x3C85] = 0xFF //TablaPosicionesPredefinidasAdso_3D11(0) = 0xFF
        TablaVariablesLogica_3C85[0x3D11 + 1 - 0x3C85] = 0 //TablaPosicionesPredefinidasAdso_3D11(1) = 0
        TablaVariablesLogica_3C85[0x3D11 + 2 - 0x3C85] = 0 //TablaPosicionesPredefinidasAdso_3D11(2) = 0
        Obsequium_2D7F = 0x1F
        NumeroDia_2D80 = 1
        MomentoDia_2D81 = 4
        PunteroProximaHoraDia_2D82 = 0x4FBC
        PunteroTablaDesplazamientoAnimacion_2D84 = 0x309F
        TiempoRestanteMomentoDia_2D86 = 0xDAC
        PunteroDatosPersonajeActual_2D88 = 0x3036
        PunteroBufferAlturas_2D8A = 0x1C0
        HabitacionEspejoCerrada_2D8C = true
        CopiarTabla(TablaOrigen: CopiaTablaPermisosPuertas_2DD9, TablaDestino: &TablaPermisosPuertas_2DD9) //puertas a las que pueden entrar los personajes
        CopiarTabla(TablaOrigen: CopiaTablaObjetosPersonajes_2DEC, TablaDestino: &TablaObjetosPersonajes_2DEC) //objetos de los personajes
        CopiarTabla(TablaOrigen: CopiaTablaDatosPuertas_2FE4, TablaDestino: &TablaDatosPuertas_2FE4) //datos de las puertas del juego
        CopiarTabla(TablaOrigen: CopiaTablaPosicionObjetos_3008, TablaDestino: &TablaPosicionObjetos_3008) //posición de los objetos
        TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] = 0x22 //posición de guillermo
        TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036] = 0x22 //posición de guillermo
        TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] = 0 //posición de guillermo
        TablaCaracteristicasPersonajes_3036[0x3047 - 0x3036] = 0x24 //posición de adso
        TablaCaracteristicasPersonajes_3036[0x3048 - 0x3036] = 0x24 //posición de adso
        TablaCaracteristicasPersonajes_3036[0x3049 - 0x3036] = 0 //posición de adso
        TablaCaracteristicasPersonajes_3036[0x3056 - 0x3036] = 0x26 //posición de malaquías
        TablaCaracteristicasPersonajes_3036[0x3057 - 0x3036] = 0x26 //posición de malaquías
        TablaCaracteristicasPersonajes_3036[0x3058 - 0x3036] = 0xF  //posición de malaquías
        TablaCaracteristicasPersonajes_3036[0x3065 - 0x3036] = 0x88 //posición del abad
        TablaCaracteristicasPersonajes_3036[0x3066 - 0x3036] = 0x84 //posición del abad
        TablaCaracteristicasPersonajes_3036[0x3067 - 0x3036] = 0x2  //posición del abad
        TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] = 0x28 //posición de berengario
        TablaCaracteristicasPersonajes_3036[0x3075 - 0x3036] = 0x48 //posición de berengario
        TablaCaracteristicasPersonajes_3036[0x3076 - 0x3036] = 0xF  //posición de berengario
        TablaCaracteristicasPersonajes_3036[0x3083 - 0x3036] = 0xC8 //posición de severino
        TablaCaracteristicasPersonajes_3036[0x3084 - 0x3036] = 0x28 //posición de severino
        TablaCaracteristicasPersonajes_3036[0x3085 - 0x3036] = 0  //posición de severino
    }

    public func DibujarAreaJuego_275C() {
        //dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
        var PunteroPantalla:Int
        //var Contador:Int
        //var Contador2:Int
        PunteroPantalla = 0
        for Contador in 1...0xA0 {//160 líneas
            for Contador2 in 0...7 {//rellena 8 bytes con 0xff (32 pixels)
                PantallaCGA[PunteroPantalla + Contador2] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Contador2, Color: 0xFF)
            }
            for Contador2 in 0...0x40 {//rellena 64 bytes con 0x00 (256 pixels)
                PantallaCGA[PunteroPantalla + 8 + Contador2] = 0
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + 8 + Contador2, Color: 0)
            }
            for Contador2 in 0...7 {//rellena 8 bytes con 0xff (32 pixels)
                PantallaCGA[PunteroPantalla + 72 + Contador2] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + 72 + Contador2, Color: 0xFF)
            }
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        }
    }

    public func DibujarMarcador_272C() {
        var PunteroDatos:Int
        var PunteroPantalla:Int
        var PunteroPantallaAnterior:Int
        //var Contador:Int
        //var Contador2:Int
        //var Contador3:Int
        PunteroDatos = 0x6328 //apunta a datos del marcador (de 0x6328 a 0x6b27)
        PunteroPantalla = 0x648 //apunta a la dirección en memoria donde se coloca el marcador (32, 160)
        for Contador in 0...3 {
            PunteroPantallaAnterior = PunteroPantalla
            for Contador2 in 0...7 {//8 líneas
                for Contador3 in 0...0x3F {//copia 64 bytes a pantalla (256 pixels)
                    PantallaCGA[PunteroPantalla + Contador3] = DatosMarcador_6328[PunteroDatos - 0x6328]
                    cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Contador3, Color: DatosMarcador_6328[PunteroDatos - 0x6328])
                    PunteroDatos = PunteroDatos + 1
                }
                PunteroPantalla = PunteroPantalla + 0x800
            }
            PunteroPantalla = PunteroPantallaAnterior
            PunteroPantalla = PunteroPantalla + 0x50
        }
    }

    public func GirarGraficosRespectoX_3552(Tabla: inout [UInt8], PunteroTablaHL:Int, AnchoC:UInt8, NGraficosB:UInt8) {
        //gira con respecto a x una serie de datos gráficos que se le pasan en Tabla
        //el ancho de los gráficos se pasa en Ancho y en NGraficos un número para calcular cuantos gráficos girar
        //var Bloque:Int //contador de líneas
        //var Contador:Int //contador dentro de la línea
        var NumeroCambios:Int
        var Valor1:UInt8
        var Valor2:UInt8
        var PunteroValor1:Int
        var PunteroValor2:Int
        NumeroCambios = (Int(AnchoC) + 1) >> 1 //Int(AnchoC + 1) / 2
        for Bloque:Int in 0..<Int(NGraficosB) {
            for Contador:Int in 0..<NumeroCambios {
                PunteroValor1 = PunteroTablaHL + Int(AnchoC) * Bloque + Contador //valor por la izquierda
                PunteroValor2 = PunteroTablaHL + Int(AnchoC) * Bloque + Int(AnchoC) - 1 - Contador //valor por la derecha
                Valor1 = Tabla[PunteroValor1]
                Valor2 = Tabla[PunteroValor2]
                //se usa la tabla auxiliar para flipx
                Valor1 = TablaFlipX_A100[Int(Valor1)]
                Valor2 = TablaFlipX_A100[Int(Valor2)]
                //intercambia los registros
                Tabla[PunteroValor1] = Valor2
                Tabla[PunteroValor2] = Valor1
            }
        }
        //3584
    }

    public func InicializarEspejo_34B0() {
        //inicializa la habitación del espejo y sus variables
        HabitacionEspejoCerrada_2D8C = true //inicialmente la habitación secreta detrás del espejo no está abierta
        NumeroRomanoHabitacionEspejo_2DBC = 0 //indica que el número romano de la habitación del espejo no se ha generado todavía
        InicializarEspejo_34B9()
    }

    public func InicializarEspejo_34B9() {
        var Contador:Int
        //DeshabilitarInterrupcion()

        for Contador in 0...4 {
            TablaAlturasPantallas_4A00[PunteroDatosAlturaHabitacionEspejo_34D9 + Contador - 0x4A00] = DatosAlturaEspejoCerrado_34DB[Contador]
        }
        //modifica la habitación del espejo para que el espejo aparezca cerrado
        EscribirValorBloqueHabitacionEspejo_336F(0x11)
        //modifica la habitación del espejo para que la trampa esté cerrada
        EscribirValorBloqueHabitacionEspejo_3372(0x1F, PunteroHabitacionEspejo_34E0 - 2)
        //HabilitarInterrupcion()
    }

    public func EscribirValorBloqueHabitacionEspejo_336F( _ Valor:UInt8) {
        //graba el valor en el bloque que forma el espejo en la habitación el espejo
        EscribirValorBloqueHabitacionEspejo_3372(Valor, PunteroHabitacionEspejo_34E0)
    }

    public func EscribirValorBloqueHabitacionEspejo_3372( _ Valor:UInt8, _ BloqueEspejoHL:Int) {
        //graba el valor en el bloque que forma el espejo en la habitación el espejo
        DatosHabitaciones_4000[BloqueEspejoHL - 0x4000] = Valor
    }

    public func InicializarDiaMomento_54D2() {
        //inicia el día y el momento del día en el que se está
        NumeroDia_2D80 = 1 //primer día
        MomentoDia_2D81 = 4 //4=nona
    }

    public func DibujarObjetosMarcador_51D4() {
        //dibuja los objetos que tiene guillermo en el marcador
        var ObjetosC:UInt8
        ObjetosC = TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC] //lee los objetos que tenemos
        ActualizarMarcador_51DA(ObjetosC: ObjetosC, MascaraA: 0xFF) //comprobar todos los objetos posibles. y si están, se dibujan
    }

    public func ActualizarMarcador_51DA(ObjetosC:UInt8, MascaraA:UInt8) {
        //comprueba si se tienen los objetos que se le pasan (se comprueban los indicados por la máscara), y si se tienen se dibujan
        var ObjetosC:UInt8=ObjetosC
        var MascaraA:UInt8=MascaraA
        var PunteroPosicionesObjetos:Int
        var PunteroSpritesObjetos:Int
        var PunteroPantalla:Int
        var PunteroPantallaAnterior:Int
        var PunteroGraficosObjeto:Int
        //var Contador:Int
        var Alto:Int
        var Ancho:Int
        //var ContadorAncho:Int
        //var ContadorAlto:Int
        PunteroPosicionesObjetos = 0x3008 //apunta a las posiciones sobre los objetos del juego
        PunteroSpritesObjetos = 0x2F1B
        PunteroPantalla = 0x6F9 //apunta a la memoria de video del primer hueco (100, 176)
        for Contador in 1...6 {//hay 6 huecos donde colocar los objetos
            if MascaraA == 0 { return } //ya no hay objetos por comprobar
            if (MascaraA & 0x80) != 0 { //comprobar objeto
                PunteroPantallaAnterior = PunteroPantalla
                if (ObjetosC & 0x80) != 0 { //objeto presente. lo dibuja
                    Alto = Int(TablaSprites_2E17[PunteroSpritesObjetos + 6 - 0x2E17]) //lee el alto del objeto
                    Ancho = Int(TablaSprites_2E17[PunteroSpritesObjetos + 5 - 0x2E17]) //lee el ancho del objeto
                    Ancho = Ancho & 0x7F //pone a 0 el bit 7
                    PunteroGraficosObjeto = Leer16(TablaSprites_2E17, PunteroSpritesObjetos + 7 - 0x2E17)
                    for ContadorAlto in 0..<Alto {
                        for ContadorAncho in 0..<Ancho {
                            PantallaCGA[PunteroPantalla + ContadorAncho] = TilesAbadia_6D00[PunteroGraficosObjeto + ContadorAlto * Ancho + ContadorAncho - 0x6D00]
                            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + ContadorAncho, Color: TilesAbadia_6D00[PunteroGraficosObjeto + ContadorAlto * Ancho + ContadorAncho - 0x6D00])
                        }
                        PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
                    }
                } else {//objeto ausente. limpia el hueco
                    for Alto in 0...11 {
                        for Ancho in 0...3 {
                            PantallaCGA[PunteroPantalla + Ancho] = 0  //limpia el pixel actual
                            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Ancho, Color: 0)
                        }
                        PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
                    }
                }
                PunteroPantalla = PunteroPantallaAnterior
            }
            PunteroPantalla = PunteroPantalla + 5 //pasa al siguiente hueco
            PunteroPosicionesObjetos = PunteroPosicionesObjetos + 5 //avanza las posiciones sobre los objetos del juego
            PunteroSpritesObjetos = PunteroSpritesObjetos + 0x14 //avanza a la siguiente entrada de las características del objeto
            if Contador == 3 { PunteroPantalla = PunteroPantalla + 1 }//al pasar del hueco 3 al 4 hay 4 pixels extra
            MascaraA = MascaraA & 0x7F
            MascaraA = MascaraA * 2 //desplaza la máscara un bit hacia la izquierda
            ObjetosC = ObjetosC & 0x7F
            ObjetosC = ObjetosC * 2 //desplaza los objetos un bit hacia la izquierda
        }
    }

    public func ActualizarDiaMarcador_5559(Dia:UInt8) {
        //actualiza el día, reflejándolo en el marcador
        var PunteroDia:Int
        var PunteroPantalla:Int
        NumeroDia_2D80 = Dia //actualiza el día
        PunteroDia = 0x4FA7 + (Int(Dia) - 1) * 3 //indexa en la tabla de los días. ajusta el índice a 0. cada entrada en la tabla ocupa 3 bytes
        PunteroPantalla = 0xEE51 - 0xC000 //apunta a pantalla (68, 165)
        DibujarNumeroDia_5583(&PunteroDia, &PunteroPantalla) //coloca el primer número de día en el marcador
        //ModPantalla.Refrescar()
        DibujarNumeroDia_5583(&PunteroDia, &PunteroPantalla) //coloca el segundo número de día en el marcador
        //ModPantalla.Refrescar()
        DibujarNumeroDia_5583(&PunteroDia, &PunteroPantalla) //coloca el tercer número de día en el marcador
        //ModPantalla.Refrescar()
        InicializarScrollMomentoDia_5575(MomentoDia: 0) //pone la primera hora del día
    }

    public func InicializarScrollMomentoDia_5575(MomentoDia:UInt8) {
        MomentoDia_2D81 = MomentoDia
        ScrollCambioMomentoDia_2DA5 = 9 //9 posiciones para realizar el scroll del cambio del momento del día
        ColocarDiaHora_550A() //pone en 0x2d86 un valor dependiente del día y la hora
    }

    public func DibujarNumeroDia_5583( _ PunteroDia: inout Int, _ PunteroPantalla: inout Int) {
        //pone un número de día
        var Sumar:Bool
        var Valor:UInt8
        var PunteroGraficos:Int
        var Contador:Int
        var PunteroPantallaAnterior:Int

        PunteroPantallaAnterior = PunteroPantalla
        Sumar = true
        Valor = TablaEtapasDia_4F7A[PunteroDia - 0x4F7A] //lee un byte de los datos que forman el número del día
        switch Valor {
            case 2:
                PunteroGraficos = 0xAB49
            case 1:
                PunteroGraficos = 0xAB39
            default:
                PunteroGraficos = 0x5581   //apunta a pixels con colores 3, 3, 3, 3
                Sumar = false
        }
        for Contador in 0...7 {//rellena las 8 líneas que ocupa la letra (8x8)
            if PunteroGraficos == 0x5581 {
                PantallaCGA[PunteroPantalla] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: 0xFF)
            } else {
                PantallaCGA[PunteroPantalla] = TablaGraficosObjetos_A300[PunteroGraficos - 0xA300]
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: TablaGraficosObjetos_A300[PunteroGraficos - 0xA300])
            }
            PunteroPantalla = PunteroPantalla + 1
            PunteroGraficos = PunteroGraficos + 1
            if PunteroGraficos == 0x5582 {
                PantallaCGA[PunteroPantalla] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: 0xFF)
            } else {
                PantallaCGA[PunteroPantalla] = TablaGraficosObjetos_A300[PunteroGraficos - 0xA300]
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: TablaGraficosObjetos_A300[PunteroGraficos - 0xA300])
            }
            PunteroPantalla = PunteroPantalla - 1
            if Sumar {
                PunteroGraficos = PunteroGraficos + 1
            } else {
                PunteroGraficos = PunteroGraficos - 1
            }
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
        }
        PunteroPantalla = PunteroPantallaAnterior + 2
        PunteroDia = PunteroDia + 1
    }

    public func ColocarDiaHora_550A() {
        //pone en 0x2d86 un valor dependiente del día y la hora
        var PunteroDuracionEtapaDia:Int
        PunteroDuracionEtapaDia = 0x4F7A + 7 * ( Int(NumeroDia_2D80) - 1 ) + Int(MomentoDia_2D81)
        TiempoRestanteMomentoDia_2D86 = Int(TablaEtapasDia_4F7A[PunteroDuracionEtapaDia - 0x4F7A]) << 8
        //el tiempo pasa más rápido que en eljuego original. ###pendiente ajustar mejor
        TiempoRestanteMomentoDia_2D86 = Int(Float(TiempoRestanteMomentoDia_2D86) * 1.6)
    }

    public func FijarPaletaMomentoDia_54DF() {
        //fija la paleta según el momento del día y muestra el número de día
        var MomentoDia_2D81Anterior:UInt8
        MomentoDia_2D81Anterior = MomentoDia_2D81
        if MomentoDia_2D81 < 6 {
            cga!.SeleccionarPaleta(2) //paleta de día
        } else {
            cga!.SeleccionarPaleta(3) //paleta de noche
        }
        //54EE
        ActualizarDiaMarcador_5559(Dia: NumeroDia_2D80) //dibuja el número de día en el marcador
        MomentoDia_2D81 = MomentoDia_2D81Anterior - 1 //recupera el momento del día en el que estaba
        PunteroProximaHoraDia_2D82 = 0x4FBC + 7 * (Int(MomentoDia_2D81) + 1) //apunta al nombre del momento del día
        ActualizarMomentoDia_553E() //avanza el momento del día
    }

    public func ActualizarMomentoDia_553E() {
        //actualiza el momento del día


        //prueba para evitar la deriva de severino
        DescartarMovimientosPensados_08BE(0x3045)
        DescartarMovimientosPensados_08BE(0x3054)
        DescartarMovimientosPensados_08BE(0x3063)
        DescartarMovimientosPensados_08BE(0x3072)
        DescartarMovimientosPensados_08BE(0x3081)



        var MomentoDiaA:UInt8
        //obtiene el momento del día
        MomentoDiaA = MomentoDia_2D81
        //avanza la hora del día
        MomentoDiaA = MomentoDiaA + 1
        //5542
        if MomentoDiaA == 7 { //si se salió de la tabla vuelve al primer momento del día
            //5546
            PunteroProximaHoraDia_2D82 = 0x4FBC
            NumeroDia_2D80 = NumeroDia_2D80 + 1 //avanza un día
            //en el caso de que se haya pasado del séptimo día, vuelve al primer día
            if NumeroDia_2D80 == 8 {
                NumeroDia_2D80 = 1
            }
            ActualizarDiaMarcador_5559(Dia: NumeroDia_2D80)
        } else {
            //5575
            InicializarScrollMomentoDia_5575(MomentoDia: MomentoDiaA)
        }
    }

    public func DecrementarObsequium_55D3(Decremento:UInt8) {
        //decrementa y actualiza en pantalla la barra de energía (obsequium)
        var TablaRellenoObsequium:[UInt8]=[0,0,0,0] //tabla con pixels para rellenar los 4 últimos pixels de la barra de obsequium
        var PunteroRelleno:UInt8 //apunta a una tabla de pixels para los 4 últimos pixels de la vida
        var Valor:UInt8
        var PunteroPantalla:Int
        TablaRellenoObsequium[0] = 0xFF
        TablaRellenoObsequium[1] = 0x7F
        TablaRellenoObsequium[2] = 0x3F
        TablaRellenoObsequium[3] = 0x1F
        Obsequium_2D7F = Z80Sub(Obsequium_2D7F, Decremento) //lee la energía y le resta las unidades leidas
        if Obsequium_2D7F > 0x80 { //aquí llega si ya no queda energía
            //55DD
            if TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] == 0 { //si guillermo está vivo
                //cambia el estado del abad para que le eche de la abadía
                TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x0B // TablaPosicionesPredefinidasAbad_3CC6(&H3CC7 - &H3CC6) = &HB
            }
            Obsequium_2D7F = 0 // actualiza el contador de energía
        }
        //55E9
        PunteroRelleno = Obsequium_2D7F & 0x3
        Valor = TablaRellenoObsequium[Int(PunteroRelleno)] //indexa en la tabla según los 2 bits menos significativos
        PunteroPantalla = 0xF1C  //apunta a pantalla (252, 177)
        DibujarBarraObsequium_560E(Ancho: UInt8(Int(Obsequium_2D7F / 4)), Relleno: 0xF, PunteroPantalla: &PunteroPantalla) //dibuja la primera parte de la barra de vida.  calcula el ancho de la barra de vida readondeada al múltiplo de 4 más cercano
        DibujarBarraObsequium_560E(Ancho: 1, Relleno: Valor, PunteroPantalla: &PunteroPantalla) //4 pixels de ancho+valor a escribir dependiendo de la vida que quede. dibuja la segunda parte de la barra de vida
        DibujarBarraObsequium_560E(Ancho: UInt8(7 - Int(Obsequium_2D7F / 4)), Relleno: 0xFF, PunteroPantalla: &PunteroPantalla) //obtiene la vida que ha perdido y rellena de negro
    }

    public func DibujarBarraObsequium_560E(Ancho:UInt8, Relleno:UInt8, PunteroPantalla: inout Int) {
        //dibuja un rectángulo de Ancho bytes de ancho y 6 líneas de alto (graba valor de relleno)
        if Ancho == 0 { return }
        //var Contador:Int
        //var Contador2:Int
        var PunteroPantallaAnterior:Int
        for Contador in 1...Ancho {
            PunteroPantallaAnterior = PunteroPantalla
            for Contador2 in 1...6 {//6 líneas de alto
                PantallaCGA[PunteroPantalla] = Relleno
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla, Color: Relleno)
                PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla)
            }
            PunteroPantalla = PunteroPantallaAnterior + 1
        }
    }

    public func LimpiarZonaFrasesMarcador_5001() {
        //limpia la parte del marcador donde se muestran las frases
        //var Contador:Int
        //var Contador2:Int
        var PunteroPantalla:Int
        PunteroPantalla = 0x2658 //apunta a pantalla (96, 164)
        for Contador in 1...8 {//8 líneas de alto
            for Contador2 in 0...0x1F {//repite hasta rellenar 128 pixels de esta línea
                PantallaCGA[PunteroPantalla + Contador2] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantalla + Contador2, Color: 0xFF)
            }
            PunteroPantalla = DireccionSiguienteLinea_3A4D_68F2(PunteroPantalla) //pasa a la siguiente línea de pantalla
        }
    }

    public func AvanzarScrollMomentoDia_5499() {
         //si no se ha completado el scroll del cambio del momento del día, lo avanza un paso
        var CaracterA:UInt8
        var PunteroPantallaHL:Int
        //var Contador:UInt8
        //var ContadorC:UInt8
        var Pixels:UInt8
         //comprueba si se ha completado el scroll del cambio del momento del día
        if ScrollCambioMomentoDia_2DA5 == 0 { return }
         //549E
         //en otro caso, queda una iteración menos
         ScrollCambioMomentoDia_2DA5 = ScrollCambioMomentoDia_2DA5 - 1
        if ScrollCambioMomentoDia_2DA5 < 7 {
             //54A8
             //lee un caracter
             CaracterA = TablaEtapasDia_4F7A[PunteroProximaHoraDia_2D82 - 0x4F7A]
             //actualiza el puntero a la próxima hora del día
             PunteroProximaHoraDia_2D82 = PunteroProximaHoraDia_2D82 + 1
        } else {
             CaracterA = 0x20 //a = espacio en blanco
        }
        //54B0
        //hace el efecto de scroll del texto del día 8 pixels hacia la izquierda
        //l = coordenada X (en bytes) + 32 pixels, h = coordenada Y (en pixels)
        //graba la posición inicial para el scroll (84, 180)
        PunteroCaracteresPantalla_2D97 = 0xB40D
        //apunta a pantalla (44, 180)
        PunteroPantallaHL = 0xE6EB
        for Contador in 0...7 { //8 líneas
            //54BC
            //hace el scroll 8 pixels a la izquierda
            for ContadorC in 0...11 { //12 bytes
                Pixels = PantallaCGA[PunteroPantallaHL + ContadorC - 0xC000]
                PantallaCGA[PunteroPantallaHL - 2 + ContadorC - 0xC000] = Pixels
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL - 2 + ContadorC - 0xC000, Color: Pixels)
            }
            //54C7
            PunteroPantallaHL = 0xC000 + DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL - 0xC000)
        } //completa las 8 líneas
        //imprime un carácter
        ImprimirCaracter_3B19(CaracterA: CaracterA, AjusteColorC: 0x0F)
    }
     
    public func ImprimirCaracter_3B19(CaracterA:UInt8, AjusteColorC:UInt8) {
        //imprime el carácter que se le pasa en a en la pantalla
        //usa la posición de pantalla que hay en 0x2d97
        var CaracterA:UInt8 = CaracterA
        var PunteroCaracteresDE:Int=0
        var PunteroPantallaHL:Int
        var Espacio:Bool=false
        var X:UInt8=0
        var Y:UInt8=0
        //var Contador:UInt8
        var DatoCaracterA:UInt8
        var Valor:UInt8
        //se asegura de que el caracter esté entre 0 y 127
        CaracterA = CaracterA & 0x7F
        //3b20
        if CaracterA != 0x20 {
            //3b22
            //si el carácter a imprimir es < 0x2d, no es imprimible y sale
            if CaracterA < 0x2D { return }
            //3b25
            //cada caracter de la tabla de caracteres ocupa 8 bytes
            //la tabla de los gráficos de los caracteres empieza en 0xb400
            PunteroCaracteresDE = 8 * (Int(CaracterA) - 0x2D) + 0xB400
        } else {
            Espacio = true
        }
        //3b30
        //lee la dirección de pantalla por la que va escribiendo actualmente (h = y en pixels, l = x en bytes)
        Integer2Nibbles(Value: PunteroCaracteresPantalla_2D97, HighNibble: &Y, LowNibble: &X)
        //convierte hl a direccion de pantalla
        PunteroPantallaHL = ObtenerDesplazamientoPantalla_3C42(X, Y)
        //3B37
        for Contador in 0...7 {//8 líneas
            //3B39
            //lee un byte que forma el caracter
            if !Espacio {
                DatoCaracterA = TablaCaracteresPalabrasFrases_B400[PunteroCaracteresDE - 0xB400]
            } else {
                DatoCaracterA = 0
            }
            //se queda con los 4 bits superiores (4 pixels izquierdos del carácter)
            //y opera con el ajuste de color
            Valor = (DatoCaracterA & 0xF0) ^ AjusteColorC
            //3B3D
            //graba el byte en pantalla
            PantallaCGA[PunteroPantallaHL - 0xC000] = Valor
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL - 0xC000, Color: Valor)
            //se queda con los 4 bits superiores (4 pixels izquierdos del carácter)
            Valor = (DatoCaracterA << 4) ^ AjusteColorC
            //3B45
            //graba el byte en pantalla
            PantallaCGA[PunteroPantallaHL + 1 - 0xC000] = Valor
            cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL + 1 - 0xC000, Color: Valor)
            PunteroPantallaHL = 0xC000 + DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL - 0xC000)
            PunteroCaracteresDE = PunteroCaracteresDE + 1
        }
        //avanza 8 pixels para la próxima ejecución
        PunteroCaracteresPantalla_2D97 = PunteroCaracteresPantalla_2D97 + 2
    }

    public func ObtenerDesplazamientoPantalla_3C42( _ X:UInt8, _ Y:UInt8) -> Int {
        //; dados X,Y, calcula el desplazamiento correspondiente en pantalla
        //al valor calculado se le suma 32 pixels a la derecha (puesto que el área de juego va desde x = 32 a x = 256 + 32 - 1
        //l = coordenada X (en bytes)
        var PunteroPantalla:Int
        var ValorLong:Int
        PunteroPantalla = Int(Y & 0xF8) //obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
        //dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
        //o lo que es lo mismo, (y >> 3)*0x50
        PunteroPantalla = 10 * PunteroPantalla //PunteroPantalla = desplazamiento dentro del banco
        ValorLong = Int(Y & 0x7) //3 bits menos significativos en y (para calcular al banco de VRAM al que va)
        ValorLong = ValorLong << 11 //ajusta los 3 bits
        PunteroPantalla = PunteroPantalla | ValorLong //completa el cálculo del banco
        PunteroPantalla = PunteroPantalla | 0xC000
        PunteroPantalla = PunteroPantalla + Int(X) //suma el desplazamiento en x
        PunteroPantalla = PunteroPantalla + 8 //ajusta para que salga 32 pixels más a la derecha
        return PunteroPantalla
    }
    
//sexta--------------------------------------------------------------------------------------

//nona--------------------------------------------------------------------------------------

     public func ComprobarCambioPantalla_2355() {

         //comprueba si el personaje que se muestra ha cambiado de pantalla y si es así, obtiene los datos de alturas de la nueva pantalla,
         //modifica los valores de las posiciones del motor ajustados para la nueva pantalla, inicia los sprites de las puertas y de los objetos
         //del juego con la orientación de la pantalla actual y modifica los sprites de los personajes según la orientación de pantalla
         var Cambios:UInt8=0 //inicialmente no ha habido cambios
         var PosicionX:UInt8
         var PosicionY:UInt8
         var PosicionZ:UInt8
         var AlturaBase:UInt8
         var PosX:UInt8 //parte alta de la posición en X del personaje actual (en los 4 bits inferiores)
         var PosY:UInt8 //parte alta de la posición en Y del personaje actual (en los 4 bits inferiores)
         var PunteroHabitacion:Int
         var PantallaActual:UInt8
         var PunteroDatosPersonajesHL:Int
         var PunteroSpritePersonajeIX:Int //dirección del sprite asociado al personaje
         var PunteroDatosPersonajeIY:Int //dirección a los datos de posición del personaje asociado al sprite
         var ValorBufferAlturas:UInt8 //valor a poner en las posiciones que ocupa el personaje en el buffer de alturas
         //cambio de cámara para depuración
         if depuracion.CamaraManual { //hay que ajustar manualmente la cámara al personaje indicado
             TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] = depuracion.CamaraPersonaje
             PunteroDatosPersonajeActual_2D88 = 0x3036 + 0x0F * Int(depuracion.CamaraPersonaje)
         }

         PosicionX = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeActual_2D88 + 2 - 0x3036] //lee la posición en X del personaje actual
         //2361
         PosicionX = PosicionX & 0xF0
         if PosicionX != PosicionXPersonajeActual_2D75 { //posición X ha cambiado
             //2366
             Cambios = Cambios + 1 //indica el cambio
             PosicionXPersonajeActual_2D75 = PosicionX //actualiza la posición de la pantalla actual
             LimiteInferiorVisibleX_2AE1 = PosicionX - 12 //limite inferior visible de X
         }
         PosicionY = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeActual_2D88 + 3 - 0x3036] //lee la posición en Y del personaje actual
         PosicionY = PosicionY & 0xF0
         if PosicionY != PosicionYPersonajeActual_2D76 { //posición Y ha cambiado
             //2376
             Cambios = Cambios + 1 //indica el cambio
             PosicionYPersonajeActual_2D76 = PosicionY //actualiza la posición de la pantalla actual
             LimiteInferiorVisibleY_2AEB = PosicionY - 12 //limite inferior visible de y
         }
         //237D
         PosicionZ = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeActual_2D88 + 4 - 0x3036] //lee la posición en Z del personaje actual
         //2381
         AlturaBase = LeerAlturaBasePlanta_2473(PosicionZ) //dependiendo de la altura, devuelve la altura base de la planta
         //2384
         if AlturaBase != PosicionZPersonajeActual_2D77 { //altura Z ha cambiado
             //2388
             AlturaBasePlantaActual_2AF9 = AlturaBase //altura base de la planta
             //238B
             PosicionZPersonajeActual_2D77 = AlturaBase
             //238C
             Cambios = Cambios + 1 //indica el cambio
             switch AlturaBase {
                 case 0:
                     PunteroPlantaActual_23EF = 0x2255 //apunta a los datos de la planta baja
                 case 0xB:
                     PunteroPlantaActual_23EF = 0x22E5 //apunta a los datos de la primera planta
                 default:
                     PunteroPlantaActual_23EF = 0x22ED //apunta a los datos de la segunda planta
             }
         }
         //23A0
         if Cambios == 0 { return } // si no ha habido ningún cambio de pantalla, sale
         //23A3
         CambioPantalla_2DB8 = true //indica que ha habido un cambio de pantalla
         //23A6
         //averigua si es una habitación iluminada o no
         HabitacionOscura_156C = false
         if PosicionZPersonajeActual_2D77 == 0x16 { //si está en la segunda planta
             //en la segunda planta las habitaciones iluminadas son la 67, 73 y 72
             if PosicionXPersonajeActual_2D75 >= 0x20 { //67 y 73 tienen x<0x20
                 if PosicionYPersonajeActual_2D76 != 0x60 { //60 tiene Y=0x60
                     HabitacionOscura_156C = true //la pantalla no está iluminada
                 }
             }
         }
         if depuracion.Luz == EnumTipoLuz.EnumTipoLuz_ON {
             HabitacionOscura_156C = false //###depuración
         } else if depuracion.Luz == EnumTipoLuz.EnumTipoLuz_Off {
             HabitacionOscura_156C = true //###depuración
         }
         //23C9
         //aquí se llega con HabitacionIluminada_156C a true o false
         TablaSprites_2E17[0x2FCF - 0x2E17] = 0xFE //marca el sprite de la luz como no visible
         //23CE
         PosX = (PosicionXPersonajeActual_2D75 & 0xF0) >> 4 //pone en los 4 bits menos significativos de Valor los 4 bits más significativos de PosicionX
         PosY = (PosicionYPersonajeActual_2D76 & 0xF0) >> 4 //pone en los 4 bits menos significativos de Valor los 4 bits más significativos de PosicionY
         OrientacionPantalla_2481 = (((PosY & 0x1) ^ (PosX & 0x1)) | ((PosX & 0x1) * 2))
         PunteroHabitacion = ((Int(PosicionYPersonajeActual_2D76) & 0xF0) | Int(PosX)) + PunteroPlantaActual_23EF //(Y, X) (desplazamiento dentro del mapa de la planta)
         //23F2
         PantallaActual = TablaHabitaciones_2255[PunteroHabitacion - 0x2255] //lee la pantalla actual
         //FrmPrincipal.TxNumeroHabitacion.Text = "0x" + String(format: "%02X", (PantallaActual)
         //23F3
         GuardarDireccionPantalla_2D00(PantallaActual) //guarda en 0x156a-0x156b la dirección de los datos de la pantalla actual
         //23F6
         RellenarBufferAlturas_2D22(PunteroDatosPersonajeActual_2D88) //rellena el buffer de alturas con los datos leidos de la abadia y recortados para la pantalla actual
         //23F9
         PunteroTablaDesplazamientoAnimacion_2D84 = Int(OrientacionPantalla_2481) << 6 //coloca la orientación en los 2 bits superiores para indexar en la tabla (cada entrada son 64 bytes)
         PunteroTablaDesplazamientoAnimacion_2D84 = PunteroTablaDesplazamientoAnimacion_2D84 + 0x309F //apunta a la tabla para el cálculo del desplazamiento según la animación de una entidad del juego
         //tabla de rutinas a llamar en 0x2add según la orientación de la cámara
         //225D:
         //    248A 2485 248B 2494
         switch OrientacionPantalla_2481 {
             case 0:
                 RutinaCambioCoordenadas_2B01 = 0x248A
             case 1:
                 RutinaCambioCoordenadas_2B01 = 0x2485
             case 2:
                 RutinaCambioCoordenadas_2B01 = 0x248B
             case 3:
                 RutinaCambioCoordenadas_2B01 = 0x2494
            default:
                break
         }
         //241A
         InicializarSpritesPuertas_0D30() //inicia los sprites de las puertas del juego para la habitación actual
         //241D
         InicializarObjetos_0D23() //inicia los sprites de los objetos del juego para la habitación actual
         //2420
         PunteroDatosPersonajesHL = 0x2BAE //apunta a la tabla con datos para los sprites de los personajes
         var DE:String
         var HL:String
         while true {
             //2423
             PunteroSpritePersonajeIX = Leer16(TablaPunterosPersonajes_2BAE, PunteroDatosPersonajesHL - 0x2BAE) //dirección del sprite asociado al personaje
             DE = String(format: "%02X", PunteroSpritePersonajeIX)
             if PunteroSpritePersonajeIX == 0xFFFF  { return }
             //mientras no lea 0xff, continúa
             //242a
             PunteroDatosPersonajeIY = Leer16(TablaPunterosPersonajes_2BAE, PunteroDatosPersonajesHL + 2 - 0x2BAE) //dirección a los datos de posición del personaje asociado al sprite
             HL = String(format: "%02X", PunteroDatosPersonajesHL + 2)
             DE = String(format: "%02X", PunteroDatosPersonajeIY)
             //242f
             //la rutina de script no se usa
             //PunteroRutinaScriptPersonaje = Leer16(TablaDatosPersonajes_2BAE, PunteroDatosPersonajesHL + 4 - 0x2BAE) //dirección de la rutina en la que el personaje piensa
             //HL = Hex$(PunteroDatosPersonajesHL + 4)
             //DE = Hex$(PunteroRutinaScriptPersonaje)
             //2436
             PunteroRutinaFlipPersonaje_2A59 = Leer16(TablaPunterosPersonajes_2BAE, PunteroDatosPersonajesHL + 6 - 0x2BAE) //rutina a la que llamar si hay que flipear los gráficos
             HL = String(format: "%02X", PunteroDatosPersonajesHL + 6)
             DE = String(format: "%02X", PunteroRutinaFlipPersonaje_2A59)
             //2441
             PunteroTablaAnimacionesPersonaje_2A84 = Leer16(TablaPunterosPersonajes_2BAE, PunteroDatosPersonajesHL + 8 - 0x2BAE) //dirección de la tabla de animaciones para el personaje
             HL = String(format: "%02X", PunteroDatosPersonajesHL + 8)
             DE = String(format: "%02X", PunteroTablaAnimacionesPersonaje_2A84)
             //2449
             ProcesarPersonaje_2468(PunteroSpritePersonajeIX, PunteroDatosPersonajeIY, PunteroDatosPersonajesHL + 0xA) //procesa los datos del personaje para cambiar la animación y posición del sprite e indicar si es visible o no
             //2455
             ValorBufferAlturas = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeIY + 0xE - 0x3036] //valor a poner en las posiciones que ocupa el personaje en el buffer de alturas
             //2458
             RellenarBufferAlturasPersonaje_28EF(PunteroDatosPersonajeIY, ValorBufferAlturas)
             //245B
             PunteroDatosPersonajesHL = PunteroDatosPersonajesHL + 10 //pasa al siguiente personaje
         }
     }

     public func LeerAlturaBasePlanta_2473( _ PosicionZ:UInt8) -> UInt8 {
         //dependiendo de la altura indicada, devuelve la altura base de la planta
        var LeerAlturaBasePlanta_2473:UInt8
         if PosicionZ < 13 {
             LeerAlturaBasePlanta_2473 = 0 //si la altura es < 13 sale con 0 (00-12 -> planta baja)
         } else if PosicionZ >= 24 {
             LeerAlturaBasePlanta_2473 = 22 //si la altura es >= 24 sale con b = 22 (24- -> segunda planta)
         } else {
             LeerAlturaBasePlanta_2473 = 11 //si la altura es >= 13 y < 24 sale con b = 11 (13-23 -> primera planta)
         }
        return LeerAlturaBasePlanta_2473
    }

    public func GuardarDireccionPantalla_2D00( _ NumeroPantalla:UInt8) {
         //guarda en 0x156a-0x156b la dirección de los datos de la pantalla a
         var PunteroDatosPantalla:Int
         var TamañoPantalla:UInt8
         //var Contador:Int
         NumeroPantallaActual_2DBD = NumeroPantalla //guarda la pantalla actual
         PunteroDatosPantalla = 0
         if NumeroPantalla != 0 { //si la pantalla actual  está definida (o no es la número 0)
             for Contador in 1...NumeroPantalla {
                 TamañoPantalla = DatosHabitaciones_4000[PunteroDatosPantalla]
                 PunteroDatosPantalla = PunteroDatosPantalla + Int(TamañoPantalla)
             }
         }
         PunteroPantallaActual_156A = PunteroDatosPantalla
     }

    public func RellenarBufferAlturas_2D22( _ PunteroDatosPersonaje:Int) {
         //rellena el buffer de alturas indicado por 0x2d8a con los datos leidos de abadia7 y recortados para la pantalla del personaje que se le pasa en iy
         var Contador:Int
         var AlturaBase:UInt8 //altura base de la planta
         var PunteroAlturasPantalla:Int
         var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4
         if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
         for Contador in 0...0x23F {
             if !BufferAuxiliar {
                 TablaBufferAlturas_01C0[Contador] = 0 //limpia 576 bytes (24x24) = (4 + 16 + 4)x2
             } else {
                 TablaBufferAlturas_96F4[Contador] = 0 //limpia 576 bytes (24x24) = (4 + 16 + 4)x2
             }
         }
         //calcula los mínimos valores visibles de pantalla para la posición del personaje
         AlturaBase = CalcularMinimosVisibles_0B8F(PunteroDatosPersonaje)
         switch AlturaBase {
             case 0:
                 PunteroAlturasPantalla = 0x4A00 //valores de altura de la planta baja
             case 0xB:
                 PunteroAlturasPantalla = 0x4F00 //valores de altura de la primera planta
             default:
                 PunteroAlturasPantalla = 0x5080 //valores de altura de la segunda planta
         }
         RellenarBufferAlturas_3945_3973(PunteroAlturasPantalla) //rellena el buffer de pantalla con los datos leidos de la abadia recortados para la pantalla actual
     }

     public func CalcularMinimosVisibles_0B8F( _ PunteroDatosPersonaje:Int) -> UInt8 {
         //dada la posición de un personaje, calcula los mínimos valores visibles de pantalla y devuelve la altura base de la planta
         var PosicionX:UInt8
         var PosicionY:UInt8
         var Altura:UInt8
         var PersonajeCamara:Bool = false //true si el puntero del personaje es 0x2d73. este puntero
         //se refiere a un área de memoria donde se guarda la posición del personaje al que sigue la
         //cámara.
         if PunteroDatosPersonaje == 0x2D73 { PersonajeCamara = true } //personaje extra
         if !PersonajeCamara {
             PosicionX = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonaje + 2 - 0x3036] //lee la posición en x del personaje
         } else {
             PosicionX = PosicionXPersonajeActual_2D75 //lee la posición en x del personaje al que sigue la cámara
         }
         PosicionX = (PosicionX & 0xF0) - 4 //se queda con la mínima posición visible en X de la parte más significativa
         MinimaPosicionXVisible_27A9 = PosicionX
         if !PersonajeCamara {
             PosicionY = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonaje + 3 - 0x3036] //lee la posición en y del personaje
         } else {
             PosicionY = PosicionYPersonajeActual_2D76 //lee la posición en y del personaje al que sigue la cámara
         }
         PosicionY = (PosicionY & 0xF0) - 4 //se queda con la mínima posición visible en y de la parte más significativa
         MinimaPosicionYVisible_279D = PosicionY
         if !PersonajeCamara {
             Altura = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonaje + 4 - 0x3036] //lee la altura del personaje
         } else {
             Altura = PosicionZPersonajeActual_2D77 //lee la posición en z del personaje al que sigue la cámara
         }
         MinimaAlturaVisible_27BA = LeerAlturaBasePlanta_2473(Altura) //dependiendo de la altura, devuelve la altura base de la planta
         AlturaBasePlantaActual_2DBA = MinimaAlturaVisible_27BA
         return MinimaAlturaVisible_27BA
    }

    public func RellenarBufferAlturas_3945_3973( _ PunteroAlturasPantalla:Int) {
         //rellena el buffer de pantalla con los datos leidos de la abadia recortados para la pantalla actual
         //entradas:
         //    byte 0
         //        bits 7-4: valor inicial de altura
         //        bit 3: si es 0, entrada de 4 bytes. si es 1, entrada de 5 bytes
         //        bit 2-0: tipo de elemento de la pantalla
         //            si es 0, 6 o 7, sale
         //            si es del 1 al 4 recorta (altura cambiante)
         //            si es 5, recorta (altura constante)
         //    byte 1: coordenada X de inicio
         //    byte 2: coordenada Y de inicio
         //    byte 3: si longitud == 4 bytes
         //        bits 7-4: número de unidades en X
         //        bits 3-0: número de unidades en Y
         //            si longitud == 5 bytes
         //        bits 7-0: número de unidades en X
         //    byte 4 número de unidades en Y
         var PunteroAlturasPantalla:Int = PunteroAlturasPantalla
         var Byte0:UInt8
         var Byte1:UInt8
         var Byte2:UInt8
         var Byte3:UInt8
         var Byte4:UInt8
         var X:UInt8 //coordenada X de inicio
         var Y:UInt8 //coordenada Y de inicio
         var Z:UInt8 //valor inicial de altura
         var nX:UInt8 //número de unidades en X
         var nY:UInt8 //número de unidades en Y
         var PunteroBufferAlturas:Int
         var Ancho:Int
         var Alto:Int
         var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4
         if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
         while true {
             Byte0 = TablaAlturasPantallas_4A00[PunteroAlturasPantalla - 0x4A00] //lee un byte
             if Byte0 == 0xFF { return } //si ha llegado al final de los datos, sale
             if (Byte0 & 0x7) == 0 { return } //si los 3 bits menos significativos del byte leido son 0, sale
             if (Byte0 & 0x7) >= 6 { return } //si el (dato & 0x07) >= 0x06, sale
             Byte3 = TablaAlturasPantallas_4A00[PunteroAlturasPantalla + 3 - 0x4A00] //lee un byte
             if (Byte0 & 0x8) == 0 { //si la entrada es de 4 bytes
                 nY = Byte3 & 0xF
                 nX = (Byte3 >> 4) & 0xF //a = 4 bits más significativos del byte 3
             } else { // si la entrada es de 5 bytes, lee el último byte
                 Byte4 = TablaAlturasPantallas_4A00[PunteroAlturasPantalla + 4 - 0x4A00] //lee el último byte
                 nX = Byte3
                 nY = Byte4
             }
             Z = (Byte0 >> 4) & 0xF //obtiene los 4 bits superiores del byte 0
             Byte1 = TablaAlturasPantallas_4A00[PunteroAlturasPantalla + 1 - 0x4A00] //lee un byte
             Byte2 = TablaAlturasPantallas_4A00[PunteroAlturasPantalla + 2 - 0x4A00] //lee un byte
             X = Byte1
             Y = Byte2
             if (Byte0 & 0x8) != 0 { //si la entrada es de 5 bytes
                 PunteroAlturasPantalla = PunteroAlturasPantalla + 1
             }
             PunteroAlturasPantalla = PunteroAlturasPantalla + 4
             nX = nX + 1
             nY = nY + 1
             //If X >= MinimaPosicionXVisible_27A9 Then
             //    If X >= 0x18 Then
             //        salta
             //    End If
             //Else
             //    If (X + nX) >= MinimaPosicionXVisible_27A9 Then sigue
             //End If
             //comprueba si se ve en x
             //39b5
             if (X >= MinimaPosicionXVisible_27A9 && X < (0x18 + MinimaPosicionXVisible_27A9)) || ((X < MinimaPosicionXVisible_27A9) && (X + nX) >= MinimaPosicionXVisible_27A9) {
                 //comprueba si se ve en y
                 //39c8
                 if (Y >= MinimaPosicionYVisible_279D && Y < (0x18 + MinimaPosicionYVisible_279D)) || ((Y < MinimaPosicionYVisible_279D) && (Y + nY) >= MinimaPosicionYVisible_279D) {
                     //si entra aquí, es porque algo de la entrada es visible
                     //39d8
                     if (Byte0 & 0x7) == 5 { //si es 5, recorta (altura constante)
                         //a partir de aquí, X e Y son incrementos respecto del borde de la pantalla
                         //39ee
                         if X >= MinimaPosicionXVisible_27A9 {
                             //39ff
                             X = X - MinimaPosicionXVisible_27A9
                             if (X + nX) >= 0x18 { nX = 0x18 - X }
                         } else {
                             //39f3
                             if (X + nX - MinimaPosicionXVisible_27A9) > 0x18 { //si la última coordenada X > limite superior en X
                                 nX = 0x18
                             } else { //si la última coordenada X <= limite superior en X, salta
                                 nX = X + nX - MinimaPosicionXVisible_27A9
                             }
                             X = 0
                         }
                         //pasa a recortar en Y
                         //3a09
                         if Y >= MinimaPosicionYVisible_279D { //si la coordenada Y > limite inferior en Y, salta
                             //3a1a
                             Y = Y - MinimaPosicionYVisible_279D
                             if (Y + nY) >= 0x18 { nY = 0x18 - Y }
                         } else {
                             //3a0e
                             if (Y + nY - MinimaPosicionYVisible_279D) > 0x18 { //si la última coordenada y > limite superior en y
                                 nY = 0x18
                             } else { //si la última coordenada y <= limite superior en y, salta
                                 nY = Y + nY - MinimaPosicionYVisible_279D
                             }
                             Y = 0
                         }
                         //3a24
                         //aquí llega la entrada una vez que ha sido recortada en X y en Y
                         //X = posición inicial en X
                         //Y = posición inicial en Y
                         //nX = número de elementos a dibujar en X
                         //nY = número de elementos a dibujar en Y
                         for Alto in 0..<nY {
                             for Ancho in 0..<nX {
                                 PunteroBufferAlturas = 24 * (Int(Y) + Int(Alto)) + Int(X) + Int(Ancho) //cada línea ocupa 24 bytes
                                 if !BufferAuxiliar {
                                     TablaBufferAlturas_01C0[PunteroBufferAlturas] = Z
                                 } else {
                                     TablaBufferAlturas_96F4[PunteroBufferAlturas] = Z
                                 }
                             }
                         }
                     } else { //si es del 1 al 4 recorta (altura cambiante)
                         //39DF
                         RellenarAlturas_38FD(X, Y, Z, nX, nY, Byte0 & 0x7)
                     }
                 }
             }
         }
     }

     public func RellenarAlturas_38FD( _ X:UInt8, _ Y:UInt8, _ Z:UInt8, _ nX:UInt8, _ nY:UInt8, _ TipoIncremento:UInt8) {
         //rutina para rellenar alturas
         //X(L)=posicion X inicial
         //Y(H)=posicion Y inicial
         //Z(a)=valor de la altura inicial de bloque
         //nX(c)=número de unidades en X
         //nY(b)=número de unidades en Y
         var Incremento1:Int=0
         var Incremento2:Int=0
         //var Alto:Int
         //var Ancho:Int
         var Altura:Int
         var AlturaAnterior:Int
         //tabla de instrucciones para modificar un bucle del cálculo de alturas
         //38EF:   00 00 -> 0 nop, nop (caso imposible)
         //        3C 00 -> 1 inc a, nop
         //        00 3D -> 2 nop, dec a
         //        3D 00 -> 3 dec a, nop
         //        00 3C -> 4 nop, inc a
         //        00 00 -> 5 nop, nop (caso imposible)
         switch TipoIncremento {
             case 0: //caso imposible
                 Incremento1 = 0
                 Incremento2 = 0
             case 1:
                 Incremento1 = 1
                 Incremento2 = 0
             case 2:
                 Incremento1 = 0
                 Incremento2 = -1
             case 3:
                 Incremento1 = -1
                 Incremento2 = 0
             case 4:
                 Incremento1 = 0
                 Incremento2 = 1
             case 5: //caso imposible
                 Incremento1 = 0
                 Incremento2 = 0
             default:
                 break
         }
         Altura = Int(Z)
         for Alto in 0..<Int(nY) {
             AlturaAnterior = Altura
             for Ancho in 0..<nX {
                 if Altura >= 0 {
                     EscribirAlturaBufferAlturas_391D(X + UInt8(Ancho), Y + UInt8(Alto), UInt8(Altura))
                 } else {
                     EscribirAlturaBufferAlturas_391D(X + UInt8(Ancho), Y + UInt8(Alto), UInt8(256 + Altura))
                 }
                 Altura = Altura + Incremento1
             }
             //3915
             Altura = AlturaAnterior + Incremento2
         }
     }

     public func EscribirAlturaBufferAlturas_391D( _ X:UInt8, _ Y:UInt8, _ Z:UInt8) {
         //si la posición X (L) ,Y (H) está dentro del buffer, lo modifica con la altura Z (C)
         var PunteroBufferAlturas:Int
         var XAjustada:Int
         var YAjustada:Int
         var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4
         if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
         YAjustada = Int(Y) - Int(MinimaPosicionYVisible_279D) //ajusta la coordenada al principio de lo visible en Y
         //3920
         if YAjustada < 0 { return } //si no es visible, sale
         //3921
         if (YAjustada - 0x18) >= 0 { return }//si no es visible, sale
         //3924
         PunteroBufferAlturas = 24 * YAjustada
         //392f
         PunteroBufferAlturas = PunteroBufferAlturas + PunteroBufferAlturas_2D8A
         //3936
         XAjustada = Int(X) - Int(MinimaPosicionXVisible_27A9)
         //3939
         if XAjustada < 0 { return } //si no es visible, sale
         //393a
         if (XAjustada - 0x18) >= 0 { return } //si no es visible, sale
         //393d
         PunteroBufferAlturas = PunteroBufferAlturas + XAjustada
         if !BufferAuxiliar {
             TablaBufferAlturas_01C0[PunteroBufferAlturas - 0x1C0] = Z
         } else {
             TablaBufferAlturas_96F4[PunteroBufferAlturas - 0x96F4] = Z
         }
         //If Y < MinimaPosicionYVisible_279D Or Y > (0x18 + MinimaPosicionYVisible_279D) Then exit sub 'si no es visible, sale
         //If X < MinimaPosicionXVisible_27A9 Or X > (0x18 + MinimaPosicionXVisible_27A9) Then exit sub 'si no es visible, sale
         //PunteroBufferAlturas = 24 * Y + X + PunteroBufferAlturas_2D8A
         //TablaBufferAlturas_01C0(PunteroBufferAlturas) = Z
     }

     public func InicializarObjetos_0D23() {
         var PunteroRutinaProcesarObjetos:Int
         var PunteroSpritesObjetos:Int
         var PunteroDatosObjetos:Int
         PunteroRutinaProcesarObjetos = 0xDBB //rutina a la que saltar para procesar los objetos del juego
         PunteroSpritesObjetos = 0x2F1B //apunta a los sprites de los objetos del juego
         PunteroDatosObjetos = 0x3008 //apunta a los datos de posición de los objetos del juego
        ProcesarObjetos_0D3B(PunteroRutinaProcesarObjetos, PunteroSpritesObjetos, PunteroDatosObjetos, ProcesarSoloUno: false)
     }

     public func InicializarSpritesPuertas_0D30() {
         var PunteroRutinaProcesarPuertas:Int
         var PunteroSpritesPuertas:Int
         var PunteroDatosPuertas:Int
         PunteroRutinaProcesarPuertas = 0xDD2 //rutina a la que saltar para procesar los sprites de las puertas
         PunteroSpritesPuertas = 0x2E8F //apunta a los sprites de las puertas
         PunteroDatosPuertas = 0x2FE4 //apunta a los datos de las puertas
        ProcesarObjetos_0D3B(PunteroRutinaProcesarPuertas, PunteroSpritesPuertas, PunteroDatosPuertas, ProcesarSoloUno: false)
     }

     public func ProcesarObjetos_0D3B( _ PunteroRutinaProcesarObjetos:Int, _ PunteroSpritesObjetosIX:Int, _ PunteroDatosObjetosIY:Int, ProcesarSoloUno:Bool) {
         var PunteroSpritesObjetosIX:Int = PunteroSpritesObjetosIX
         var PunteroDatosObjetosIY:Int = PunteroDatosObjetosIY
         var Valor:UInt8
         var Visible:Bool
         var XL:UInt8=0
         var YH:UInt8=0
         var Z:UInt8=0
         var YpC:UInt8=0
         var PunteroSpritesObjetosIXAnterior:Int
         while true {
             if PunteroDatosObjetosIY < 0x3008 { //el puntero apunta a la tabla de puertas
                 Valor = TablaDatosPuertas_2FE4[PunteroDatosObjetosIY - 0x2FE4] //lee un byte y si encuentra 0xff termina
             } else { //el puntero apunta a la tabla de objetos
                 Valor = TablaPosicionObjetos_3008[PunteroDatosObjetosIY - 0x3008] //lee un byte y si encuentra 0xff termina
             }
             if Valor == 0xFF { return }
             //0D44
             Visible = ObtenerCoordenadasObjeto_0E4C(PunteroSpritesObjetosIX, PunteroDatosObjetosIY, &XL, &YH, &Z, &YpC) //obtiene en X,Y,Z la posición en pantalla del objeto. Si no es visible devuelve False
             if Visible { //si el objeto es visible, salta a la rutina siguiente
                 PunteroSpritesObjetosIXAnterior = PunteroSpritesObjetosIX
                 switch PunteroRutinaProcesarObjetos {
                     case 0xDD2: //rutina a la que saltar para procesar los sprites de las puertas
                         ProcesarPuertaVisible_0DD2(PunteroSpritesObjetosIX, PunteroDatosObjetosIY, XL, YH, YpC)
                     case 0xDBB: //rutina a la que saltar para procesar los objetos del juego
                         ProcesarObjetoVisible_0DBB(PunteroSpritesObjetosIX, PunteroDatosObjetosIY, XL, YH, YpC)
                     default:
                         break
                 }
                 PunteroSpritesObjetosIX = PunteroSpritesObjetosIXAnterior
             }
             //pone la posición actual del sprite como la posición antigua
             TablaSprites_2E17[PunteroSpritesObjetosIX + 3 - 0x2E17] = TablaSprites_2E17[PunteroSpritesObjetosIX + 1 - 0x2E17]
             TablaSprites_2E17[PunteroSpritesObjetosIX + 4 - 0x2E17] = TablaSprites_2E17[PunteroSpritesObjetosIX + 2 - 0x2E17]
             PunteroDatosObjetosIY = PunteroDatosObjetosIY + 5 //avanza a la siguiente entrada
             PunteroSpritesObjetosIX = PunteroSpritesObjetosIX + 0x14 //apunta al siguiente sprite
             if ProcesarSoloUno { return }
        }
     }

     public func ObtenerCoordenadasObjeto_0E4C(_ PunteroSpritesObjetosIX:Int, _ PunteroDatosObjetosIY:Int, _ XL: inout UInt8, _ YH: inout UInt8, _ Z: inout UInt8, _ YpC: inout UInt8) -> Bool {
         //devuelve la posición la entidad en coordenadas de pantalla. Si no es visible sale con False
         //si es visible devuelve en Z la profundidad del sprite y en X,Y devuelve la posición en pantalla del sprite
         var Visible:Bool
         var ObtenerCoordenadasObjeto_0E4C:Bool
         ObtenerCoordenadasObjeto_0E4C = false
         ModificarPosicionSpritePantalla_2B2F = false
         Visible = ProcesarObjeto_2ADD(PunteroSpritesObjetosIX, PunteroDatosObjetosIY, &XL, &YH, &Z, &YpC)
         ModificarPosicionSpritePantalla_2B2F = true
         if !Visible {
             TablaSprites_2E17[PunteroSpritesObjetosIX + 0 - 0x2E17] = 0xFE //marca el sprite como no visible
         } else {
             ObtenerCoordenadasObjeto_0E4C = Visible
         }
         return ObtenerCoordenadasObjeto_0E4C
     }

     public func LeerBytePersonajeObjeto( _ PunteroDatosObjeto:Int) -> UInt8 {
         //devuelve un valor de la tabla TablaPosicionesAlternativas_0593,TablaDatosPuertas_2FE4,
         //TablaPosicionObjetos_3008, TablaCaracteristicasPersonajes_3036 ó TablaVariablesLogica_3C85
         var LeerBytePersonajeObjeto:UInt8
         if PunteroDatosObjeto < 0x2FE4 { //el objeto es una personaje en la tabla de alternativas
             LeerBytePersonajeObjeto = TablaPosicionesAlternativas_0593[PunteroDatosObjeto - 0x0593]
         } else if PunteroDatosObjeto < 0x3008 { //el objeto es una puerta
             LeerBytePersonajeObjeto = TablaDatosPuertas_2FE4[PunteroDatosObjeto - 0x2FE4]
         } else if PunteroDatosObjeto < 0x3036 { //objetos del juego
             LeerBytePersonajeObjeto = TablaPosicionObjetos_3008[PunteroDatosObjeto - 0x3008]
         } else if PunteroDatosObjeto < 0x3C85 { //personajes
             LeerBytePersonajeObjeto = TablaCaracteristicasPersonajes_3036[PunteroDatosObjeto - 0x3036]
         } else { //Posiciones predefinidas
             LeerBytePersonajeObjeto = TablaVariablesLogica_3C85[PunteroDatosObjeto - 0x3C85]
         }
         return LeerBytePersonajeObjeto
     }

     public func EscribirBytePersonajeObjeto( _ PunteroDatosObjeto:Int, _ Valor:UInt8) {
         //devuelve un valor de la tabla TablaPosicionesAlternativas_0593,TablaDatosPuertas_2FE4,
         //TablaPosicionObjetos_3008, TablaCaracteristicasPersonajes_3036 ó TablaVariablesLogica_3C85
         if PunteroDatosObjeto < 0x2FE4 { //el objeto es una personaje en la tabla de alternativas
             TablaPosicionesAlternativas_0593[PunteroDatosObjeto - 0x0593] = Valor
         } else if PunteroDatosObjeto < 0x3008 { //el objeto es una puerta
             TablaDatosPuertas_2FE4[PunteroDatosObjeto - 0x2FE4] = Valor
         } else if PunteroDatosObjeto < 0x3036 { //objetos del juego
             TablaPosicionObjetos_3008[PunteroDatosObjeto - 0x3008] = Valor
         } else if PunteroDatosObjeto < 0x3C85 { //personajes
             TablaCaracteristicasPersonajes_3036[PunteroDatosObjeto - 0x3036] = Valor
         } else { //Posiciones predefinidas
             TablaVariablesLogica_3C85[PunteroDatosObjeto - 0x3C85] = Valor
         }
     }

     public func LeerDatoGrafico( _ PunteroDatosGrafico:Int) -> UInt8 {
         //devuelve un valor de la tabla TilesAbadia_6D00, BufferSprites_9500, TablaGraficosObjetos_A300 ó DatosMonjes_AB59
         var LeerDatoGrafico:UInt8
         if PunteroDatosGrafico < 0x9500 { //TilesAbadia_6D00
             LeerDatoGrafico = TilesAbadia_6D00[PunteroDatosGrafico - 0x6D00]
         } else if PunteroDatosGrafico < 0xA300 { //BufferSprites_9500
             LeerDatoGrafico = BufferSprites_9500[PunteroDatosGrafico - 0x9500]
         } else if PunteroDatosGrafico < 0xAB59 { //TablaGraficosObjetos_A300
             LeerDatoGrafico = TablaGraficosObjetos_A300[PunteroDatosGrafico - 0xA300]
         } else { //DatosMonjes_AB59
             LeerDatoGrafico = DatosMonjes_AB59[PunteroDatosGrafico - 0xAB59]
         }
         return LeerDatoGrafico
     }

     public func LeerByteTablaCualquiera( _ Puntero:Int) -> UInt8 {
         //lee un byte que puede pertenecer a cualquier tabla. usado en los errores de overflow del programa original
         var LeerByteTablaCualquiera:UInt8
         LeerByteTablaCualquiera = 0
         if PunteroPerteneceTabla(Puntero, TablaBugDejarObjetos_0000, 0x0000) {
             LeerByteTablaCualquiera = TablaBugDejarObjetos_0000[Puntero]
         }
         if PunteroPerteneceTabla(Puntero, TablaBufferAlturas_01C0, 0x1C0) {
             LeerByteTablaCualquiera = TablaBufferAlturas_01C0[Puntero - 0x1C0]
         }
         if PunteroPerteneceTabla(Puntero, TablaBloquesPantallas_156D, 0x156D) {
             LeerByteTablaCualquiera = TablaBloquesPantallas_156D[Puntero - 0x156D]
         }
         if PunteroPerteneceTabla(Puntero, DatosAlturaEspejoCerrado_34DB, 0x34DB) {
             LeerByteTablaCualquiera = DatosAlturaEspejoCerrado_34DB[Puntero - 0x34DB]
         }
         if PunteroPerteneceTabla(Puntero, TablaRutinasConstruccionBloques_1FE0, 0x1FE0) {
             LeerByteTablaCualquiera = TablaRutinasConstruccionBloques_1FE0[Puntero - 0x1FE0]
         }
         if PunteroPerteneceTabla(Puntero, VariablesBloques_1FCD, 0x1FCD) {
             LeerByteTablaCualquiera = VariablesBloques_1FCD[Puntero - 0x1FCD]
         }
         if PunteroPerteneceTabla(Puntero, TablaCaracteristicasMaterial_1693, 0x1693) {
             LeerByteTablaCualquiera = TablaCaracteristicasMaterial_1693[Puntero - 0x1693]
         }
         if PunteroPerteneceTabla(Puntero, TablaHabitaciones_2255, 0x2255) {
             LeerByteTablaCualquiera = TablaHabitaciones_2255[Puntero - 0x2255]
         }
         if PunteroPerteneceTabla(Puntero, TablaAvancePersonaje4Tiles_284D, 0x284D) {
             LeerByteTablaCualquiera = TablaAvancePersonaje4Tiles_284D[Puntero - 0x284D]
         }
         if PunteroPerteneceTabla(Puntero, TablaAvancePersonaje1Tile_286D, 0x286D) {
             LeerByteTablaCualquiera = TablaAvancePersonaje1Tile_286D[Puntero - 0x286D]
         }
         if PunteroPerteneceTabla(Puntero, TablaPunterosPersonajes_2BAE, 0x2BAE) {
             LeerByteTablaCualquiera = TablaPunterosPersonajes_2BAE[Puntero - 0x2BAE]
         }
         if PunteroPerteneceTabla(Puntero, TablaVariablesAuxiliares_2D8D, 0x2D8D) {
             LeerByteTablaCualquiera = TablaVariablesAuxiliares_2D8D[Puntero - 0x2D8D]
         }
         if PunteroPerteneceTabla(Puntero, TablaPermisosPuertas_2DD9, 0x2DD9) {
             LeerByteTablaCualquiera = TablaPermisosPuertas_2DD9[Puntero - 0x2DD9]
         }
         if PunteroPerteneceTabla(Puntero, TablaObjetosPersonajes_2DEC, 0x2DEC) {
             LeerByteTablaCualquiera = TablaObjetosPersonajes_2DEC[Puntero - 0x2DEC]
         }
         if PunteroPerteneceTabla(Puntero, TablaSprites_2E17, 0x2E17) {
             LeerByteTablaCualquiera = TablaSprites_2E17[Puntero - 0x2E17]
         }
         if PunteroPerteneceTabla(Puntero, TablaDatosPuertas_2FE4, 0x2FE4) {
             LeerByteTablaCualquiera = TablaDatosPuertas_2FE4[Puntero - 0x2FE4]
         }
         if PunteroPerteneceTabla(Puntero, TablaDatosPuertas_2FE4, 0x2FE4) {
             LeerByteTablaCualquiera = TablaDatosPuertas_2FE4[Puntero - 0x2FE4]
         }
         if PunteroPerteneceTabla(Puntero, TablaPosicionObjetos_3008, 0x3008) {
             LeerByteTablaCualquiera = TablaPosicionObjetos_3008[Puntero - 0x3008]
         }
         if PunteroPerteneceTabla(Puntero, TablaCaracteristicasPersonajes_3036, 0x3036) {
             LeerByteTablaCualquiera = TablaCaracteristicasPersonajes_3036[Puntero - 0x3036]
         }
         if PunteroPerteneceTabla(Puntero, TablaPunterosCarasMonjes_3097, 0x3097) {
             LeerByteTablaCualquiera = TablaPunterosCarasMonjes_3097[Puntero - 0x3097]
         }
         if PunteroPerteneceTabla(Puntero, TablaDesplazamientoAnimacion_309F, 0x309F) {
             LeerByteTablaCualquiera = TablaDesplazamientoAnimacion_309F[Puntero - 0x309F]
         }
         if PunteroPerteneceTabla(Puntero, TablaAnimacionPersonajes_319F, 0x319F) {
             LeerByteTablaCualquiera = TablaAnimacionPersonajes_319F[Puntero - 0x319F]
         }
         if PunteroPerteneceTabla(Puntero, TablaAccesoHabitaciones_3C67, 0x3C67) {
             LeerByteTablaCualquiera = TablaAccesoHabitaciones_3C67[Puntero - 0x3C67]
         }
         if PunteroPerteneceTabla(Puntero, TablaVariablesLogica_3C85, 0x3C85) {
             LeerByteTablaCualquiera = TablaVariablesLogica_3C85[Puntero - 0x3C85]
         }
         //If PunteroPerteneceTabla(Puntero, TablaPosicionesPredefinidasMalaquias_3CA8, 0x3CA8&) Then
         //LeerByteTablaCualquiera = TablaPosicionesPredefinidasMalaquias_3CA8(Puntero - 0x3CA8&)
         //End If
         //If PunteroPerteneceTabla(Puntero, TablaPosicionesPredefinidasAbad_3CC6, 0x3CC6&) Then
         //LeerByteTablaCualquiera = TablaPosicionesPredefinidasAbad_3CC6(Puntero - 0x3CC6&)
         //End If
         //If PunteroPerteneceTabla(Puntero, TablaPosicionesPredefinidasBerengario_3CE7, 0x3CE7&) Then
         //LeerByteTablaCualquiera = TablaPosicionesPredefinidasBerengario_3CE7(Puntero - 0x3CE7&)
         //End If
         //If PunteroPerteneceTabla(Puntero, TablaPosicionesPredefinidasSeverino_3CFF, 0x3CFF&) Then
         //LeerByteTablaCualquiera = TablaPosicionesPredefinidasSeverino_3CFF(Puntero - 0x3CFF&)
         //End If
         //If PunteroPerteneceTabla(Puntero, TablaPosicionesPredefinidasAdso_3D11, 0x3D11&) Then
         //LeerByteTablaCualquiera = TablaPosicionesPredefinidasAdso_3D11(Puntero - 0x3D11&)
         //End If
         if PunteroPerteneceTabla(Puntero, TablaPunterosVariablesScript_3D1D, 0x3D1D) {
             LeerByteTablaCualquiera = TablaPunterosVariablesScript_3D1D[Puntero - 0x3D1D]
         }
         if PunteroPerteneceTabla(Puntero, DatosHabitaciones_4000, 0x4000) {
             LeerByteTablaCualquiera = DatosHabitaciones_4000[Puntero - 0x4000]
         }
         if PunteroPerteneceTabla(Puntero, TablaPunterosTrajesMonjes_48C8, 0x48C8) {
             LeerByteTablaCualquiera = TablaPunterosTrajesMonjes_48C8[Puntero - 0x48C8]
         }
         if PunteroPerteneceTabla(Puntero, TablaPatronRellenoLuz_48E8, 0x48E8) {
             LeerByteTablaCualquiera = TablaPatronRellenoLuz_48E8[Puntero - 0x48E8]
         }
         if PunteroPerteneceTabla(Puntero, TablaAlturasPantallas_4A00, 0x4A00) {
             LeerByteTablaCualquiera = TablaAlturasPantallas_4A00[Puntero - 0x4A00]
         }
         if PunteroPerteneceTabla(Puntero, TablaEtapasDia_4F7A, 0x4F7A) {
             LeerByteTablaCualquiera = TablaEtapasDia_4F7A[Puntero - 0x4F7A]
         }
         if PunteroPerteneceTabla(Puntero, DatosMarcador_6328, 0x6328) {
             LeerByteTablaCualquiera = DatosMarcador_6328[Puntero - 0x6328]
         }
         if PunteroPerteneceTabla(Puntero, DatosCaracteresPergamino_6947, 0x6947) {
             LeerByteTablaCualquiera = DatosCaracteresPergamino_6947[Puntero - 0x6947]
         }
         if PunteroPerteneceTabla(Puntero, PunterosCaracteresPergamino_680C, 0x680C) {
             LeerByteTablaCualquiera = PunterosCaracteresPergamino_680C[Puntero - 0x680C]
         }
         if PunteroPerteneceTabla(Puntero, TilesAbadia_6D00, 0x6D00) {
             LeerByteTablaCualquiera = TilesAbadia_6D00[Puntero - 0x6D00]
         }
         if PunteroPerteneceTabla(Puntero, TablaRellenoBugTiles_8D00, 0x8D00) {
             LeerByteTablaCualquiera = TablaRellenoBugTiles_8D00[Puntero - 0x8D00]
         }
         if PunteroPerteneceTabla(Puntero, TextoPergaminoPresentacion_7300, 0x7300) {
             LeerByteTablaCualquiera = TextoPergaminoPresentacion_7300[Puntero - 0x7300]
         }
         if PunteroPerteneceTabla(Puntero, DatosGraficosPergamino_788A, 0x788A) {
             LeerByteTablaCualquiera = DatosGraficosPergamino_788A[Puntero - 0x788A]
         }
         if PunteroPerteneceTabla(Puntero, BufferTiles_8D80, 0x8D80) {
             LeerByteTablaCualquiera = BufferTiles_8D80[Puntero - 0x8D80]
         }
         if PunteroPerteneceTabla(Puntero, BufferSprites_9500, 0x9500) {
             LeerByteTablaCualquiera = BufferSprites_9500[Puntero - 0x9500]
         }
         //If PunteroPerteneceTabla(Puntero, TablaBufferAlturas_96F4, 0x96F4) { 'esta tabla se solapa con el buffer de sprites
         // LeerByteTablaCualquiera = TablaBufferAlturas_96F4(Puntero - 0x96F4)
         // End If

         if PunteroPerteneceTabla(Puntero, TablasAndOr_9D00, 0x9D00) {
             LeerByteTablaCualquiera = TablasAndOr_9D00[Puntero - 0x9D00]
         }
         if PunteroPerteneceTabla(Puntero, TablaFlipX_A100, 0xA100) {
             LeerByteTablaCualquiera = TablaFlipX_A100[Puntero - 0xA100]
         }
         if PunteroPerteneceTabla(Puntero, TablaGraficosObjetos_A300, 0xA300) {
             LeerByteTablaCualquiera = TablaGraficosObjetos_A300[Puntero - 0xA300]
         }
         if PunteroPerteneceTabla(Puntero, DatosMonjes_AB59, 0xAB59) {
             LeerByteTablaCualquiera = DatosMonjes_AB59[Puntero - 0xAB59]
         }
         if PunteroPerteneceTabla(Puntero, BufferComandosMonjes_A200, 0xA200) {
             LeerByteTablaCualquiera = BufferComandosMonjes_A200[Puntero - 0xA200]
         }
     return LeerByteTablaCualquiera
     }

     public func ProcesarObjeto_2ADD( _ PunteroSpritesObjetosIX:Int, _ PunteroDatosObjetosIY:Int, _ XL: inout UInt8, _ YH: inout UInt8, _ Z: inout UInt8, _ YpC: inout UInt8) -> Bool {
         //comprueba si el sprite está dentro de la zona visible de pantalla.
         //Si no es así, sale. Si está dentro de la zona visible lo transforma
         //a otro sistema de coordenadas. Dependiendo de un parámetro sigue o no.
         //Si sigue actualiza la posición según la orientación
         //si no es visible, sale. Si es visible, sale 2 veces (2 pop de pila)
         var ProcesarObjeto_2ADD:Bool=false
         var ValorX:Int
         var ValorY:Int
         var ValorZ:UInt8
         var AlturaBase:UInt8
         //On Error Resume Next 'desplazamiento puede ser <0
         //If PunteroDatosObjetosIY = 0x3036 Then Stop
         ValorX = Int(LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 2)) - Int(LimiteInferiorVisibleX_2AE1)
         ValorY = Int(LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 3)) - Int(LimiteInferiorVisibleY_2AEB)
         ValorZ = LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 4)
         if ValorX < 0 || ValorX > 0x28 { //si el objeto en X es < limite inferior visible de X o el objeto en X es >= limite superior visible de X, sale
             ProcesarObjeto_2ADD = false
             return ProcesarObjeto_2ADD
         }
         if ValorY < 0 || ValorY > 0x28 { //si el objeto en Y es < limite inferior visible de Y o el objeto en Y es >= limite superior visible de Y, sale
             ProcesarObjeto_2ADD = false
             return ProcesarObjeto_2ADD
         }
         //2af4
         AlturaBase = LeerAlturaBasePlanta_2473(ValorZ) //dependiendo de la altura, devuelve la altura base de la planta
         if AlturaBase != AlturaBasePlantaActual_2AF9 { //si el objeto no está en la misma planta, sale
             ProcesarObjeto_2ADD = false
             return ProcesarObjeto_2ADD
         }
         XL = UInt8(ValorX) //coordenada X del objeto en la pantalla
         YH = UInt8(ValorY) //coordenada Y del objeto en la pantalla
         Z = ValorZ - AlturaBase //altura del objeto ajustada para esta pantalla
         //2b00
         //al llegar aquí los parámetros son:
         //X = coordenada X del objeto en la rejilla
         //Y = coordenada Y del objeto en la rejilla
         //Z = altura del objeto en la rejilla ajustada para esta planta
         switch RutinaCambioCoordenadas_2B01 { //rutina que cambia el sistema de coordenadas dependiendo de la orientación de la pantalla
             case 0x248A:
                 CambiarCoordenadasOrientacion0_248A(&XL, &YH)
             case 0x2485:
                 CambiarCoordenadasOrientacion1_2485(&XL, &YH)
             case 0x248B:
                 CambiarCoordenadasOrientacion2_248B(&XL, &YH)
             case 0x2494:
                 CambiarCoordenadasOrientacion3_2494(&XL, &YH)
             default:
                break
         }
         TablaSprites_2E17[PunteroSpritesObjetosIX + 0x12 - 0x2E17] = XL //graba las nuevas coordenadas x e y en el sprite
         TablaSprites_2E17[PunteroSpritesObjetosIX + 0x13 - 0x2E17] = YH //graba las nuevas coordenadas x e y en el sprite
         //2b09
         //convierte las coordenadas en la rejilla a coordenadas de pantalla
         var Xcalc:Int
         var Ycalc:Int
         var Ypantalla:Int
         //2b09
         Ycalc = Int(XL) + Int(YH) //pos x + pos y = coordenada y en pantalla
         //2B0B
         Ypantalla = Ycalc
         //2B0C
         Ycalc = Ycalc - Int(Z) //le resta la altura (cuanto más alto es el objeto, menor y tiene en pantalla)
         //2B0D
         if Ycalc < 0 { return ProcesarObjeto_2ADD }
         //2B0E
         Ycalc = Ycalc - 6 //y calc = y calc - 6 (traslada 6 unidades arriba)
         //2b10
         if Ycalc < 0 { return ProcesarObjeto_2ADD } //si y calc < 0, sale
         //2b11
         if Ycalc < 8 { return ProcesarObjeto_2ADD } //si y calc < 8, sale
         //2b14
         if Ycalc >= 0x3A { return ProcesarObjeto_2ADD } //si y calc  >= 58, sale
         //llega aquí si la y calc está entre 8 y 57
         //2b17
         Ycalc = 4 * (Ycalc + 1)
         Xcalc = 2 * (Int(XL) - Int(YH)) + 0x50 - 0x28
         if Xcalc < 0 { return ProcesarObjeto_2ADD }
         if Xcalc >= 0x50 { return ProcesarObjeto_2ADD }
         //2b26
         XL = UInt8(Xcalc) //pos x con nuevo sistema de coordenadas
         YH = UInt8(Ycalc) //pos y con nuevo sistema de coordenadas
         ProcesarObjeto_2ADD = true //el objeto es visible
         Ypantalla = Ypantalla - 0x10
         if Ypantalla < 0 { Ypantalla = 0 }//si la posición en y < 16, pos y = 0
         YpC = Int2ByteSigno(Ypantalla)
         if !ModificarPosicionSpritePantalla_2B2F { return ProcesarObjeto_2ADD }
         //si llega aquí modifica la posición del sprite en pantalla
         //2B30
         var Entrada:UInt8
         var Ocupa1Posicion:Bool=false //true si ocupa una posición. false si ocupa 4 posiciones
         var MovimientoPar:Bool=false //true si el contador de animación es 0 ó 2. false si es 1 ó 3
         var OrientadoEscaleras:Bool=false //true si está orientado para subir o bajar escaleras. false si esta girado
         var Subiendo:Bool=false //true si está subiendo escaleras, false si está bajando
         Entrada = 0 //primera entrada
         if (LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 5) & 0x80) != 0 { Ocupa1Posicion = true }
         if (LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 0) & 1) == 0 { MovimientoPar = true } //lee el bit 0 del contador de animación
         if (LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 5) & 32) == 0 { OrientadoEscaleras = true }
         if (LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 5) & 0x10) == 0 { Subiendo = true }
         if Ocupa1Posicion {
             Entrada = Entrada + 2
             if !OrientadoEscaleras {
                 if !MovimientoPar { Entrada = Entrada + 1 }
             } else {
                 if MovimientoPar {
                     Entrada = Entrada + 2
                 } else {
                     Entrada = Entrada + 3
                     if !Subiendo { Entrada = Entrada + 1 }
                 }
             }
         } else { //ocupa 4 posiciones
             if !MovimientoPar { Entrada = Entrada + 1 }
         }
         //2B41
         var Puntero:Int
         var Orientacion:UInt8
         var Desplazamiento:Int
         Orientacion = ModificarOrientacion_2480(LeerBytePersonajeObjeto(PunteroDatosObjetosIY + 1)) //obtiene la orientación del personaje. modifica la orientación que se le pasa en a con la orientación de la pantalla actual
         //2b4b
         Puntero = ((Int(Orientacion) << 4) & 0x30) + 2 * Int(Entrada) + PunteroTablaDesplazamientoAnimacion_2D84
         //2b58
         //Desplazamiento = TablaDesplazamientoAnimacion_309F(Puntero - 0x309F) 'lee un byte de la tabla
         Desplazamiento = Leer8Signo(TablaDesplazamientoAnimacion_309F, Puntero - 0x309F) //lee un byte de la tabla
         //2b59
         Desplazamiento = Desplazamiento + Int(XL) //le suma la x del nuevo sistema de coordenadas
         //2b5a
         //Desplazamiento = Desplazamiento - (256 - LeerDatoObjeto(PunteroDatosObjetosIY + 7)) 'le suma un desplazamieno
         Desplazamiento = Desplazamiento + Leer8Signo(TablaCaracteristicasPersonajes_3036, PunteroDatosObjetosIY + 7 - 0x3036) //le suma un desplazamieno
         if Desplazamiento >= 0 {
             XL = UInt8(Desplazamiento) //actualiza la x
         } else {
             XL = UInt8(256 + Desplazamiento) //no deberían aparecer coordenadas negativas. bug del original?
         }
         Puntero = Puntero + 1
         //Desplazamiento = TablaDesplazamientoAnimacion_309F(Puntero - 0x309F) 'lee un byte de la tabla
         Desplazamiento = Leer8Signo(TablaDesplazamientoAnimacion_309F, Puntero - 0x309F) //lee un byte de la tabla
         Desplazamiento = Desplazamiento + Int(YH) //le suma la Y del nuevo sistema de coordenadas
         //Desplazamiento = Desplazamiento - (256 - LeerDatoObjeto(PunteroDatosObjetosIY + 8)) 'le suma un desplazamieno
         Desplazamiento = Desplazamiento + Leer8Signo(TablaCaracteristicasPersonajes_3036, PunteroDatosObjetosIY + 8 - 0x3036) //le suma un desplazamieno
         YH = UInt8(Desplazamiento) //actualiza la Y
         TablaSprites_2E17[PunteroSpritesObjetosIX + 1 - 0x2E17] = XL //graba la posición x del sprite (en bytes)
         TablaSprites_2E17[PunteroSpritesObjetosIX + 2 - 0x2E17] = YH //graba la posición y del sprite (en pixels)
         if TablaSprites_2E17[PunteroSpritesObjetosIX + 0 - 0x2E17] != 0xFE { return ProcesarObjeto_2ADD }
         //si el sprite no es visible, continua
         TablaSprites_2E17[PunteroSpritesObjetosIX + 3 - 0x2E17] = XL //graba la posición anterior x del sprite (en bytes)
         TablaSprites_2E17[PunteroSpritesObjetosIX + 4 - 0x2E17] = YH //graba la posición anterior y del sprite (en pixels)
         return ProcesarObjeto_2ADD
    }

     public func CambiarCoordenadasOrientacion0_248A( _ X: inout UInt8, _ Y: inout UInt8) {
         //realiza el cambio de coordenadas si la orientación la cámara es del tipo 0
         //no hace ningún cambio
     }

     public func CambiarCoordenadasOrientacion1_2485( _ X: inout UInt8, _ Y: inout UInt8) {
         //realiza el cambio de coordenadas si la orientación la cámara es del tipo 1
         var Valor:UInt8
         Valor = Y //guarda Y
         Y = X
         X = 0x28 - Valor
     }

     public func CambiarCoordenadasOrientacion2_248B( _ X: inout UInt8, _ Y: inout UInt8) {
         //realiza el cambio de coordenadas si la orientación la cámara es del tipo 2
         Y = 0x28 - Y
         X = 0x28 - X
     }

     public func CambiarCoordenadasOrientacion3_2494( _ X: inout UInt8, _ Y: inout UInt8) {
         //realiza el cambio de coordenadas si la orientación la cámara es del tipo 1
         var Valor:UInt8
         Valor = X //guarda x
         X = Y
         Y = 0x28 - Valor
     }

     public func ModificarOrientacion_2480( _ Orientacion:UInt8) -> UInt8 {
         //modifica la orientación que se le pasa en a con la orientación de la pantalla actual
         var Resultado:Int
         Resultado = (Int(Orientacion) - Int(OrientacionPantalla_2481)) & 0x3
         return Int2ByteSigno(Resultado)
         //If Orientacion < OrientacionPantalla_2481 {
         //    ModificarOrientacion_2480 = 3
         //    Exit Function
         //End If
         //ModificarOrientacion_2480 = (Orientacion - OrientacionPantalla_2481) And 0x3
    }

     public func ProcesarPuertaVisible_0DD2( _ PunteroSpriteIX:Int, _ PunteroDatosIY:Int, _ X:UInt8, _ Y:UInt8, _ Z:UInt8) {
         //rutina llamada cuando las puertas son visibles en la pantalla actual
         //se encarga de modificar la posición del sprite según la orientación, modificar el buffer de alturas para indicar si se puede pasar
         //por la zona de la puerta o no, colocar el gráfico de las puertas y modificar 0x2daf
         //PunteroSprite apunta al sprite de una puerta
         //PunteroDatos apunta a los datos de la puerta
         //X,Y contienen la posición en pantalla del objeto
         //Z tiene la profundidad de la puerta en pantalla
         var DeltaX:Int=0
         var DeltaY:Int=0
         var DeltaBuffer:Int=0
         var Orientacion:UInt8
         var TablaDesplazamientoOrientacionPuertas_05AD:[Int]=[Int](repeating: 0, count: 32)
         var Valor:Int
         var PunteroBufferAlturasIX:Int=0
         var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4
         if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
         //tabla de desplazamientos relacionada con las orientaciones de las puertas
         //cada entrada ocupa 8 bytes
         //byte 0: relacionado con la posición x de pantalla
         //byte 1: relacionado con la posición y de pantalla
         //byte 2: relacionado con la profundidad de los sprites
         //byte 3: indica el estado de flipx de los gráficos que necesita la puerta
         //byte 4: relacionado con la posición x de la rejilla
         //byte 5: relacionado con la posición y de la rejilla
         //byte 6-7: no usado, pero es el desplazamiento en el buffer de alturas
         //05AD:   FF DE 01 00 00 00 0001 -> -01 -34  +01  00    00  00   +01
         //        FF D6 00 01 00 00 FFE8 -> -01 -42   00 +01    00  00   -24
         //        FB D6 00 00 00 00 FFFF -> -05 -42   00  00    00  00   -01
         //        FB DE 01 01 01 01 0018 -> -05 -34  +01 +01   +01 +01   +24
         TablaDesplazamientoOrientacionPuertas_05AD[0] = -1
         TablaDesplazamientoOrientacionPuertas_05AD[1] = -34
         TablaDesplazamientoOrientacionPuertas_05AD[2] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[7] = 1

         TablaDesplazamientoOrientacionPuertas_05AD[8] = -1
         TablaDesplazamientoOrientacionPuertas_05AD[9] = -42
         TablaDesplazamientoOrientacionPuertas_05AD[11] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[14] = -1
         TablaDesplazamientoOrientacionPuertas_05AD[15] = -24

         TablaDesplazamientoOrientacionPuertas_05AD[16] = -5
         TablaDesplazamientoOrientacionPuertas_05AD[17] = -42
         TablaDesplazamientoOrientacionPuertas_05AD[22] = -1
         TablaDesplazamientoOrientacionPuertas_05AD[23] = -1

         TablaDesplazamientoOrientacionPuertas_05AD[24] = -5
         TablaDesplazamientoOrientacionPuertas_05AD[25] = -34
         TablaDesplazamientoOrientacionPuertas_05AD[26] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[27] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[28] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[29] = 1
         TablaDesplazamientoOrientacionPuertas_05AD[31] = 24

         DefinirDatosSpriteComoAntiguos_2AB0(PunteroSpriteIX)
         LeerOrientacionPuerta_0E7C(PunteroSpriteIX, &DeltaX, &DeltaY)  //lee 2 valores relacionados con la orientación y modifica la posición del sprite (en coordenadas locales) según la orientación
         Orientacion = TablaDatosPuertas_2FE4[PunteroDatosIY + 0 - 0x2FE4] //lee la orientación de la puerta
         Orientacion = ModificarOrientacion_2480(Orientacion & 0x3)  //modifica la orientación que se le pasa con la orientación de la pantalla actual
         //0deb
         Valor = TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8] //indexa en la tabla
         TablaSprites_2E17[PunteroSpriteIX + 1 - 0x2E17] = Int2ByteSigno(Valor + DeltaX + Int(X)) //modifica la posición x del sprite
         //0df1
         Valor = TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8 + 1] //indexa en la tabla
         TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17] = Int2ByteSigno(Valor + DeltaY + Int(Y)) //modifica la posición y del sprite
         //0df8
         Valor = TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8 + 2] //indexa en la tabla
         Valor = Valor + Int(Z)
         if PintarPantalla_0DFD { Valor = Valor | 0x80 } //Si se pinta la pantalla, 0x80, en otro caso 0
         if RedibujarPuerta_0DFF { Valor = Valor | 0x80 }//Si se pinta la puerta, 0x80, en otro caso 0
         //0e00
         TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = Int2ByteSigno(Valor)
         if TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8 + 3] != 0 { PuertaRequiereFlip_2DAF = true }
         //modifica la posición x e y del sprite en la rejilla según los 2 siguientes valores de la tabla
         Valor = TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8 + 4] //indexa en la tabla
         TablaSprites_2E17[PunteroSpriteIX + 0x12 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 0x12 - 0x2E17] + UInt8(Valor)
         Valor = TablaDesplazamientoOrientacionPuertas_05AD[Int(Orientacion) * 8 + 5] //indexa en la tabla
         TablaSprites_2E17[PunteroSpriteIX + 0x13 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 0x13 - 0x2E17] + UInt8(Valor)
         //coloca la dirección del gráfico de la puerta en el sprite (0xaa49)
         //0e0e
         TablaSprites_2E17[PunteroSpriteIX + 7 - 0x2E17] = 0x49
         TablaSprites_2E17[PunteroSpriteIX + 8 - 0x2E17] = 0xAA
         //si el objeto no es visible, sale. En otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
        if !LeerDesplazamientoPuerta_0E2C(&PunteroBufferAlturasIX, PunteroDatosIY, &DeltaBuffer) { return }
         if !BufferAuxiliar {
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x01C0] = 0xF //marca la altura de esta posición del buffer de alturas
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX + DeltaBuffer - 0x01C0] = 0xF //marca la altura de la siguiente posición del buffer de alturas
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX + 2 * DeltaBuffer - 0x01C0] = 0xF //marca la altura de la siguiente posición del buffer de alturas
         } else {
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x96F4] = 0xF //marca la altura de esta posición del buffer de alturas
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX + DeltaBuffer - 0x96F4] = 0xF //marca la altura de la siguiente posición del buffer de alturas
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX + 2 * DeltaBuffer - 0x96F4] = 0xF //marca la altura de la siguiente posición del buffer de alturas
         }
     }

     public func DefinirDatosSpriteComoAntiguos_2AB0( _ PunteroSpriteIX:Int) {
         //pone la posición y dimensiones actuales como posición y dimensiones antiguas
         //copia la posición actual en x y en y como la posición antigua
         TablaSprites_2E17[PunteroSpriteIX + 3 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 1 - 0x2E17]
         TablaSprites_2E17[PunteroSpriteIX + 4 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17]
         //copia el ancho y alto del sprite actual como el ancho y alto antiguos
         TablaSprites_2E17[PunteroSpriteIX + 9 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 5 - 0x2E17]
         TablaSprites_2E17[PunteroSpriteIX + 10 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 6 - 0x2E17]
     }

     public func LeerOrientacionPuerta_0E7C( _ PunteroSpriteIX:Int, _ DeltaX: inout Int, _ DeltaY: inout Int) {
         //lee en DeltaX, DeltaY 2 valores relacionados con la orientación y modifica la posición del sprite (en coordenadas locales) según la orientación
         //PunteroSprite apunta al sprite de una puerta
        var TablaDesplazamientoOrientacionPuertas_0E9D:[Int]=[Int](repeating: 0, count: 16)
         var Orientacion:UInt8
         //tabla relacionada con el desplazamiento de las puertas y la orientación
         //cada entrada ocupa 4 bytes
         //byte 0: valor a sumar a la posición x en coordenadas de pantalla del sprite de la puerta
         //byte 1: valor a sumar a la posición y en coordenadas de pantalla del sprite de la puerta
         //byte 2: valor a sumar a la posición x en coordenadas locales del sprite de la puerta
         //byte 3: valor a sumar a la posición y en coordenadas locales del sprite de la puerta
         //0E9D:   02 00 00 FF -> +2 00 00 -1
         //        00 FC FF FF -> 00 -4 -1 -1
         //        FE 00 FF 00 -> -2 00 -1 00
         //        00 04 00 00 -> 00 +4 00 00
         TablaDesplazamientoOrientacionPuertas_0E9D[0] = 2
         TablaDesplazamientoOrientacionPuertas_0E9D[3] = -1

         TablaDesplazamientoOrientacionPuertas_0E9D[5] = -4
         TablaDesplazamientoOrientacionPuertas_0E9D[6] = -1
         TablaDesplazamientoOrientacionPuertas_0E9D[7] = -1

         TablaDesplazamientoOrientacionPuertas_0E9D[8] = -2
         TablaDesplazamientoOrientacionPuertas_0E9D[10] = -1

         TablaDesplazamientoOrientacionPuertas_0E9D[13] = 4

         Orientacion = ModificarOrientacion_2480(3) //modifica la orientación que se le pasa con la orientación de la pantalla actual
         //indexa en la tabla. cada entrada ocupa 4 bytes
         //lee los valores a sumar a la posición en coordenadas de pantalla del sprite de la puerta
         DeltaX = TablaDesplazamientoOrientacionPuertas_0E9D[Int(Orientacion) * 4]
         DeltaY = TablaDesplazamientoOrientacionPuertas_0E9D[Int(Orientacion) * 4 + 1]
         // modifica la posición x de la rejilla según la orientación de la cámara con el valor leido
         TablaSprites_2E17[PunteroSpriteIX + 0x12 - 0x2E17] = UInt8(Int(TablaSprites_2E17[PunteroSpriteIX + 0x12 - 0x2E17]) + TablaDesplazamientoOrientacionPuertas_0E9D[Int(Orientacion) * 4 + 2])
         TablaSprites_2E17[PunteroSpriteIX + 0x13 - 0x2E17] = UInt8(Int(TablaSprites_2E17[PunteroSpriteIX + 0x13 - 0x2E17]) + TablaDesplazamientoOrientacionPuertas_0E9D[Int(Orientacion) * 4 + 3])
     }

     public func LeerDesplazamientoPuerta_0E2C( _ PunteroBufferAlturasIX: inout Int, _ PunteroDatosIY:Int, _ DeltaBuffer: inout Int) -> Bool {
         //lee en DeltaBuffer el desplazamiento para el buffer de alturas, y si la puerta es visible devuelve en PunteroBufferAlturasIX un puntero a la entrada de la tabla de alturas de la posición correspondiente
         //DeltaBuffer=incremento entre posiciones marcadas en el buffer de alturas
         //devuelve true si el elemento ocupa una posición central
         var LeerDesplazamientoPuerta_0E2C:Bool
         var Orientacion:UInt8
         var TablaDesplazamientosBufferPuertas:[Int]=[0,0,0,0]
         //tabla de desplazamientos en el buffer de alturas relacionada con la orientación de las puertas
         //0E44:   0001 -> +01
         //        FFE8 -> -24
         //        FFFF -> -01
         //        0018 -> +24
         TablaDesplazamientosBufferPuertas[0] = 1
         TablaDesplazamientosBufferPuertas[1] = -24
         TablaDesplazamientosBufferPuertas[2] = -1
         TablaDesplazamientosBufferPuertas[3] = 24
         Orientacion = LeerBytePersonajeObjeto(PunteroDatosIY + 0)  //obtiene la orientación de la puerta
         Orientacion = Orientacion & 0x3
         //Orientacion = Orientacion * 2 'cada entrada ocupa 2 bytes
         //DeltaX = TablaDesplazamientosBufferPuertas(Orientacion)
         //DeltaY = TablaDesplazamientosBufferPuertas(Orientacion + 1)
         DeltaBuffer = Int(TablaDesplazamientosBufferPuertas[Int(Orientacion)])
         LeerDesplazamientoPuerta_0E2C = DeterminarPosicionCentral_0CBE(PunteroDatosIY, &PunteroBufferAlturasIX)
         return LeerDesplazamientoPuerta_0E2C
    }

     public func DeterminarPosicionCentral_0CBE( _ PunteroDatosIY:Int, _ PunteroBufferAlturasIX: inout Int) -> Bool {
         //si la posición no es una de las del centro de la pantalla o la altura del personaje no coincide con la altura base de la planta, sale con false
         //en otro caso, devuelve en PunteroBufferAlturasIX un puntero a la entrada de la tabla de alturas de la posición correspondiente
         //llamado con PunteroDatosIY = dirección de los datos de posición asociados al personaje/objeto
         var DeterminarPosicionCentral_0CBE:Bool
         var Altura:UInt8
         var AlturaBase:UInt8
         var X:UInt8
         var Y:UInt8
         DeterminarPosicionCentral_0CBE = false
         Altura = LeerBytePersonajeObjeto(PunteroDatosIY + 4) //obtiene la altura del personaje
         AlturaBase = LeerAlturaBasePlanta_2473(Altura) //dependiendo de la altura, devuelve la altura base de la planta
         if AlturaBasePlantaActual_2DBA != AlturaBase { return DeterminarPosicionCentral_0CBE } //si las alturas son distintas, sale con false
         X = LeerBytePersonajeObjeto(PunteroDatosIY + 2) //posición x del personaje
         Y = LeerBytePersonajeObjeto(PunteroDatosIY + 3) //posición y del personaje
         if !DeterminarPosicionCentral_279B(&X, &Y) { return DeterminarPosicionCentral_0CBE } //ajusta la posición pasada en X,Y a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, sale
         DeterminarPosicionCentral_0CBE = true //visible
         PunteroBufferAlturasIX = PunteroBufferAlturas_2D8A + 24 * Int(Y) + Int(X)
         return DeterminarPosicionCentral_0CBE
    }

     public func DeterminarPosicionCentral_279B( _ X: inout UInt8, _ Y: inout UInt8) -> Bool {
         //ajusta la posición pasada en X,Y a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, devuelve false
         var DeterminarPosicionCentral_279B:Bool
         DeterminarPosicionCentral_279B = false
         if Y < MinimaPosicionYVisible_279D { return DeterminarPosicionCentral_279B } //si la posición en y es < el límite inferior en y en esta pantalla, sale
         Y = Y - MinimaPosicionYVisible_279D //límite inferior en y
         if Y < 2 { return DeterminarPosicionCentral_279B }
         if Y >= 0x16 { return DeterminarPosicionCentral_279B } //si la posición en y es > el límite superior en y en esta pantalla, sale
         if X < MinimaPosicionXVisible_27A9 { return DeterminarPosicionCentral_279B } // si la posición en x es < el límite inferior en x en esta pantalla, sale
         X = X - MinimaPosicionXVisible_27A9 //límite inferior en x
         if X < 2 { return DeterminarPosicionCentral_279B }
         if X >= 0x16 { return DeterminarPosicionCentral_279B } //si la posición en x es > el límite superior en x en esta pantalla, sale
         DeterminarPosicionCentral_279B = true
         return DeterminarPosicionCentral_279B
     }

     public func ProcesarObjetoVisible_0DBB( _ PunteroSpriteIX:Int, _ PunteroDatosIY:Int, _ X:UInt8, _ Y:UInt8, _ Z:UInt8) {
         //rutina llamada cuando los objetos del juego son visibles en la pantalla actual
         //si no se dibujaba el objeto, ajusta la posición y lo marca para que se dibuje
         //PunteroSpriteIX apunta al sprite del objeto
         //PunteroDatosIY apunta a los datos del objeto
         //X,Y continene la posición en pantalla del objeto
         //X = la coordenada y del sprite en pantalla (-16)
         if LeerBitArray(TablaPosicionObjetos_3008, PunteroDatosIY - 0x3008, 7) { return } //si el objeto ya se ha cogido, sale
         TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = Z | 0x80  //indica que hay que pintar el objeto y actualiza la profundidad del objeto dentro del buffer de tiles
         TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17] = Y - 8  //modifica la posición y del objeto (-8 pixels)
         if X >= 2 {
             TablaSprites_2E17[PunteroSpriteIX + 1 - 0x2E17] = X - 2 //modifica la posición x del objeto (-2 pixels)
         } else {
             TablaSprites_2E17[PunteroSpriteIX + 1 - 0x2E17] = UInt8(256 + Int(X) - 2) //evita el bug del pergamino
         }
     }

     public func ProcesarPersonaje_2468( _ PunteroSpritePersonajeIX:Int, _ PunteroDatosPersonajeIY:Int, _ PunteroDatosPersonajeHL:Int) {
         //procesa los datos del personaje para cambiar la animación y posición del sprite
         //PunteroSpritePersonajeIX = dirección del sprite correspondiente
         //PunteroDatosPersonajeIY = datos de posición del personaje correspondiente
         var PunteroTablaAnimaciones:Int
         var Y:UInt8=0
         var HL:String
         var IX:String
         var IY:String
         IX = String(format: "%02X", PunteroSpritePersonajeIX)
         IY = String(format: "%02X", PunteroDatosPersonajeIY)
         HL = String(format: "%02X", PunteroDatosPersonajeHL)
         PunteroTablaAnimaciones = CambiarAnimacionTrajesMonjes_2A61(PunteroSpritePersonajeIX, PunteroDatosPersonajeIY) //cambia la animación de los trajes de los monjes según la posición y en contador de animaciones
         HL = String(format: "%02X", PunteroTablaAnimaciones)
         if ComprobarVisibilidadSprite_245E(PunteroSpritePersonajeIX, PunteroDatosPersonajeIY, &Y) {
             ActualizarDatosGraficosPersonaje_2A34(PunteroSpritePersonajeIX, PunteroDatosPersonajeIY, PunteroTablaAnimaciones, Y)
         }
     }

     public func CambiarAnimacionTrajesMonjes_2A61( _ PunteroSpritePersonajeIX:Int, _ PunteroDatosPersonajeIY:Int) -> Int {
         //cambia la animación de los trajes de los monjes según la posición y en contador de animaciones y obtiene la dirección de los
         //datos de la animación que hay que poner en hl
         //PunteroSpritePersonajeIX = dirección del sprite correspondiente
         //PunteroDatosPersonajeIY = datos de posición del personaje correspondiente
         //al salir devuelve el índice en la tabla de animaciones
         var CambiarAnimacionTrajesMonjes_2A61:Int
         var AnimacionPersonaje:UInt8
         var AnimacionTraje:UInt8
         var AnimacionSprite:UInt8
         var Orientacion:UInt8
         var PunteroAnimacion:Int
         var IX:String
         var IY:String
         var DE:String
         IX = String(format: "%02X", PunteroSpritePersonajeIX)
         IY = String(format: "%02X", PunteroDatosPersonajeIY)
         AnimacionPersonaje = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeIY - 0x3036] //obtiene la animación del personaje
         //2A64
         Orientacion = TablaCaracteristicasPersonajes_3036[PunteroDatosPersonajeIY + 1 - 0x3036]  //obtiene la orientación del personaje
         //2A67
         Orientacion = ModificarOrientacion_2480(Orientacion) //modifica la orientación que se le pasa con la orientación de la pantalla actual
         //2A6b
         AnimacionTraje = (Orientacion * 4) | AnimacionPersonaje //desplaza la orientación 2 a la izquierda y la combina con la animación para obtener la animación del traje de los monjes
         //2A6F
         AnimacionSprite = TablaSprites_2E17[PunteroSpritePersonajeIX + 0xB - 0x2E17] //lee el antiguo valor...
         //2A72
         AnimacionSprite = AnimacionSprite & 0xF0 //...y se queda con los bits que no son de la animación
         AnimacionSprite = AnimacionSprite | AnimacionTraje
         //2A75
         TablaSprites_2E17[PunteroSpritePersonajeIX + 0xB - 0x2E17] = AnimacionSprite //combina el valor anterior con la animación del traje
         //2A78
         PunteroAnimacion = Int(Orientacion) //recupera la orientación del personaje en la pantalla actual
         PunteroAnimacion = PunteroAnimacion + 1
         PunteroAnimacion = PunteroAnimacion & 2 //indica si el personaje mira hacia la derecha o hacia la izquierda
         PunteroAnimacion = PunteroAnimacion << 1 //desplaza 1 bit a la izquierda
         PunteroAnimacion = PunteroAnimacion | Int(AnimacionPersonaje) //combina con el número de animación actual
         PunteroAnimacion = PunteroAnimacion * 4 //desplaza 2 bits a la izquierda (las animaciones de las x y de las y están separadas por 8 entradas)
         //2A80
         //a = 0 0 0 (si se mueve en x, 0, si se mueve en y, 1) (número de la secuencia de animación (2 bits)) 0 0
         DE = String(format: "%02X", PunteroTablaAnimacionesPersonaje_2A84)
         if (PunteroTablaAnimacionesPersonaje_2A84 & 0xC000) != 0xC000 {
             //2A8D
             PunteroAnimacion = PunteroAnimacion + PunteroTablaAnimacionesPersonaje_2A84 //indexa en la tabla
             CambiarAnimacionTrajesMonjes_2A61 = PunteroAnimacion
             return CambiarAnimacionTrajesMonjes_2A61 //si la dirección que se ha puesto en 2A84 empieza por 0xc0, vuelve
         }
         //aquí llega si la dirección que se ha puesto en la instrucción modificada empieza por 0xc0
         //PunteroAnimacion = índice en la tabla de animaciones
         var NumeroMonje:UInt8
         var PunteroCaraMonje:Int
         //2A8F
         NumeroMonje = UInt8(PunteroTablaAnimacionesPersonaje_2A84 & 0xFF) //número de monje (0, 2, 4 ó 6)
         //2A96
         PunteroCaraMonje = Leer16(TablaPunterosCarasMonjes_3097, Int(NumeroMonje) + 0x3097 - 0x3097)
         //2aa0
         if (PunteroAnimacion & 0x10) != 0 { //según se mueva en x o en y, pone una cabeza
             //2AA5
             PunteroCaraMonje = PunteroCaraMonje + 0x32 //si el bit 4 es 1 (se mueve en y), coge la segunda cara
         }
         //2AA9
         PunteroAnimacion = PunteroAnimacion + 0x31DF
         Escribir16(&TablaAnimacionPersonajes_319F, PunteroAnimacion - 0x319F, PunteroCaraMonje)
         CambiarAnimacionTrajesMonjes_2A61 = PunteroAnimacion
         return CambiarAnimacionTrajesMonjes_2A61
     }

     public func ComprobarVisibilidadSprite_245E( _ PunteroSpritePersonajeIX:Int, _ PunteroDatosPersonajeIY:Int, _ Ypantalla: inout UInt8) -> Bool {
         var ComprobarVisibilidadSprite_245E:Bool
         var Visible:Bool
         var X:UInt8=0
         var Z:UInt8=0
         var Y:UInt8=0
         ComprobarVisibilidadSprite_245E = false
         Visible = ProcesarObjeto_2ADD(PunteroSpritePersonajeIX, PunteroDatosPersonajeIY, &X, &Y, &Z, &Ypantalla) //comprueba si es visible y si lo es, actualiza su posición si fuese necesario
         if !Visible {
             TablaSprites_2E17[PunteroSpritePersonajeIX + 0 - 0x2E17] = 0xFE //marca el sprite como no usado
             return ComprobarVisibilidadSprite_245E //sale con visibilidad=false
         }
         ComprobarVisibilidadSprite_245E = Visible
         return ComprobarVisibilidadSprite_245E
     }

     public func ActualizarDatosGraficosPersonaje_2A34 ( _ PunteroSpritePersonajeIX:Int, _ PunteroDatosPersonajeIY:Int, _ PunteroDatosPersonajeHL:Int, _ Y:UInt8) {
         //aquí se llega desde fuera si un sprite es visible, después de haber actualizado su posición.
         //en PunteroDatosPersonajeHL se apunta a la animación correspondiente para el sprite
         //PunteroSpritePersonajeIX = dirección del sprite correspondiente
         //PunteroDatosPersonajeIY = datos de posición del personaje correspondiente
         //Y = posición y en pantalla del sprite
         var Orientacion:UInt8
         TablaSprites_2E17[PunteroSpritePersonajeIX + 7 - 0x2E17] = TablaAnimacionPersonajes_319F[PunteroDatosPersonajeHL - 0x319F] //actualiza la dirección de los gráficos del sprite con la animación que toca
         //2a38
         TablaSprites_2E17[PunteroSpritePersonajeIX + 8 - 0x2E17] = TablaAnimacionPersonajes_319F[PunteroDatosPersonajeHL + 1 - 0x319F] //actualiza la dirección de los gráficos del sprite con la animación que toca
         //2a3d
         TablaSprites_2E17[PunteroSpritePersonajeIX + 5 - 0x2E17] = TablaAnimacionPersonajes_319F[PunteroDatosPersonajeHL + 2 - 0x319F] //actualiza el ancho y alto del sprite según la animación que toca
         //2a42
         TablaSprites_2E17[PunteroSpritePersonajeIX + 6 - 0x2E17] = TablaAnimacionPersonajes_319F[PunteroDatosPersonajeHL + 3 - 0x319F] //actualiza el ancho y alto del sprite según la animación que toca
         //2a47
         TablaSprites_2E17[PunteroSpritePersonajeIX + 0 - 0x2E17] = Y | 0x80 //indica que hay que redibujar el sprite. combina el valor con la posición y de pantalla del sprite
         //2a4d
         Orientacion = ModificarOrientacion_2480(LeerBytePersonajeObjeto(PunteroDatosPersonajeIY + 1)) //obtiene la orientación del personaje. modifica la orientación que se le pasa en a con la orientación de la pantalla actual
         //2a53
         Orientacion = Orientacion >> 1
         //2a55
         if Orientacion != LeerBytePersonajeObjeto(PunteroDatosPersonajeIY + 6) { //comprueba si ha cambiado la orientación del personaje
             //si es así, salta al método correspondiente por si hay que flipear los gráficos
             //2A58
             switch PunteroRutinaFlipPersonaje_2A59 {
                 case 0x353B:
                     FlipearSpritesGuillermo_353B()
                 case 0x34E2:
                     FlipearSpritesAdso_34E2()
                 case 0x34FB:
                     FlipearSpritesMalaquias_34FB()
                 case 0x350B:
                     FlipearSpritesAbad_350B()
                 case 0x351B:
                     FlipearSpritesBerengario_351B()
                 case 0x352B:
                     FlipearSpritesSeverino_352B()
                 case 0x5473:
                     FlipearGraficosEspejo_5473(PunteroSpriteIX: PunteroSpritePersonajeIX)
                 default:
                     break
             }
         }
         //2A5D
         MovimientoRealizado_2DC1 = true //indica que ha habido movimiento
     }

     public func FlipearSpritesGuillermo_353B() {
         //este método se llama cuando cambia la orientación del sprite de guillermo y se encarga de flipear los sprites de guillermo
         TablaCaracteristicasPersonajes_3036[0x303C - 0x3036] = TablaCaracteristicasPersonajes_3036[0x303C - 0x3036] ^ 1 //invierte el estado del flag
         //A300 apunta a los gráficos de guillermo de 5 bytes de ancho
         //5 bytes de ancho y 0x366 bytes (0xae*5)
        GirarGraficosRespectoX_3552(Tabla: &TablaGraficosObjetos_A300, PunteroTablaHL: 0xA300 - 0xA300, AnchoC: 5, NGraficosB: 0xAE)
         //A666 apunta a los gráficos de guillermo de 4 bytes de ancho
         //4 bytes de ancho y 0x84 bytes (0x21*4)
        GirarGraficosRespectoX_3552(Tabla: &TablaGraficosObjetos_A300, PunteroTablaHL: 0xA666 - 0xA300, AnchoC: 4, NGraficosB: 0x21)
     }

    public func FlipearSpritesAdso_34E2() {
        //este método se llama cuando cambia la orientación del sprite de adso y se encarga de flipear los sprites de adso
        TablaCaracteristicasPersonajes_3036[0x304B - 0x3036] = TablaCaracteristicasPersonajes_3036[0x304B - 0x3036] ^ 1 //flip de adso
        //A6EA apunta a los sprites de adso de 5 bytes de ancho
        GirarGraficosRespectoX_3552(Tabla: &TablaGraficosObjetos_A300, PunteroTablaHL: 0xA6EA - 0xA300, AnchoC: 5, NGraficosB: 0x5F)
        //A8C5 apunta a los sprite de adso de 4 bytes de ancho
        GirarGraficosRespectoX_3552(Tabla: &TablaGraficosObjetos_A300, PunteroTablaHL: 0xA8C5 - 0xA300, AnchoC: 4, NGraficosB: 0x5A)
    }

    public func FlipearSpritesMalaquias_34FB() {
        //este método se llama cuando cambia la orientación del sprite de malaquías y se encarga de flipear las caras del sprite
        var PunteroDatos:Int
        TablaCaracteristicasPersonajes_3036[0x305A - 0x3036] = TablaCaracteristicasPersonajes_3036[0x305A - 0x3036] ^ 1 //flip de malaquías
        PunteroDatos = Leer16(TablaPunterosCarasMonjes_3097, 0x3097 - 0x3097) //apunta a los datos de las caras de malaquías
        GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: PunteroDatos - 0xAB59, AnchoC: 5, NGraficosB: 0x14) //flipea las caras de malaquías
    }

    public func FlipearSpritesAbad_350B() {
        //este método se llama cuando cambia la orientación del sprite del abad y se encarga de flipear las caras del sprite
        var PunteroDatos:Int
        TablaCaracteristicasPersonajes_3036[0x3069 - 0x3036] = TablaCaracteristicasPersonajes_3036[0x3069 - 0x3036] ^ 1 //flip de malaquías
        PunteroDatos = Leer16(TablaPunterosCarasMonjes_3097, 0x3099 - 0x3097) //apunta a los datos de las caras del abad
        GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: PunteroDatos - 0xAB59, AnchoC: 5, NGraficosB: 0x14) //flipea las caras del abad
    }

    public func FlipearSpritesBerengario_351B() {
        //este método se llama cuando cambia la orientación del sprite de berengario y se encarga de flipear las caras del sprite
        var PunteroDatos:Int
        TablaCaracteristicasPersonajes_3036[0x3078 - 0x3036] = TablaCaracteristicasPersonajes_3036[0x3078 - 0x3036] ^ 1 //flip de malaquías
        PunteroDatos = Leer16(TablaPunterosCarasMonjes_3097, 0x309B - 0x3097) //apunta a los datos de las caras de berengario
        GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: PunteroDatos - 0xAB59, AnchoC: 5, NGraficosB: 0x14) //flipea las caras de berengario
    }

     public func FlipearSpritesSeverino_352B() {
         //este método se llama cuando cambia la orientación del sprite de severino y se encarga de flipear las caras del sprite
         var PunteroDatos:Int
         TablaCaracteristicasPersonajes_3036[0x3087 - 0x3036] = TablaCaracteristicasPersonajes_3036[0x3087 - 0x3036] ^ 1 //flip de malaquías
         PunteroDatos = Leer16(TablaPunterosCarasMonjes_3097, 0x309D - 0x3097) //apunta a los datos de las caras de severino
        GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: PunteroDatos - 0xAB59, AnchoC: 5, NGraficosB: 0x14) //flipea las caras de severino
     }
    
    public func FlipearGraficosEspejo_5473(PunteroSpriteIX:Int) {
        //rutina encargada de flipear los gráficos
        var AnchoL:UInt8
        var AltoH:UInt8
        var ContadorBC:Int
        var PunteroGraficosHL:Int
        var PunteroSpritesDE:Int
        //obtiene el ancho y el alto del sprite
        AnchoL = TablaSprites_2E17[PunteroSpriteIX + 5 - 0x2E17]
        AltoH = TablaSprites_2E17[PunteroSpriteIX + 6 - 0x2E17]
        //bc = ancho*alto
        ContadorBC = Int(AnchoL) * Int(AltoH)
        PunteroSpritesDE = PunteroEspejo_5483
        //hl = dirección de los gráficos del sprite
        PunteroGraficosHL = Leer16(TablaSprites_2E17, PunteroSpriteIX + 0x07 - 0x2E17)
        //pone la nueva dirección de los gráficos
        Escribir16(&TablaSprites_2E17, PunteroSpriteIX + 0x07 - 0x2E17, PunteroEspejo_5483)
        //copia los gráficos al destino
        while true {
            BufferSprites_9500[PunteroSpritesDE - 0x9500] = TablaGraficosObjetos_A300[PunteroGraficosHL - 0xA300]
            PunteroSpritesDE = PunteroSpritesDE + 1
            PunteroGraficosHL = PunteroGraficosHL + 1
            ContadorBC = ContadorBC - 1
            if ContadorBC == 0 { break }
        }
        //flipea los gráficos apuntados por hl según las características indicadas por bc
        GirarGraficosRespectoX_3552(Tabla: &BufferSprites_9500, PunteroTablaHL: PunteroEspejo_5483 - 0x9500, AnchoC: AnchoL, NGraficosB: AltoH)
    }

    public func RellenarBufferAlturasPersonaje_28EF( _ PunteroDatosPersonajeIY:Int, _ ValorBufferAlturas:UInt8) {
         //si la posición del sprite es central y la altura está bien, pone ValorBufferAlturas en las posiciones que ocupa del buffer de alturas
         //PunteroDatosPersonajeIY = dirección de los datos de posición asociados al personaje
         //ValorBufferAlturas = valor a poner en las posiciones que ocupa el personaje del buffer de alturas
         var PunteroBufferAlturasIX:Int=0
         var Altura:UInt8
         var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4
         if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
         if !DeterminarPosicionCentral_0CBE(PunteroDatosPersonajeIY, &PunteroBufferAlturasIX) { return } //si la posición no es una de las del centro de la pantalla o la altura del personaje no coincide con la altura base de la planta, sale
         //28F3
         //en otro caso PunteroBufferAlturasIX apunta a la altura de la pos actual
         if !BufferAuxiliar {
             Altura = TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x01C0] //obtiene la entrada del buffer de alturas
         } else {
             Altura = TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x96F4] //obtiene la entrada del buffer de alturas
         }
         //28f6
         if !BufferAuxiliar {
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x01C0] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y)
         } else {
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x96F4] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y)
         }
         //28FC
         if LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroDatosPersonajeIY + 5 - 0x3036, 7) { return }//si el bit 7 del byte 5 está puesto, sale
         //2901
         //indica que el personaje también ocupa la posición (x - 1, y)
         if !BufferAuxiliar {
             Altura = TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 1 - 0x01C0]
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 1 - 0x01C0] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x-1, y)
         } else {
             Altura = TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 1 - 0x96F4]
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 1 - 0x96F4] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x-1, y)
         }
         //290A
         //indica que el personaje también ocupa la posición (x, y-1)
         if !BufferAuxiliar {
             Altura = TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x18 - 0x01C0]
         } else {
             Altura = TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x18 - 0x96F4]
         }
         //290D
         if !BufferAuxiliar {
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x18 - 0x01C0] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y-1)
         } else {
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x18 - 0x96F4] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y-1)
         }
         //2913
         //indica que el personaje también ocupa la posición (x-1, y-1)
         if !BufferAuxiliar {
             Altura = TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x19 - 0x01C0]
             TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x19 - 0x01C0] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y-1)
         } else {
             Altura = TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x19 - 0x96F4]
             TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x19 - 0x96F4] = (Altura & 0xF) | ValorBufferAlturas //indica que el personaje está en la posición (x, y-1)
         }
     }

     public func DibujarSprites_2674() {
        //dibuja los sprites
        if HabitacionOscura_156C {
            DibujarSprites_267B()
        } else {
            DibujarSprites_4914()
        }
    }

    public func DibujarSprites_267B() {
        //dibuja los sprites
        var PunteroSpritesHL:Int
        var Valor:UInt8

        //dibujo de los sprites cuando la habitación no está iluminada
        PunteroSpritesHL = 0x2E17 //apunta al primer sprite de los personajes
        while true {
            //2681
            Valor = TablaSprites_2E17[PunteroSpritesHL - 0x2E17]
            if Valor == 0xFF {
                break //si ha llegado al final, salta
            } else if Valor != 0xFE { //si es visible, marca el sprite como que no hay que dibujarlo (porque está oscuro)
                //268A
                TablaSprites_2E17[PunteroSpritesHL - 0x2E17] = Valor & 0x7F
            }
            PunteroSpritesHL = PunteroSpritesHL + 0x14 //longitud de cada sprite
        }
        //268F
        if !depuracion.LuzEnGuillermo {
            if TablaSprites_2E17[0x2E2B - 0x2E17] == 0xFE { return } //si el sprite de adso no es visible, sale //### depuración
        }
        if (!depuracion.LuzEnGuillermo && depuracion.Luz == EnumTipoLuz.EnumTipoLuz_Off) || depuracion.Luz == EnumTipoLuz.EnumTipoLuz_Normal {
            if !depuracion.Lampara {
                //2695
                if !LeerBitArray(TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7) { return } //si adso no tiene la lámpara, sale //### depuración
            }
        }
        TablaSprites_2E17[0x2FCF - 0x2E17] = 0xBC //activa el sprite de la luz
        DibujarSprites_4914()
    }

    public func DibujarSprites_4914() {
        var Punteros:[Int]=[Int](repeating:0, count: 23) //punteros a los sprites
        var NumeroSprites:Int=0 //número de sprites en la pila
        var NumeroSpritesVisibles:Int //número de elementos visibles
        var PunteroSpriteIX:Int //sprite original (bucle exterior)
        var Valor:UInt8
        var NumeroCambios:UInt8
        var Temporal:Int
        var Contador:Int
        var Contador2:Int
        var Profundidad1:UInt8
        var Profundidad2:UInt8
        var Xactual:UInt8
        var Yactual:UInt8
        var nXactual:UInt8
        var nYactual:UInt8
        var Xanterior:UInt8
        var Yanterior:UInt8
        var nXanterior:UInt8
        var nYanterior:UInt8
        var TileX:UInt8=0
        var TileY:UInt8=0
        var nXsprite:UInt8=0
        var nYsprite:UInt8=0
        var ValorLongDE:Int
        var PunteroBufferTiles:Int
        var AltoXanchoSprite:Int
        var PunteroBufferSprites:Int
        var PunteroBufferSpritesAnterior:Int
        var PunteroBufferSpritesLibre:Int //4908
        var ProfundidadMaxima_4DD9:Int //límite superior de profundidad de la iteración anterior
        var PunteroSpriteIY:Int //sprite actual (bucle interior)
        var Distancia1X:UInt8=0 //distancia desde el inicio del sprite actual al inicio del sprite original
        var Distancia2X:UInt8=0 //distancia desde el inicio del sprite original al inicio del sprite actual
        var LongitudX:UInt8=0 //longitud a pintar del sprite actual
        var Distancia1Y:UInt8=0
        var Distancia2Y:UInt8=0
        var LongitudY:UInt8=0
        var ProfundidadMaxima:Int //profundidad máxima de la iteración actual
        var PunteroBufferTilesAnterior_3095:Int
        var NCiclos:Int=0
        //ModPantalla.Refrescar()
        if !depuracion.PersonajesAdso {
            TablaSprites_2E17[0x2E2B + 0 - 0x2E17] = 0xFE //desconecta a adso
        }
        if !depuracion.PersonajesMalaquias {
            TablaSprites_2E17[0x2E3F + 0 - 0x2E17] = 0xFE //desconecta a malaquías
        }
        if !depuracion.PersonajesAbad {
            TablaSprites_2E17[0x2E53 + 0 - 0x2E17] = 0xFE //desconecta al abad ###depuración
        }
        if !depuracion.PersonajesBerengario {
            TablaSprites_2E17[0x2E67 + 0 - 0x2E17] = 0xFE //desconecta a berengario
        }
        if !depuracion.PersonajesSeverino {
            TablaSprites_2E17[0x2E7B + 0 - 0x2E17] = 0xFE //desconecta a severino
        }


        //TablaSprites_2E17(0x2E2B + 1 - 0x2E17) = TablaSprites_2E17(0x2E17 + 1 - 0x2E17)
        //TablaSprites_2E17(0x2E2B + 2 - 0x2E17) = TablaSprites_2E17(0x2E17 + 2 - 0x2E17)
        //TablaSprites_2E17(0x2E2B + 3 - 0x2E17) = TablaSprites_2E17(0x2E17 + 3 - 0x2E17)


        while true {
            //4918
            PunteroBufferSprites = 0x9500 //apunta al comienzo del buffer para los sprites
            PunteroBufferSpritesLibre = 0x9500
            PunteroSpriteIX = 0x2E17 //apunta al primer sprite
            //limpia los punteros de la iteración anterior
            for Contador in 0..<NumeroSprites {
                Punteros[Contador] = 0
            }
            NumeroSprites = 0
            NumeroSpritesVisibles = 0
            while true {
                //4929
                Valor = TablaSprites_2E17[PunteroSpriteIX - 0x2E17]
                if Valor == 0xFF {
                    break //si ha llegado al final, salta
                } else if Valor != 0xFE { //si es visible, guarda la dirección
                    //4932
                    Punteros[NumeroSprites] = PunteroSpriteIX //ojo, cambiado.  antes NumeroSpritesVisibles
                    NumeroSprites = NumeroSprites + 1
                    if (Valor & 0x80) != 0 { //hay que dibujar el sprite
                        if LeerBitArray(TablaSprites_2E17, PunteroSpriteIX + 0 - 0x2E17, 7) { //hay que dibujar el sprite
                            NumeroSpritesVisibles = NumeroSpritesVisibles + 1
                        }
                    }
                }
                PunteroSpriteIX = PunteroSpriteIX + 0x14 //20 bytes por entrada
                //Application.DoEvents()
            }
            //493b
            //aquí llega una vez que ha metido en la pila las entradas a tratar
            if NumeroSpritesVisibles == 0 { return } // si no había alguna entrada activa, vuelve
            //494a
            //aquí llega si había alguna entrada que había que pintar
            //primero se ordenan las entradas según la profundidad por el método de la burbuja mejorado
            if NumeroSprites > 1 {
                while true {
                    NumeroCambios = 0
                    for Contador in stride(from: NumeroSprites - 2, through: 0, by: -1) {
                        Profundidad1 = TablaSprites_2E17[Punteros[Contador + 1] - 0x2E17] & 0x3F
                        Profundidad2 = TablaSprites_2E17[Punteros[Contador] - 0x2E17] & 0x3F
                        if Profundidad2 < Profundidad1 { //realiza un intercambio
                            Temporal = Punteros[Contador]
                            Punteros[Contador] = Punteros[Contador + 1]
                            Punteros[Contador + 1] = Temporal
                            NumeroCambios = NumeroCambios + 1
                        }
                    }
                    if NumeroCambios == 0 { break }
                    //Application.DoEvents()
                }
            }
            //aquí llega una vez que las entradas de la pila están ordenadas por la profundidad
            //4977
            for Contador in stride(from: NumeroSprites - 1, through: 0, by: -1)  {
                //498C
                PunteroSpriteIX = Punteros[Contador]
                //498F
                ClearBitArray(&TablaSprites_2E17, PunteroSpriteIX + 0 - 0x2E17, 6) //pone el bit 6 a 0. sprite no prcesado
                if LeerBitArray(TablaSprites_2E17, PunteroSpriteIX + 0 - 0x2E17, 7) { //el sprite ha cambiado
                    //4999

                    Xactual = TablaSprites_2E17[PunteroSpriteIX + 1 - 0x2E17] //posición x en bytes
                    Yactual = TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17] //posición y en pixels
                    nYactual = TablaSprites_2E17[PunteroSpriteIX + 6 - 0x2E17] //alto en pixels
                    nXactual = TablaSprites_2E17[PunteroSpriteIX + 5 - 0x2E17] //ancho en bytes
                    nXactual = nXactual & 0x7F //el bit7 de la posición 5 no nos interesa ahora
                    CalcularDimensionesAmpliadasSprite_4D35(Xactual, Yactual, nXactual, nYactual, &nXsprite, &nYsprite, &TileX, &TileY)
                    Xanterior = TablaSprites_2E17[PunteroSpriteIX + 3 - 0x2E17] //posición x en bytes
                    Yanterior = TablaSprites_2E17[PunteroSpriteIX + 4 - 0x2E17] //posición y en pixels
                    nYanterior = TablaSprites_2E17[PunteroSpriteIX + 0xA - 0x2E17]  //alto en pixels
                    nXanterior = TablaSprites_2E17[PunteroSpriteIX + 9 - 0x2E17] //ancho en bytes

                    //l=X=anterior posición x del sprite (en bytes)
                    //h=Y=anterior posición y del sprite (en pixels)
                    //e=nX=anterior ancho del sprite (en bytes)
                    //d=nY=anterior alto del sprite (en pixels)
                    //2DD5=TileX=posición x del tile en el que empieza el sprite
                    //2DD6=TileY=posición y del tile en el que empieza el sprite
                    //2DD7=nXsprite=tamaño en x del sprite
                    //2DD8=nYsprite=tamaño en y del sprite
                    //49BD
                    if !depuracion.DeshabilitarCalculoDimensionesAmpliadas && NCiclos < 100 {
                        CalcularDimensionesAmpliadasSprite_4CBF(Xanterior, Yanterior, nXanterior, nYanterior, &nXsprite, &nYsprite, &TileX, &TileY)
                    }

                    TablaSprites_2E17[PunteroSpriteIX + 0xC - 0x2E17] = TileX //posición en x del tile en el que empieza el sprite (en bytes)
                    TablaSprites_2E17[PunteroSpriteIX + 0xD - 0x2E17] = TileY //posición en y del tile en el que empieza el sprite (en pixels
                    //dado PunteroSpriteIX, calcula la coordenada correspondiente del buffer de tiles (buffer de tiles de 16x20, donde cada tile ocupa 16x8)
                    //49c9
                    ValorLongDE = Int(TileX) & 0xFC //posición en x del tile inicial en el que empieza el sprite (en bytes)
                    ValorLongDE = ValorLongDE + (ValorLongDE >> 1) //x + x/2 (ya que en cada byte hay 4 pixels y cada entrada en el buffer de tiles es de 6 bytes)
                    //49d6
                    PunteroBufferTiles = Int(TileY) //tile inicial en y en el que empieza el sprite (en pixels)
                    PunteroBufferTiles = PunteroBufferTiles * 12 + ValorLongDE //apunta a la línea correspondiente en el buffer de tiles
                    //TileY tiene valores múltiplos de 8, porque utiliza el pixel como unidad. cada tile son 8 píxeles,
                    //por lo que el cambio de tile supone 12*8=96 bytes


                    //indexa en el buffer de tiles (0x8b94 se corresponde a la posición X = -2, Y = -5 en el buffer de tiles)
                    //que en pixels es: (X = -32, Y = -40), luego el primer pixel del buffer de tiles en coordenadas de sprite es el (32,40)
                    //49e1
                    PunteroBufferTiles = PunteroBufferTiles + 0x8B94


                    //3095=PunteroBuffertiles
                    PunteroBufferTilesAnterior_3095 = PunteroBufferTiles
                    TablaSprites_2E17[PunteroSpriteIX + 0xE - 0x2E17] = nXsprite //ancho final del sprite (en bytes)
                    TablaSprites_2E17[PunteroSpriteIX + 0xF - 0x2E17] = nYsprite //alto final del sprite (en pixels)
                    AltoXanchoSprite = Int(nXsprite) * Int(nYsprite) //alto del sprite*ancho del sprite
                    PunteroBufferSprites = PunteroBufferSpritesLibre
                    TablaSprites_2E17[PunteroSpriteIX + 0x10 - 0x2E17] = LeerByteInt(Valor: PunteroBufferSprites, NumeroByte: 0) //dirección del buffer de sprites asignada a este sprite
                    TablaSprites_2E17[PunteroSpriteIX + 0x11 - 0x2E17] = LeerByteInt(Valor: PunteroBufferSprites, NumeroByte: 1) //dirección del buffer de sprites asignada a este sprite
                    PunteroBufferSpritesLibre = PunteroBufferSprites + AltoXanchoSprite //guarda la dirección libre del buffer de sprites
                    if PunteroBufferSpritesLibre > 0x9CFE { break } //9CFE= límite del buffer de sprites. si no hay sitio para el sprite, salta pasa vaciar la lista de los procesados y procesa el resto
                    //4a13
                    //aquí llega si hay espacio para procesar el sprite
                    SetBitArray(&TablaSprites_2E17, PunteroSpriteIX + 0 - 0x2E17, 6) //pone el bit 6 a 1. marca el sprite como procesado
                    for Contador2 in PunteroBufferSprites..<PunteroBufferSpritesLibre  {
                        BufferSprites_9500[Contador2 - 0x9500] = 0 //limpia la zona asignada del buffer de sprites
                    }
                    //4A1F
                    ProfundidadMaxima_4DD9 = 0
                    //4a2e
                    for Contador2 in stride(from: NumeroSprites - 1, through: 0, by: -1) {
                        //4a56
                        PunteroSpriteIY = Punteros[Contador2] //dirección de la entrada del sprite actual
                        if !LeerBitArray(TablaSprites_2E17, PunteroSpriteIY + 5 - 0x2E17, 7) { //si el sprite no va a desaparecer
                            //4A5F
                            //entrada:
                            //l=PosicionOriginal
                            //h=PosicionActual
                            //e=LongitudOriginal
                            //d=LongitudActual
                            //en a=Longitud devuelve la longitud a pintar del sprite actual para la coordenada que se pasa
                            //en h=Distancia1 devuelve la distancia desde el inicio del sprite actual al inicio del sprite original
                            //en l=Distancia2 devuelve la distancia desde el inicio del sprite original al inicio del sprite actual
                            //si devuelve true, indica que debe evitarse el proceso de esta combinación de sprites
                            //comprueba si el sprite actual puede verse en la zona del sprite original
                            if !ObtenerDistanciaSprites_4D54(PosicionOriginal: TileX, PosicionActual: TablaSprites_2E17[PunteroSpriteIY + 1 - 0x2E17], LongitudOriginal: nXsprite, LongitudActual: TablaSprites_2E17[PunteroSpriteIY + 5 - 0x2E17], Distancia1: &Distancia1X, Distancia2: &Distancia2X, Longitud: &LongitudX) {
                                //4a70                   comprueba si el sprite actual puede verse en la zona del sprite original
                                if !ObtenerDistanciaSprites_4D54(PosicionOriginal: TileY, PosicionActual: TablaSprites_2E17[PunteroSpriteIY + 2 - 0x2E17], LongitudOriginal: nYsprite, LongitudActual: TablaSprites_2E17[PunteroSpriteIY + 6 - 0x2E17], Distancia1: &Distancia1Y, Distancia2: &Distancia2Y, Longitud: &LongitudY) {
                                    //4A9A
                                    //obtiene la posición del sprite en coordenadas de cámara
                                    ProfundidadMaxima = Bytes2Int(Byte0: TablaSprites_2E17[PunteroSpriteIY + 0x12 - 0x2E17], Byte1: TablaSprites_2E17[PunteroSpriteIY + 0x13 - 0x2E17]) //combina los dos bytes en un entero largo
                                    //obtiene el límite superior de profundidad de la iteración anterior y lo coloca como límite inferior
                                    PunteroBufferSpritesAnterior = PunteroBufferSprites
                                    //GuardarArchivo "D:\datos\vbasic\Abadia\Abadia2\BufferSprites", BufferSprites_9500
                                    //4AA0
                                    CopiarTilesBufferSprites_4D9E(ProfundidadMaxima, ProfundidadMaxima_4DD9, false, PunteroBufferTiles, PunteroBufferSprites, nXsprite, nYsprite) //copia en el buffer de sprites los tiles que están detras del sprite
                                    //GuardarArchivo "D:\datos\vbasic\Abadia\Abadia2\BufferSprites", BufferSprites_9500
                                    ProfundidadMaxima_4DD9 = ProfundidadMaxima
                                    PunteroBufferSprites = PunteroBufferSpritesAnterior
                                    DibujarSprite_4AA3(PunteroSpriteIY, Distancia1Y, Distancia2Y, Distancia1X, Distancia2X, nXsprite, PunteroBufferSprites, LongitudY, LongitudX) //al llegar aquí pinta el sprite actual
                                    //GuardarArchivo "D:\datos\vbasic\Abadia\Abadia2\BufferSprites", BufferSprites_9500
                                }
                            }
                        }
                    }
                    //4A43
                    //aquí llega si ya se han procesado todos los sprites de la pila (con respecto al sprite actual)
                    //fcfc: se le pasa un valor de profundidad muy alto
                    //obtiene el límite superior de profundidad de la iteración anterior y lo coloca como límite inferior
                    PunteroBufferTiles = PunteroBufferTilesAnterior_3095
                    //GuardarArchivo "D:\datos\vbasic\Abadia\Abadia2\BufferSprites", BufferSprites_9500
                    //4A4B
                    CopiarTilesBufferSprites_4D9E(0xFCFC, ProfundidadMaxima_4DD9, true, PunteroBufferTiles, PunteroBufferSprites, nXsprite, nYsprite) //dibuja en el buffer de sprites los tiles que están delante del sprite
                    //GuardarArchivo "D:\datos\vbasic\Abadia\Abadia2\BufferSprites", BufferSprites_9500
                }
            }
            //4BDF
            //aquí llega una vez ha procesado todos los sprites que había que redibujar (o si no había más espacio en el buffer de sprites)
            NCiclos = NCiclos + 1
            PunteroSpriteIX = 0x2E17 //apunta al primer sprite
            while true {
                Valor = TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17]
                if Valor == 0xFF { break } //cuando encuentra el último, sale
                if Valor != 0xFE {
                    if (Valor & 0x40) != 0 { //si  tiene puesto el bit 6 (sprite procesado)
                        //4BF2
                        //aquí llega si el sprite actual tiene puesto a 1 el bit 6 (el sprite ha sido procesado)
                        CopiarSpritePantalla_4C1A(PunteroSpriteIX)
                        TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] & 0x3F //limpia el bit 6 y 7 del byte 0
                        if LeerBitArray(TablaSprites_2E17, PunteroSpriteIX + 5 - 0x2E17, 7) { //si el sprite va a desaparecer
                            TablaSprites_2E17[PunteroSpriteIX + 5 - 0x2E17] = TablaSprites_2E17[PunteroSpriteIX + 5 - 0x2E17] & 0x7F //limpia el bit 7
                            TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = 0xFE //marca el sprite como inactivo
                        }
                    }
                }
                PunteroSpriteIX = PunteroSpriteIX + 0x14 //pasa al siguiente sprite
                //Application.DoEvents()
            }
            //Application.DoEvents()
        }
    }

    public func CalcularDimensionesAmpliadasSprite_4D35( _ X:UInt8, _ Y:UInt8, _ nX:UInt8, _ nY:UInt8, _ nXsprite: inout UInt8, _ nYsprite: inout UInt8, _ TileX: inout UInt8, _ TileY: inout UInt8) {
        //devuelve en TileX,TileY la posición inicial del tile en el que empieza el sprite (TileY = pos inicial Y en pixels, TileX = posición inicial X en bytes)
        //devuelve en nXsprite,nYsprite las dimensiones del sprite ampliadas para abarcar todos los tiles en los que se va a dibujar el sprite
        //en X,Y se le pasa la posición inicial (Y = pos Y en pixels, X = pos X en bytes)
        //en nX,nY se le pasa las dimensiones del sprite (nY = alto en pixels, nX = ancho en bytes)
        var b:UInt8
        var c:UInt8
        c = Y & 7 //pos Y dentro del tile actual (en pixels)
        TileY = Y & 0xF8 //posición del tile actual en Y (en pixels)
        b = X & 3 //pos X dentro del tile actual (en bytes)
        TileX = X & 0xFC //posición del tile actual en X (en bytes)
        nYsprite = (nY + c + 7) & 0xF8 //calcula el alto del objeto para que abarque todos los tiles en los que se va a dibujar
        nXsprite = (nX + b + 3) & 0xFC //calcula el ancho del objeto para que abarque todos los tiles en los que se va a dibujar
    }

    public func CalcularDimensionesAmpliadasSprite_4CBF( _ X:UInt8, _ Y:UInt8, _ nX:UInt8, _ nY:UInt8, _ nXsprite: inout UInt8, _ nYsprite: inout UInt8, _ TileX: inout UInt8, _ TileY: inout UInt8) {
        //comprueba las dimensiones mínimas del sprite (para borrar el sprite viejo) y actualiza 0x2dd5 y 0x2dd7
        //en X,Y se le pasa la posición anterior (Y = pos Y en pixels, X = pos X en bytes)
        //en nX,nY se le pasa las dimensiones anteriores del sprite (nY = alto en pixels, nX = ancho en bytes)
        //l=X=anterior posición x del sprite (en bytes)
        //h=Y=anterior posición y del sprite (en pixels)
        //e=nX=anterior ancho del sprite (en bytes)
        //d=nY=anterior alto del sprite (en pixels)
        //2DD5=TileX=posición x del tile en el que empieza el sprite
        //2DD6=TileY=posición y del tile en el que empieza el sprite
        //2DD7=nXsprite=tamaño en x del sprite
        //2DD8=nYsprite=tamaño en y del sprite
        var nX:UInt8 = nX
        var nY:UInt8 = nY
        var Valor:UInt8
        if TileX >= X { //si Xtile >= X2
            //4cc5
            Valor = Z80Add(TileX - X, nXsprite)
            if Valor > nX { nX = Valor }//si el ancho ampliado es mayor que el mínimo, e = ancho ampliado + Xtile - Xspr (coge el mayor ancho del sprite)
            //4cce
            Valor = X & 3 //posición x dentro del tile actual
            TileX = X & 0xFC //actualiza la posición inicial en x del tile en el que empieza el sprite
            nXsprite = ((nX + Valor + 3) & 0xFC) //redondea el ancho al tile superior
        } else {
            //4CE3
            //aquí llega si la posición del sprite en x > que el inicio de un tile en x
            Valor = X - TileX //diferencia de posición en x del tile a x2
            Valor = Z80Add(Valor, nX) //añade al ancho del sprite la diferencia en x entre el inicio del sprite y el del tile asociado al sprite
            if nXsprite < Valor { //si el ancho ampliado del sprite < el ancho mínimo del sprite
                nXsprite = ((Valor + 3) & 0xFC)  //amplia el ancho mínimo del sprite
            }
        }
        //4cf5
        //ahora hace lo mismo para y
        if TileY >= Y { //si ytile >= Y2
            //4cfb
            Valor = TileY - Y + nYsprite
            if Valor > nY { nY = Valor } //si el alto ampliado es mayor que el mínimo, d = alto ampliado + Ytile - Yspr (coge el mayor alto del sprite)
            //4d04
            Valor = Y & 7 //posición y dentro del tile actual
            TileY = Y & 0xF8 //actualiza la posición inicial en y del tile en el que empieza el sprite
            nYsprite = ((nY + Valor + 7) & 0xF8) //redondea el ancho del sprite
            return
        } else {
            //4d18
            Valor = Y - TileY //Y2 - Ytile - Y2
            Valor = Valor + nY //suma al alto del sprite lo que sobresale del inicio del tile en y
            if nYsprite >= Valor { return } //si el alto del sprite >= el alto mínimo, sale
            nYsprite = ((Valor + 7) & 0xF8) //redondea el alto al tile superior y actualiza el alto del sprite
            return
        }
    }

    public func ObtenerDistanciaSprites_4D54(PosicionOriginal:UInt8, PosicionActual:UInt8, LongitudOriginal:UInt8, LongitudActual:UInt8, Distancia1: inout UInt8, Distancia2: inout UInt8, Longitud: inout UInt8) -> Bool {
        //dado l y e, y h y d, que son las posiciones iniciales y longitudes de los sprites original y actual, comprueba si el sprite actual puede
        //verse en la zona del sprite original. Si puede verse, lo recorta. En otro caso, salta a por otro sprite actual
        //entrada:
        //l=PosicionOriginal
        //h=PosicionActual
        //e=LongitudOriginal
        //d=LongitudActual
        //salida:
        //en a=Longitud devuelve la longitud a pintar del sprite actual para la coordenada que se pasa
        //en h=Distancia1 devuelve la distancia desde el inicio del sprite actual al inicio del sprite original
        //en l=Distancia2 devuelve la distancia desde el inicio del sprite original al inicio del sprite actual
        //si devuelve true, indica que debe evitarse el proceso de esta combinación de sprites
        var ObtenerDistanciaSprites_4D54:Bool
        ObtenerDistanciaSprites_4D54 = false
        if PosicionOriginal == PosicionActual { //el sprite original empieza en el mismo punto que el sprite actual
            //4d69
            Distancia1 = 0
            Distancia2 = 0
            if LongitudOriginal < LongitudActual {
                Longitud = LongitudOriginal
            } else {
                Longitud = LongitudActual
            }
        } else if PosicionOriginal < PosicionActual { //el sprite original empieza antes que el actual
            //4d71
            Distancia1 = 0
            Distancia2 = PosicionActual - PosicionOriginal //distancia entre la posición inicial del sprite original y del actual
            if Distancia2 > LongitudOriginal { //si la distancia entre el origen de los 2 sprites es >= que el ancho ampliado del sprite original
                //4D81
                ObtenerDistanciaSprites_4D54 = true
            } else {
                //4D79
                Longitud = LongitudOriginal - Distancia2 //guarda la longitud de la parte visible del sprite actual en el sprite original
                if Longitud > LongitudActual { Longitud = LongitudActual } //si esa longitud es > que la longitud del sprite actual, modifica la longitud a pintar del sprite actual
            }
        } else { //si llega aquí, el sprite actual empieza antes que el sprite original
            //4d5a
            if (PosicionOriginal - PosicionActual) >= LongitudActual { //si la distancia entre los sprites es >= que el ancho del sprite actual, el sprite actual no es visible
                //4D81
                ObtenerDistanciaSprites_4D54 = true
            } else {
                //4d5d
                Distancia1 = PosicionOriginal - PosicionActual //distancia desde el inicio del sprite actual al inicio del sprite original
                Distancia2 = 0
                if (PosicionOriginal - PosicionActual + LongitudOriginal) >= LongitudActual { //si la distancia entre los sprites + la longitud del sprite original >=LongitudActual
                    //4D66
                    //como el sprite original no está completamente dentro del sprite actual, dibuja solo la parte del sprite
                    //actual que se superpone con el sprite original
                    Longitud = LongitudActual - Distancia1
                } else {
                    //4d64
                    Longitud = LongitudOriginal
                }
            }
        }
        return ObtenerDistanciaSprites_4D54
    }

    public func DibujarSprite_4AA3( _ PunteroSpriteIY:Int, _ Distancia1Y:UInt8, _ Distancia2Y:UInt8, _ Distancia1X:UInt8, _ Distancia2X:UInt8, _ nXsprite:UInt8, _ PunteroBufferSprites:Int, _ LongitudY:UInt8, _ LongitudX:UInt8) {
        //pinta el sprite actual
        //Distancia1Y=h
        //Distancia2Y=l
        var Distancia1Y:UInt8=Distancia1Y
        var nX:UInt8 //ancho del sprite actual
        var PunteroDatosGraficosSpriteHL:Int
        var PunteroDatosGraficosSpriteAnterior:Int
        var PunteroBufferSpritesDE:Int
        var PunteroBufferSpritesAnterior:Int
        var ValorLong:Int
        var Valor:UInt8
        var DesplazAdsoX:UInt8
        var Contador:Int=0
        var Contador2:Int
        var MascaraOr:Int
        var MascaraAnd:Int
        var Fila:Int
        var PunteroPatronLuz:Int=0
        var DesplazamientoDE:UInt8 //= 80 (desplazamiento de medio tile)
        var PunteroBufferSpritesIX:Int
        var ValorRelleno:Int //valor de la tabla 48E8 de rellenos de la luz
        var HL:String
        //4AA3
        if Distancia1Y < 10 || (Distancia1Y >= 10 && LeerBitArray(TablaSprites_2E17, PunteroSpriteIY + 0xB - 0x2E17, 7)) { //si la distancia en y desde el inicio del sprite actual al inicio del sprite original < 10 o no se trata de un monje
            //4AD5
            //calcula la línea en la que empezar a dibujar el sprite actual (saltandose la distancia entre el inicio del sprite actual y el inicio del sprite original)
            nX = TablaSprites_2E17[PunteroSpriteIY + 5 - 0x2E17] //obtiene el ancho del sprite actual
            ValorLong = Int(Distancia1Y) //(distancia en y desde el inicio del sprite actual al incio del sprite original
            ValorLong = ValorLong * Int(nX)
            PunteroDatosGraficosSpriteHL = Bytes2Int(Byte0: TablaSprites_2E17[PunteroSpriteIY + 7 - 0x2E17], Byte1: TablaSprites_2E17[PunteroSpriteIY + 8 - 0x2E17]) //dirección de los datos gráficos del sprite
            //dirección de los datos gráficos del sprite (saltando lo que no se superpone con el área del sprite original en y)
            PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + ValorLong
            HL = String(format: "%02X", PunteroDatosGraficosSpriteHL)

        } else {
            //4AB5
            //si llega aquí es porque la distancia en y desde el inicio del sprite actual al inicio del sprite original es >= 10, por lo que del sprite
            //actual (que es un monje), ya se ha pasado la cabeza. Por ello, obtiene un puntero al traje del monje
            ValorLong = Int(Distancia1Y) - 10
            nX = TablaSprites_2E17[PunteroSpriteIY + 5 - 0x2E17] //obtiene el ancho del sprite actual
            ValorLong = ValorLong * Int(nX)
            Valor = TablaSprites_2E17[PunteroSpriteIY + 0xB - 0x2E17] //animación del traje del monje
            PunteroDatosGraficosSpriteHL = Leer16(TablaPunterosTrajesMonjes_48C8, 2 * Int(Valor)) //cada entrada son 2 bytes
            PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + ValorLong
        }
        //4ae5
        //dirección de los datos gráficos del sprite (saltando lo que no está en el área del sprite original en x y en y)
        PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + Int(Distancia1X) //suma la distancia en x desde el inicio del sprite actual al incio del sprite original
        HL = String(format: "%02X", PunteroDatosGraficosSpriteHL)
        //4AED
        //distancia en y desde el inicio del sprite original al inicio del sprite actual * ancho ampliado del sprite original
        ValorLong = Int(Distancia2Y) * Int(nXsprite)
        //PunteroBufferSpritelibre=posición inicial del buffer de sprites para este sprite
        //dirección del buffer de sprites para el sprite original (saltando lo que no puede sobreescribir el sprite actual en y)
        PunteroBufferSpritesDE = PunteroBufferSprites + ValorLong
        //dirección del buffer de sprites para el sprite original (saltando lo que no puede sobreescribir el sprite actual en x y en y)
        PunteroBufferSpritesDE = PunteroBufferSpritesDE + Int(Distancia2X)
        //4b05
        if PunteroDatosGraficosSpriteHL != 0 { //si hl <> 0 (no es el sprite de la luz)
            //4B0A
            //c=Distancia1Y
            //b'=LongitudY
            //b=LongitudX
            for Fila in 0..<LongitudY {
                PunteroDatosGraficosSpriteAnterior = PunteroDatosGraficosSpriteHL
                PunteroBufferSpritesAnterior = PunteroBufferSpritesDE
                for Contador in 0..<LongitudX {
                    //Valor = TablaGraficosObjetos_A300(PunteroDatosGraficosSpriteHL - 0xA300) 'lee un byte gráfico
                    Valor = LeerDatoGrafico(PunteroDatosGraficosSpriteHL)
                    if Valor != 0 { //si es 0, salta al siguiente pixel
                        //4B18
                        MascaraOr = Int(Valor)                //b7 b6 b5 b4 b3 b2 b1 b0
                        ValorLong = rol8(Value: MascaraOr, Shift: 4) //b3 b2 b1 b0 b7 b6 b5 b4
                        ValorLong = ValorLong | MascaraOr   //b7|b3 b6|b2 b5|b1 b4|b0 b7|b3 b6|b2 b5|b1 b4|b0
                        if ValorLong != 0 { //si es 0, salta (???, no sería 0 antes tb???)
                            //4B21
                            MascaraAnd = (-ValorLong - 1) & 0xFF //invierte el byte inferior (los sprites usan el color 0 como transparente)
                            Valor = BufferSprites_9500[PunteroBufferSpritesDE - 0x9500] //lee un byte del buffer de sprites
                            Valor = Valor & Int2ByteSigno(MascaraAnd)
                        }
                        //4b27
                        Valor = Valor | Int2ByteSigno(MascaraOr) //combina el byte leido
                        BufferSprites_9500[PunteroBufferSpritesDE - 0x9500] = Valor //escribe el byte en buffer de sprites después de haberlo combinado
                    }
                    //4b2a
                    PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + 1 //avanza a la siguiente posición en x del gráfico
                    PunteroBufferSpritesDE = PunteroBufferSpritesDE + 1 //avanza a la siguiente posición en x dentro del buffer de sprites
                } //repite para el ancho
                //4B2E
                PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteAnterior
                PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + Int(nX) //pasa a la siguiente línea del sprite
                PunteroBufferSpritesDE = PunteroBufferSpritesAnterior //obtiene el puntero al buffer de sprites
                Distancia1Y = Distancia1Y + 1
                if Distancia1Y == 10 && LeerBitArray(TablaSprites_2E17, PunteroSpriteIY + 0xB - 0x2E17, 7) == false {
                    //4B41
                    //si llega a 10, cambia la dirección de los datos gráficos de origen,
                    //puesto que se pasa de dibujar la cabeza de un monje a dibujar su traje
                    Valor = TablaSprites_2E17[PunteroSpriteIY + 0xB - 0x2E17] & 0x7F //animación del traje del monje
                    PunteroDatosGraficosSpriteHL = 0x48C8 //apunta a la tabla de las posiciones de los trajes de los monjes
                    PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + 2 * Int(Valor)
                    PunteroDatosGraficosSpriteHL = Leer16(TablaPunterosTrajesMonjes_48C8, PunteroDatosGraficosSpriteHL - 0x48C8)
                    //modifica la dirección de los datos gráficos de origen, para que apunte a la animación del traje del monje
                    PunteroDatosGraficosSpriteHL = PunteroDatosGraficosSpriteHL + Int(Distancia1X) //distancia en x desde el inicio del sprite actual al incio del sprite original
                }
                //4B53
                PunteroBufferSpritesDE = PunteroBufferSpritesDE + Int(nXsprite) //pasa a la siguiente línea del buffer de sprites
            } //repite para las líneas de alto
        } else { //si hl == 0 (es el sprite de la luz)
            //4B60
            //aquí llega si el sprite tiene un puntero a datos gráficos = 0 (es el sprite de la luz)
            //apunta a la tabla con el patrón de relleno de la luz
            for Contador in 0...Int(SpriteLuzTipoRelleno_4B6B)  { //TipoRellenoLuz_4B6B=0x00ef o 0x009f
                BufferSprites_9500[PunteroBufferSpritesDE + Contador - 0x9500] = 0xFF //rellena un tile o tile y medio de negro (la parte superior del sprite de la luz)
            }
            PunteroBufferSpritesIX = PunteroBufferSpritesDE + Contador //apunta a lo que hay después del buffer de tiles
            DesplazamientoDE = 0x50 //de= 80 (desplazamiento de medio tile)
            //4b79
            for Contador in 1...15 {//15 veces rellena con bloques de 4x4
                //4b7b
                PunteroBufferSpritesAnterior = PunteroBufferSpritesIX
                ValorRelleno = Leer16Inv(TablaPatronRellenoLuz_48E8, PunteroPatronLuz - 0x48E8) //lee un valor de la tabla
                PunteroPatronLuz = PunteroPatronLuz + 2
                //4B86
                DesplazAdsoX = SpriteLuzAdsoX_4B89 //posición x del sprite de adso dentro del tile
                if DesplazAdsoX != 0 {
                    //4b8e
                    for Contador2 in 0..<DesplazAdsoX {
                        BufferSprites_9500[PunteroBufferSpritesIX + 0 - 0x9500] = 0xFF //relleno negro, primera línea
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x14 - 0x9500] = 0xFF //relleno negro, segunda línea
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x28 - 0x9500] = 0xFF //relleno negro, tercera línea
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x3C - 0x9500] = 0xFF //relleno negro, cuarta línea
                        PunteroBufferSpritesIX = PunteroBufferSpritesIX + 1
                    } //completa el relleno de la parte izquierda
                }
                //4b9e
                if SpriteLuzFlip_4BA0 {
                    ValorRelleno = ValorRelleno << 1 //0x00 o 0x29 (si los gráficos de adso están flipeados o no)
                }
                for Contador2 in 1...16 {//16 bits tiene el valor de la tabla 48E8
                    if (ValorRelleno & 0x8000) == 0 { //si el bit más significativo es 0, rellena de negro el bloque de 4x4
                        //4ba4
                        BufferSprites_9500[PunteroBufferSpritesIX + 0 - 0x9500] = 0xFF //relleno negro
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x14 - 0x9500] = 0xFF //relleno negro
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x28 - 0x9500] = 0xFF //relleno negro
                        BufferSprites_9500[PunteroBufferSpritesIX + 0x3C - 0x9500] = 0xFF //relleno negro
                    }
                    //4bb0
                    ValorRelleno = ValorRelleno << 1
                    PunteroBufferSpritesIX = PunteroBufferSpritesIX + 1
                } //completa los 16 bits
                //4BB4
                DesplazAdsoX = SpriteLuzAdsoX_4BB5  //4 - (posición x del sprite de adso & 0x03)
                for Contador2 in 1...DesplazAdsoX  {//completa la parte de los 16 pixels que sobra por la derecha según la ampliación de la posición x
                    //4bb6
                    BufferSprites_9500[PunteroBufferSpritesIX + 0 - 0x9500] = 0xFF //relleno negro
                    BufferSprites_9500[PunteroBufferSpritesIX + 0x14 - 0x9500] = 0xFF //relleno negro
                    BufferSprites_9500[PunteroBufferSpritesIX + 0x28 - 0x9500] = 0xFF //relleno negro
                    BufferSprites_9500[PunteroBufferSpritesIX + 0x3C - 0x9500] = 0xFF //relleno negro
                    PunteroBufferSpritesIX = PunteroBufferSpritesIX + 1
                    //4BC4
                } //completa la parte derecha
                //4bc6
                PunteroBufferSpritesIX = PunteroBufferSpritesAnterior
                PunteroBufferSpritesIX = PunteroBufferSpritesIX + Int(DesplazamientoDE)
                //4bcb
            } //repite hasta completar los 15 bloques de 4 pixels de alto
            //4BCD
            for Contador in 0...Int(SpriteLuzTipoRelleno_4BD1)  {//0x00ef o 0x009f
                BufferSprites_9500[PunteroBufferSpritesIX + Contador - 0x9500] = 0xFF //rellena un tile o tile y medio de negro (la parte inferior del sprite de la luz)
            }
        }
        return
    }

    public func EsValidoPunteroBufferTiles( _ Puntero:Int) -> Bool {
        //comprueba si un puntero al buffer de tiles está dentro de sus límites
        if (Puntero - 0x8D80) >= 0 && (Puntero - 0x8D80) < BufferTiles_8D80.count {
            return true
        } else {
            return false
        }
    }

    public func CopiarTilesBufferSprites_4D9E( _ ProfundidadMaxima:Int, _ ProfundidadMinima:Int, _ SpritesPilaProcesados:Bool, _ PunteroBufferTilesIX:Int, _ PunteroBufferSpritesDE:Int, _ nXsprite:UInt8, _ nYsprite:UInt8) {
        //4dd9=ProfundidadMinima
        //4afa=PunteroBufferSpritesDE
        //bc=ProfundidadMaxima
        //3095=ix=PunteroBufferTilesIX
        //2dd7=nXsprite
        //2dd8=nYsprite
        //copia en el buffer de sprites los tiles que están entre la profundidad mínima y la máxima
        //Exit Sub
        var ProfundidadMaxima:Int = ProfundidadMaxima
        var PunteroBufferSpritesDE:Int=PunteroBufferSpritesDE
        var PunteroBufferTilesIX:Int=PunteroBufferTilesIX
        var NtilesY:Int //número de tiles que ocupa el sprite en y
        var NtilesX:Int //número de tiles que ocupa el sprite en x
        var PunteroBufferTilesAnterior:Int
        var PunteroBufferSpritesAnterior:Int
        var PunteroBufferSpritesAnterior2:Int
        var Contador:Int
        var Contador2:Int
        var ProcesarTileDirectamente_4DE4:Bool //true si salta a 4E11 (procesar directamente), false salta a 4DE6 (comprobaciones previas)
        var Valor:UInt8
        var ProfundidadX:UInt8
        var ProfundidadY:UInt8
        var ProfundidadMinimaX:UInt8
        var ProfundidadMinimaY:UInt8
        var ProfundidadMaximaX:UInt8
        var ProfundidadMaximaY:UInt8
        var ProcesarTile:Bool
        var Contador3:Int
        var PunteroBufferTilesAnterior3:Int
        var BugOverflow:Bool //true si el puntero a la tabla de tiles está fuera


        var H4dd9:String
        var DE:String
        var IX:String
        H4dd9 = String(format: "%02X", ProfundidadMaxima)
        DE = String(format: "%02X", PunteroBufferSpritesDE)
        IX = String(format: "%02X", PunteroBufferTilesIX)



        PunteroBufferTilesAnterior3 = PunteroBufferTilesIX
        ProfundidadMaxima = ProfundidadMaxima + 257
        ProfundidadMinimaX = LeerByteInt(Valor: ProfundidadMinima, NumeroByte: 0)
        ProfundidadMinimaY = LeerByteInt(Valor: ProfundidadMinima, NumeroByte: 1)
        ProfundidadMaximaX = LeerByteInt(Valor: ProfundidadMaxima, NumeroByte: 0)
        ProfundidadMaximaY = LeerByteInt(Valor: ProfundidadMaxima, NumeroByte: 1)
        //4DB8
        NtilesY = Int(nYsprite) >> 3 //nysprite = nysprite/8 (número de tiles que ocupa el sprite en y)
        NtilesX = Int(nXsprite) >> 2 //nxsprite = nxsprite/4 (número de tiles que ocupa el sprite en x)
        //4dc2
        for Contador3 in 1...NtilesY {
            PunteroBufferTilesAnterior = PunteroBufferTilesIX
            PunteroBufferSpritesAnterior = PunteroBufferSpritesDE
            for Contador in 1...NtilesX {
                //4DC9
                ProcesarTileDirectamente_4DE4 = false
                for Contador2 in 1...2 { //cada tile tiene 2 prioridades
                    //4DD1
                    IX = String(format: "%02X", PunteroBufferTilesIX)
                    if EsValidoPunteroBufferTiles(PunteroBufferTilesIX) {
                        BugOverflow = false
                        Valor = BufferTiles_8D80[PunteroBufferTilesIX + 2 - 0x8D80] //lee el número de tile de la entrada actual del buffer de tiles
                    } else { //corrección bug del programa original. en algunas pantallas parte de la cabeza de guillermo queda fuera
                        BugOverflow = true
                        Valor = LeerByteTablaCualquiera(PunteroBufferTilesIX + 2)
                    }
                    if Valor != 0 {
                        //4DD7
                        ProcesarTile = false
                        if !BugOverflow {
                            ProfundidadX = BufferTiles_8D80[PunteroBufferTilesIX + 0 - 0x8D80] //lee la profundidad en x del tile actual
                        } else {
                            ProfundidadX = LeerByteTablaCualquiera(PunteroBufferTilesIX + 0)
                        }
                        //si en esta llamada no se ha pintado en esta posición del buffer de tiles, comprueba si hay que pintar el
                        //tile que hay en esta capa de profundidad. Si se ha pintado y el tile de esta capa se había pintado
                        //en otra iteración anterior, lo combina sin comprobar la profundidad
                        if (ProfundidadX & 0x80) == 0 || (((ProfundidadX & 0x80)) != 0 && !ProcesarTileDirectamente_4DE4) {
                            //4de3
                            //If Not ProcesarTileDirectamente_4DE4 Then
                            //4de6
                            if !BugOverflow {
                                ProfundidadY = BufferTiles_8D80[PunteroBufferTilesIX + 1 - 0x8D80] //lee la profundidad en y del tile actual
                            } else {
                                ProfundidadY = LeerByteTablaCualquiera(PunteroBufferTilesIX + 1)
                            }
                            if (ProfundidadX >= ProfundidadMinimaX || ProfundidadY >= ProfundidadMinimaY) &&
                        (ProfundidadX < ProfundidadMaximaX && ProfundidadY < ProfundidadMaximaY) && (ProfundidadX & 0x80) == 0 {
                                ProcesarTile = true
                                //4e00
                                //aquí llega si el tile tiene mayor profundidad que el mínimo y menor profundidad que el sprite
                                ProcesarTileDirectamente_4DE4 = true //modifica un salto para indicar que en esta llamada ha pintado algún tile para esta posición del buffer de tiles
                                //4E07
                                if EsDireccionBufferTiles_37A5(PunteroBufferTilesIX) { //si ix está dentro del buffer de tiles
                                    if !BugOverflow {
                                        SetBitArray(&BufferTiles_8D80, PunteroBufferTilesIX + 0 - 0x8D80, 7) //indica que se ha procesado este tile
                                    }
                                }

                            } else {
                                ProcesarTile = false
                            }
                            //Else
                            //ProcesarTile = True
                            //End If
                        } else {
                            ProcesarTile = true
                        }
                        //4e11
                        if ProcesarTile {
                            PunteroBufferSpritesAnterior2 = PunteroBufferSpritesDE

                            DE = String(format: "%02X", PunteroBufferSpritesDE)
                            IX = String(format: "%02X", PunteroBufferTilesIX)
                            CombinarTileBufferSprites_4E49(PunteroBufferTilesIX, PunteroBufferSpritesDE, nXsprite)
                            PunteroBufferSpritesDE = PunteroBufferSpritesAnterior2
                        }
                    }
                    //4E1B
                    //avanza al siguiente tile o a la siguiente prioridad
                    if EsValidoPunteroBufferTiles(PunteroBufferTilesIX) {
                        LimpiarBit7BufferTiles_4D85(SpritesPilaProcesados, PunteroBufferTilesIX) //ret (si no ha terminado de procesar los sprites de la pila) o limpia el bit 7 de (ix+0) del buffer de tiles (si es una posición válida del buffer)
                    }
                    PunteroBufferTilesIX = PunteroBufferTilesIX + 3 //pasa al tile de mayor prioridad del buffer de tiles
                    //4e25
                } //repite hasta que se hayan completado las prioridades de la entrada del buffer de tiles
                //4e27
                PunteroBufferSpritesDE = PunteroBufferSpritesDE + 4 //pasa a la posición del siguiente tile en x del buffer de sprites
                //4e2d
            } //repite mientras no se termine en x
            //4e2f
            PunteroBufferSpritesDE = PunteroBufferSpritesAnterior
            PunteroBufferSpritesDE = PunteroBufferSpritesDE + 8 * Int(nXsprite) //pasa a la posición del siguiente tile en y del buffer de sprites (ancho del sprite*8)
            PunteroBufferTilesIX = PunteroBufferTilesAnterior //recupera la posición del buffer de tiles
            PunteroBufferTilesIX = PunteroBufferTilesIX + 0x60 //pasa a la siguiente línea del buffer de tiles
            //4e45
        } //repite hasta que se acaben los tiles en y
        PunteroBufferTilesIX = PunteroBufferTilesAnterior3
    }

    public func LimpiarBit7BufferTiles_4D85( _ SpritesPilaProcesados:Bool, _ PunteroBufferTilesIX:Int) {
        //vuelve si no ha terminado de procesar los sprites de la pila o limpia el bit 7 de (ix+0) del buffer de tiles (si es una posición válida del buffer)
        if !SpritesPilaProcesados { return }
        if EsDireccionBufferTiles_37A5(PunteroBufferTilesIX) {
            ClearBitArray(&BufferTiles_8D80, PunteroBufferTilesIX + 0 - 0x8D80, 7) //limpia el bit mas significativo del buffer de tiles
        }
    }

    public func EsDireccionBufferTiles_37A5( _ PunteroBufferTilesIX:Int) -> Bool {
        //dada una dirección, devuelve true si es una dirección válida del buffer de tiles
        if PunteroBufferTilesIX >= 0x8D80 {
            return true //8d80=inicio del buffer de tiles
        } else {
            return false
        }
    }

    public func CombinarTileBufferSprites_4E49( _ PunteroBufferTilesIX:Int, _ PunteroBufferSpritesDE:Int, _ nXsprite:UInt8) {
        //aquí entra con PunteroBufferTilesIX apuntando a alguna entrada del buffer de tiles y PunteroBufferSpritesDE apuntando
        //a alguna posición del buffer de sprites
        //combina el tile de la entrada actual de ix en la posición actual del buffer de sprites
        var PunteroBufferSpritesDE:Int=PunteroBufferSpritesDE
        var NumeroTile:UInt8
        var PunteroDatosTile:Int
        var Contador:Int
        var Contador2:Int
        var PunteroTablasAndOr:Int
        var MascaraAnd:UInt8
        var MascaraOr:UInt8
        var Valor:UInt8
        var BugOverflow:Bool=false
        if PunteroPerteneceTabla(PunteroBufferTilesIX, BufferTiles_8D80, 0x8D80) {
            NumeroTile = BufferTiles_8D80[PunteroBufferTilesIX + 2 - 0x8D80] //número de tile de la entrada actual
        } else {
            NumeroTile = LeerByteTablaCualquiera(PunteroBufferTilesIX + 2)
            BugOverflow = true
        }
        PunteroDatosTile = Int(NumeroTile) * 32 //cada tile ocupa 32 bytes
        PunteroDatosTile = PunteroDatosTile + 0x6D00 //a partir de 0x6d00 están los gráficos de los tiles que forman las pantallas
        if NumeroTile < 0xB { //si el gráfico es menor que el 0x0b (gráficos sin transparencia, caso más sencillo)
            //4e92
            //aquí llega si el número de tile era < 0x0b (son gráficos sin transparencia)
            for Contador in 1...8 { //8 pixels de alto
                for Contador2 in 1...4 { //4 bytes de ancho (16 pixels)
                    BufferSprites_9500[PunteroBufferSpritesDE - 0x9500] = TilesAbadia_6D00[PunteroDatosTile - 0x6D00]
                    PunteroBufferSpritesDE = PunteroBufferSpritesDE + 1
                    PunteroDatosTile = PunteroDatosTile + 1
                }
                //4ea7
                PunteroBufferSpritesDE = PunteroBufferSpritesDE + Int(nXsprite) - 4 //pasa a la siguiente línea del sprite
                //4eae
            }
            //4eb0
        } else {
            //4e60
            //si el gráfico es mayor o igual que 0x0b (gráficos con transparencia)
            if !BugOverflow {
                if LeerBitArray(BufferTiles_8D80, PunteroBufferTilesIX + 2 - 0x8D80, 7) == false { //comprueba que tabla usar según el número de tile que haya
                    PunteroTablasAndOr = 0x9D00 //tablas 0 y 1
                } else {
                    PunteroTablasAndOr = 0x9F00 //tablas 2 y 3
                }
            } else {
                if (NumeroTile & 0x80) == 0 { //comprueba que tabla usar según el número de tile que haya
                    PunteroTablasAndOr = 0x9D00 //tablas 0 y 1
                } else {
                    PunteroTablasAndOr = 0x9F00 //tablas 2 y 3
                }

            }
            for Contador in 1...8 { //8 pixels de alto
                for Contador2 in 1...4 { //4 bytes de ancho (16 pixels)
                    //4e75
                    Valor = TilesAbadia_6D00[PunteroDatosTile - 0x6D00] //obtiene un byte del gráfico
                    MascaraOr = TablasAndOr_9D00[PunteroTablasAndOr + Int(Valor) - 0x9D00] //obtiene el or
                    MascaraAnd = TablasAndOr_9D00[PunteroTablasAndOr + Int(Valor) + 256 - 0x9D00] //obtiene el and
                    Valor = BufferSprites_9500[PunteroBufferSpritesDE - 0x9500] //obtiene un valor del buffer de sprites
                    Valor = (Valor & MascaraAnd) | MascaraOr //aplica el valor de las máscaras
                    BufferSprites_9500[PunteroBufferSpritesDE - 0x9500] = Valor //graba el valor obtenido combinando el fondo con el sprite
                    PunteroBufferSpritesDE = PunteroBufferSpritesDE + 1 //avanza a la siguiente posición del buffer
                    PunteroDatosTile = PunteroDatosTile + 1 //avanza al siguiente byte del gráfico
                    //4e83
                }
                //4e86
                PunteroBufferSpritesDE = PunteroBufferSpritesDE + Int(nXsprite) - 4 //pasa a la siguiente línea del sprite
            } //repite hasta que se complete el alto del tile
            //4e91
        }
    }

    public func CopiarSpritePantalla_4C1A( _ PunteroSpriteIX:Int) {
        //vuelca el buffer del sprite a la pantalla
        var Xnovisible:UInt8 //distancia en x de lo que no es visible
        var Xsprite:UInt8 //posición en x del tile en el que empieza el sprite (en bytes)
        var Ysprite:UInt8 //posición en y del tile en el que empieza el sprite
        var nXsprite:UInt8 //ancho final del sprite (en bytes)
        var nYsprite:UInt8 //alto final del sprite (en pixels)
        var PunteroBufferSpritesHL:Int //dirección del buffer de sprites asignada a este sprite
        var PunteroPantallaDE:Int //posición en pantalla donde copiar los bytes
        var PunteroPantallaAnterior:Int
        var Contador:Int
        var Contador2:Int
        var ValorPantalla:UInt8
        //4C1A
        Xnovisible = 0 //distancia en x de lo que no es visible
        Ysprite = TablaSprites_2E17[PunteroSpriteIX + 0xD - 0x2E17] //posición en y del tile en el que empieza el sprite
        nYsprite = TablaSprites_2E17[PunteroSpriteIX + 0xF - 0x2E17] //alto final del sprite (en pixels)
        PunteroPantallaDE = 0
        if Ysprite >= 200 { return } //si la coordenada y >= 200 (no es visible en pantalla), sale
        //4C2D
        if Ysprite <= 40 { //si la coordenada y <= 40 (no visible o visible en parte en pantalla)
            if (40 - Ysprite) >= nYsprite { //si la distancia desde el punto en que comienza el sprite al primer punto visible >= la altura del sprite, sale (no visible)
                return
            }
            //4C36
            nXsprite = TablaSprites_2E17[PunteroSpriteIX + 0xE - 0x2E17]
            PunteroPantallaDE = (40 - Int(Ysprite)) * Int(nXsprite) //avanza las líneas del sprite no visible
            nYsprite = nYsprite - (40 - Ysprite) //modifica el alto del sprite por el recorte
            Ysprite = 0 //el sprite empieza en y = 0
        } else {
            Ysprite = Ysprite - 40 //ajusta la coordenada y
        }
        //4C45
        //dirección del buffer de sprites asignada a este sprit
        PunteroBufferSpritesHL = Bytes2Int(Byte0: TablaSprites_2E17[PunteroSpriteIX + 0x10 - 0x2E17], Byte1: TablaSprites_2E17[PunteroSpriteIX + 0x11 - 0x2E17])
        PunteroBufferSpritesHL = PunteroBufferSpritesHL + PunteroPantallaDE //salta los bytes no visibles en y
        //4C4E
        Xsprite = TablaSprites_2E17[PunteroSpriteIX + 0xC - 0x2E17] //posición en x del tile en el que empieza el sprite (en bytes)
        nXsprite = TablaSprites_2E17[PunteroSpriteIX + 0xE - 0x2E17] //ancho final del sprite (en bytes)
        if Xsprite >= 72 { return } //sale si la posición en x >= (32 + 256 pixels)
        //4C58
        if Xsprite < 8 { //si la coordenada x <= 32 (no visible o visible en parte en pantalla)
            //4C5D
            if (8 - Xsprite) >= nXsprite { //si la distancia desde el punto en que comienza el sprite al primer punto visible >= la anchura del sprite, sale (no visible)
                return
            }
            //4C63
            PunteroBufferSpritesHL = PunteroBufferSpritesHL + 8 - Int(Xsprite) //avanza los pixels recortados
            Xnovisible = 8 - Xsprite
            nXsprite = nXsprite - (8 - Xsprite) //modifica el ancho a pintar
            Xsprite = 0 //el sprite empieza en x = 0
        } else {
            Xsprite = Xsprite - 8
        }
        //4c72
        if (Xsprite + nXsprite) >= 64 {  //comprueba si el sprite es más ancho que la pantalla (64*4 = 256)
            Xnovisible = nXsprite + Xsprite - 64
            nXsprite = nXsprite - Xnovisible //pone un nuevo ancho para el sprite
        }
        //4C7F
        if (Ysprite + nYsprite) >= 160 { //comprueba si el sprite es más alto que la pantalla (160)
            //4C8A
            nYsprite = nYsprite - (Ysprite + nYsprite - 160) //actualiza el alto a pintar
        }
        //4C8E
        PunteroPantallaDE = ObtenerDesplazamientoPantalla_3C42(Xsprite, Ysprite) //dadas coordenadas X,Y, calcula el desplazamiento correspondiente en pantalla
        //4C95
        for Contador in stride(from: nYsprite, through: 1, by: -1)  {
            //4C9A
            PunteroPantallaAnterior = PunteroPantallaDE
            for Contador2 in stride(from: nXsprite, through: 1, by: -1)  {
                ValorPantalla = BufferSprites_9500[PunteroBufferSpritesHL - 0x9500]
                PantallaCGA[PunteroPantallaDE - 0xC000] = ValorPantalla
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaDE - 0xC000, Color: ValorPantalla)
                PunteroBufferSpritesHL = PunteroBufferSpritesHL + 1
                PunteroPantallaDE = PunteroPantallaDE + 1
            }
            PunteroBufferSpritesHL = PunteroBufferSpritesHL + Int(Xnovisible)
            PunteroPantallaDE = PunteroPantallaAnterior
            //4CA7
            //pasa a la siguiente línea de pantalla
            PunteroPantallaDE = PunteroPantallaDE + 0x800 //pasa al siguiente banco
            if (PunteroPantallaDE & 0x3800) == 0 { //banco inexistente
                PunteroPantallaDE = PunteroPantallaDE - 0x800 //vuelve al banco anterior
                PunteroPantallaDE = PunteroPantallaDE & 0xC7FF
                PunteroPantallaDE = PunteroPantallaDE + 0x50 //cada línea ocupa 0x50 bytes
            }
            //4CBC
        }
    }

    public func ObtenerDesplazamientoPantalla_3C42(X:UInt8, Y:UInt8) -> Int {
        //; dados X,Y, calcula el desplazamiento correspondiente en pantalla
        //al valor calculado se le suma 32 pixels a la derecha (puesto que el área de juego va desde x = 32 a x = 256 + 32 - 1
        //l = coordenada X (en bytes)
        var PunteroPantalla:Int
        var ValorLong:Int
        PunteroPantalla = Int(Y & 0xF8) //obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
        //dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
        //o lo que es lo mismo, (y >> 3)*0x50
        PunteroPantalla = 10 * PunteroPantalla //PunteroPantalla = desplazamiento dentro del banco
        ValorLong = Int(Y & 0x7) //3 bits menos significativos en y (para calcular al banco de VRAM al que va)
        ValorLong = ValorLong << 11 //ajusta los 3 bits
        PunteroPantalla = PunteroPantalla | ValorLong //completa el cálculo del banco
        PunteroPantalla = PunteroPantalla | 0xC000
        PunteroPantalla = PunteroPantalla + Int(X) //suma el desplazamiento en x
        PunteroPantalla = PunteroPantalla + 8 //ajusta para que salga 32 pixels más a la derecha
        return PunteroPantalla
    }

    public func ActualizarDatosPersonaje_291D( _ PunteroPersonajeHL:Int) {
        //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        //PunteroPersonajeHL apunta a la tabla del personaje a mover
        //0x2BAE //guillermo
        //0x2BB8 //adso
        //0x2BC2 //malaquías
        //0x2BCC //abad
        //0x2BD6 //berengario
        //0x2BE0 //severino
        var PunteroSpriteIX:Int
        var PunteroCaracteristicasPersonajeIY:Int
        var PunteroRutinaComportamientoHL:Int
        var PunteroRutinaFlipearGraficos:Int
        var Valor:UInt8
        PunteroSpriteIX = Leer16(TablaPunterosPersonajes_2BAE, PunteroPersonajeHL + 0 - 0x2BAE)
        PunteroCaracteristicasPersonajeIY = Leer16(TablaPunterosPersonajes_2BAE, PunteroPersonajeHL + 2 - 0x2BAE)
        PunteroRutinaComportamientoHL = Leer16(TablaPunterosPersonajes_2BAE, PunteroPersonajeHL + 4 - 0x2BAE)
        PunteroRutinaFlipearGraficos = Leer16(TablaPunterosPersonajes_2BAE, PunteroPersonajeHL + 6 - 0x2BAE)
        PunteroRutinaFlipPersonaje_2A59 = PunteroRutinaFlipearGraficos
        PunteroTablaAnimacionesPersonaje_2A84 = Leer16(TablaPunterosPersonajes_2BAE, PunteroPersonajeHL + 8 - 0x2BAE)
        DefinirDatosSpriteComoAntiguos_2AB0(PunteroSpriteIX) //pone la posición y dimensiones actuales del sprite como posición y dimensiones antiguas
        //si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupaba el sprite en el buffer de alturas
        //292f
        RellenarBufferAlturasPersonaje_28EF(PunteroCaracteristicasPersonajeIY, 0)
        //2932
        if MalaquiasAscendiendo_4384 {
            MalaquiasAscendiendo_4384 = false
            //2945
            AvanzarAnimacionSprite_2A27(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
        } else {
            //2948
            //lee el contador de la animación
            Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 0 - 0x3036]
            if (Valor & 1) != 0 {
                //294d
                IncrementarContadorAnimacionSprite_2A01(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
            } else {
                //2950
                switch PunteroRutinaComportamientoHL {
                    case 0x288D: //guillermo
                        EjecutarComportamientoGuillermo_288D(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
                    case 0x2C3A: //resto
                        EjecutarComportamientoPersonaje_2C3A(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
                    default:
                        break
                }
            }
        }
        //2940
        //lee el valor a poner en el buffer de alturas para indicar que está el personaje
        Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 0xE - 0x3036]
        //2943
        //si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
        RellenarBufferAlturasPersonaje_28EF(PunteroCaracteristicasPersonajeIY, Valor)
    }

    public func AvanzarAnimacionSprite_2A27( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int) {
        //avanza la animación del sprite y lo redibuja
        var PunteroTablaAnimacionesHL:Int
        var Yp:UInt8=0 //posición y en pantalla del sprite
        //cambia la animación de los trajes de los monjes según la posición y el contador de animaciones y
        //obtiene la dirección de los datos de la animación que hay que poner en hl
        PunteroTablaAnimacionesHL = CambiarAnimacionTrajesMonjes_2A61(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
        MovimientoRealizado_2DC1 = true //indica que ha habido movimiento
        if EsSpriteVisible_2AC9(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, &Yp) == true {
            //aquí se llega desde fuera si un sprite es visible, después de haber actualizado su posición.
            //en PunteroTablaAnimacionesHL se apunta a la animación correspondiente para el sprite
            //PunteroSpriteIX = dirección del sprite correspondiente
            //PunteroCaracteristicasPersonajeIY = datos de posición del personaje correspondiente
            //2a34
            ActualizarDatosGraficosPersonaje_2A34(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, PunteroTablaAnimacionesHL, Yp)
        }
    }

    public func EsSpriteVisible_2AC9( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int, _ Yp: inout UInt8) -> Bool {
        var Visible:Bool
        var X:UInt8=0
        var Y:UInt8=0
        var Z:UInt8=0
        //comprueba si es visible y si lo es, actualiza su posición si fuese necesario.
        //Si es visible no vuelve, sino que sale a la rutina que lo llamó
        Visible = ProcesarObjeto_2ADD(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, &X, &Y, &Z, &Yp)
        if Visible {
            return true
        }
        MarcarSpriteInactivo_2ACE(PunteroSpriteIX)
        return false
    }

    public func MarcarSpriteInactivo_2ACE( _ PunteroSpriteIX:Int) {
        //aquí llega si el sprite no es visible
        if TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] == 0xFE { //si el sprite no era visible, sale
            return
        } else {
            TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = 0x80 //en otro caso, indica que hay que redibujar el sprite
            SetBitArray(&TablaSprites_2E17, PunteroSpriteIX + 5 - 0x2E17, 7)  //indica que el sprite va a pasar a inactivo, y solo se quiere redibujar la zona que ocupaba
        }
    }

    public func IncrementarContadorAnimacionSprite_2A01( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int) {
        //incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
        var Valor:UInt8
        //lee el contador de la animación
        Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 0 - 0x3036]
        Valor = Valor + 1
        Valor = Valor & 3
        //2a07
        TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 0 - 0x3036] = Valor
        //2A0A
        AvanzarAnimacionSprite_2A27(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
    }

    public func EjecutarComportamientoGuillermo_288D( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int) {
        //rutina del comportamiento de guillermo
        //PunteroSpriteIX que apunta al sprite de guillermo
        //PunteroCaracteristicasPersonajeIY apunta a los datos de posición de guillermo
        var Valor:UInt8
        var RetornoA:Int=0
        var RetornoC:Int=0
        var RetornoHL:Int=0
        if EstadoGuillermo_288F != 0 {
            //2893
            if EstadoGuillermo_288F == 1 { return } //si EstadoGuillermo_288F era 1, sale
            EstadoGuillermo_288F = EstadoGuillermo_288F - 1
            if EstadoGuillermo_288F == 0x13 {
                //289C
                //aquí llega si el estado de guillermo es 0x13
                if AjustePosicionYSpriteGuillermo_28B1 == 2 {
                    //28a3
                    //decrementa la posición en x de guillermo
                    Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036]
                    Valor = Valor - 1
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036] = Valor
                    //avanza la animación del sprite y lo redibuja
                    AvanzarAnimacionSprite_2A27(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
                    return
                }
            }
            //28a9
            //si se modifica la y del sprite con 1, salta y marca el sprite como inactivo
            if EstadoGuillermo_288F != 1 {
                //28ad
                //modifica la posición y del sprite
                Valor = TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17]
                Valor = Z80Add(Valor, AjustePosicionYSpriteGuillermo_28B1)
                TablaSprites_2E17[PunteroSpriteIX + 2 - 0x2E17] = Valor
                Valor = TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17]
                Valor = Valor & 0x3F
                Valor = Valor | 0x80
                TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = Valor //marca el sprite para dibujar
                MovimientoRealizado_2DC1 = true //indica que ha habido movimiento
            } else {
                //28c5
                //aquí llega si se modifica la y del sprite con 1 y el estado de guillermo es el 0x13
                TablaSprites_2E17[PunteroSpriteIX + 0 - 0x2E17] = 0xFE //marca el sprite como inactivo
            }
        } else {
            //28ca
            //aquí llega si el estado de guillermo es 0, que es el estado normal
            if TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] != 0 { return } //si la cámara no sigue a guillermo, sale
            //28CF
            if teclado!.TeclaPulsadaFlanco(EnumAreaTecla.TeclaIzquierda) {
                //2a0c
                ActualizarDatosPersonajeCursorIzquierdaDerecha_2A0C(true, PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
            }
            //28d9
            if teclado!.TeclaPulsadaFlanco(EnumAreaTecla.TeclaDerecha) { //comprueba si ha cambiado el estado de cursor derecha
                //2a0c
                ActualizarDatosPersonajeCursorIzquierdaDerecha_2A0C(false, PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
            } else {
                //28e3
                if teclado!.TeclaPulsadaNivel(EnumAreaTecla.TeclaArriba) == false { return }//si no se ha pulsado el cursor arriba, sale
                //28E9
                ObtenerAlturaDestinoPersonaje_27B8(0, 0xFF, PunteroCaracteristicasPersonajeIY, &RetornoA, &RetornoC, &RetornoHL)
                //28EC
                AvanzarPersonaje_2954(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, RetornoA, RetornoC, RetornoHL)
            }
        }
    }

    public func ActualizarDatosPersonajeCursorIzquierdaDerecha_2A0C( _ IzquierdaC:Bool, _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int) {
        //aquí llega si se ha pulsado cursor derecha o izquierda
        var Valor:UInt8
        TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 0 - 0x3036] = 0 //resetea el contador de la animación
        //2A10
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 7) != false {
            //2a16
            //si el personaje ocupa 4 casillas en el buffer de alturas
            Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 5 - 0x3036]
            Valor = Valor ^ 0x20
            TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 5 - 0x3036] = Valor
        }
        //2a1e
        Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 1 - 0x3036] //lee la orientación
        //cambia la orientación del personaje
        if IzquierdaC {
            Valor = UInt8((Int(Valor) + 1) & 0x3)
        } else {
            Valor = UInt8((Int(Valor) + 255) & 0x3)
        }
        //2A24
        TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 1 - 0x3036] = Valor
        //2A27
        AvanzarAnimacionSprite_2A27(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
    }

    public func ObtenerAlturaDestinoPersonaje_27B8( _ DiferenciaAlturaA:UInt8, _ AlturaC:UInt8, _ PunteroCaracteristicasPersonajeIY:Int, _ Salida1A: inout Int, _ Salida2C: inout Int, _ Salida3HL: inout Int) {
        //comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en Salida1A y Salida2C
        //en Salida3HL devuelve el puntero en la tabla TablaAvancePersonaje con los incrementos necesarios en x e y para avanzar el personaje
        //si el personaje no está en la pantalla actual, se devuelve lo mismo que se pasó en DiferenciaAlturaA (se supone que ya se ha calculado la diferencia de altura fuera)
        //DiferenciaAlturaA se usará si el personaje no está en la pantalla actual
        //en PunteroCaracteristicasPersonajeIY se pasan las características del personaje que se mueve hacia delante
        //llamado al pulsar cursor arriba
        var AlturaPersonaje:UInt8
        var AlturaBasePlanta:UInt8
        var AlturaRelativa:UInt8 //altura relativa dentro de la planta
        //27b9
        AlturaPersonaje = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] //obtiene la altura del personaje
        //27bc
        AlturaBasePlanta = LeerAlturaBasePlanta_2473(AlturaPersonaje)
        if AlturaBasePlanta != AlturaBasePlantaActual_2DBA { //si no coincide la planta en la que está el personaje con la que se está mostrando, sale
            Salida1A = Int(DiferenciaAlturaA)
            Salida2C = Int(AlturaC)
            return
        }
        //27c6
        AlturaRelativa = AlturaPersonaje - AlturaBasePlanta
        //27CB
        ObtenerAlturaDestinoPersonaje_27CB(AlturaRelativa, DiferenciaAlturaA, AlturaC, PunteroCaracteristicasPersonajeIY, &Salida1A, &Salida2C, &Salida3HL)
    }

    public func ObtenerAlturaDestinoPersonaje_27CB( _ DiferenciaAlturaA:UInt8, _ DiferenciaAlturaB:UInt8, _ AlturaC:UInt8, _ PunteroCaracteristicasPersonajeIY:Int, _ Salida1A: inout Int, _ Salida2C: inout Int, _ Salida3HL: inout Int) {
        //comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
        //si el personaje no está visible, se devuelve lo mismo que se pasó en a
        //en iy se pasan las características del personaje que se mueve hacia delante
        //aquí llega con DiferenciaAlturaA = altura relativa dentro de la planta
        var PosicionX:UInt8 //posición global del personaje
        var PosicionY:UInt8 //posición global del personaje
        var PunteroBufferAlturas:Int
        var PunteroBufferAlturasAnterior:Int
        var PunteroTablaAvancePersonaje:Int //puntero a la tabla de incrementos
        var IncrementoBucleInterior:Int
        var IncrementoBucleExterior:Int
        var IncrementoInicial:Int
        var ContadorExterior:Int
        var ContadorInterior:Int

        var PunteroBufferAuxiliar:Int
        var ValorBufferAlturas:UInt8
        var BufferAuxiliar:Bool=false //true: se usa el buffer secundario de 96F4

        if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
        //obtiene la posición global del personaje
        PosicionY = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 3 - 0x3036]
        PosicionX = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036]
        if !DeterminarPosicionCentral_279B(&PosicionX, &PosicionY) { //PosicionX,PosicionY = posición ajustada a las 20x20 posiciones centrales
            //27d8
            Salida1A = Int(DiferenciaAlturaB)
            Salida2C = Int(AlturaC)
            return
        }
        //aquí llega si la posición es visible
        //27db
        PunteroBufferAlturas = 24 * Int(PosicionY) + Int(PosicionX)
        //27EC
        PunteroBufferAlturas = PunteroBufferAlturas + PunteroBufferAlturas_2D8A //indexa en el buffer de alturas
        //27EE
        PunteroTablaAvancePersonaje = ObtenerPunteroPosicionVecinaPersonaje_2783(PunteroCaracteristicasPersonajeIY)
        //27F1
        IncrementoBucleInterior = LeerDatoTablaAvancePersonaje(PunteroTablaAvancePersonaje, 16)
        IncrementoBucleExterior = LeerDatoTablaAvancePersonaje(PunteroTablaAvancePersonaje + 2, 16)
        IncrementoInicial = LeerDatoTablaAvancePersonaje(PunteroTablaAvancePersonaje + 4, 16)
        Salida3HL = PunteroTablaAvancePersonaje + 6
        //280A
        PunteroBufferAlturas = PunteroBufferAlturas + IncrementoInicial //suma a la posición actual en el buffer de alturas el desplazamiento leido
        //280B
        PunteroBufferAuxiliar = 0x2DC5 //apunta a un buffer auxiliar
        //280E
        for ContadorExterior in 1...4 { //el bucle exterior realiza 4 iteraciones
            //2811
            PunteroBufferAlturasAnterior = PunteroBufferAlturas
            //2812
            for ContadorInterior in 1...4 { //el bucle interior realiza 4 iteraciones
                //2815
                if !BufferAuxiliar {
                    ValorBufferAlturas = TablaBufferAlturas_01C0[PunteroBufferAlturas - 0x1C0]
                } else {
                    ValorBufferAlturas = TablaBufferAlturas_96F4[PunteroBufferAlturas - 0x96F4]
                }
                if ValorBufferAlturas < 0x10 { //comprueba si en esa posición hay algun personaje
                    // 281E
                    BufferAuxiliar_2DC5[PunteroBufferAuxiliar - 0x2DC5] = Int(ValorBufferAlturas) - Int(DiferenciaAlturaA)
                } else {
                    //281A
                    BufferAuxiliar_2DC5[PunteroBufferAuxiliar - 0x2DC5] = Int(ValorBufferAlturas) & 0x30
                }
                //2821
                PunteroBufferAuxiliar = PunteroBufferAuxiliar + 1
                //2822
                PunteroBufferAlturas = PunteroBufferAlturas + IncrementoBucleInterior
            }
            //282C
            PunteroBufferAlturas = PunteroBufferAlturasAnterior + IncrementoBucleExterior
        }
        //2833
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 7) {  //si el personaje sólo ocupa 1 posición
            //2839
            //guarda en a y en c el contenido de las 2 posiciones hacia las que avanza el personaje
            Salida2C = BufferAuxiliar_2DC5[0x2DC6 - 0x2DC5]
            Salida1A = BufferAuxiliar_2DC5[0x2DCA - 0x2DC5]
        } else { //si el personaje ocupa 4 posiciones en el buffer de alturas
            //2841
            //si en las 2 posiciones en las que se avanza no hay lo mismo, sale con valores iguales para a y c
            Salida2C = BufferAuxiliar_2DC5[0x2DC6 - 0x2DC5]
            Salida1A = BufferAuxiliar_2DC5[0x2DC7 - 0x2DC5]
            if Salida1A != Salida2C {
                Salida1A = 2 //indica que hay una diferencia entre las alturas > 1
            }
        }
    }

    public func ObtenerPunteroPosicionVecinaPersonaje_2783( _ PunteroCaracteristicasPersonajeIY:Int) -> Int {
        //devuelve la dirección de la tabla para calcular la altura de las posiciones vecinas
        //según el tamaño de la posición del personaje y la orientación
        //iy=3072,a=0->284d
        var ObtenerPunteroPosicionVecinaPersonaje_2783:Int
        var OrientacionA:Int
        //obtiene la orientación del personaje
        //278f
        OrientacionA = Int(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 1 - 0x3036])
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 7) {
            //2792
            ObtenerPunteroPosicionVecinaPersonaje_2783 = 0x286D + 8 * OrientacionA
        } else { //si el bit 7 no está puesto (si el personaje ocupa 4 tiles)
            //apunta a la tabla si el personaje ocupa 4 tiles
            //2792
            ObtenerPunteroPosicionVecinaPersonaje_2783 = 0x284D + 8 * OrientacionA
        }
        return ObtenerPunteroPosicionVecinaPersonaje_2783
    }

    private func LeerDatoTablaAvancePersonaje( _ PunteroPosicionVecinaPersonajeHL:Int, _ NBits:Int) -> Int {
        //busca en la tabla 284D ó 286D, dependiendo del valor de HL, un valor con signo de 8 ó 16 bits

        //; tabla para el cálculo del avance de los personajes según la orientación (para personajes que ocupan 4 tiles)
        //; bytes 0-1: desplazamiento en el bucle interior del buffer de tiles
        //; bytes 2-3: desplazamiento en el bucle exterior del buffer de tiles
        //; bytes 4-5: desplazamiento inicial en el buffer de alturas para el bucle
        //: byte 6: valor a sumar a la posición x del personaje si avanza en este sentido
        //: byte 7: valor a sumar a la posición y del personaje si avanza en este sentido
        //284D:   0018 FFFF FFD1 01 00 -> +24 -1  -47 [+1 00]
        //        0001 0018 FFCE 00 FF -> +1  +24 -50 [00 -1]
        //        FFE8 0001 0016 FF 00 -> -24 +1  +22 [-1 00]
        //        FFFF FFE8 0019 00 01 -> -1  -24 +25 [00 +1]

        //; tabla para el cálculo del avance de los personajes según la orientación (para personajes que ocupan 1 tile)
        //286D:   0018 FFFF FFEA 01 00 -> +24  -1 -22 [+1 00]
        //        0001 0018 FFCF 00 FF -> +1  +24 -49 [00 -1]
        //        FFE8 0001 0016 FF 00 -> -24  +1 +22 [-1 00]
        //        FFFF FFE8 0031 00 01 -> -1  -24 +49 [00 +1]
        var LeerDatoTablaAvancePersonaje:Int
        LeerDatoTablaAvancePersonaje = 0
        if PunteroPosicionVecinaPersonajeHL < 0x286D { //personaje ocupa 4 tiles
            if NBits == 8 {
                LeerDatoTablaAvancePersonaje = Leer8Signo(TablaAvancePersonaje4Tiles_284D, PunteroPosicionVecinaPersonajeHL - 0x284D)
            } else if NBits == 16 {
                LeerDatoTablaAvancePersonaje = Leer16Signo(TablaAvancePersonaje4Tiles_284D, PunteroPosicionVecinaPersonajeHL - 0x284D)
            } else {
                ErrorExtraño()
            }
        } else { //personaje ocupa 1 tile
            if NBits == 8 {
                LeerDatoTablaAvancePersonaje = Leer8Signo(TablaAvancePersonaje1Tile_286D, PunteroPosicionVecinaPersonajeHL - 0x286D)
            } else if NBits == 16 {
                LeerDatoTablaAvancePersonaje = Leer16Signo(TablaAvancePersonaje1Tile_286D, PunteroPosicionVecinaPersonajeHL - 0x286D)
            } else {
                ErrorExtraño()
            }
        }
        return LeerDatoTablaAvancePersonaje
    }

    public func AvanzarPersonaje_2954( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int, _ Altura1A:Int, _ Altura2C:Int, _ PunteroTablaAvancePersonajeHL:Int) {
        //; rutina llamada para ver si el personaje avanza
        //; en a y en c se pasa la diferencia de alturas a la posición a la que quiere avanzar
        // en HL se pasa el puntero a la tabla de avence de personaje para actualizar la posición del personaje
        var AlturaPersonajeE:UInt8
        var TamañoOcupadoA:UInt8=0 //tamaño ocupado por el personaje en el buffer de alturas
        ClearBitArray(&TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 4)  //pone a 0 el bit que indica si el personaje está bajando o subiendo
        //295C
        AlturaPersonajeE = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] //altura del personaje
        //295F
        if !LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 7) { // si el personaje ocupa 4 posiciones
            //29b7
            //aquí salta si el personaje ocupa 4 posiciones. Llega con:
            //Altura1A = diferencia de altura con la posicion 1 más cercana al personaje según la orientación
            //Altura2C = diferencia de altura con la posicion 2 más cercana al personaje según la orientación
            if Altura1A == 1 || Altura1A == -1 {
                if Altura1A == 1 { //si se va hacia arriba
                    //29c3
                    //aquí llega si se sube
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] = Z80Inc(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036]) //incrementa la altura del personaje
                    TamañoOcupadoA = 0x80 //cambia el tamaño ocupado en el buffer de alturas de 4 a 1
                } else if Altura1A == -1 { //si se va hacia abajo
                    //29ca
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] = Z80Dec(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036]) //decrementa la altura del personaje)
                    TamañoOcupadoA = 0x90 //cambia el tamaño ocupado en el buffer de alturas de 4 a 1 e indica que está bajando
                }
                //29cf
                TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 5 - 0x3036] = TamañoOcupadoA
                //29d3
                //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                AvanzarPersonaje_29E4(PunteroCaracteristicasPersonajeIY, PunteroTablaAvancePersonajeHL)
                if ObtenerOrientacion_29AE(PunteroCaracteristicasPersonajeIY) != 0 { //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                    //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    AvanzarPersonaje_29E4(PunteroCaracteristicasPersonajeIY, PunteroTablaAvancePersonajeHL)
                }
                //29dd
                MovimientoRealizado_2DC1 = true //indica que ha habido movimiento
                //29E2
                //incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
                IncrementarContadorAnimacionSprite_2A01(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
                return
                //29bf
            } else if Altura1A != 0 { //en otro caso, sale si quiere subir o bajar más de una unidad
                //29c0
                return
            } else {
                //29C1
                //si no cambia de altura, actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
                AvanzarPersonaje_29F4(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, Altura1A, Altura2C, PunteroTablaAvancePersonajeHL)
            }
            return
        } else {
            //2961
            // aquí llega si el personaje ocupa una sola posición
            //  Altura1A = diferencia de altura con la posición más cercana al personaje según la orientación
            //  Altura2C = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
            if Altura2C == 0x10 { return } //si en la posición del personaje + 2 (según la orientación que tenga) hay un personaje, sale
            if Altura2C == 0x20 { return } //si se quiere avanzar a una posición donde hay un personaje, sale
            //2969
            if !LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 5) { //si el personaje no está girado en el sentido de subir o bajar en el desnivel
                //297D
                // aquí salta si el bit 5 es 0. Llega con:
                //  Altura1A = diferencia de altura con la posición más cercana al personaje según la orientación
                //  Altura2C = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
                TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] = Z80Inc(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036]) //incrementa la altura del personaje
                if Altura1A != 1 { //si no se está subiendo una unidad
                    //2984
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] = Z80Dec(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036]) //deshace el incremento
                    if Altura1A != -1 { return } //si no se está bajando una unidad, sale
                    //298a
                    SetBitArray(&TablaCaracteristicasPersonajes_3036, PunteroCaracteristicasPersonajeIY + 5 - 0x3036, 4) //indica que está bajando
                    //298e
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036] = Z80Dec(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 4 - 0x3036]) //decrementa la altura del personaje
                }
                //2991
                if Altura1A != Altura2C { //compara la altura de la posición más cercana al personaje con la siguiente
                    //2992
                    //si las alturas no son iguales, avanza la posición
                    AvanzarPersonaje_29F4(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, Altura1A, Altura2C, PunteroTablaAvancePersonajeHL)
                } else {
                    //2994
                    //aquí llega si avanza y las 2 posiciones siguientes tienen la misma altura
                    //tan solo deja activo el bit 4, por lo que el personaje pasa de ocupar una posición en el buffer de alturas a ocupar 4
                    TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 5 - 0x3036] = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 5 - 0x3036] & 0x10
                    //299C
                    //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    AvanzarPersonaje_29E4(PunteroCaracteristicasPersonajeIY, PunteroTablaAvancePersonajeHL)
                    if ObtenerOrientacion_29AE(PunteroCaracteristicasPersonajeIY) == 0 { //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                        //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                        AvanzarPersonaje_29E4(PunteroCaracteristicasPersonajeIY, PunteroTablaAvancePersonajeHL)
                    }
                    MovimientoRealizado_2DC1 = true //indica que ha habido movimiento
                    //incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
                    IncrementarContadorAnimacionSprite_2A01(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
                }
            } else {
                //2970
                var Orientacion:Int
                var Valor:Int
                Orientacion = Int(ObtenerOrientacion_29AE(PunteroCaracteristicasPersonajeIY)) //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                //2974
                //cuando va hacia la derecha o hacia abajo, al convertir la posición en 4, solo hay 1 de diferencia
                //en cambio, si se va a los otros sentidos al convertir la posición a 4 hay 2 de dif
                Valor = Altura1A
                //2975
                if Orientacion != 0 {
                    //2977
                    Valor = Altura2C
                }
                //2978
                if Valor != 0 { return } //si no está a ras de suelo, sale?
                //297a
                //aunque en realidad se llama a 29FE, la primera parte no hace nada, así que es lo mismo llamar a 29F4
                AvanzarPersonaje_29F4(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY, Altura1A, Altura2C, PunteroTablaAvancePersonajeHL)
            }
        }
    }

    public func AvanzarPersonaje_29F4( _ PunteroSpriteIX:Int, _ PunteroCaracteristicasPersonajeIY:Int, _ Altura1A:Int, _ Altura2C:Int, _ PunteroTablaAvancePersonajeHL:Int) {
        //; actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
        //; aquí salta si las alturas de las 2 posiciones no son iguales. Llega con:
        //;  Altura1A = diferencia de altura con la posición más cercana al personaje según la orientación
        //;  Altura2C = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
        //   PunteroTablaAvancePersonajeHL=puntero a la tabla de avance del personaje
        var DiferenciaAlturaA:Int
        DiferenciaAlturaA = Altura1A - Altura2C + 1
        //29F8
        AvanzarPersonaje_29E4(PunteroCaracteristicasPersonajeIY, PunteroTablaAvancePersonajeHL)
        //modFunciones.GuardarArchivo "Perso0", TablaCaracteristicasPersonajes_3036
        //2a01
        IncrementarContadorAnimacionSprite_2A01(PunteroSpriteIX, PunteroCaracteristicasPersonajeIY)
    }

    public func AvanzarPersonaje_29E4( _ PunteroCaracteristicasPersonajeIY:Int, _ PunteroTablaAvancePersonajeHL:Int) {
        //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
        var AvanceX:Int
        var AvanceY:Int
        AvanceX = LeerDatoTablaAvancePersonaje(PunteroTablaAvancePersonajeHL, 8)
        //29e5
        if AvanceX > 0 {
            TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036] = Z80Add(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036], UInt8(AvanceX))
        } else {
            TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036] = Z80Sub(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 2 - 0x3036], UInt8(-AvanceX))
        }
        //29eb
        AvanceY = LeerDatoTablaAvancePersonaje(PunteroTablaAvancePersonajeHL + 1, 8)
        //29EC
        if AvanceY > 0 {
            TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 3 - 0x3036] = Z80Add(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 3 - 0x3036], UInt8(AvanceY))
        } else {
            TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 3 - 0x3036] = Z80Sub(TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 3 - 0x3036], UInt8(-AvanceY))
        }

    }

    public func ObtenerOrientacion_29AE( _ PunteroCaracteristicasPersonajeIY:Int) -> UInt8 {
        //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
        var ObtenerOrientacion_29AE:UInt8
        var Valor:UInt8
        Valor = TablaCaracteristicasPersonajes_3036[PunteroCaracteristicasPersonajeIY + 1 - 0x3036] //lee la orientación del personaje
        //29b1
        Valor = Valor & 0x3
        if Valor == 0 {
            ObtenerOrientacion_29AE = 0
        } else {
            //29B4
            ObtenerOrientacion_29AE = Valor ^ 0x3
        }
        return ObtenerOrientacion_29AE
    }

    public func ModificarCaracteristicasSpriteLuz_26A3() {
        //modifica las características del sprite de la luz si puede ser usada por adso
        var PosicionX:Int //posición x del sprite de la luz
        var PosicionY:Int //posición y del sprite de la luz
        TablaSprites_2E17[0x2FCF - 0x2E17] = 0xFE //desactiva el sprite de la luz
        if !HabitacionOscura_156C { return } //si la habitación está iluminada, sale
        //26ad
        //aqui llega si es una habitación oscura
        if !depuracion.LuzEnGuillermo {
            if TablaSprites_2E17[0x2E2B - 0x2E17] == 0xFE { DibujarSprites_267B() } //si el sprite de adso no es visible, evita que se redibujen los sprites y sale //###depuracion
        } else {
            if TablaSprites_2E17[0x2E17 - 0x2E17] == 0xFE { DibujarSprites_267B() } //si el sprite de guillermo no es visible, evita que se redibujen los sprites y sale //###depuracion
        }
        //26B4
        if !depuracion.LuzEnGuillermo {
            PosicionX = Int(TablaSprites_2E17[0x2E2C - 0x2E17]) //posición x del sprite de adso //###depuración
        } else {
            PosicionX = Int(TablaSprites_2E17[0x2E17 + 1 - 0x2E17]) //posición x del sprite de guillermo //###depuración
        }
        SpriteLuzAdsoX_4B89 = UInt8(PosicionX & 0x3) //posición x del sprite de adso dentro del tile
        //26BD
        SpriteLuzAdsoX_4BB5 = 4 - SpriteLuzAdsoX_4B89 //4 - (posición x del sprite de adso & 0x03)
        //26C4
        TablaSprites_2E17[0x2FCF + 0x12 - 0x2E17] = 0xFE //le da la máxima profundidad al sprite
        TablaSprites_2E17[0x2FCF + 0x13 - 0x2E17] = 0xFE //le da la máxima profundidad al sprite
        //26d1
        PosicionX = (PosicionX & 0xFC) - 8
        if PosicionX < 0 { PosicionX = 0 }
        TablaSprites_2E17[0x2FCF + 1 - 0x2E17] = Int2ByteSigno(PosicionX) //fija la posición x del sprite
        TablaSprites_2E17[0x2FCF + 3 - 0x2E17] = Int2ByteSigno(PosicionX) //fija la posición anterior x del sprite
        //26de
        if !depuracion.LuzEnGuillermo {
            PosicionY = Int(TablaSprites_2E17[0x2E2D - 0x2E17]) //obtiene la posición y del sprite de adso //###depuración
        } else {
            PosicionY = Int(TablaSprites_2E17[0x2E17 + 2 - 0x2E17]) //obtiene la posición y del sprite de guillermo //###depuración
        }
        if (PosicionY & 0x7) >= 4 { //si el desplazamiento dentro del tile en y >=4...
            SpriteLuzTipoRelleno_4B6B = 0xEF //bytes a rellenar (tile y medio)
            SpriteLuzTipoRelleno_4BD1 = 0x9F //bytes a rellenar (tile)
        } else { //si es <4, intercambia los rellenos
            SpriteLuzTipoRelleno_4B6B = 0x9F //bytes a rellenar (tile)
            SpriteLuzTipoRelleno_4BD1 = 0xEF //bytes a rellenar (tile y medio)
        }
        //26F6
        PosicionY = (PosicionY & 0xF8) - 0x18 //ajusta la posición y del sprite de adso al tile más cercano y la traslada
        if PosicionY < 0 { PosicionY = 0 }
        //26FE
        TablaSprites_2E17[0x2FCF + 2 - 0x2E17] = Int2ByteSigno(PosicionY) //modifica la posición y del sprite
        TablaSprites_2E17[0x2FCF + 4 - 0x2E17] = Int2ByteSigno(PosicionY) //modifica la posición anterior y del sprite
        //2704
        if TablaCaracteristicasPersonajes_3036[0x304B - 0x3036] != 0 { //si los gráficos estan flipeados
            SpriteLuzFlip_4BA0 = true
        } else {
            SpriteLuzFlip_4BA0 = false
        }
    }
    

    
    
    
   
   

   
}

