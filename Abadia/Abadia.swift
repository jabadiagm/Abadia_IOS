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
    private var BloqueoSonido:Bool = false
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
        ActualizarFrase_3B54()
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
        
        /*DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
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
            
        } */
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
            BloqueoSonido = true
            ActualizarSonidos_1060()
            BloqueoSonido = false
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
    
   
   
    func ErrorExtraño() {
        print("Error extraño")
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
            if TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] != 0 { //###666 bug???
                TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] = TablaDatosSonidos_0F96[PunteroCanalIX + 0x02 - 0x0F96] - 1
            } else {
                ErrorExtraño()
            }
            
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
        if TablaDatosSonidos_0F96[0x0F96 - 0x0F96] == TablaDatosSonidos_0F96[0x0F97 - 0x0F96] {
            return
        }
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
    
    public func EsperarBloqueoSonido() {
        var Contador:Int = 0
        while BloqueoSonido {
            Contador = Contador + 1
        }
    }

    public func ReproducirSonidoMelodia_1007() {
        //apunta al registro de control del canal 3
        if TablaDatosSonidos_0F96[0x0FD0 + 0x0E - 0x0F96] != 0 { return }
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FD0, 0x13FE)
    }


    public func ReproducirSonidoPuertaSeverino_102A() {
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FB8, 0x1550)
    }

    public func ReproducirSonidoAbrir_101B() {
        //sonido ??? por el canal 2
        //apunta a la entrada 2
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FB8, 0x14E7)
    }

    public func ReproducirSonidoCerrar_1016() {
        //sonido ??? por el canal 2
        //apunta a la entrada 2
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FB8, 0x1560)
    }

    public func ReproducirSonidoCampanas_100C() {
        //sonido ??? por el canal 1
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FA0, 0x14F3)
    }

    public func ReproducirSonidoCampanillas_1011() {
        //sonido de campanas después de la espiral cuadrada por el canal 1
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FA0, 0x14BA)
    }

    public func ReproducirSonidoCoger_1025() {
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FB8, 0x149F)
    }

    public func ReproducirSonidoDejar_102F() {
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FB8, 0x14A8)
    }

    public func ReproducirSonidoCogerDejar_5088( _ ObjetosAntesA:UInt8, _ ObjetosDespuesC:UInt8) {
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
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FD0, 0x1496)
    }

    public func ReproducirSonidoAbrirEspejoCanal1_0FFD() {
        //sonido ??? por el canal 1
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FA0, 0x1480)
    }

    public func ReproducirSonidoVoz_1020() {
        //apunta a los datos de inicialización y al canal 3
        if BloqueoSonido { return }
        IniciarCanal_104F(0x0FD0, 0x14B1)
    }

    public func ReproducirSonidoPergamino() {
        EsperarBloqueoSonido()
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
        EsperarBloqueoSonido()
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
            viewController?.definirModo(modo: 1) //fija el modo 1 (256x192 4 colores, sin marcos)
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
        viewController?.definirModo(modo: 2)
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
    
    public func TeclaPulsadaFlanco_3472(CodigoTecla:UInt8) -> Bool {
        //comprueba si ha sido pulsanda la tecla con el código indicado. si no ha sido pulsada o ya se ha preguntado antes, devuelve true
        return teclado!.TeclaPulsadaFlanco(TraducirCodigoTecla(CodigoTecla))
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
            case 0x2F: //espacio
                return .AreaObjetos
            case 0x44:
                return .TeclaTabulador
            case 0x17:
                return .TeclaControl
            case 0x15:
                return .TeclaMayusculas
            case 0x6: //enter
                return .AreaDepuracion
            case 0x4F:
                return .TeclaSuprimir
            case 0x42:
                return .TeclaEscape
            case 0x7:
                return .TeclaPunto
            case 0x3C: //s
                return .AreaTextosIzquierda
            case 0x2E: //n
                return .AreaTextosDerecha
            case 0x43: //Q
                return .AreaObjetos
            case 0x32: //R
                return .AreaObjetos
            case 0x66:
                return .AreaEscenario
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
            if TeclaPulsadaNivel_3482(0x2F) || TeclaPulsadaNivel_3482(0x66) {
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
            //TablaCaracteristicasPersonajes_3036[0x3063 + 2 - 0x3036] = 0x89
            //guillermo en el espejo
            //TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x02
            //TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x26
            //TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x69
            //TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0x18
            //adso
            //TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036) = 0x8D
            //TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036) = 0x85
            //TablaCaracteristicasPersonajes_3036[0x3045 + 4 - 0x3036) = 0x2
            Estatico.Inicializado = true
        }
        
        if depuracion.PaseoGuillermo {
            struct Estatico {
                static var Estado:Int = 0
                static var PosicionYAnterior:UInt8 = 0
                static var ContadorBloqueos:Int = 0
            }
            var PosicionY:UInt8
            var Bloqueo:Bool = false
            Obsequium_2D7F = 5
            PosicionY = TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036]
            if Estatico.PosicionYAnterior == PosicionY {
                Estatico.ContadorBloqueos = Estatico.ContadorBloqueos + 1
                if Estatico.ContadorBloqueos > 30 {
                    Bloqueo = true
                    //Estatico.ContadorBloqueos = 0
                    if Estatico.ContadorBloqueos > 60 {
                        TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x50
                    }
                }
            } else {
                Estatico.ContadorBloqueos = 0
            }
            Estatico.PosicionYAnterior = PosicionY
            switch Estatico.Estado {
                case 0:
                    TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x01 //orientación norte
                    teclado!.KeyDown(EnumAreaTecla.TeclaArriba) //andando
                    Estatico.Estado = 1
                case 1:
                    if PosicionY == 0x40 || Bloqueo { //ha llegado al altar
                        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x03 //media vuelta
                        Estatico.Estado = 2
                    }
                case 2:
                    if PosicionY == 0xAF || Bloqueo { //ha llegado al principio
                        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0x01 //media vuelta
                        Estatico.Estado = 1
                    }
                default:
                    break
            }
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
        //FrmPrincipal.TxOrientacion.Text = Hex$(TablaCaracteristicasPersonajes_3036[1))
        //FrmPrincipal.TxX.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036[2))
        //FrmPrincipal.TxY.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036[3))
        //FrmPrincipal.TxZ.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036[4))
        //FrmPrincipal.TxEscaleras.Text = "&H" + Hex$(TablaCaracteristicasPersonajes_3036[5))
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
        DescartarMovimientosPensados_08BE(PersonajeIY: 0x3045)
        DescartarMovimientosPensados_08BE(PersonajeIY: 0x3054)
        DescartarMovimientosPensados_08BE(PersonajeIY: 0x3063)
        DescartarMovimientosPensados_08BE(PersonajeIY: 0x3072)
        DescartarMovimientosPensados_08BE(PersonajeIY: 0x3081)



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
            PunteroPatronLuz = 0x48E8 //apunta a la tabla con el patrón de relleno de la luz
            for Contador in 0...Int(SpriteLuzTipoRelleno_4B6B)  { //TipoRellenoLuz_4B6B=0x00ef o 0x009f
                BufferSprites_9500[PunteroBufferSpritesDE + Contador - 0x9500] = 0xFF //rellena un tile o tile y medio de negro (la parte superior del sprite de la luz)
            }
            PunteroBufferSpritesIX = PunteroBufferSpritesDE + Int(SpriteLuzTipoRelleno_4B6B) + 1 //apunta a lo que hay después del buffer de tiles
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

    //nona--------------------------------------------------------------------------------------
    
    //vísperas--------------------------------------------------------------------------------------

    public func EscribirComando_0CE9( _ PersonajeIY:Int, _ DatosComandoHL:Int, _ LongitudDatosB:UInt8) -> Int {
        //; escribe b bits del comando que se le pasa en hl del personaje pasado en iy
        //;  iy = apunta a los datos de posición del personaje (características)
        //;  b = longitud del comando
        //;  hl = datos del comando
        //devuelve:
        // de = posición del último byte escrito en el buffer de comandos
        var EscribirComando_0CE9:Int
        var DatosComandoHL:Int = DatosComandoHL
        var Contador:UInt8
        var NBits:UInt8
        var PunteroDE:Int
        var Comando:UInt8
        EscribirComando_0CE9 = 0
        for Contador in 0..<LongitudDatosB {
            NBits = TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] //lee el contador
            //0cec
            if NBits == 8 {
                //aquí llega cuando se ha procesado un byte completo
                //0cf0
                TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0 //si llega a 8 se reinicia
                PunteroDE = Int(TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036]) //lee el índice de la tabla de bc
                PunteroDE = PunteroDE + Leer16(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x0C - 0x3036) //punterode = dirección[indice]
                //incrementa el índice de la tabla
                TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] + 1
                Comando = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] //lee el comando y lo escribe en la posición anterior
                //escribe en el buffer de comandos
                BufferComandosMonjes_A200[PunteroDE - 0xA200] = Comando
                EscribirComando_0CE9 = PunteroDE
            }
            //0d07
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] << 1
            if (DatosComandoHL & 0x8000) != 0 {
                TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] + 1 //rota el valor a la izquierda y mete el bit 15 de HL como bit 0
            }
            DatosComandoHL = (DatosComandoHL << 1) & 0xFFFF
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] + 1
        }
        return EscribirComando_0CE9
    }

    public func EscribirComando_4729( _ PersonajeIY:Int, _ Altura1A:UInt8, _ Altura2C:UInt8, _ PunteroTablaAvancePersonajeHL:Int) {
        //; escribe un comando dependiendo de si sube, baja o se mantiene
        //; llamado con:
        //;  iy = datos de posición del personaje
        //;  a y c = altura de las posiciones a las que va a moverse el personaje
        var PunteroTablaComandosHL:Int
        var NuevoEstadoA:UInt8
        var Comando:Int
        var LongitudComando:UInt8
        ClearBitArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 4) //indica que el personaje no está bajando en altura
        //4731
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) { //si el personaje ocupa una posición
            //aquí llega si el personaje ocupa una posición
            //4733
            if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 5) {
                //si el personaje está girado con respecto al desnivel
                //4739
                PunteroTablaComandosHL = 0x441A //apunta a la tabla de comandos si el personaje sube en altura
                //47b4
                AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL)
            } else {
                //aquí llega si el personaje ocupa una posición y el bit 5 es 0
                //4741
                IncByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 4 - 0x3036) //incrementa la altura del personaje
                PunteroTablaComandosHL = 0x441A //apunta a la tabla de comandos si el personaje sube en altura
                if Altura1A != 1 {
                    //si la diferencia de altura no es 1 (está bajando)
                    //474D
                    PunteroTablaComandosHL = 0x4420 //apunta a la tabla de comandos si el personaje baja en altura
                    DecByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 4 - 0x3036)
                    SetBitArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 4)
                    DecByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 4 - 0x3036)
                }
                //475C
                if Altura1A == Altura2C {
                    //si las diferencias de altura son iguales
                    //475F
                    PunteroTablaComandosHL = PunteroTablaComandosHL + 3 //pasa a otra entrada de la tabla
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] & 0x10 //preserva tan solo el bit de si sube y baja (y convierte al personaje en uno de 4 posiciones)
                    //476c
                    AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    if ObtenerOrientacion_29AE(PersonajeIY) == 0 { //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                        AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    }
                } else {
                    //47ae
                    AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                }
            }
        } else {
            //4779
            //aquí llega si el personaje ocupa cuatro posiciones
            //altura1a = diferencia de altura con la posicion 1 más cercana al personaje según la orientación
            //altura1c = diferencia de altura con la posicion 2 más cercana al personaje según la orientación
            if Altura1A == 1 {
                //si está subiendo
                //4788
                IncByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 4 - 0x3036) //incrementa la altura
                NuevoEstadoA = 0x80
                PunteroTablaComandosHL = 0x441D //apunta a la tabla si el personaje sube en altura
                //479e
                TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] = NuevoEstadoA //actualiza el estado
                AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                if ObtenerOrientacion_29AE(PersonajeIY) != 0 { //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                    AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                }
            } else {
                //477D
                if Altura1A == 0xFF {
                    //si está bajando
                    //4794
                    DecByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 4 - 0x3036) //decrementa la altura
                    NuevoEstadoA = 0x90
                    PunteroTablaComandosHL = 0x4423 //apunta a la tabla si el personaje baja en altura
                    //479e. repetido para evitar got0s
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] = NuevoEstadoA //actualiza el estado
                    AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    if ObtenerOrientacion_29AE(PersonajeIY) != 0 { //devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
                        AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                    }
                } else {
                    //si el personaje no cambia de altura
                    //4781
                    PunteroTablaComandosHL = 0x4426 //apunta a la tabla si el personaje no cambia de altura
                    //47ae. repetido para evitar got0s
                    AvanzarPersonaje_29E4(PersonajeIY, PunteroTablaAvancePersonajeHL) //actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
                }
            }
        }
        //47b7
        Comando = Leer16Inv(TablaComandos_440C, PunteroTablaComandosHL - 0x440C) //lee en el comando a poner
        LongitudComando = TablaComandos_440C[PunteroTablaComandosHL + 2 - 0x440C] //lee la longitud del comando
        EscribirComando_0CE9(PersonajeIY, Comando, LongitudComando) //escribe b bits del comando que se le pasa en hl del personaje pasado en iy
    }

    public func GenerarComandosOrientacionPersonaje_47C3(PersonajeIY:Int, ActualA:UInt8, RequeridaC: inout UInt8) {
        //escribe unos comandos para cambiar la orientación del personaje desde la orientación actual a la deseada
        //a = orientación actual del personaje
        //c = orientación que tomará del personaje
        var OrientacionC:UInt8
        var PunteroComandoHL:Int
        var Comando:Int
        var LongitudComando:UInt8
        if ActualA >= RequeridaC {
            //si la diferencia es positiva
            //47CE
            OrientacionC = ActualA - RequeridaC
        } else {
            //47C6
            OrientacionC = RequeridaC - ActualA
            OrientacionC = OrientacionC ^ 0x02 //cambia el sentido en x
            if OrientacionC == 0 { OrientacionC = 2 } //si era 0, pone 2
        }
        //47cf
        PunteroComandoHL = 0x440C //apunta a la tabla de la longitud de los comandos según la orientación
        PunteroComandoHL = PunteroComandoHL + Int(OrientacionC)
        LongitudComando = TablaComandos_440C[PunteroComandoHL - 0x440C] //lee la longitud del comando
        PunteroComandoHL = 0x4410 //apunta a la tabla de comandos para girar
        PunteroComandoHL = PunteroComandoHL + 2 * Int(OrientacionC)
        Comando = Leer16Inv(TablaComandos_440C, PunteroComandoHL - 0x440C)
        EscribirComando_0CE9(PersonajeIY, Comando, LongitudComando) //escribe b bits del comando que se le pasa en hl del personaje pasado en iy
        RequeridaC = OrientacionC
    }

    public func GenerarComandosOrigenDestino_4660( _ PersonajeIY:Int, _ PunteroPilaCaminoHL:Int) {
        //genera los comandos para seguir un camino en la misma pantalla
        var PunteroBufferSpritesHL:Int
        var PunteroBufferSpritesIX:Int
        var DestinoDE:Int
        var DestinoYD:UInt8=0
        var DestinoXE:UInt8=0
        var PosicionBC:Int=0 //posición intermedia
        var PosicionXC:UInt8=0 //nibble inferior de BC
        var PosicionYB:UInt8=0 //nibble superior de BC
        var OrientacionA:UInt8
        var OrientacionB:UInt8=0
        var Valor:Int
        var Valor1:UInt8=0
        var Valor2:UInt8=0
        var Altura1A:Int=0
        var Altura2C:Int=0
        var PunteroTablaAvanceHL:Int=0
                                         //corrección para evitar colisión con tareasonido
        ContadorInterrupcion_2D4B = 0xFE //pone el contador de la interrupción al máximo para que no se espere nada en el bucle principal
        PunteroPilaCamino = PunteroPilaCaminoHL
        DestinoDE = PopCamino() //obtiene el movimiento en el tope de la pila
        Integer2Nibbles(Value: DestinoDE, HighNibble: &DestinoYD, LowNibble: &DestinoXE)
        PunteroBufferSpritesHL = 0x9500 //apunta al comienzo del buffer de sprites
        BufferSprites_9500[PunteroBufferSpritesHL - 0x9500] = 0xFF //marca el final de los movimientos
        PunteroBufferSpritesHL = PunteroBufferSpritesHL + 1
        //4674
        Escribir16(&BufferSprites_9500, PunteroBufferSpritesHL - 0x9500, PosicionDestino_2DB4) //obtiene la posición a la que debe ir el personaje y la graba al principio del buffer
        PunteroBufferSpritesHL = PunteroBufferSpritesHL + 2
        OrientacionA = TablaComandos_440C[0x4418 - 0x440C] //lee la orientación resultado
        OrientacionA = OrientacionA ^ 0x02 //invierte la orientación
        BufferSprites_9500[PunteroBufferSpritesHL - 0x9500] = OrientacionA //escribe la orientación

        if TablaComandos_440C[0x4419 - 0x440C] != 1 { //si el número de iteraciones realizadas no es 1, comienza a iterar
            //si llega aquí, ya se ha encontrado el camino completo del destino al origen
            //4689
            while true {
                repeat { //coge valores de la pila hasta encontrar el marcador de iteración (-1)
                    Valor = PopCamino()
                } while (Valor & 0x8000) == 0
                //aquí llega después de sacar FFFF de la pila
                //468F
                PunteroBufferSpritesHL = PunteroBufferSpritesHL + 1
                //graba el movimiento del tope de la pila
                //4690
                BufferSprites_9500[PunteroBufferSpritesHL - 0x9500] = DestinoXE
                PunteroBufferSpritesHL = PunteroBufferSpritesHL + 1
                BufferSprites_9500[PunteroBufferSpritesHL - 0x9500] = DestinoYD
                while true {
                    while true {
                        //4693
                        PosicionBC = PopCamino() //obtiene el siguiente valor de la pila
                        Integer2Nibbles(Value: PosicionBC, HighNibble: &PosicionYB, LowNibble: &PosicionXC)
                        //si la distancia en y o en x >= 2, sigue sacando valores de la pila
                        Valor1 = Z80Inc(Z80Sub(PosicionYB, DestinoYD))
                        Valor2 = Z80Inc(Z80Sub(PosicionXC, DestinoXE))
                        if (Valor1 < 3) && (Valor2 < 3) { break }
                    }
                    //46A5
                    //combina las distancias +1 en x y en y en los 4 bits inferiores de a
                    OrientacionA = Valor2 * 4 + Valor1
                    //46ad
                    //prueba la orientación 0
                    OrientacionB = 0
                    //a = 1 (00 01) cuando la distancia en x es -1 y en y es 0 (x-1,y)
                    if OrientacionA == 1 { break }
                    //prueba la orientación 1
                    OrientacionB = 1
                    //a = 6 (01 10) cuando la distancia en x es 0 y en y es 1 (x,y+1)
                    if OrientacionA == 6 { break }
                    //prueba la orientación 2
                    OrientacionB = 2
                    //a = 9 (10 01) cuando la distancia en x es 1 y en y es 0 (x+1,y)
                    if OrientacionA == 9 { break }
                    //prueba la orientación 3
                    OrientacionB = 3
                    //a = 4 (01 00) cuando la distancia en x es 0 y en y es -1 (x,y-1)
                    if OrientacionA == 4 { break }
                    //si no es ninguno de los 4 casos en los que se ha avanzado una unidad, sigue sacando elementos
                }
                //aquí llega si el valor sacado de la pila era una iteración anterior de alguno de los de antes
                //define como destino la última dirección sacada de la pila
                DestinoYD = PosicionYB
                DestinoXE = PosicionXC
                //46c2
                PunteroBufferSpritesHL = PunteroBufferSpritesHL + 1
                BufferSprites_9500[PunteroBufferSpritesHL - 0x9500] = OrientacionB //graba la orientación del movimiento

                if PosicionBC == PosicionOrigen_2DB2 { break }
                //si la coordenada del origen no es la misma que la sacada de la pila, continua procesando una iteración más
            }
        }
        //si llega aquí, ya se ha encontrado el camino completo del destino al origen
        //46d3
        PunteroBufferSpritesIX = PunteroBufferSpritesHL //obtiene el principio de la pila de movimientos en ix
        while true {
            //46db
            OrientacionB = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036] //obtiene la orientación del personaje
            OrientacionA = BufferSprites_9500[PunteroBufferSpritesIX - 0x9500] //lee la orientación que debe tomar
            //si el personaje ocupa 4 posiciones, salta esta parte
            if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) {
                //el personaje ocupa 1 posición
                //46E7
                //compara la orientación del personaje con la que debe tomar
                if ((OrientacionB ^ OrientacionA) & 0x01) != 0 { //si el personaje está girado respecto de las escaleras
                    //en otro caso, cambia el estado de girado en desnivel
                    //46ED
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] ^ 0x20
                }
            }
            //46f5
            //modifica la orientación del personaje con la de la ruta que debe seguir
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036] = OrientacionA
            if OrientacionA != OrientacionB { //comprueba si ha variado su orientación
                //si ha variado su orientación, escribe unos comandos para cambiar la orientación del personaje
                //46fa
                GenerarComandosOrientacionPersonaje_47C3(PersonajeIY: PersonajeIY, ActualA: OrientacionB, RequeridaC: &OrientacionA)
            }
            //46fd
            ObtenerAlturaDestinoPersonaje_27B8(0, OrientacionA, PersonajeIY, &Altura1A, &Altura2C, &PunteroTablaAvanceHL)
            EscribirComando_4729(PersonajeIY, Int2ByteSigno(Altura1A), Int2ByteSigno(Altura2C), PunteroTablaAvanceHL)
            while true {
                //4707
                PunteroBufferSpritesIX = PunteroBufferSpritesIX - 3 //avanza a la siguiente posición del camino
                Valor1 = BufferSprites_9500[PunteroBufferSpritesIX - 0x9500]
                if Valor1 == 0xFF { return } //si se ha alcanzado la última posición del camino, sale
                //obtiene la posición del personaje
                PosicionXC = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036]
                PosicionYB = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
                //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
                DeterminarPosicionCentral_279B(&PosicionXC, &PosicionYB)
                DestinoXE = BufferSprites_9500[PunteroBufferSpritesIX + 1 - 0x9500]
                DestinoYD = BufferSprites_9500[PunteroBufferSpritesIX + 2 - 0x9500]
                //4723
                //compara la posición del personaje con la de la pila
                //si coincide, es porque comprueba ha llegado a la posición de destino y debe sacar más valores de la pila
                if (DestinoXE == PosicionXC) && (DestinoYD == PosicionYB) { break }
                //en otro caso, sigue procesando entradas
            }
        }

    }

    public func CambiarOrientacionPersonaje_464F( _ PersonajeIY:Int, _ OrientacionNuevaC:UInt8) {
        //cambia la orientación del personaje y avanza en esa orientación
        //iy apunta a los datos de posición de un personaje
        //c = nueva orientación del personaje
        var OrientacionActualA:UInt8
        var OrientacionNuevaC:UInt8 = OrientacionNuevaC
        var Altura1A:Int=0
        var Altura2C:Int=0
        var Altura1AByte:UInt8
        var Altura2CByte:UInt8
        var PunteroTablaAvanceHL:Int=0
        OrientacionActualA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036] //obtiene la orientación del personaje
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036] = OrientacionNuevaC //pone la nueva orientación del personaje
        //4656
        if OrientacionActualA != OrientacionNuevaC { //comprueba si era la orientación que tenía el personaje
            //si no era así, escribe unos comandos para cambiar la orientación del personaje
            GenerarComandosOrientacionPersonaje_47C3(PersonajeIY: PersonajeIY, ActualA: OrientacionActualA, RequeridaC: &OrientacionNuevaC)
        }
        //4659
        //comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
        ObtenerAlturaDestinoPersonaje_27B8(0, OrientacionNuevaC, PersonajeIY, &Altura1A, &Altura2C, &PunteroTablaAvanceHL)
        Altura1AByte = Int2ByteSigno(Altura1A)
        Altura2CByte = Int2ByteSigno(Altura2C)
        //escribe un comando dependiendo de si sube, baja o se mantiene
        EscribirComando_4729(PersonajeIY, Altura1AByte, Altura2CByte, PunteroTablaAvanceHL)
    }

    public func GenerarComandos_47E6(PersonajeIY:Int, OrientacionNuevaC:UInt8, NumeroRutina:Int, PunteroPilaCaminoHL:Int) {
        //puede llamar a la rutina 0x4660 o a la 0x464f
        //la rutina 0x4660 se encarga de generar todos los comandos para ir desde el origen al destino
        //la rutina de 0x464f escribe un comando dependiendo de si sube, baja o se mantiene o de la orientación y sale
        //iy apunta a los datos de posición de un personaje
        //c = nueva orientación del personaje
        var OrientacionActualA:UInt8
        var PosicionActualDE:Int
        var AlturaActual:UInt8
        var Posiciones:UInt8
        //guarda la posición del personaje
        PosicionActualDE = Leer16(TablaCaracteristicasPersonajes_3036, PersonajeIY + 2 - 0x3036)
        //guarda la orientación
        OrientacionActualA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036]
        //guarda la altura del personaje
        AlturaActual = TablaCaracteristicasPersonajes_3036[PersonajeIY + 4 - 0x3036]
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0 //reinicia las acciones del personaje
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
        //a indica para donde se mueve el personaje y su tamaño
        Posiciones = TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036]
        //4800
        if NumeroRutina == 0x4660 {
            GenerarComandosOrigenDestino_4660(PersonajeIY, PunteroPilaCaminoHL)
        } else { //464f
            CambiarOrientacionPersonaje_464F(PersonajeIY, OrientacionNuevaC)
        }
        //restaura el valor anterior de iy+05
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 5 - 0x3036] = Posiciones
        //escribe un comando para que espere un poco antes de volver a moverse
        EscribirComando_0CE9(PersonajeIY, 0x1000, 0x0C) //escribe b bits del comando que se le pasa en hl del personaje pasado en iy
        //480F
        //restaura la orientación y altura del personaje
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 4 - 0x3036] = AlturaActual
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036] = OrientacionActualA
        //restaura la posición del personaje
        Escribir16(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 2 - 0x3036, PosicionActualDE)
        //481D
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0 //reinicia el puntero de las acciones del personaje
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
    }

    public func ComprobarPosicionesVecinas_4517( _ PosicionDE:Int, _ PunteroBufferAlturasIX:Int, _ AlturaC:UInt8, _ AlturaBase_451C:UInt8, _ RutinaCompleta:Bool) -> Bool {
        //comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
        //aquí llega con:
        //c = contenido del buffer de alturas (sin el bit 7) para una posición próxima a la que estaba el personaje
        //ix = puntero a una posición del buffer de alturas
        //RutinaCompleta=false: sale en 4559
        //si devuelve true, la función llamante debe terminar
        var ComprobarPosicionesVecinas_4517:Bool
        var AlturaC:UInt8 = AlturaC
        var Valor:UInt8
        var DiferenciaAltura:UInt8
        var Encontrado:Bool
        ComprobarPosicionesVecinas_4517 = false
        AlturaC = AlturaC & 0x3F //quita el bit 7 y 6
        //obtiene la diferencia de altura entre el personaje y la posición que se está considerando
        //y le suma 1
        DiferenciaAltura = Z80Inc(Z80Sub(AlturaC, AlturaBase_451C))
        if DiferenciaAltura >= 3 { return ComprobarPosicionesVecinas_4517 } //si la diferencia de altura es >= 0x02, sale
        //4522
        //compara la altura de la posición de la izquierda con la altura de la posición actual
        Valor = LeerByteBufferAlturas(PunteroBufferAlturasIX - 1)
        Valor = Valor & 0x3F
        DiferenciaAltura = Z80Sub(Valor, AlturaC)
        if DiferenciaAltura != 0 {
            //aquí llega si la altura de pos (x,y) y de pos (x-1,y) no coincide
            //452a
            DiferenciaAltura = Z80Inc(DiferenciaAltura)
            if DiferenciaAltura >= 3 { return ComprobarPosicionesVecinas_4517 } //si la diferencia de altura es muy grande, sale
            //452e
            //obtiene la altura de la posición (x,y-1)
            Valor = LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x18)
            Valor = Z80Sub(Valor & 0x3F, AlturaC)
            if Valor != 0 { return ComprobarPosicionesVecinas_4517 } //si no coincide la altura con la de (x,y), sale
            //4536
            //obtiene la altura de la posición (x-1,y-1)
            Valor = LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x19)
            Valor = Z80Inc(Z80Sub(Valor & 0x3F, AlturaC))
            if Valor != DiferenciaAltura { return ComprobarPosicionesVecinas_4517 } //si la diferencia de altura no coincide con la de (x-1,y), sale
        } else {
            //aquí llega si la altura de pos (x,y) y de pos (x-1,y) coincide
            //4541
            //obtiene la altura de la posición (x,y-1)
            Valor = LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x18)
            DiferenciaAltura = Z80Inc(Z80Sub(Valor & 0x3F, AlturaC))
            if DiferenciaAltura >= 3 { return ComprobarPosicionesVecinas_4517 }//si la diferencia de altura es muy grande, sale
            //454B
            //obtiene la altura de la posición (x-1,y-1)
            Valor = LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x19)
            Valor = Z80Inc(Z80Sub(Valor & 0x3F, AlturaC))
            if Valor != DiferenciaAltura { return ComprobarPosicionesVecinas_4517 } //si la diferencia de altura no coincide con la de (x,y-1), sale
        }
        //aquí llega si la diferencia de altura entre las 4 posiciones consideradas es pequeña
        //4555
        SetBitBufferAlturas(PunteroBufferAlturasIX, 7) //pone a 1 el bit 7 de la posición
        if !RutinaCompleta { return ComprobarPosicionesVecinas_4517 }
        //455a
        ClearBitBufferAlturas(PunteroBufferAlturasIX, 7) //pone el bit 7 a 0 (no es una posición explorada)
        Encontrado = LeerBitBufferAlturas(PunteroBufferAlturasIX, 6)
        if Encontrado == false {
            //si no ha encontrado lo que busca
            //4567
            //pone el bit 7 a 1 (casilla explorada)
            SetBitBufferAlturas(PunteroBufferAlturasIX, 7)
            PushCamino(PosicionDE)
        } else {
            //aquí llega si el bit 6 es 1 (ha encontrado lo que se buscaba)
            //456f
            ComprobarPosicionesVecinas_4517 = true //hace que en la función llamante vuelva
            ResultadoBusqueda_2DB6 = 0xFF //0xff indica que la búsqueda fue fructífera
        }
        return ComprobarPosicionesVecinas_4517
    }

    public func ComprobarPosicionesVecinas_450E( _ PosicionDE:Int, _ OrientacionA:UInt8, _ AlturaBase_451C:UInt8, _ PunteroBufferAlturasIX:Int) -> Bool {
        //si no se había explorado esta posición, comprueba las 4 posiciones vecinas ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y
        //si no hay mucha diferencia de altura, pone el bit 7 de (x,y). también escribe la orientación final en 0x4418
        //si devuelve true, la función llamante debe terminar
        var ComprobarPosicionesVecinas_450E:Bool
        var AlturaC:UInt8
        var BufferAuxiliar:Bool = false //true: se usa el buffer secundario de 96F4
        if PunteroBufferAlturas_2D8A != 0x01C0 { BufferAuxiliar = true }
        ComprobarPosicionesVecinas_450E = false
        //obtiene el valor del buffer de alturas de la posición actual
        if !BufferAuxiliar {
            AlturaC = TablaBufferAlturas_01C0[PunteroBufferAlturasIX - 0x01C0]
        } else {
            AlturaC = TablaBufferAlturas_96F4[PunteroBufferAlturasIX - 0x96F4]
        }
        TablaComandos_440C[0x4418 - 0x440C] = OrientacionA //graba la orientación final
        //si la posición ya ha sido explorada, sale
        if (AlturaC & 0x80) != 0 { return ComprobarPosicionesVecinas_450E }
        ComprobarPosicionesVecinas_450E = ComprobarPosicionesVecinas_4517(PosicionDE, PunteroBufferAlturasIX, AlturaC, AlturaBase_451C, true)
        return ComprobarPosicionesVecinas_450E
    }

    public func SetBitBufferAlturas( _ Puntero:Int, _ NBit:UInt8) {
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            SetBitArray(&TablaBufferAlturas_01C0, Puntero - 0x01C0, Int(NBit))
        } else { //buffer auxiliar para la búsqueda de caminos
            if ((Puntero - 0x96F4) >= TablaBufferAlturas_96F4.count) || Puntero < 0x96F4 { return }
            SetBitArray(&TablaBufferAlturas_96F4, Puntero - 0x96F4, Int(NBit))
        }
    }

    public func ClearBitBufferAlturas( _ Puntero:Int, _ NBit:UInt8) {
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            ClearBitArray(&TablaBufferAlturas_01C0, Puntero - 0x01C0, Int(NBit))
        } else { //buffer auxiliar para la búsqueda de caminos
            if ((Puntero - 0x96F4) >= TablaBufferAlturas_96F4.count) || (Puntero < 0x96F4) { return }
            ClearBitArray(&TablaBufferAlturas_96F4, Puntero - 0x96F4, Int(NBit))
        }
    }

    public func LeerByteBufferAlturas( _ Puntero:Int) -> UInt8 {
        var LeerByteBufferAlturas:UInt8
        LeerByteBufferAlturas = 0
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            if !PunteroPerteneceTabla(Puntero, TablaBufferAlturas_01C0, 0x01C0) { return LeerByteBufferAlturas }
            LeerByteBufferAlturas = TablaBufferAlturas_01C0[Puntero - 0x01C0]
        } else { //buffer auxiliar para la búsqueda de caminos
            if !PunteroPerteneceTabla(Puntero, TablaBufferAlturas_96F4, 0x96F4) { return LeerByteBufferAlturas }
            LeerByteBufferAlturas = TablaBufferAlturas_96F4[Puntero - 0x96F4]
        }
        return LeerByteBufferAlturas
    }

    public func EscribirByteBufferAlturas( _ Puntero:Int, _ Valor:UInt8) {
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            if !PunteroPerteneceTabla(Puntero, TablaBufferAlturas_01C0, 0x01C0) { return }
            TablaBufferAlturas_01C0[Puntero - 0x01C0] = Valor
        } else { //buffer auxiliar para la búsqueda de caminos
            if !PunteroPerteneceTabla(Puntero, TablaBufferAlturas_96F4, 0x96F4) { return }
            TablaBufferAlturas_96F4[Puntero - 0x96F4] = Valor
        }
    }

    public func LeerBitBufferAlturas( _ Puntero:Int, _ NBit:UInt8) -> Bool {
        var LeerBitBufferAlturas:Bool
        LeerBitBufferAlturas = false
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            LeerBitBufferAlturas = LeerBitArray(TablaBufferAlturas_01C0, Puntero - 0x01C0, Int(NBit))
        } else { //buffer auxiliar para la búsqueda de caminos
            if ((Puntero - 0x96F4) >= TablaBufferAlturas_96F4.count) || Puntero < 0x96F4 { return LeerBitBufferAlturas }
            LeerBitBufferAlturas = LeerBitArray(TablaBufferAlturas_96F4, Puntero - 0x96F4, Int(NBit))
        }
        return LeerBitBufferAlturas
    }

    public func PushCamino( _ Valor:Int) {
        //escribe un valor de 16 bits en el buffer de sprites cuando se utiliza como pila
        //para el cálculo de caminos
        PunteroPilaCamino = PunteroPilaCamino - 2
        if PunteroPilaCamino < 0x9500 {
            //Stop //final del buffer de sprites
            return
        }
        Escribir16(&BufferSprites_9500, PunteroPilaCamino - 0x9500, Valor)
        //PilaDebug(UBound(PilaDebug) - (0x9CFC - PunteroPilaCamino) / 2) = Valor
    }

    public func PopCamino() -> Int {
        //lee un valor de 16 bits del buffer de sprites cuando se utiliza como pila
        //para el cálculo de caminos
        var PopCamino:Int
        PopCamino = Leer16(BufferSprites_9500, PunteroPilaCamino - 0x9500)
        PunteroPilaCamino = PunteroPilaCamino + 2
        if PunteroPilaCamino > 0x9CFE { ErrorExtraño() } //final del buffer de sprites
        return PopCamino
    }

    public func LeerPilaCamino( _ PunteroPilaCaminoHL:Int) -> Int {
        //lee un valor de 16 bits del buffer de sprites cuando se utiliza como pila
        //para el cálculo de caminos, utilizando un puntero diferente al actual
        return Leer16(BufferSprites_9500, PunteroPilaCaminoHL - 0x9500)
    }

    public func BuscarCamino_446A( _ PunteroPilaHL: inout Int) -> Bool {
        //rutina de búsqueda de caminos desde la posición que hay en 0x2db2 (destino) a la posicion del buffer de altura que tenga el bit 6 (orígen)
        //sale con true para indicar que ha encontrado el camino
        //devuelve en PunteroPilaHL el puntero al movimiento de la pila que dio la solución
        var BuscarCamino_446A:Bool
        var PunteroBufferAlturasDE:Int //puntero a la última línea del buffer de alturas
        var PunteroBufferAlturasHL:Int //puntero a la primera línea del buffer de alturas
        var PunteroBufferAlturasIX:Int //puntero al borde izquierdo del buffer de alturas
        //Dim PunteroPilaHL:Int
        var Contador:Int
        var PosicionDE:Int
        var OrientacionA:UInt8
        var AlturaBase_451C:UInt8
        BuscarCamino_446A = false
        PunteroBufferAlturasDE = PunteroBufferAlturas_2D8A + 0x0228 //de = posición (X = 0, Y = 23) del buffer de alturas
        PunteroBufferAlturasIX = PunteroBufferAlturas_2D8A //de = posición (X = 0, Y = 23) del buffer de alturas
        PunteroBufferAlturasHL = PunteroBufferAlturas_2D8A //hl = posición (X = 0, Y = 0) del buffer de alturas
        for Contador in 0...23 { //recorre todas las filas/columnas del buffer de alturas
            //447a
            SetBitBufferAlturas(PunteroBufferAlturasHL, 7) //pone el bit 7 de la posición en el borde superior
            SetBitBufferAlturas(PunteroBufferAlturasIX, 7) //pone el bit 7 de la posición en el borde izquierdo
            SetBitBufferAlturas(PunteroBufferAlturasIX + 23, 7) //pone el bit 7 de la posición en el borde izquierdo
            SetBitBufferAlturas(PunteroBufferAlturasDE, 7) //pone el bit 7 de la posición en el borde inferior
            PunteroBufferAlturasIX = PunteroBufferAlturasIX + 24 //avanza ix a la siguiente línea
            PunteroBufferAlturasDE = PunteroBufferAlturasDE + 1 //pasa a la siguiente columna de la última línea del buffer de alturas
            PunteroBufferAlturasHL = PunteroBufferAlturasHL + 1 //pasa a la siguiente columna de la primera línea del buffer de alturas
        } //repite hasta haber puesto el bit 7 de todas las posiciones del borde del buffer de alturas
        //ModFunciones.GuardarArchivo("Buffer0", TablaBufferAlturas_01C0) //0x23F
        //ModFunciones.GuardarArchivo("Buffer0", TablaBufferAlturas_96F4) //0x23F

        //4493
        PunteroPilaCamino = 0x9CFE //pone la pila al final del buffer de sprites
        TablaComandos_440C[0x4419 - 0x440C] = 1 //inicia el nivel de recursión
        PunteroBufferAlturasDE = PosicionOrigen_2DB2 //obtiene la posición inicial ajustada al buffer de alturas
        PushCamino(PunteroBufferAlturasDE) //guarda en la pila la posición inicial
        //indexa en la tabla de alturas con de y devuelve la dirección correspondiente en ix
        //0cd4
        PunteroBufferAlturasIX = ((PunteroBufferAlturasDE & 0x0000FF00) >> 8) * 24 + (PunteroBufferAlturasDE & 0x000000FF) + PunteroBufferAlturas_2D8A
        //44A8
        SetBitBufferAlturas(PunteroBufferAlturasIX, 7) //marca la posición inicial como explorada
        PushCamino(0xFFFF) //mete en la pila -1
        PunteroPilaHL = 0x9CFE //hl apunta al final de la pila
        while true {
            //44b3
            PunteroPilaHL = PunteroPilaHL - 2
            PosicionDE = Leer16(BufferSprites_9500, PunteroPilaHL - 0x9500) //de = valor sacado de la pila
            //44ba
            if PosicionDE != 0xFFFF { //si no recuperó -1, salta a explorar las posiciones vecinas
                //aqui llega si no se leyó -1 de la pila
                //44d0
                //indexa en la tabla de alturas con de y devuelve la dirección correspondiente en ix
                //0cd4
                PunteroBufferAlturasIX = ((PosicionDE & 0x0000FF00) >> 8) * 24 + (PosicionDE & 0x000000FF) + PunteroBufferAlturas_2D8A
                AlturaBase_451C = LeerByteBufferAlturas(PunteroBufferAlturasIX) & 0x0F
                //trata de explorar las posiciones que rodean al valor de posición que ha sacado de la pila (si no hay mucha diferencia de altura)
                //44E0
                OrientacionA = 2 //orientación izquierda
                //pasa a la posición (x+1,y)
                //si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
                //((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
                if ComprobarPosicionesVecinas_450E(PosicionDE + 1, OrientacionA, AlturaBase_451C, PunteroBufferAlturasIX + 1) {
                    BuscarCamino_446A = true
                    return BuscarCamino_446A
                }
                //44E8
                OrientacionA = 3 //orientación arriba
                //pasa a la posición (x,y-1)
                //si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
                //((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
                if ComprobarPosicionesVecinas_450E(PosicionDE - 0x100, OrientacionA, AlturaBase_451C, PunteroBufferAlturasIX - 24) {
                    BuscarCamino_446A = true
                    return BuscarCamino_446A
                }
                //44f4
                OrientacionA = 0 //orientación derecha
                //pasa a la posición (x-1,y)
                //si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
                //((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
                if ComprobarPosicionesVecinas_450E(PosicionDE - 1, OrientacionA, AlturaBase_451C, PunteroBufferAlturasIX - 1) {
                    BuscarCamino_446A = true
                    return BuscarCamino_446A
                }
                //4500
                OrientacionA = 1 //orientación abajo
                //pasa a la posición (x,y+1)
                //si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
                //((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
                if ComprobarPosicionesVecinas_450E(PosicionDE + 0x100, OrientacionA, AlturaBase_451C, PunteroBufferAlturasIX + 24) {
                    BuscarCamino_446A = true
                    return BuscarCamino_446A
                }
            } else {
                //aquí llega si ha terminado una iteración
                //44bc
                if PunteroPilaHL == PunteroPilaCamino {
                    //si se han procesado todos los elementos, sale
                    //4575
                    ResultadoBusqueda_2DB6 = 0 //escribe el resultado de la búsqueda
                    return BuscarCamino_446A
                } else {
                    //en otro caso, mete un -1 para indicar que termina un nivel
                    //44C6
                    PushCamino(0xFFFF)
                    TablaComandos_440C[0x4419 - 0x440C] = TablaComandos_440C[0x4419 - 0x440C] + 1 //incrementa el nivel de recursión
                }
            }
        }
        return BuscarCamino_446A
    }

    public func BuscarCamino_4435( _ PunteroPilaHL: inout Int) -> Bool {
        //rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5 comprobando si es alcanzable
        //sale con true para indicar que ha encontrado el camino
        //devuelve en PunteroPilaHL el puntero al movimiento de la pila que dio la solución
        var BuscarCamino_4435:Bool
        var PunteroBufferAlturasIX:Int
        var AlturaBase_451C:UInt8
        BuscarCamino_4435 = false
        //indexa en la tabla de alturas con PosicionDestino_2DB4 y devuelve la dirección correspondiente en ix
        //0cd4
        PunteroBufferAlturasIX = ((PosicionDestino_2DB4 & 0x0000FF00) >> 8) * 24 + (PosicionDestino_2DB4 & 0x000000FF) + PunteroBufferAlturas_2D8A
        //lee la altura de esa posición
        AlturaBase_451C = LeerByteBufferAlturas(PunteroBufferAlturasIX) & 0x0F
        if AlturaBase_451C < 0x0E {
            //444f
            //comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
            ComprobarPosicionesVecinas_4517(0, PunteroBufferAlturasIX, AlturaBase_451C, AlturaBase_451C, false)
            if LeerBitBufferAlturas(PunteroBufferAlturasIX, 7) { //si se puede alcanzar el destino
                ClearBitBufferAlturas(PunteroBufferAlturasIX, 7) //quita marca de posición explorada
                SetBitBufferAlturas(PunteroBufferAlturasIX, 6) //marca la posición como objetivo de la búsqueda
                //rutina de búsqueda de caminos desde la posición que hay en 0x2db2 (destino) a la posicion del buffer de altura que tenga el bit 6 (orígen)
                BuscarCamino_4435 = BuscarCamino_446A(&PunteroPilaHL)
                return BuscarCamino_4435
            }
        }
        //si no se puede alcanzar el destino, sale
        //4575
        ResultadoBusqueda_2DB6 = 0
        return BuscarCamino_4435
    }

    public func BuscarCamino_4429( _ PunteroPilaHL: inout Int) -> Bool {
        //rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5
        //sale con true para indicar que ha encontrado el camino
        //devuelve en PunteroPilaHL el puntero al movimiento de la pila que dio la solución
        var BuscarCamino_4429:Bool
        var PunteroBufferAlturasIX:Int
        //0cd4
        PunteroBufferAlturasIX = ((PosicionDestino_2DB4 & 0x0000FF00) >> 8) * 24 + (PosicionDestino_2DB4 & 0x000000FF) + PunteroBufferAlturas_2D8A
        //442f
        SetBitBufferAlturas(PunteroBufferAlturasIX, 6) //marca la posición como objetivo de la búsqueda
        BuscarCamino_4429 = BuscarCamino_446A(&PunteroPilaHL)
        return BuscarCamino_4429
    }

    public func LimpiarRastrosBusquedaBufferAlturas_0BAE() {
        //elimina todos los rastros de la búsqueda del buffer de alturas
        var Contador:Int
        if PunteroBufferAlturas_2D8A == 0x01C0 { //buffer principal con la pantalla actual
            for Contador in 0...0x023F { //24*24
                //0BB7
                TablaBufferAlturas_01C0[Contador] = TablaBufferAlturas_01C0[Contador] & 0x3F
            }
        } else { //buffer auxiliar para la búsqueda de caminos
            for Contador in 0...0x023F { //24*24
                //0BB7
                TablaBufferAlturas_96F4[Contador] = TablaBufferAlturas_96F4[Contador] & 0x3F
            }
        }
    }

    public func LeerTablaPlantas_48B5( _ PosicionHL:Int) -> Int {
        //dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
        return PunteroTablaConexiones_440A + ((PosicionHL & 0xF00) >> 4 | (PosicionHL & 0x0F))
    }

    public func ComprobarPosicionCaminoHabitacion_489B(PosicionDE:Int, PunteroTablaConexionesHabitacionesIX:Int, MascaraBusquedaHabitacion_48A4:UInt8, OrientacionSalidaC:UInt8, OrientacionCaminoB:UInt8) -> Bool {
        //comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
        //si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
        //MascaraBusquedaHabitacion_48A4 = número de bit a comprobar en la búsqueda de habitación (ojo: valor=0-7, no 7x)
        //de=posición a analizar
        //c = orientación por la que se quiere salir de la habitación
        //b = orientación usada para ir del destino al origen
        var ComprobarPosicionCaminoHabitacion_489B:Bool
        var DatosHabitacion:UInt8
        ComprobarPosicionCaminoHabitacion_489B = false
        if PunteroPerteneceTabla(PunteroTablaConexionesHabitacionesIX, TablaConexionesHabitaciones_05CD, 0x05CD) {
            DatosHabitacion = TablaConexionesHabitaciones_05CD[PunteroTablaConexionesHabitacionesIX - 0x05CD] //obtiene los datos de la habitación
        } else {
            DatosHabitacion = 0
            //Stop
            return ComprobarPosicionCaminoHabitacion_489B
        }
        if (DatosHabitacion & OrientacionSalidaC) != 0 { return ComprobarPosicionCaminoHabitacion_489B } //si no se puede salir de la habitación por la orientación que se le pasa, sale
        //48a0
        if LeerBitArray(TablaConexionesHabitaciones_05CD, PunteroTablaConexionesHabitacionesIX - 0x05CD, Int(MascaraBusquedaHabitacion_48A4)) {
            //si está puesto el bit que se busca, sale del algoritmo guardando la orientación de destino e indicando que la búsqueda fue fructífera
            //456f
            TablaComandos_440C[0x4418 - 0x440C] = OrientacionCaminoB //guarda la orientación final
            ComprobarPosicionCaminoHabitacion_489B = true //indica que la búsqueda fue fructífera
            ResultadoBusqueda_2DB6 = 0xFF //0xff indica que la búsqueda fue fructífera
        } else {
            //48A8
            if LeerBitArray(TablaConexionesHabitaciones_05CD, PunteroTablaConexionesHabitacionesIX - 0x05CD, 7) {
                //en otro caso, si la posición ya ha sido explorada, sale
                return ComprobarPosicionCaminoHabitacion_489B
            } else {
                //48ad
                //si la posición no se había explorado, la marca como explorada
                SetBitArray(&TablaConexionesHabitaciones_05CD, PunteroTablaConexionesHabitacionesIX - 0x05CD, 7)
                PushCamino(PosicionDE) //mete en la pila la posición actual
            }
        }
        return ComprobarPosicionCaminoHabitacion_489B
    }

    public func BuscarHabitacion_4830( _ MascaraBusquedaHabitacion_48A4:UInt8, _ PunteroPilaHL: inout Int, _ ElementoActualPilaDE: inout Int) -> Bool {
        //busca la pantalla indicada que cumpla una máscara que se especifica en 0x48a4, iniciando la búsqueda en la posición indicada en 0x2db2
        //devuelve en ix la última posición del puntero de pila, y en de la última posición leída de la pila
        var BuscarHabitacion_4830:Bool
        var PunteroTablaConexionesHabitacionesIX:Int
        //Dim ElementoActualPilaDE:Int
        BuscarHabitacion_4830 = false
        PunteroPilaCamino = 0x9CFE //pone como dirección la pila el final del buffer de sprites
        //483B
        PushCamino(PosicionOrigen_2DB2) //guarda en la pila la posición inicial
        //dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
        PunteroTablaConexionesHabitacionesIX = LeerTablaPlantas_48B5(PosicionOrigen_2DB2)
        SetBitArray(&TablaConexionesHabitaciones_05CD, PunteroTablaConexionesHabitacionesIX - 0x05CD, 7) //marca la posición inicial como explorada
        PushCamino(0xFFFF) //mete en la pila -1
        PunteroPilaHL = 0x9CFE //apunta con hl a la parte procesada de la pila
        var nose:Int = 0
        //484B
        while true {
            PunteroPilaHL = PunteroPilaHL - 2
            if PunteroPilaHL < 0x9500 {
                ResultadoBusqueda_2DB6 = 0 //escribe el resultado de la búsqueda
                return BuscarHabitacion_4830
            }
            ElementoActualPilaDE = LeerPilaCamino(PunteroPilaHL)
            if ElementoActualPilaDE == 0xFFFF { //si no se ha completado una iteración
                //4854
                //comprueba si ha procesado todos los elementos de la pila
                if PunteroPilaHL == PunteroPilaCamino {
                    //4575
                    //si es así, sale
                    ResultadoBusqueda_2DB6 = 0 //escribe el resultado de la búsqueda
                    return BuscarHabitacion_4830
                } else { //no se han procesado todos los elementos de la pila. marca el fín del nivel y continúa procesando
                    //485E
                    PushCamino(0xFFFF) //mete en la pila -1
                }
            } else { //aquí llega para procesar un elemento de la pila
                //4861
                //dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
                PunteroTablaConexionesHabitacionesIX = LeerTablaPlantas_48B5(ElementoActualPilaDE)
                //4869
                //comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
                //si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
                //pasa a la posición (x+1,y)
                //orientación = 2, trata de ir por bit 2
                if ComprobarPosicionCaminoHabitacion_489B(PosicionDE: ElementoActualPilaDE + 1, PunteroTablaConexionesHabitacionesIX: PunteroTablaConexionesHabitacionesIX + 1, MascaraBusquedaHabitacion_48A4: MascaraBusquedaHabitacion_48A4, OrientacionSalidaC: 4, OrientacionCaminoB: 2) {
                    ElementoActualPilaDE = ElementoActualPilaDE + 1
                    BuscarHabitacion_4830 = true
                    return BuscarHabitacion_4830
                }
                //4872
                //comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
                //si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
                //pasa a la posición (x,y-1)
                //orientación = 3, trata de ir por bit 3
                if ComprobarPosicionCaminoHabitacion_489B(PosicionDE: ElementoActualPilaDE - 0x100, PunteroTablaConexionesHabitacionesIX: PunteroTablaConexionesHabitacionesIX - 16, MascaraBusquedaHabitacion_48A4: MascaraBusquedaHabitacion_48A4, OrientacionSalidaC: 8, OrientacionCaminoB: 3) {
                    ElementoActualPilaDE = ElementoActualPilaDE - 0x100
                    BuscarHabitacion_4830 = true
                    return BuscarHabitacion_4830
                }
                //487F
                //comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
                //si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
                //pasa a la posición (x-1,y)
                //orientación = 0, trata de ir por bit 1
                if ComprobarPosicionCaminoHabitacion_489B(PosicionDE: ElementoActualPilaDE - 1, PunteroTablaConexionesHabitacionesIX: PunteroTablaConexionesHabitacionesIX - 1, MascaraBusquedaHabitacion_48A4: MascaraBusquedaHabitacion_48A4, OrientacionSalidaC: 1, OrientacionCaminoB: 0) {
                    ElementoActualPilaDE = ElementoActualPilaDE - 1
                    BuscarHabitacion_4830 = true
                    return BuscarHabitacion_4830
                }
                //488c
                //comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
                //si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
                //pasa a la posición (x,y+1)
                //orientación = 1, trata de ir por bit 2
                if ComprobarPosicionCaminoHabitacion_489B(PosicionDE: ElementoActualPilaDE + 0x100, PunteroTablaConexionesHabitacionesIX: PunteroTablaConexionesHabitacionesIX + 16, MascaraBusquedaHabitacion_48A4: MascaraBusquedaHabitacion_48A4, OrientacionSalidaC: 2, OrientacionCaminoB: 1) {
                    ElementoActualPilaDE = ElementoActualPilaDE + 0x100
                    BuscarHabitacion_4830 = true
                    return BuscarHabitacion_4830
                }
            }
        }
        return BuscarHabitacion_4830
    }

    public func BuscarHabitacion_4826( _ MascaraBusquedaHabitacion_48A4:UInt8, _ PunteroPilaHL: inout Int, _ ValorPilaDE: inout Int) -> Bool {
        //busca la pantalla indicada en 0x2db4 empezando en la posición indicada en 0x2db2
        var PunteroTablaConexionesHabitacionesIX:Int
        //dada la la pantalla que se busca en hl, indexa en la tabla de la planta y devuelve la entrada en ix
        PunteroTablaConexionesHabitacionesIX = LeerTablaPlantas_48B5(PosicionDestino_2DB4)
        //marca la pantalla buscada como el destino dentro de la planta
        SetBitArray(&TablaConexionesHabitaciones_05CD, PunteroTablaConexionesHabitacionesIX - 0x05CD, 6)
        //busca la pantalla indicada que cumpla una máscara que se especifica en 0x48a4, iniciando la búsqueda en la posición indicada en 0x2db2
        return BuscarHabitacion_4830(MascaraBusquedaHabitacion_48A4, &PunteroPilaHL, &ValorPilaDE)
    }

    public func EsDistanciaPequeña_0C75(Coordenada1A:UInt8, Coordenada2C:UInt8, Distancia: inout UInt8) -> Bool {
        //calcula la distancia entre la parte más significativa de las posiciones a y c, e indica si es >= 2
        //en distancia devuelve el valor calculado
        //deja en el nibble inferior de c la parte de la posición más significativa
        var EsDistanciaPequeña_0C75:Bool
        var Coordenada1A:UInt8 = Coordenada1A
        var Coordenada2C:UInt8 = Coordenada2C
        Coordenada2C = Coordenada2C >> 4
        //deja en el nibble inferior de a la parte de la posición más significativa
        Coordenada1A = Coordenada1A >> 4
        //0C85
        Distancia = Z80Inc(Z80Sub(Coordenada1A, Coordenada2C))
        if Distancia <= 2 && Distancia >= 0 { //si a = 0, 1 ó 2, CF = 1. Es decir, si la distancia era -1, 0 ó 1
            EsDistanciaPequeña_0C75 = true
        } else {
            EsDistanciaPequeña_0C75 = false
        }
        return EsDistanciaPequeña_0C75
    }

    public func EscribirAlturaPuertaBufferAlturas_0E19( _ AlturaPuertaA:UInt8,  _ PunteroDatosIY:Int) {
        //modifica el buffer de alturas con la altura de la puerta
        var PunteroBufferAlturasIX:Int=0
        var DeltaBuffer:Int=0
        //lee en bc un valor relacionado con el desplazamiento de la puerta en el buffer de alturas
        //si el objeto no es visible, sale. En otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
        if !LeerDesplazamientoPuerta_0E2C(&PunteroBufferAlturasIX, PunteroDatosIY, &DeltaBuffer) { return }
        //marca la altura de esta posición del buffer de altura
        EscribirByteBufferAlturas(PunteroBufferAlturasIX, AlturaPuertaA)
        //marca la altura de la siguiente posición del buffer de alturas
        EscribirByteBufferAlturas(PunteroBufferAlturasIX + DeltaBuffer, AlturaPuertaA)
        //marca la altura de la siguiente posición del buffer de alturas
        EscribirByteBufferAlturas(PunteroBufferAlturasIX + 2 * DeltaBuffer, AlturaPuertaA)
    }

    public func RestaurarBufferAlturas_0B76() {
        //restaura el buffer de alturas de la pantalla actual
        PunteroBufferAlturas_2D8A = 0x01C0
        //0B7E
        //restaura los mínimos valores visibles de pantalla a los valores del personaje que sigue la cámara
        CalcularMinimosVisibles_0B8F(0x2D73)
        //fija la altura base de la planta con la altura del personaje al que sigue la cámara
        //y lo graba en el motor
        AlturaBasePlantaActual_2DBA = PosicionZPersonajeActual_2D77
    }

    public func ReorientarPersonaje_0A58( _ PunteroTablaPosicionesAlternativasIX:Int, _ PersonajeIY:Int) {
        //genera los comandos para obtener la orientación indicada en la posición alternativa
        var OrientacionActual:UInt8
        var OrientacionRequerida:UInt8
        //lee la altura y la orientación de la posición de destino
        OrientacionRequerida = TablaPosicionesAlternativas_0593[PunteroTablaPosicionesAlternativasIX + 2 - 0x0593]
        //se queda con la orientación en los 2 bits menos significativos
        OrientacionRequerida = OrientacionRequerida >> 6
        //0A5F
        //lee la orientación del personaje que busca. si las orientaciones son iguales, sale
        OrientacionActual = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036]
        if OrientacionActual == OrientacionRequerida { return }
        //0A65
        //fija la primera posición del buffer de comandos
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
        //escribe unos comandos para cambiar la orientación del personaje
        GenerarComandosOrientacionPersonaje_47C3(PersonajeIY: PersonajeIY, ActualA: OrientacionActual, RequeridaC: &OrientacionRequerida)
        //escribe b bits del comando que se le pasa en hl del personaje pasado en iy
        EscribirComando_0CE9(PersonajeIY, 0x1000, 0x0C)
        //0a73
        //fija la primera posición del buffer de comandos
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
    }

    public func BuscarCamino_0B0E(PersonajeIY:Int, Rutina4429:Bool) -> Bool {
        //busca la ruta desde la posición del personaje a lo grabado en 0x2db4-0x2db5
        //Rutina4429=true, llama a la función de búsqueda 4429, y convierte a =0B0E en 0AFA
        var BuscarCamino_0B0E:Bool
        var PersonajeX:UInt8
        var PersonajeY:UInt8
        var PunteroPilaHL:Int=0
        var PosicionAlternativaX:UInt8
        var PosicionAlternativaY:UInt8
        BuscarCamino_0B0E = false
        while true {
            //obtiene la posición del personaje
            PersonajeY = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
            PersonajeX = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036]
            //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran
            DeterminarPosicionCentral_279B(&PersonajeX, &PersonajeY)
            //pone el origen de la búsqueda
            PosicionOrigen_2DB2 = Int(PersonajeY) << 8 | Int(PersonajeX)
            //0b1a
            //rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que tiene puesto el bit 6
            if !Rutina4429 {
                //rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que tiene puesto el bit 6
                BuscarCamino_4435(&PunteroPilaHL)
            } else {
                //rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5 y las que tengan el bit 6 a 1
                BuscarCamino_4429(&PunteroPilaHL)
            }
            if ResultadoBusqueda_2DB6 == 0 { //si no se encontró un camino
                //0b26
                //aquí llega si no se encontró un camino
                //avanza el puntero a la siguiente alternativa
                PunteroAlternativaActual_05A3 = PunteroAlternativaActual_05A3 + 3
                if TablaPosicionesAlternativas_0593[PunteroAlternativaActual_05A3 - 0x0593] != 0xFF { //si no se han probado todas las alternativas
                    //0B3B
                    //elimina todos los rastros de la búsqueda del buffer de alturas
                    LimpiarRastrosBusquedaBufferAlturas_0BAE()
                    //obtiene la posición de la siguiente alternativa
                    PosicionAlternativaX = TablaPosicionesAlternativas_0593[PunteroAlternativaActual_05A3 - 0x0593]
                    PosicionAlternativaY = TablaPosicionesAlternativas_0593[PunteroAlternativaActual_05A3 + 1 - 0x0593]
                    ResultadoBusqueda_2DB6 = 0xFD //indica que los personajes están en la misma habitación
                    //0B49
                    //si la posición de destino de la alternativa es la misma que la del personaje, genera los comandos para obtener la orientación correcta
                    if TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036] == PosicionAlternativaX &&
                            TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036] == PosicionAlternativaY {
                        ReorientarPersonaje_0A58(PunteroAlternativaActual_05A3, PersonajeIY)
                        //0B66
                        RestaurarBufferAlturas_0B76()
                        return BuscarCamino_0B0E
                    }
                    //0B5A
                    ResultadoBusqueda_2DB6 = 0 //indica que no se ha encontrado un camino
                    //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
                    DeterminarPosicionCentral_279B(&PosicionAlternativaX, &PosicionAlternativaY)
                    //modifica la posición a la que debe ir el personaje
                    PosicionDestino_2DB4 = Int(PosicionAlternativaY) << 8 | Int(PosicionAlternativaX)
                } else { //si se han probado todas las alternativas
                    //0B66
                    RestaurarBufferAlturas_0B76()
                    return BuscarCamino_0B0E
                }
            } else { //aquí llega si se encontró un camino
                //0B6B
                //indica que se ha encontrado un camino en esta iteración del bucle principal
                CaminoEncontrado_2DA9 = true
                //elimina todos los rastros de la búsqueda del buffer de alturas
                LimpiarRastrosBusquedaBufferAlturas_0BAE()
                //0B73
                //genera todos los comandos para ir desde el origen al destino
                GenerarComandos_47E6(PersonajeIY: PersonajeIY, OrientacionNuevaC: 0, NumeroRutina: 0x4660, PunteroPilaCaminoHL: PunteroPilaHL)
                //restaura el buffer de alturas de la pantalla actual
                PunteroBufferAlturas_2D8A = 0x1C0
                //restaura los mínimos valores visibles de pantalla a los valores del personaje que sigue la cámara
                CalcularMinimosVisibles_0B8F(0x2D73)
                //fija la altura base de la planta con la altura del personaje y los graba en el motor
                AlturaBasePlantaActual_2DBA = PosicionZPersonajeActual_2D77
                //0B8D
                BuscarCamino_0B0E = true
                return BuscarCamino_0B0E
            }
        }
        return BuscarCamino_0B0E
    }

    public func MarcarSalidaHabitacion0CA0(PunteroBufferAlturasBC:Int, IncrementoDE:Int) {
        //marca como punto de destino los 16 puntos indicados en bc, con el incremento de
        var Contador:UInt8
        var nose:Int
        for Contador in 0...15 { //16 posiciones
            SetBitBufferAlturas(PunteroBufferAlturasBC + PunteroBufferAlturas_2D8A + Contador * IncrementoDE, 6)
            nose = PunteroBufferAlturasBC + PunteroBufferAlturas_2D8A + Contador * IncrementoDE
        }
    }

    public func BuscarHabitacionDerecha_0CAC() {
        //marca como punto de destino cualquiera que vaya a la pantalla de la derecha
        //salta a marcar las posiciones con incremento de +24
        MarcarSalidaHabitacion0CA0(PunteroBufferAlturasBC: 0x74, IncrementoDE: 0x18) //bc = 116 (X = 20, Y = 4)
    }

    public func BuscarHabitacionArriba_0C9A() {
        //marca como punto de destino cualquiera que vaya a la pantalla de arriba
        //salta a marcar las posiciones con incremento de +1
        MarcarSalidaHabitacion0CA0(PunteroBufferAlturasBC: 0x4C, IncrementoDE: 1) //bc = 76 (X = 4, Y = 3)
    }

    public func BuscarHabitacionIzquierda_0CB4() {
        //marca como punto de destino cualquiera que vaya a la pantalla de la izquierda
        //salta a marcar las posiciones con incremento de +24
        MarcarSalidaHabitacion0CA0(PunteroBufferAlturasBC: 0x63, IncrementoDE: 0x18) //bc = 99 (X = 3, Y = 4)
    }

    public func BuscarHabitacionAbajo_0CB9() {
        //marca como punto de destino cualquiera que vaya a la pantalla de abajo
        //salta a marcar las posiciones con incremento de +1
        MarcarSalidaHabitacion0CA0(PunteroBufferAlturasBC: 0x01E4, IncrementoDE: 1) //bc = 484 (X = 4, Y = 20)
    }

    public func Leer_PosicionPersonaje_0A8E( _ PersonajeIY:Int) -> Int {
        //devuelve en la parte menos significativa de hl la parte más significativa de la posición del personaje que se le pasa en iy
        var PosicionXL:UInt8
        var PosicionYH:UInt8
        //obtiene la posición x del personaje
        PosicionXL = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036]
        //l = parte más significativa de la posición x del personaje en el nibble inferior
        PosicionXL = (PosicionXL >> 4) & 0x0F
        //obtiene la posición y del personaje
        PosicionYH = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
        //h = parte más significativa de la posición y del personaje en el nibble superior
        PosicionYH = (PosicionYH >> 4) & 0x0F
        return Int(PosicionYH) << 8 | Int(PosicionXL)
    }

    public func LimpiarTablaConexionesHabitaciones_0AA3() {
        //limpia los bits usados para la búsqueda de recorridos en la tabla deconexionesentre habitaciones
        //var Contador:Int
        for Contador in 0..<TablaConexionesHabitaciones_05CD.count { //0x130 bytes
            TablaConexionesHabitaciones_05CD[Contador] = TablaConexionesHabitaciones_05CD[Contador] & 0x3F
        }
    }

    public func RellenarAlturasPersonaje_0BBF( _ PersonajeIY:Int) {
        //rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
        //que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
        var PosicionXGuillermo:UInt8
        var PosicionYGuillermo:UInt8
        var PosicionXPersonaje:UInt8
        var PosicionYPersonaje:UInt8
        var AlturaGuillermo:UInt8
        var AlturaPersonaje:UInt8=0
        var GuillermoLejos:Bool=false
        var PersonajesMismaPlanta:Bool=false
        var MinimaXB:UInt8=0
        var MinimaYC:UInt8=0
        var NumeroPersonajes:UInt8
        var PunteroDatosPersonajesHL:Int //puntero a TablaDatosPersonajes_2BAE
        var Contador:UInt8
        var PunteroDatosPersonajeDE:Int
        var PunteroDatosPuertaIY:Int
        PunteroBufferAlturas_2D8A = 0x96F4 //cambia el puntero al buffer de alturas de la pantalla actual
        //rellena el buffer de alturas con los datos recortados para la pantalla en la que está el personaje indicado por iy
        RellenarBufferAlturas_2D22(PersonajeIY)
        PosicionXGuillermo = TablaCaracteristicasPersonajes_3036[2] //obtiene la posición x de guillermo
        PosicionXPersonaje = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036] //obtiene la posición x del personaje
        PosicionYPersonaje = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036] //obtiene la posición y del personaje
        //0bcf
        if EsDistanciaPequeña_0C75(Coordenada1A: PosicionXGuillermo, Coordenada2C: PosicionXPersonaje, Distancia: &MinimaXB) {
            PosicionYGuillermo = TablaCaracteristicasPersonajes_3036[3] //obtiene la posición y de guillermo
            //0BDB
            if EsDistanciaPequeña_0C75(Coordenada1A: PosicionYGuillermo, Coordenada2C: PosicionYPersonaje, Distancia: &MinimaYC) {
                //0BE1
                AlturaPersonaje = TablaCaracteristicasPersonajes_3036[PersonajeIY + 4 - 0x3036] //obtiene la altura del personaje
                AlturaGuillermo = TablaCaracteristicasPersonajes_3036[4] //obtiene la altura de guillermo
                //0BF2
                if LeerAlturaBasePlanta_2473(AlturaPersonaje) == LeerAlturaBasePlanta_2473(AlturaGuillermo) {
                    PersonajesMismaPlanta = true
                }
            } else {
                GuillermoLejos = true
            }
        } else {
            GuillermoLejos = true
        }
        if GuillermoLejos || !PersonajesMismaPlanta {
            //mismo proceso que antes, pero entre el personaje actual y el personaje al que
            //sigue la cámara
            //0BF4
            //aquí llega si la distancia entre guillermo y el personaje es >= 2 en alguna coordenada, o no están en la misma planta
            //si la distancia en x es >= 2, sale
            if !EsDistanciaPequeña_0C75(Coordenada1A: PosicionXPersonajeActual_2D75, Coordenada2C: PosicionXPersonaje, Distancia: &MinimaXB) {
                //cuando guillermo no está en la escena, no se tiene en cuenta la posición de los
                //personajes en el mapa de alturas, ni el estado de las puertas, lo que
                //facilita el cálculo de caminos
                return
            }
            //0BFF
            //si la distancia en y es >= 2, salta
            if !EsDistanciaPequeña_0C75(Coordenada1A: PosicionYPersonajeActual_2D76, Coordenada2C: PosicionYPersonaje, Distancia: &MinimaYC) {
                //cuando guillermo no está en la escena, no se tiene en cuenta la posición de los
                //personajes en el mapa de alturas, ni el estado de las puertas, lo que
                //facilita el cálculo de caminos
                return
            }
            //0C0A
            //si el personaje no está en la misma planta que el personaje la que sigue la cámara, sale
            if LeerAlturaBasePlanta_2473(PosicionZPersonajeActual_2D77) != AlturaPersonaje {
                //cuando guillermo no está en la escena, no se tiene en cuenta la posición de los
                //personajes en el mapa de alturas, ni el estado de las puertas, lo que
                //facilita el cálculo de caminos
                return
            }
        }
        //0C17
        //aquí llega si al personaje y a guillermo les separa poca distancia en la misma planta, o al personaje y a quien muestra la cámara les separa poca distancia en la misma planta
        //bc = distancia en x y en y del personaje que estaba cerca
        //apunta a una dirección que contiene un puntero a los datos de posición de adso
        PunteroDatosPersonajesHL = 0x2BBA
        NumeroPersonajes = 5 //comprueba 5 personajes
        if MinimaXB == 1 { //distancia en x + 1=1 -> misma habitación en x que guillermo
            //0C25
            if MinimaYC == 1 { //distancia en y + 1=1 -> misma habitación que guillermo
                //0C2A
                //si el personaje que estaba cerca está en lamisma habitación que guillermo, empieza a dibujar en guillermo
                //apunta a una dirección que contiene un puntero a los datos de posición guillermo
                PunteroDatosPersonajesHL = 0x2BB0
                NumeroPersonajes = NumeroPersonajes + 1 //comprueba 6 personajes
            }
        }
        //0C2E
        for Contador in 0..<NumeroPersonajes {
            //de = dirección de los datos de posición del personaje a comprobar
            PunteroDatosPersonajeDE = Leer16(TablaPunterosPersonajes_2BAE, PunteroDatosPersonajesHL - 0x2BAE)
            if PunteroDatosPersonajeDE != PersonajeIY { //si no coincide con la del personaje
                //0C3E
                //aquí llega si el personaje que se le ha pasado a la rutina no es el que se está comprobando
                //si la posición del sprite es central y la altura está bien, rellena en el buffer de alturas las posiciones ocupadas por el personaje
                RellenarBufferAlturasPersonaje_28EF(PunteroDatosPersonajeDE, 0x10)
            }
            //0c48
            PunteroDatosPersonajesHL = PunteroDatosPersonajesHL + 10 //avanza al siguiente personaje
        }
        //0C4F
        PunteroDatosPuertaIY = 0x2FE4 //iy apunta a los datos de las puertas
        while true {
            if LeerBitArray(TablaDatosPuertas_2FE4, PunteroDatosPuertaIY + 1 - 0x2FE4, 6) {
                //si la puerta está abierta, marca su posición en el buffer de alturas
                //0x0f = altura en el buffer de alturas de una puerta cerrada
                EscribirAlturaPuertaBufferAlturas_0E19(0x0F, PunteroDatosPuertaIY)
            }
            //0C5F
            //avanza a la siguiente puerta
            PunteroDatosPuertaIY = PunteroDatosPuertaIY + 5 //cada entrada es de 5 bytes
            if TablaDatosPuertas_2FE4[PunteroDatosPuertaIY - 0x2FE4] == 0xFF { break }
            //repite hasta que se completen las puertas
        }
        //0C6B
        //si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa del buffer de alturas
        RellenarBufferAlturasPersonaje_28EF(PersonajeIY, 0)
    }

    public func LimitarAlternativasCamino_0F88() {
        //limita las alternativas de caminos a probar a la primera opción
        PunteroAlternativaActual_05A3 = 0x0593 //inicia el puntero al buffer de las alternativas
        //marca el final del buffer después de la primera entrada
        TablaPosicionesAlternativas_0593[3] = 0xFF
    }

    public func BuscarCaminoHabitacion_0AC4(PersonajeIY:Int, PantallaDestinoHL:Int, MascaraBusquedaHabitacion_48A4:UInt8) -> Bool {
        //busca un camino para ir de la habitación actual a la habitación destino. Si lo encuentra, recrea la habitación y genera la ruta para llegar a donde se quiere
        //hl = pantalla de destino
        //iy = datos de posición de personaje que quiere ir a la posición de destino
        var BuscarCaminoHabitacion_0AC4:Bool
        var PunteroPilaHL:Int=0
        var OrientacionA:UInt8
        var PunteroDestinoHL:Int
        var ValorPilaDE:Int=0
        var Rutina:Int //dirección de la rutina a llamar según la pantalla por la que hay que salir
        BuscarCaminoHabitacion_0AC4 = false
        PosicionOrigen_2DB2 = PantallaDestinoHL //guarda la pantalla de destino
        PosicionDestino_2DB4 = Leer_PosicionPersonaje_0A8E(PersonajeIY) //guarda la pantalla de origen
        //busca un camino para ir de la habitación actual a la habitación destino
        BuscarHabitacion_4826(MascaraBusquedaHabitacion_48A4, &PunteroPilaHL, &ValorPilaDE)
        LimpiarTablaConexionesHabitaciones_0AA3()
        if ResultadoBusqueda_2DB6 == 0 { return BuscarCaminoHabitacion_0AC4 } //si no se ha encontrado el camino, sale
        //0AD8
        //obtiene la orientación que se ha de seguir para llegar al camino
        OrientacionA = TablaComandos_440C[0x4418 - 0x440C]
        //hl apunta a una tabla auxiliar para marcar las posiciones a las que debe ir el personaje
        PunteroDestinoHL = 0x0C8A + 4 * Int(OrientacionA) //cada entrada ocupa 4 bytes
        //0AE4
        Rutina = Leer16(TablaDestinos_0C8A, PunteroDestinoHL - 0x0C8A) //indexa en la tabla
        PunteroDestinoHL = PunteroDestinoHL + 2
        //0aed
        LimitarAlternativasCamino_0F88() //limita las opciones a probar a la primera opción
        //guarda la posición de destino
        PosicionDestino_2DB4 = Leer16(TablaDestinos_0C8A, PunteroDestinoHL - 0x0C8A)
        //rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
        //que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
        RellenarAlturasPersonaje_0BBF(PersonajeIY)
        //rutina a llamar según la orientación a seguir
        //esta rutina pone el bit 6 de las posiciones del buffer de alturas de la orientación que se debe seguir
        //para pasar a la pantalla según calculo el buscador de caminos
        switch Rutina {
            case 0x0CAC:
                BuscarHabitacionDerecha_0CAC()
            case 0x0C9A:
                BuscarHabitacionArriba_0C9A()
            case 0x0CB4:
                BuscarHabitacionIzquierda_0CB4()
            case 0x0CB9:
                BuscarHabitacionAbajo_0CB9()
            default:
                break
        }
        //0afd
        BuscarCaminoHabitacion_0AC4 = BuscarCamino_0B0E(PersonajeIY: PersonajeIY, Rutina4429: true)
        return BuscarCaminoHabitacion_0AC4
    }

    public func BuscarCaminoGeneral_098A( _ PersonajeIY:Int, _ PunteroPersonajeObjetoIX:Int) -> Bool {
        //algoritmo de alto nivel para la búsqueda de caminos entre 2 posiciones
        //iy apunta a los datos del personaje que busca a otro
        //ix apunta a la posición del personaje/objeto que se busca dentro de la tabla de alternativas
        var BuscarCaminoGeneral_098A:Bool
        var MascaraBusqueda:UInt8 //número de bit que marca el destino en el algoritmo de búsqueda
        var AlturaBaseOrigenE:UInt8 //altura base de la planta en la que está el personaje de origen
        var AlturaBaseDestinoB:UInt8 //altura base de la planta en la que está el personaje/objeto de destino
        var SubirOBajarC:UInt8 //c = indicador de si hay que subir o bajar planta 0x10=subir, 0x20=bajar
        var PosicionHabitacion:UInt8 //coordenadas de la habitación buscada
        var PunteroTablaConexionesHabitacionesDE:Int
        var PunteroPilaHL:Int=0
        var ValorPilaDE:Int=0
        var Escalera:UInt8 //valor a buscar en el buffer de alturas cuando se busca un punto para subir o bajar
        BuscarCaminoGeneral_098A = false
        ResultadoBusqueda_2DB6 = 0xFE //indica que no se ha podido buscar un camino
        //si está en la mitad de la animación, sale
        if (ContadorAnimacionGuillermo_0990 & 1) != 0 { return BuscarCaminoGeneral_098A }
        //si en esta iteración ya se ha encontrado un camino, sale (sólo se busca un camino por iteración)
        if CaminoEncontrado_2DA9 != false { return BuscarCaminoGeneral_098A }
        //0999
        MascaraBusqueda = 6 //indica que hay que buscar una posición con el bit 6 en el algoritmo de búsqueda de caminos
        ResultadoBusqueda_2DB6 = 0 //indica que de momento no se ha encontrado un camino
        //obtiene la altura del personaje que busca a otro
        AlturaBaseOrigenE = LeerAlturaBasePlanta_2473(TablaCaracteristicasPersonajes_3036[PersonajeIY + 4 - 0x3036])
        //09A9
        //obtiene la altura base dela planta en la que está el personaje/objeto de destino
        AlturaBaseDestinoB = LeerAlturaBasePlanta_2473(LeerBytePersonajeObjeto(PunteroPersonajeObjetoIX + 2) & 0x3F)
        //09B1
        switch AlturaBaseOrigenE {
            case 0: //si el personaje que busca a otro está en la planta baja
                PunteroTablaConexiones_440A = 0x05CD //apunta a tabla con las conexiones de la planta baja
            case 0x0B: //si el personaje que busca a otro está en la primera planta
                PunteroTablaConexiones_440A = 0x067D //apunta a tabla con las conexiones de la primera baja
            default:
                PunteroTablaConexiones_440A = 0x0685 //apunta a tabla con las conexiones de la segunda baja
        }
        //09C5
        if AlturaBaseOrigenE != AlturaBaseDestinoB {
            //09C8
            //aquí llega si los personajes no están en la misma planta
            if AlturaBaseOrigenE < AlturaBaseDestinoB {
                SubirOBajarC = 0x10
            } else {
                SubirOBajarC = 0x20
            }
            //09CE
            //obtiene la posición y del personaje que busca a otro
            PosicionHabitacion = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
            //se queda con la parte más significativa de la posición y
            PosicionHabitacion = PosicionHabitacion & 0xF0
            //se queda con la parte más significativa de la posición x en el nibble inferior
            //combina las posiciones para hallar en que habitación de la planta está
            PosicionHabitacion = PosicionHabitacion | ((TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036] >> 4) & 0x0F)
            //indexa en la tabla de la planta
            PunteroTablaConexionesHabitacionesDE = Int(PosicionHabitacion) + PunteroTablaConexiones_440A
            //09E2
            if (TablaConexionesHabitaciones_05CD[PunteroTablaConexionesHabitacionesDE - 0x05CD] & SubirOBajarC) == 0 {
                //09e7
                //aquí llega si desde la habitación actual no se puede ni subir ni bajar
                if SubirOBajarC == 0x10 {
                    MascaraBusqueda = 4 //indica que hay que buscar una posición con el bit 4 en el algoritmo de búsqueda de caminos
                } else {
                    MascaraBusqueda = 5 //indica que hay que buscar una posición con el bit 5 en el algoritmo de búsqueda de caminos
                }
                //09f2
                //guarda la posición más significativa del personaje que busca a otro
                PosicionOrigen_2DB2 = Leer_PosicionPersonaje_0A8E(PersonajeIY)
                //busca la orientación que hay que seguir para encontrar las escaleras más próximas en esta planta
                BuscarHabitacion_4830(MascaraBusqueda, &PunteroPilaHL, &ValorPilaDE)
                //limpia los bits usados para la búsqueda de recorridos en la tabla actual
                LimpiarTablaConexionesHabitaciones_0AA3()
                //restaura la instrucción para indicar que tiene que buscar el bit 6
                MascaraBusqueda = 6
                if ResultadoBusqueda_2DB6 == 0 { return BuscarCaminoGeneral_098A } //si no se encontró ningún camino, sale
                //0A08
                //aquí llega si desde la habitación actual no se puede ni subir ni bajar, pero ha encontrado un camino a una habitación de la planta con escaleras
                BuscarCaminoGeneral_098A = BuscarCaminoHabitacion_0AC4(PersonajeIY: PersonajeIY, PantallaDestinoHL: ValorPilaDE, MascaraBusquedaHabitacion_48A4: MascaraBusqueda)
                return BuscarCaminoGeneral_098A
            }
            //0a0c
            //aquí llega si desde la habitación actual se puede subir o bajar
            //si había que subir, a = 0x0d. si había que bajar a = 0x01;
            if SubirOBajarC == 0x10 {
                Escalera = 0x0D
            } else {
                Escalera = 1
            }
            //rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
            //que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
            RellenarAlturasPersonaje_0BBF(PersonajeIY)
            //0A1A
            for contador in 0..<TablaBufferAlturas_96F4.count {
                if TablaBufferAlturas_96F4[contador] == Escalera {
                    //marca la posición como un objetivo a buscar
                    SetBitArray(&TablaBufferAlturas_96F4, contador, 6)
                }

            }
            //0A2D
            PosicionDestino_2DB4 = 0 //pone a 0 la posición de destino
            LimitarAlternativasCamino_0F88() //limita las opciones a probar a la primera opción
            //busca la ruta y pone las instrucciones para llegar a las escaleras
            BuscarCaminoGeneral_098A = BuscarCamino_0B0E(PersonajeIY: PersonajeIY, Rutina4429: true)
            return BuscarCaminoGeneral_098A
        }
        //0A37
        //aqui llega buscando un camino entre 2 personajes que están en la misma planta
        //iy apunta a los datos del personaje que busca a otro
        //ix apunta a los datos del personaje buscado
        var OrigenX:UInt8
        var OrigenY:UInt8
        var OrigenOrientacion:UInt8
        var DestinoX:UInt8
        var DestinoY:UInt8
        var DestinoZ:UInt8
        var DestinoOrientacion:UInt8
        DestinoX = LeerBytePersonajeObjeto(PunteroPersonajeObjetoIX)
        DestinoY = LeerBytePersonajeObjeto(PunteroPersonajeObjetoIX + 1)
        OrigenX = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036]
        OrigenY = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
        if (DestinoX & 0xF0) == (OrigenX & 0xF0) { //si el número de habitación en x coincide
            //0A46
            if (DestinoY & 0xF0) == (OrigenY & 0xF0) { //si el número de habitación en y coincide
                //0A4F
                //aqui llega si están en la misma habitación
                //indica origen y destino están en la misma habitación
                ResultadoBusqueda_2DB6 = 0xFD
                if OrigenX == DestinoX && OrigenY == DestinoY {
                    //0a58
                    //aquí llega si origen y destino son la misma posicion. sólo queda comprobar la orientación
                    //lee la altura y la orientación de la posición de destino
                    DestinoZ = LeerBytePersonajeObjeto(PunteroPersonajeObjetoIX + 2)
                    //se queda con la orientación en los 2 bits menos significativos
                    DestinoOrientacion = DestinoZ >> 6
                    //lee la orientación del personaje que busca
                    OrigenOrientacion = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036]
                    //si las orientaciones son iguales, sale
                    if OrigenOrientacion == DestinoOrientacion { return BuscarCaminoGeneral_098A }
                    //0A65
                    //0a73
                    //fija la primera posición del buffer de comandos
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
                    //0A68
                    //escribe unos comandos para cambiar la orientación del personaje
                    GenerarComandosOrientacionPersonaje_47C3(PersonajeIY: PersonajeIY, ActualA: OrigenOrientacion, RequeridaC: &DestinoOrientacion)
                    //escribe b bits del comando que se le pasa en hl del personaje pasado en iy
                    EscribirComando_0CE9(PersonajeIY, 0x1000, 0x0C)
                    //0a73
                    //fija la primera posición del buffer de comandos
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0
                    TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
                    return BuscarCaminoGeneral_098A
                } else {
                    //0a7c
                    //llega cuando las 2 posiciones están dentro de la misma habitación pero en distinto lugar
                    ResultadoBusqueda_2DB6 = 0 //indica que la búsqueda ha fallado
                    //rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
                    //que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
                    RellenarAlturasPersonaje_0BBF(PersonajeIY)
                    //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
                    DeterminarPosicionCentral_279B(&DestinoX, &DestinoY)
                    PosicionDestino_2DB4 = (Int(DestinoY) << 8) | Int(DestinoX)
                    //rutina llamada para buscar la ruta desde la posición del personaje a lo grabado en 0x2db4-0x2db5
                    BuscarCaminoGeneral_098A = BuscarCamino_0B0E(PersonajeIY: PersonajeIY, Rutina4429: false)
                    return BuscarCaminoGeneral_098A
                }
                return BuscarCaminoGeneral_098A
            }
        }
        //0AB4
        //se queda con el nibble superior de las coordenadas, para formar el número de habitación
        DestinoY = DestinoY >> 4
        DestinoX = DestinoX >> 4
        BuscarCaminoGeneral_098A = BuscarCaminoHabitacion_0AC4(PersonajeIY: PersonajeIY, PantallaDestinoHL: (Int(DestinoY) << 8) | Int(DestinoX), MascaraBusquedaHabitacion_48A4: MascaraBusqueda)
        return BuscarCaminoGeneral_098A
    }

    public func CheckCamino1() -> UInt8 {
        //camino original de severino desde el punto de inicio hasta su habitación
        //0x3036-0x3044    características de guillermo
        //0x3045-0x3053    características de adso
        //0x3054-0x3062    características de malaquías
        //0x3063-0x3071    características del abad
        //0x3072-0x3080    características de berengario/bernardo gui/encapuchado/jorge
        //0x3081-0x308f    características de severino/jorge
        var CheckCamino1:UInt8 = 0
        //guillermo
        TablaCaracteristicasPersonajes_3036[0x3036 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x88
        TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0xA8
        TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3036 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3036 + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 10 - 0x3036] = 0xFD
        TablaCaracteristicasPersonajes_3036[0x3036 + 11 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 12 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 13 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 14 - 0x3036] = 0x10
        //adso
        TablaCaracteristicasPersonajes_3036[0x3045 + 0 - 0x3036] = 2
        TablaCaracteristicasPersonajes_3036[0x3045 + 1 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036] = 0x86
        TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036] = 0xA9
        TablaCaracteristicasPersonajes_3036[0x3045 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3045 + 8 - 0x3036] = 0xE0
        TablaCaracteristicasPersonajes_3036[0x3045 + 9 - 0x3036] = 4
        TablaCaracteristicasPersonajes_3036[0x3045 + 10 - 0x3036] = 0x10
        TablaCaracteristicasPersonajes_3036[0x3045 + 11 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 12 - 0x3036] = 0xC0
        TablaCaracteristicasPersonajes_3036[0x3045 + 13 - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3045 + 14 - 0x3036] = 0x20
        //malaquías
        TablaCaracteristicasPersonajes_3036[0x3054 + 0 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3054 + 1 - 0x3036] = 3
        TablaCaracteristicasPersonajes_3036[0x3054 + 2 - 0x3036] = 0x26
        TablaCaracteristicasPersonajes_3036[0x3054 + 3 - 0x3036] = 0x27
        TablaCaracteristicasPersonajes_3036[0x3054 + 4 - 0x3036] = 0x0F
        TablaCaracteristicasPersonajes_3036[0x3054 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3054 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3054 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3054 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3054 + 9 - 0x3036] = 4
        TablaCaracteristicasPersonajes_3036[0x3054 + 0x0A - 0x3036] = 0xF0
        TablaCaracteristicasPersonajes_3036[0x3054 + 0x0B - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3054 + 0x0C - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3054 + 0x0D - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3054 + 0x0E - 0x3036] = 0x10
        //abad
        TablaCaracteristicasPersonajes_3036[0x3063 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3063 + 1 - 0x3036] = 3
        TablaCaracteristicasPersonajes_3036[0x3063 + 2 - 0x3036] = 0x88
        TablaCaracteristicasPersonajes_3036[0x3063 + 3 - 0x3036] = 0x84
        TablaCaracteristicasPersonajes_3036[0x3063 + 4 - 0x3036] = 0x02
        TablaCaracteristicasPersonajes_3036[0x3063 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3063 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3063 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3063 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3063 + 9 - 0x3036] = 3
        TablaCaracteristicasPersonajes_3036[0x3063 + 0x0A - 0x3036] = 0x10
        TablaCaracteristicasPersonajes_3036[0x3063 + 0x0B - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3063 + 0x0C - 0x3036] = 0x30
        TablaCaracteristicasPersonajes_3036[0x3063 + 0x0D - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3063 + 0x0E - 0x3036] = 0x10
        //berengario
        TablaCaracteristicasPersonajes_3036[0x3072 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3072 + 1 - 0x3036] = 3
        TablaCaracteristicasPersonajes_3036[0x3072 + 2 - 0x3036] = 0x28
        TablaCaracteristicasPersonajes_3036[0x3072 + 3 - 0x3036] = 0x48
        TablaCaracteristicasPersonajes_3036[0x3072 + 4 - 0x3036] = 0x0F
        TablaCaracteristicasPersonajes_3036[0x3072 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3072 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3072 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3072 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3072 + 9 - 0x3036] = 3
        TablaCaracteristicasPersonajes_3036[0x3072 + 0x0A - 0x3036] = 0xF8
        TablaCaracteristicasPersonajes_3036[0x3072 + 0x0B - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3072 + 0x0C - 0x3036] = 0x60
        TablaCaracteristicasPersonajes_3036[0x3072 + 0x0D - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3072 + 0x0E - 0x3036] = 0x10
        //severino
        TablaCaracteristicasPersonajes_3036[0x3081 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 1 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 2 - 0x3036] = 0xC8
        TablaCaracteristicasPersonajes_3036[0x3081 + 3 - 0x3036] = 0x28
        TablaCaracteristicasPersonajes_3036[0x3081 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3081 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3081 + 9 - 0x3036] = 0x84
        TablaCaracteristicasPersonajes_3036[0x3081 + 0x0A - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3081 + 0x0B - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3081 + 0x0C - 0x3036] = 0x90
        TablaCaracteristicasPersonajes_3036[0x3081 + 0x0D - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3081 + 0x0E - 0x3036] = 0x10

        TablaPosicionesAlternativas_0593[0] = 0x68
        TablaPosicionesAlternativas_0593[1] = 0x55
        TablaPosicionesAlternativas_0593[2] = 0x02
        TablaPosicionesAlternativas_0593[3] = 0x66
        TablaPosicionesAlternativas_0593[4] = 0x55
        TablaPosicionesAlternativas_0593[5] = 0x02
        TablaPosicionesAlternativas_0593[6] = 0x68
        TablaPosicionesAlternativas_0593[7] = 0x57
        TablaPosicionesAlternativas_0593[8] = 0x42
        TablaPosicionesAlternativas_0593[9] = 0x6A
        TablaPosicionesAlternativas_0593[10] = 0x55
        TablaPosicionesAlternativas_0593[11] = 0x82
        TablaPosicionesAlternativas_0593[12] = 0x68
        TablaPosicionesAlternativas_0593[13] = 0x53
        TablaPosicionesAlternativas_0593[14] = 0xC2

        CaminoEncontrado_2DA9 = false

        BuscarCaminoGeneral_098A(0x3081, 0x0593)
        if BufferComandosMonjes_A200[0x90] != 0x5F || BufferComandosMonjes_A200[0x91] != 0xC8 || BufferComandosMonjes_A200[0x92] != 0x40 { CheckCamino1 = 1 }//error

        return CheckCamino1
    }
/*
    public func CheckCamino2() -> UInt8 {
        //adso buscando la posición en la que está en ese momento. ojo, hay que parchear el original
        //para que se comporte así
        //guillermo
        TablaCaracteristicasPersonajes_3036[0x3036 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x86
        TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x9D
        TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3036 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3036 + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 10 - 0x3036] = 0xFD
        TablaCaracteristicasPersonajes_3036[0x3036 + 11 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 12 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 13 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 14 - 0x3036] = 0x10
        //adso
        TablaCaracteristicasPersonajes_3036[0x3045 + 0 - 0x3036] = 2
        TablaCaracteristicasPersonajes_3036[0x3045 + 1 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036] = 0x86
        TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036] = 0x9D
        TablaCaracteristicasPersonajes_3036[0x3045 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3045 + 8 - 0x3036] = 0xE0
        TablaCaracteristicasPersonajes_3036[0x3045 + 9 - 0x3036] = 0x85
        TablaCaracteristicasPersonajes_3036[0x3045 + 10 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 11 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 12 - 0x3036] = 0xC0
        TablaCaracteristicasPersonajes_3036[0x3045 + 13 - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3045 + 14 - 0x3036] = 0x20

        BuscarCaminoGeneral_098A(0x3045, 0x3038)

        If BufferComandosMonjes_A200[0xC0] <> 0x42 Or
            TablaCaracteristicasPersonajes_3036[0x3045 + 9 - 0x3036] <> 0 Or
            TablaCaracteristicasPersonajes_3036[0x3045 + 0xB - 0x3036] <> 0 Then CheckCamino2 = 1
    End Function

    public func CheckCamino3() -> UInt8 {
        //adso buscando una posición de la primera planta. ojo, hay que parchear el original
        //para que se comporte así
        //guillermo
        TablaCaracteristicasPersonajes_3036[0x3036 + 0 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036] = 0    //orientación
        TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] = 0x4C //x
        TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] = 0x6A //y
        TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] = 0x0F //z
        TablaCaracteristicasPersonajes_3036[0x3036 + 5 - 0x3036] = 0    //número de tiles
        TablaCaracteristicasPersonajes_3036[0x3036 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3036 + 8 - 0x3036] = 0xDE
        TablaCaracteristicasPersonajes_3036[0x3036 + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 10 - 0x3036] = 0xFD
        TablaCaracteristicasPersonajes_3036[0x3036 + 11 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 12 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 13 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3036 + 14 - 0x3036] = 0x10
        //adso
        TablaCaracteristicasPersonajes_3036[0x3045 + 0 - 0x3036] = 2
        TablaCaracteristicasPersonajes_3036[0x3045 + 1 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036] = 0x86
        TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036] = 0x9D
        TablaCaracteristicasPersonajes_3036[0x3045 + 4 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 5 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 6 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 7 - 0x3036] = 0xFE
        TablaCaracteristicasPersonajes_3036[0x3045 + 8 - 0x3036] = 0xE0
        TablaCaracteristicasPersonajes_3036[0x3045 + 9 - 0x3036] = 0x85
        TablaCaracteristicasPersonajes_3036[0x3045 + 10 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x3045 + 11 - 0x3036] = 1
        TablaCaracteristicasPersonajes_3036[0x3045 + 12 - 0x3036] = 0xC0
        TablaCaracteristicasPersonajes_3036[0x3045 + 13 - 0x3036] = 0xA2
        TablaCaracteristicasPersonajes_3036[0x3045 + 14 - 0x3036] = 0x20

        TablaConexionesHabitaciones_05CD(0x0602 - 0x05CD) = 0x0F
        BuscarCaminoGeneral_098A(0x3045, 0x3038)
        If BufferComandosMonjes_A200[0xC0] <> 0xFF Or
                BufferComandosMonjes_A200[0xC0 + 1] <> 0xF2 Or
                BufferComandosMonjes_A200[0xC0 + 2] <> 0x10 Then CheckCamino3 = 1

    End Function
*/
    public func DescartarMovimientosPensados_08BE(PersonajeIY:Int) {
        //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
        var PunteroComandosMonjesHL:Int
        //hl = dirección de datos de las acciones
        PunteroComandosMonjesHL = Leer16(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x0C - 0x3036)
        //escribe el comando para que ponga el bit 7,(9)
        Escribir16(&BufferComandosMonjes_A200, PunteroComandosMonjesHL - 0xA200, 0x0010)
        //pone a cero el contador de comandos pendientes y el índice de comandos
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
    }

    public func GenerarPropuestaMovimiento_07D2( _ OrientacionB:UInt8, _ PersonajeObjetoIX:Int, _ PunteroAlternativasIY: inout Int) {
        //dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
        //ix tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
        //iy apunta a una posición vacía del buffer para buscar caminos alternativos
        //b = orientación
        //tabla de desplazamientos según la orientación
        var TablaDesplazamientosOrientacion_05A5:[Int] = [2, 0, 0, -2, -2, 0, 0, 2]
        //05A5:     02 00 -> [+2 00]
        //       00 FE -> [00 -2]
        //       FE 00 -> [-2 00]
        //       00 02 -> [00 +2]
        var PunteroDesplazamientosOrientacion:UInt8
        var NuevaAlturaOrientacionC:UInt8
        var AntiguaAlturaOrientacion:UInt8
        var PosicionDestinoX:Int
        var PosicionDestinoY:Int
        var PunteroBufferAlturasIX:Int=0
        var DiferenciaAlturas:UInt8
        var PosicionCentral:Bool
        //ajusta la orientación para que esté entre las 4 válidas. cada entrada ocupa 2 bytes
        PunteroDesplazamientosOrientacion = (OrientacionB & 0x3) * 2
        //pone los 2 bits de la orientación como los 2 bits más significativos de a
        //invierte la orientación en x y en y
        NuevaAlturaOrientacionC = ((OrientacionB & 0x03) << 6) ^ 0x80
        //07E4
        //combina con la altura/orientación de destino con la actual y la guarda en c
        AntiguaAlturaOrientacion = LeerBytePersonajeObjeto(PersonajeObjetoIX + 4)
        NuevaAlturaOrientacionC = NuevaAlturaOrientacionC | AntiguaAlturaOrientacion
        //copia la altura/orientación de destino deseada al buffer
        TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 4 - 0x0593] = AntiguaAlturaOrientacion
        //07EE
        //obtiene la posición x del destino
        PosicionDestinoX = Int(LeerBytePersonajeObjeto(PersonajeObjetoIX + 2))
        PosicionDestinoX = PosicionDestinoX + TablaDesplazamientosOrientacion_05A5[Int(PunteroDesplazamientosOrientacion)]
        PunteroDesplazamientosOrientacion = PunteroDesplazamientosOrientacion + 1
        //copia la posición x de destino más un pequeño desplazamiento según la orientación en el buffer
        TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 2 - 0x0593] = UInt8(PosicionDestinoX)
        //07F6
        //obtiene la posición y del destino
        PosicionDestinoY = Int(LeerBytePersonajeObjeto(PersonajeObjetoIX + 3))
        PosicionDestinoY = PosicionDestinoY + TablaDesplazamientosOrientacion_05A5[Int(PunteroDesplazamientosOrientacion)]
        //copia la posición y de destino más un pequeño desplazamiento según la orientación en el buffer
        TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 3 - 0x0593] = UInt8(PosicionDestinoY)
        //07FD
        //llamado con iy = dirección de los datos de posición asociados al personaje/objeto
        //si la posición a la que ir no es una de las del centro de la pantalla que se muestra, CF=1
        //en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
        PosicionCentral = DeterminarPosicionCentral_0CBE(PunteroAlternativasIY, &PunteroBufferAlturasIX)
        TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 4 - 0x0593] = NuevaAlturaOrientacionC
        if PosicionCentral {
            //080e
            //aquí llega si en a se leyó la altura de la posición a la que ir porque es una de las posiciones que se muestran en pantalla
            //0807
            //lee el posible contenido del buffer de alturas
            NuevaAlturaOrientacionC = LeerByteBufferAlturas(PunteroBufferAlturasIX)
            //elimina de los datos del buffer de alturas el de los personajes que hay (excepto adso) (???)
            NuevaAlturaOrientacionC = NuevaAlturaOrientacionC & 0xEF
            //0812
            //obtiene la altura del destino
            DiferenciaAlturas = AntiguaAlturaOrientacion
            //le resta a la altura del destino la altura base de la planta
            DiferenciaAlturas = Z80Sub(DiferenciaAlturas, LeerAlturaBasePlanta_2473(AntiguaAlturaOrientacion))
            //le resta la altura en el buffer de alturas
            DiferenciaAlturas = Z80Sub(DiferenciaAlturas, NuevaAlturaOrientacionC)
            DiferenciaAlturas = Z80Inc(DiferenciaAlturas)
            //081B
            if DiferenciaAlturas > 6 { //si hay poca diferencia de altura
                //820
                //pone el marcador de fin al inicio de esta entrada (esta entrada queda descartada)
                TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 2 - 0x0593] = 0xFF
                return
            }
        }
        //0825
        //aquí llega si la posición a la que se quiere ir no es una de las del buffer de alturas de la pantalla
        //pone el marcador de fin al final de esta entrada
        PunteroAlternativasIY = PunteroAlternativasIY + 3
        TablaPosicionesAlternativas_0593[PunteroAlternativasIY + 2 - 0x0593] = 0xFF
    }

    public func GenerarPropuestasMovimiento_07BD(PersonajeObjetoHL:Int, PunteroAlternativasDE:Int, PersonajeIY:Int) {
        //genera una propuesta de movimiento al lado de la posición indicada por hl por cada orientación posible y la graba en el buffer de de
        //hl tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
        //de apunta a una posición vacía del buffer para buscar caminos alternativos
        //iy apunta a los datos de posición del personaje que se quiere mover
        var PunteroAlternativasDE:Int = PunteroAlternativasDE
        var OrientacionB:UInt8
        //lee la orientación del personaje/objeto al que se quiere llegar
        OrientacionB = LeerBytePersonajeObjeto(PersonajeObjetoHL + 1)
        //dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
        GenerarPropuestaMovimiento_07D2(OrientacionB, PersonajeObjetoHL, &PunteroAlternativasDE)
        GenerarPropuestaMovimiento_07D2(OrientacionB + 1, PersonajeObjetoHL, &PunteroAlternativasDE)
        GenerarPropuestaMovimiento_07D2(OrientacionB + 2, PersonajeObjetoHL, &PunteroAlternativasDE)
        GenerarPropuestaMovimiento_07D2(OrientacionB + 3, PersonajeObjetoHL, &PunteroAlternativasDE)
    }

    public func GenerarMovimiento_073C(PersonajeOrigenIY:Int, PersonajeObjetoIX:Int) {
        //aquí saltan todos los personajes que "piensan" para llenar su buffer de acciones
        //ix = las variables de la lógica del personaje
        //iy = datos de posición del personaje
        var PersonajeA:UInt8
        var PersonajeDestinoHL:Int
        var PunteroAlternativasDE:Int
        var Contador:Int
        //si no tiene un movimiento pensado
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeOrigenIY + 9 - 0x3036, 7) {
            //0743
            //si el personaje no tiene que ir a ninguna parte, sale
            if TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] != 0 { return }
            //0748
            //lee a donde hay que ir
            PersonajeA = LeerBytePersonajeObjeto(PersonajeObjetoIX - 1)
            //apunta a la primera posición libre del buffer - 2
            PunteroAlternativasDE = 0x0591
            switch PersonajeA {
                case 0xFF: //si hay que ir a por guillermo
                    PersonajeDestinoHL = 0x3036
                case 0xFE: //si hay que ir a por el abad
                    PersonajeDestinoHL = 0x3063
                case 0xFD: //si hay que ir a por el libro
                    PersonajeDestinoHL = 0x3008
                case 0xFC: //si hay que ir a por el pergamino
                    PersonajeDestinoHL = 0x3017
                default: //aquí llega si en ix-1 no encontró 0xff, 0xfe, 0xfd ni 0xfc
                    //075D
                    //copia 3 bytes al buffer que se usa en los algoritmos de posición
                    for Contador in 0...2 {
                        //indexa en la tabla de sitios a donde suele ir el personaje
                        TablaPosicionesAlternativas_0593[Contador] = LeerBytePersonajeObjeto(PersonajeObjetoIX + 3 * Int(PersonajeA) + Contador)
                    }
                    //0772
                    //marca el final de la entrada
                    TablaPosicionesAlternativas_0593[3] = 0xFF
                    PersonajeDestinoHL = PersonajeObjetoIX + 3 * Int(PersonajeA) - 2
                    //apunta a la siguiente posición libre del buffer -2
                    PunteroAlternativasDE = 0x0594
            }
            //07a4
            //hl tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
            //de apunta a una posición vacía del buffer para buscar caminos alternativos
            //iy apunta a los datos de posición del personaje que se quiere mover
            //genera una propuesta de movimiento a la posición indicada por hl por cada orientación posible y la graba en el buffer de de

            GenerarPropuestasMovimiento_07BD(PersonajeObjetoHL: PersonajeDestinoHL, PunteroAlternativasDE: PunteroAlternativasDE, PersonajeIY: PersonajeOrigenIY)
            //apunta a la primera entrada de datos del buffer
            PunteroAlternativaActual_05A3 = 0x0593
            //si no hay ninguna alternativa a evaluar, sale
            if TablaPosicionesAlternativas_0593[0] == 0xFF { return }
            //077d
            //aquí se salta para procesar una alternativa
            //ix posición generada en el buffer
            //iy apunta a los datos de posición del personaje
            //va a por un personaje que no está en la misma zona de pantalla que se muestra (iy a por ix)
            BuscarCaminoGeneral_098A(PersonajeOrigenIY, PunteroAlternativaActual_05A3)
            //If ResultadoBusqueda_2DB6 = 0 Then Stop
            //si no está en el destino, sale
            if ResultadoBusqueda_2DB6 != 0xFD { return }
            //0788
            //si ha llegado al sitio, lo indica
            TablaVariablesLogica_3C85[PersonajeObjetoIX - 3 - 0x3C85] = LeerBytePersonajeObjeto(PersonajeObjetoIX - 1)
        } else {
            //0872
            //aquí llega si tiene un movimiento pensado
            //si no hay movimiento
            //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
            if !MovimientoRealizado_2DC1 { DescartarMovimientosPensados_08BE(PersonajeIY: PersonajeOrigenIY) }
        }

    }

    public func RechazarPropuestasMovimiento_45FB( _ PersonajeIY:Int) {
        //si llega aquí, el personaje no puede moverse a ninguna de las orientaciones propuestas
        var AlturaC:UInt8
        AlturaC = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0E - 0x3036]
        //si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
        RellenarBufferAlturasPersonaje_28EF(PersonajeIY, AlturaC)
    }

    public func BuscarOrientacionAdso_45C7( _ PersonajeIY:Int, _ EntradaTablaOrientacionesA:UInt8, _ PunteroBufferAlturasAdsoIX:Int, _ AlturaBase_451C:UInt8, _ RutinaCompleta:Bool) {
        //escribir los comandos para avanzar en la orientación a la que mira guillermo
        //tabla de orientaciones a probar para moverse en un determinado sentido
        //cada entrada ocupa 4 bytes. Se prueban las orientaciones de cada entrada de izquierda a derecha
        //las entradas están ordenadas inteligentemente.
        //se pueden distinguir 2 grandes grupos de entradas. El primer grupo de entradas (las 4 primeras)
        //da más prioridad a los movimientos a la derecha y el segundo grupo de entradas (las 4 últimas)
        //da más prioridad a los movimientos a la izquierda. Dentro de cada grupo de entradas, las 2 primeras
        //entradas dan más prioridad a los movimientos hacia abajo, y las otras 2 entradas dan más prioridad
        //a los movimientos hacia arriba
        //461F:     03 00 02 01    -> 0x00 -> (+y, +x, -x, -y) -> si adso está a la derecha y detrás de guillermo, con dist y >= dist x
        //       00 03 01 02 -> 0x01 -> (+x, +y, -y, -x) -> si adso está a la derecha y detrás de guillermo, con dist y < dist x
        //       01 00 02 03 -> 0x02 -> (-y, +x, -x, +y) -> si adso está a la derecha y delante de guillermo, con dist y >= dist x
        //       00 01 03 02 -> 0x03 -> (+x, -y, +y, -x) -> si adso está a la derecha y delante de guillermo, con dist y < dist x

        //       03 02 00 01 -> 0x04 -> (+y, -x, +x, -y) -> si adso está a la izquierda y detrás de guillermo, con dist y >= dist x
        //       02 03 01 00 -> 0x05 -> (-x, +y, -y, +x) -> si adso está a la izquierda y detrás de guillermo, con dist y < dist x
        //       01 02 00 03 -> 0x06 -> (-y, -x, +x, +y) -> si adso está a la izquierda y delante de guillermo, con dist y >= dist x
        //       02 01 03 00 -> 0x07 -> (-x, -y, +y, +x) -> si adso está a la izquierda y delante de guillermo, con dist y < dist x
        var Contador:UInt8
        var ValorTablaOrientacionesC:Int
        var ValorTablaDesplazamientosC:Int
        var ValorBufferAlturasC:UInt8
        var PunteroTablaOrientacionesDE:Int
        var PunteroTablaDesplazamientosHL:Int
        var PunteroBufferAlturasIX:Int
        var TablaDesplazamientosSegunOrientacion_4617:[Int] = [1, -24, -1, 24]
        //tabla de desplzamientos dentro del buffer de alturas según la orientación (relacionada con 0x461f)
        //4617:     0001 = +01 -> 0x00
        //       FFE8 = -24 -> 0x01
        //       FFFF = -01 -> 0x02
        //       0018 = +24 -> 0x03
        //indexa en la tabla de orientaciones a probar para moverse. cada entrada ocupa 4 bytes
        PunteroTablaOrientacionesDE = 4 * Int(EntradaTablaOrientacionesA) + 0x461F
        //45D0
        //repite para 3 valores (la orientación contraria a la que se quiere mover no se prueba)
        for Contador in 1...3 {
            //45d2
            //lee un valor de la tabla y lo guarda en c
            ValorTablaOrientacionesC = Int(TablaOrientacionesAdsoGuillermo_461F[PunteroTablaOrientacionesDE - 0x461F])
            //apunta a la tabla de desplazamientos en el buffer de altura según la orientación
            PunteroTablaDesplazamientosHL = 1 * ValorTablaOrientacionesC + 0x4617 //en el original es 2x, pero es tabla de enteros en lugar de bytes
            //lee el desplazamiento según la orientación a probar
            ValorTablaDesplazamientosC = TablaDesplazamientosSegunOrientacion_4617[PunteroTablaDesplazamientosHL - 0x4617]
            //45E2
            //calcula la posición en el buffer de alturas
            PunteroBufferAlturasIX = PunteroBufferAlturasAdsoIX + ValorTablaDesplazamientosC
            //45e4
            //quita el bit 7
            ClearBitBufferAlturas(PunteroBufferAlturasIX, 7)
            //obtiene lo que hay
            ValorBufferAlturasC = LeerByteBufferAlturas(PunteroBufferAlturasIX)
            //comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
            ComprobarPosicionesVecinas_4517(PunteroTablaOrientacionesDE, PunteroBufferAlturasIX, ValorBufferAlturasC, AlturaBase_451C, RutinaCompleta)
            //si la rutina anterior ha puesto el bit 7 (porque puede avanzarse en esa posición), salta
            if LeerBitBufferAlturas(PunteroBufferAlturasIX, 7) {
                //4606
                //el personaje va a moverse a la orientación que estaba probando
                //quita el bit 7
                ClearBitBufferAlturas(PunteroBufferAlturasIX, 7)
                //escribe un comando para avanzar en la nueva orientación del personaje
                GenerarComandos_47E6(PersonajeIY: PersonajeIY, OrientacionNuevaC: UInt8(ValorTablaOrientacionesC), NumeroRutina: 0x464F, PunteroPilaCaminoHL: 0)
                //deja la rutina anterior como estaba y pone las posiciones del buffer de alturas del personaje
                RechazarPropuestasMovimiento_45FB(PersonajeIY)
                //vuelve a llamar al comportamiento de adso
                EjecutarComportamientoAdso_087B()
                return
            }
            //45f4
            //prueba con otra orientación de la tabla
            PunteroTablaOrientacionesDE = PunteroTablaOrientacionesDE + 1
        } //repite para las 3 orientaciones que hay
        //45FB
        RechazarPropuestasMovimiento_45FB(PersonajeIY)
    }

    public func LimpiarBufferAlturasAdso_4591( _ PersonajeIY:Int, _ PunteroBufferAlturasIX:Int, _ AlturaBase_451C: inout UInt8, _ RutinaCompleta: inout Bool) {
        //limpia las posiciones del buffer de alturas que ocupa adso y modifica un par de instrucciones
        //si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
        RellenarBufferAlturasPersonaje_28EF(PersonajeIY, 0)
        RutinaCompleta = false
        //obtiene la altura de la posición principal del personaje en el buffer de alturas
        AlturaBase_451C = LeerByteBufferAlturas(PunteroBufferAlturasIX) & 0x0F
    }

    public func DejarPasoGuillermo_45A4( _ PersonajeIY:Int, _ PunteroBufferAlturasIX:Int) {
        //llamado desde adso cuando éste le impide avanzar a guillermo
        //aquí llega con ix apuntando al buffer de alturas de adso
        var AlturaBase_451C:UInt8=0
        var RutinaCompleta:Bool=false
        var PosicionXGuillermo:UInt8
        var PosicionYGuillermo:UInt8
        var PosicionXAdso:UInt8
        var PosicionYAdso:UInt8
        var DistanciaX:UInt8
        var DistanciaY:UInt8
        var EntradaTablaOrientacionesC:UInt8=0
        //limpia las posiciones del buffer de alturas que ocupa adso y modifica un par de instrucciones
        LimpiarBufferAlturasAdso_4591(PersonajeIY, PunteroBufferAlturasIX, &AlturaBase_451C, &RutinaCompleta)
        //obtiene la posición de guillermo
        PosicionXGuillermo = TablaCaracteristicasPersonajes_3036[2]
        PosicionYGuillermo = TablaCaracteristicasPersonajes_3036[3]
        //45AD
        //obtiene la posición x de adso
        PosicionXAdso = TablaCaracteristicasPersonajes_3036[0x3045 + 2 - 0x3036]
        if PosicionXAdso < PosicionXGuillermo { //si adso está a la izquierda de guillermo
            //45b3
            //indica que guillermo está a la derecha de adso
            SetBit(&EntradaTablaOrientacionesC, 2)
            //distancia en x entre los 2 personajes
            DistanciaX = PosicionXGuillermo - PosicionXAdso
        } else {
            DistanciaX = PosicionXAdso - PosicionXGuillermo
        }
        //45b8
        //obtiene la posición y de adso
        PosicionYAdso = TablaCaracteristicasPersonajes_3036[0x3045 + 3 - 0x3036]
        if PosicionYAdso < PosicionYGuillermo { //si adso está delante de guillermo
            //45BE
            //indica que guillermo está detrás de adso
            SetBit(&EntradaTablaOrientacionesC, 1)
            //distancia en y entre los 2 personajes
            DistanciaY = PosicionYGuillermo - PosicionYAdso
        } else {
            DistanciaY = PosicionYAdso - PosicionYGuillermo
        }
        //45C2
        if DistanciaY < DistanciaX {
            //45c5
            EntradaTablaOrientacionesC = EntradaTablaOrientacionesC + 1
        }
        //45C7
        BuscarOrientacionAdso_45C7(PersonajeIY, EntradaTablaOrientacionesC, PunteroBufferAlturasIX, AlturaBase_451C, RutinaCompleta)
    }

    public func AvanzarDireccionGuillermo_4582( _ PersonajeIY:Int, _ PunteroBufferAlturasIX:Int) {
        //llamado desde adso cuando se pulsa cursor abajo
        //trata de avanzar en la orientación de guillermo
        var AlturaBase_451C:UInt8 = 0
        var RutinaCompleta:Bool = false
        var OrientacionGuillermoA:UInt8
        //limpia las posiciones del buffer de alturas que ocupa adso y modifica un par de instrucciones
        LimpiarBufferAlturasAdso_4591(PersonajeIY, PunteroBufferAlturasIX, &AlturaBase_451C, &RutinaCompleta)
        //obtiene la orientación de guillermo y selecciona una entrada de la tabla según la orientación de guillermo
        OrientacionGuillermoA = TablaCaracteristicasPersonajes_3036[0x3036 + 1 - 0x3036]
        OrientacionGuillermoA = OrientacionGuillermoA + 1
        //0 -> 1
        //1 -> 2
        //2 -> 7
        //3 -> 4
        //4589
        if OrientacionGuillermoA == 3 { OrientacionGuillermoA = 7 }
        //salta a escribir los comandos para avanzar en la orientación a la que mira guillermo
        BuscarOrientacionAdso_45C7(PersonajeIY, OrientacionGuillermoA, PunteroBufferAlturasIX, AlturaBase_451C, RutinaCompleta)
    }

    public func ActualizarTablaPuertas_3EA4(MascaraPuertasC:UInt8) {
        //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre qué habitaciones están
        //c = máscara de las puertas que interesan de todas las que pueden abrirse
        var PuertasAbriblesPersonajeA:UInt8
        var PunteroAccesoHabitacionesIX:Int
        var PunteroConexionesHabitacionesHL:Int
        var Contador:UInt8
        var Bit0:Bool
        var ValorHabitacionesA:UInt8
        var ConexionesHabitacionE:UInt8
        // tabla para modificar el acceso a las habitaciones según las llaves que se tengan. 6 entradas (una por puerta) de 5 bytes
        // byte 0: indice de la habitación en la matriz de habitaciones de la planta baja
        // byte 1: permisos para esa habitación
        // byte 2: indice de la habitación en la matriz de habitaciones de la planta baja
        // byte 3: permisos para esa habitación
        // byte 4: 0xff
        //3C67:     35 01 36 04 FF    ; entre la habitación (3, 5) = 0x3e y la (3, 6) = 0x3d hay una puerta (la de la habitación del abad)
        //        1B 08 2B 02 FF    ; entre la habitación (1, b) = 0x00 y la (2, b) = 0x38 hay una puerta (la de la habitación de los monjes)
        //        56 08 66 02 FF    ; entre la habitación (5, 6) = 0x3d y la (6, 6) = 0x3c hay una puerta (la de la habitación de severino)
        //        29 01 2A 04 FF    ; entre la habitación (2, 9) = 0x29 y la (2, a) = 0x37 hay una puerta (la de la salida de las habitaciones hacia la iglesia)
        //        27 01 28 04 FF    ; entre la habitación (2, 7) = 0x28 y la (2, 8) = 0x26 hay una puerta (la del pasadizo de detrás de la cocina)
        //        75 01 76 04 FF    ; entre la habitación (7, 5) = 0x11 y la (7, 6) = 0x12 hay una puerta (la que cierra el paso a la parte izquierda de la planta baja)
        //lee datos de movimiento de adso y guarda ese valor que luego usará como si fuera un valor aleatorio
        TablaVariablesLogica_3C85[ValorAleatorio_3C9D - 0x3C85] = BufferComandosMonjes_A200[0xA2C0 - 0xA200]
        //obtiene la máscara de las puertas que puede atravesar el personaje
        PuertasAbriblesPersonajeA = TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] & MascaraPuertasC
        //3EB1
        //apunta a la tabla con las habitaciones que comunican las puertas
        PunteroAccesoHabitacionesIX = 0x3C67
        for Contador in 0...5 { //6 puertas
            //3EB7
            //comprueba el bit0
            if (PuertasAbriblesPersonajeA % 2) != 0 {
                Bit0 = true
            } else {
                Bit0 = false
            }
            //desplaza c a la derecha
            PuertasAbriblesPersonajeA = PuertasAbriblesPersonajeA >> 1
            while true {
                //3EC1
                //apunta a las conexiones de las habitaciones de la planta baja
                PunteroConexionesHabitacionesHL = 0x05CD
                //lee el índice en la matriz de habitaciones de la planta baja
                ValorHabitacionesA = TablaAccesoHabitaciones_3C67[PunteroAccesoHabitacionesIX - 0x3C67]
                PunteroAccesoHabitacionesIX = PunteroAccesoHabitacionesIX + 1
                //si encuentra 0xff pasa a la siguiente iteración
                if ValorHabitacionesA == 0xFF { break }
                //3ECD
                PunteroConexionesHabitacionesHL = PunteroConexionesHabitacionesHL + Int(ValorHabitacionesA)
                //lee el valor para esa habitación
                ValorHabitacionesA = TablaAccesoHabitaciones_3C67[PunteroAccesoHabitacionesIX - 0x3C67]
                PunteroAccesoHabitacionesIX = PunteroAccesoHabitacionesIX + 1
                //obtiene las conexiones de esa habitación
                ConexionesHabitacionE = TablaConexionesHabitaciones_05CD[PunteroConexionesHabitacionesHL - 0x05CD]
                //3ED7
                if Bit0 { //si cf = 1 a = ~a & e
                    ValorHabitacionesA = (255 - ValorHabitacionesA) & ConexionesHabitacionE
                } else { //si cf = 0 (es decir, si no puede ir a esa puerta), a = a | e
                    ValorHabitacionesA = ValorHabitacionesA | ConexionesHabitacionE
                }
                //3EDB
                //modifica el valor de esa habitación
                TablaConexionesHabitaciones_05CD[PunteroConexionesHabitacionesHL - 0x05CD] = ValorHabitacionesA
                //3EDC
            }
            //3EDE
        } //repite hasta acabar las 6 entradas
    }

    public func LeerComandoPersonaje_2C10( _ PersonajeIY:Int) -> UInt8 {
        //lee un bit de datos de los comandos del personaje y lo mete en el CF
        var LeerComandoPersonaje_2C10:UInt8
        var PunteroComandosMonjes:Int
        LeerComandoPersonaje_2C10 = 0
        //si no quedan comandos pendientes
        if TablaCaracteristicasPersonajes_3036[PersonajeIY + 9 - 0x3036] == 0 {
            //2C16
            //aquí entra si el contador de los bits 0-2 de iy+09 es 0, y el bit 7 de iy+0x09 no es 1
            //en 0x0b está el índice dentro de los comandos
            PunteroComandosMonjes = Int(TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036])
            //en 0x0c y 0x0d se guarda un puntero a los datos de los comandos de movimiento del personaje
            PunteroComandosMonjes = PunteroComandosMonjes + Leer16(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x0C - 0x3036)
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] + 1
            //obtiene un nuevo byte de comandos y lo graba
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] = BufferComandosMonjes_A200[PunteroComandosMonjes - 0xA200]
        }
        //2c29
        //incrementa el contador de los bits 0-2
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x09 - 0x3036] = (TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x09 - 0x3036] + 1) & 0x7
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0xA - 0x3036, 7) { LeerComandoPersonaje_2C10 = 1 }
        //desplaza los bits de los comandos a la izquierda una posición
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0A - 0x3036] << 1
        return LeerComandoPersonaje_2C10
    }

    public func LeerComandosPersonaje_2CB8(PersonajeIY:Int, Volver: inout Bool, ResultadoC: inout UInt8) {
        //lee e interpreta los comandos que se le han pasado al personaje. Según los bits que lea, se devuelven valores:
        //x si el personaje ocupa de 4 posiciones
        //  si lee 1 -> devuelve c = 1 -> trata de avanzar una posición hacia delante (con a = 0 y c = -1) -> avanza
        //  si lee 010 -> devuelve c = 2 -> gira a la derecha
        //  si lee 011 -> devuelve c = 3 -> gira a la izquierda
        //  si lee 0010 -> devuelve c = 4 -> trata de avanzar una posición hacia delante (con a = 1 y c = -1) -> sube (y pasa a ocupar una posición)
        //  si lee 0011 -> devuelve c = 5 -> trata de avanzar una posición hacia delante (con a = -1 y c = -1) -> baja (y pasa a ocupar una posición)
        //  si lee 0001 -> pone el bit 7,(9) y sale 2 rutinas para fuera
        //  si lee 0000 -> reinicia el contador, el índice, habilita los comandos, y procesa otro comando
        //x si el personaje ocupa de 1 posición:
        //  si lee 10 -> devuelve c = 0 ->     si bit 5 = 1, trata de avanzar una posición hacia delante (con a = 0 y c = 0) -> avanza
        //                                si bit 5 = 0, sube (y sigue ocupando una posición) (con a = 1 y c = 2)
        //  si lee 11 -> devuelve c = 1 -> baja (y sigue ocupando una posición) (con a = -1 y c = -2)
        //  si lee 010 -> devuelve c = 2 -> gira a la derecha
        //  si lee 011 -> devuelve c = 3 -> gira a la izquierda
        //  si lee 0010 -> devuelve c = 4 -> sube (y pasa a ocupar 4 posiciones) (con a = 1 y c = 1)
        //  si lee 0011 -> devuelve c = 5 -> baja (y pasa a ocupar 4 posiciones) (con a = -1 y c = -1)
        //  si lee 0001 -> pone el bit 7,(9) y sale 2 rutinas para fuera
        //  si lee 0000 -> sale con c = 0
        var ComandoC:UInt8
        while true {
            //comprueba si el personaje ocupa 1 ó 4 posiciones en el buffer de alturas
            if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) {
                //2CBE
                //aqui llega si el personaje ocupa una posicion en el buffer de alturas
                //lee un bit de datos de los comandos del personaje y lo mete en el CF
                ComandoC = LeerComandoPersonaje_2C10(PersonajeIY)
                if ComandoC != 0 {
                    //2CC3
                    //lee un bit de datos de los comandos del personaje y lo mete en el CF
                    ResultadoC = LeerComandoPersonaje_2C10(PersonajeIY)
                    return
                } else {
                    //si ha leido un 0, salta a procesar el resto como si fuera de 4 posiciones
                }
            } else {
                //2CCB
                //aqui llega si el personaje ocupa 4 posiciones en el buffer de alturas
                //lee un bit de datos de los comandos del personaje y lo mete en el CF
                ComandoC = LeerComandoPersonaje_2C10(PersonajeIY)
            }
            //2CCE
            ResultadoC = 1
            //si ha leido un 1, sale
            if ComandoC != 0 { return }
            //2CD1
            //lee un bit de datos de los comandos del personaje y lo mete en el CF
            ComandoC = LeerComandoPersonaje_2C10(PersonajeIY)
            if ComandoC != 0{
                //2CD6
                //lee un bit de datos de los comandos del personaje y lo mete en el CF
                ResultadoC = ResultadoC << 1 | LeerComandoPersonaje_2C10(PersonajeIY)
                return
            }
            //2CDC
            ResultadoC = ResultadoC << 1 | ComandoC
            if LeerComandoPersonaje_2C10(PersonajeIY) != 0 {
                //2CD6
                //lee un bit de datos de los comandos del personaje y lo mete en el CF
                ResultadoC = ResultadoC << 1 | LeerComandoPersonaje_2C10(PersonajeIY)
                return
            }
            //2CE3
            //lee un bit de datos de los comandos del personaje y lo mete en el CF
            ComandoC = LeerComandoPersonaje_2C10(PersonajeIY)
            if ComandoC != 0 { //si ha leido un 1
                //2cf9
                //indica que se han acabado los comandos y sale 2 rutinas fuera
                SetBitArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 9 - 0x3036, 7)
                Volver = true
                return
            }
            //2ce8
            ResultadoC = 0
            //si es un personaje que ocupa solo una posición en el buffer de posiciones, sale
            if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) { return }
            //2CEF
            //reinicia el contador, el índice y habilita los comandos
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x0B - 0x3036] = 0
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x09 - 0x3036] = 0
        }
    }

    public func EjecutarComportamientoPersonaje_2C3A( _ PunteroSpriteIX:Int, _ PersonajeIY:Int) {
        //ejecuta los comandos de movimiento para adso y para los monjes
        //ix que apunta al sprite del personaje
        //iy apunta a los datos de posición del personaje
        var PunteroHL:Int
        var Contador:UInt8
        var ComandoC:UInt8 = 0
        var Altura1A:UInt8
        var Altura2C:UInt8
        var Volver:Bool = false
        //si no hay comandos en el buffer, sale
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 9 - 0x3036, 7) { return }
        //2C3F
        //devuelve la dirección para calcular la altura de las posiciones vecinas según el tamaño de la posición del personaje y la orientación
        PunteroHL = ObtenerPunteroPosicionVecinaPersonaje_2783(PersonajeIY)
        //apunta a la cantidad a sumar a la posición si el personaje sigue avanzando en ese sentido
        PunteroHL = PunteroHL + 6
        //2C46
        //2d5c
        for Contador in 0..<0x0A { //longitud de los datos
            BufferAuxiliar_2D68[Contador] = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 + Contador - 0x3036]
        }
        //2C4C
        //lee en c un comando del personaje
        LeerComandosPersonaje_2CB8(PersonajeIY: PersonajeIY, Volver: &Volver, ResultadoC: &ComandoC)
        if Volver { return }
        Altura2C = 1 //c = +1
        //2C53
        if ComandoC == 3 { //si obtuvo un 3, se gira a la izquierda
            ActualizarDatosPersonajeCursorIzquierdaDerecha_2A0C(true, PunteroSpriteIX, PersonajeIY)
            return
        } else {
            //2C58
            Altura2C = 0xFF //c = -1
            if ComandoC == 2 { //si obtuvo un 2, se gira a la derecha
                ActualizarDatosPersonajeCursorIzquierdaDerecha_2A0C(false, PunteroSpriteIX, PersonajeIY)
                return
            }
        }
        //2C5F
        //si el personaje ocupa 4 posiciones en el buffer de alturas
        if !LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) {
            //2C65
            //aquí llega si el personaje ocupa 4 posiciones en el buffer de alturas, y con c = -1
            if ComandoC == 1 {
                //2C69
                Altura1A = 0
            } else {
                //2C6D
                //aquí llega con c = -1 si el personaje ocupa una sola posición en el buffer de alturas o si obtuvo algo distinto de un uno y el personaje ocupa 4 posiciones del buffer de tiles
                if ComandoC == 5 {
                    //2C6F
                    Altura1A = 0xFF
                } else {
                    //2C73
                    Altura1A = 1
                }
            }
        } else {
            //2C77
            //aqui llega con c = -1 si el personaje ocupa una sola posición en el buffer de alturas
            if ComandoC == 0 {
                //2C7A
                if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 5) {
                    //2c80
                    //si el bit 5 es 1 (si está girado en un desnivel)
                    Altura1A = 0
                    Altura2C = 0
                } else {
                    //2C84
                    //aquí llega si el personaje ocupa una posición, obtuvo un 0 y el bit 5 era 0 (si no está girado en un desnivel)
                    Altura1A = 1
                    Altura2C = 2
                }
            } else {
                //2C8A
                //aquí llega si el personaje ocupa una posición, y no obtuvo un 0
                if ComandoC == 1 {
                    //2c8e
                    Altura2C = 0xFE
                    Altura1A = 0xFF
                } else {
                    //2c94
                    if ComandoC == 4 {
                        //2c98
                        Altura2C = 1
                        Altura1A = 1
                    } else {
                        //2c9d
                        Altura2C = 0xFF
                        Altura1A = 0xFF
                    }
                }
            }
        }
        //2ca0
        //comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje
        //en a pasa la diferencia de altura a donde se mueve, que se usará si el personaje no está en la pantalla actual
        //indica que de momento no hay movimiento
        MovimientoRealizado_2DC1 = false
        var Salida1A:Int = 0
        var Salida2C:Int = 0
        var Salida3HL:Int
        //2CA6
        //comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
        //si el personaje no está en la pantalla que se muestra, a, c = lo que se pasó
        Salida3HL = PunteroHL
        ObtenerAlturaDestinoPersonaje_27B8(Altura1A, Altura2C, PersonajeIY, &Salida1A, &Salida2C, &Salida3HL)
        //If Salida3HL = 0 Then Stop
        //si puede moverse hacia delante, actualiza el sprite del personaje
        if Salida1A == 0xFF { Salida1A = -1 }
        if Salida2C == 0xFF { Salida2C = -1 }
        AvanzarPersonaje_2954(PunteroSpriteIX, PersonajeIY, Salida1A, Salida2C, Salida3HL)
        //si el personaje se ha movido, sale
        if MovimientoRealizado_2DC1 { return }
        //2CB1
        //en otro caso, restaura la copia de datos del personaje del buffer
        //2d5c
        for Contador in 0..<0x0A { //longitud de los datos
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 + Contador - 0x3036] = BufferAuxiliar_2D68[Contador]
        }
    }

    public func EjecutarComportamientoAdso_087B() {
        //comportamiento de adso
        var PersonajeIY:Int
        var PunteroDatosAdsoIX:Int
        var PunteroBufferAlturasIX:Int = 0
        var PunteroAuxiliarHL:Int
        var PosicionXAdsoL:UInt8
        var PosicionYAdsoH:UInt8
        var PosicionXGuillermoL:UInt8
        var PosicionYGuillermoH:UInt8
        var PunteroPilaHL:Int = 0
        var MarcaGuillermoC:UInt8 //identificador de Guillermo en el buffer de alturas
        var MarcaAdsoC:UInt8 //identificador de Guillermo en el buffer de alturas
        var MinimasIteracionesC:UInt8
        var OrientacionNuevaC:UInt8
        var flipe:UInt8 = 0
        while true {
            PersonajeIY = 0x3045 //apunta a los datos de posición de adso
            PunteroDatosAdsoIX = 0x3D14 //apunta a los datos de estado de adso
            //indica que el personaje inicialmente si quiere moverse
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 0
            ProcesarLogicaAdso_5DA1() //procesa el comportamiento de adso
            //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
            ActualizarTablaPuertas_3EA4(MascaraPuertasC: 0x3C)
            //088F
            //apunta a la tabla para mover a adso
            //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
            ActualizarDatosPersonaje_291D(0x2BB8)
            //0895
            //lee a donde debe ir adso
            if TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] == 0xFF {
                //08a1
                //adso tiene que seguir a guillermo
                //lee el personaje al que sigue la cámara
                if TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] >= 2 { return } //si la cámara no sigue a guillermo o a adso, sale
                //08A7
                //comprueba si tiene un movimiento pensado
                if !LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x9 - 0x3036, 7) {
                    //08AD
                    //aquí llega si tenía un movimiento pensado
                    //apunta al contador de movimientos frustados
                    //PunteroVariablesAuxiliaresHL = 0x2DAA
                    //08B0
                    //si el personaje se pudo mover hacia donde quería, sale
                    if MovimientoRealizado_2DC1 { return }
                    //08B6
                    //obtiene el contador de movimientos frustados y lo incrementa
                    ContadorMovimientosFrustrados_2DAA = ContadorMovimientosFrustrados_2DAA + 1
                    //TablaVariablesAuxiliares_2D8D(PunteroVariablesAuxiliaresHL - 0x2D8D) = TablaVariablesAuxiliares_2D8D(PunteroVariablesAuxiliaresHL - 0x2D8D) + 1
                    //si es < 10, sale
                    if ContadorMovimientosFrustrados_2DAA < 10 { return }
                    //mantiene el valor entre 0 y 9
                    ContadorMovimientosFrustrados_2DAA = 0
                    //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
                    DescartarMovimientosPensados_08BE(PersonajeIY: PersonajeIY)
                    return
                } else {
                    //08CF
                    //aquí llega si no tenía un movimiento pensado
                    //si tiene el control pulsado, adso se queda quieto
                    if TeclaPulsadaNivel_3482(0x17) && depuracion.PararAdsoCTRL { return }
                    //08D8
                    //indica que de momento no ha encontrado una ruta hasta guillermo
                    ResultadoBusqueda_2DB6 = 0
                    //08E3
                    //si la posición no es una de las del centro de la pantalla que se muestra, CF=1
                    //en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
                    if DeterminarPosicionCentral_0CBE(PersonajeIY, &PunteroBufferAlturasIX) && !(depuracion.CamaraManual && (TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] == 1)) {
                        //08E6
                        //adso está en la pantalla que se muestra
                        if TeclaPulsadaNivel_3482(0) { //si se pulsa cursor arriba
                            //08ed
                            //aquí llega si adso está en el centro de la pantalla y se pulsa cursor arriba
                            //comprueba la altura de las posiciones a las que va a moverse guillermo y las devuelve en a y c
                            //si el personaje no está visible, se devuelve lo mismo que se pasó en a
                            var Salida1A:Int=0
                            var Salida2C:Int=0
                            var Salida3HL:Int=0
                            var ValorAlturaA:Int
                            ObtenerAlturaDestinoPersonaje_27CB(0, 0, 0, 0x3036, &Salida1A, &Salida2C, &Salida3HL)
                            //apunta al buffer auxiliar para el cálculo de las alturas a los movimientos usado por la rutina anterior
                            PunteroAuxiliarHL = 0x2DC6
                            //08FB
                            //combina el contenido de las 2 casillas por las que va a moverse guillermo
                            ValorAlturaA = BufferAuxiliar_2DC5[PunteroAuxiliarHL - 0x2DC5]
                            ValorAlturaA = ValorAlturaA | BufferAuxiliar_2DC5[PunteroAuxiliarHL + 1 - 0x2DC5]
                            PunteroAuxiliarHL = PunteroAuxiliarHL + 1
                            //08FE
                            //pasa a la siguiente línea
                            PunteroAuxiliarHL = PunteroAuxiliarHL + 3
                            ValorAlturaA = ValorAlturaA | BufferAuxiliar_2DC5[PunteroAuxiliarHL - 0x2DC5]
                            ValorAlturaA = ValorAlturaA | BufferAuxiliar_2DC5[PunteroAuxiliarHL + 1 - 0x2DC5]
                            PunteroAuxiliarHL = PunteroAuxiliarHL + 1
                            //0904
                            if (ValorAlturaA & 0x20) != 0 {
                                //si adso no está en alguna de esas, escribe comandos para moverse hacia ellas
                                DejarPasoGuillermo_45A4(PersonajeIY, PunteroBufferAlturasIX)
                                return
                            }
                        }
                        //0909
                        //aquí llega si no se pulsa cursor arriba o si adso no molestaba a guillermo para avanzar
                        if TeclaPulsadaNivel_3482(0x02) { //si se pulsa cursor abajo
                            //4582
                            AvanzarDireccionGuillermo_4582(PersonajeIY, PunteroBufferAlturasIX)
                            return
                        }
                        //0911
                        //apunta a los datos posición de guillermo
                        //si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa guillermo en el buffer de alturas
                        RellenarBufferAlturasPersonaje_28EF(0x3036, 0)
                        //si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa adso en el buffer de alturas
                        RellenarBufferAlturasPersonaje_28EF(0x3045, 0)
                        //0923
                        //obtiene la posición de adso
                        PosicionXAdsoL = TablaCaracteristicasPersonajes_3036[0x3047 - 0x3036]
                        PosicionYAdsoH = TablaCaracteristicasPersonajes_3036[0x3048 - 0x3036]
                        //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
                        DeterminarPosicionCentral_279B(&PosicionXAdsoL, &PosicionYAdsoH)
                        //0929
                        //guarda la posición relativa de adso
                        PosicionDestino_2DB4 = Int(PosicionYAdsoH) << 8 | Int(PosicionXAdsoL)
                        //092C
                        //obtiene la posición de guillermo
                        PosicionXGuillermoL = TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036]
                        PosicionYGuillermoH = TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036]
                        //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
                        DeterminarPosicionCentral_279B(&PosicionXGuillermoL, &PosicionYGuillermoH)
                        //guarda la posición relativa de guillermo
                        PosicionOrigen_2DB2 = Int(PosicionYGuillermoH) << 8 | Int(PosicionXGuillermoL)
                        //0935
                        //busca el camino para ir de guillermo a adso (o viceversa)
                        BuscarCamino_4429(&PunteroPilaHL)
                        //elimina todos los rastros de la búsqueda del buffer de alturas
                        LimpiarRastrosBusquedaBufferAlturas_0BAE()
                        //093E
                        //obtiene la altura usada en el buffer de alturas para indicar que está Guillermo
                        MarcaGuillermoC = TablaCaracteristicasPersonajes_3036[0x3036 + 0x0E - 0x3036]
                        //si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
                        RellenarBufferAlturasPersonaje_28EF(0x3036, MarcaGuillermoC)
                        //0948
                        //obtiene la altura usada en el buffer de alturas para indicar que está Adso
                        MarcaAdsoC = TablaCaracteristicasPersonajes_3036[0x3045 + 0x0E - 0x3036]
                        //si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
                        RellenarBufferAlturasPersonaje_28EF(0x3045, MarcaAdsoC)
                        //0952
                        //si no encontró un camino del origen al destino, sale
                        if ResultadoBusqueda_2DB6 == 0 { return }
                        //0957
                        //aquí llega si se encontró un camino del origen al destino
                        //iy apunta a los datos de posición de adso
                        //mínimo número de iteraciones del algoritmo
                        MinimasIteracionesC = 4
                        if !LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 5 - 0x3036, 7) {
                            //095f
                            //si el personaje ocupa cuatro posiciones en el buffer de alturas
                            //si ocupa 4 posiciones, se permite una iteración menos
                            MinimasIteracionesC = MinimasIteracionesC - 1
                            if (PosicionXGuillermoL != PosicionXAdsoL) && (PosicionYGuillermoH != PosicionYAdsoH) {
                                //si ninguna de las 2 coordenadas son iguales, se incrementa el número de iteraciones mínimas del algoritmo
                                //096f
                                MinimasIteracionesC = MinimasIteracionesC + 1
                            }
                        }
                        //0970
                        //obtiene el nivel de recursión de la rutina de búsqueda
                        //si el número de iteraciones es menor que el tolerable, sale
                        if TablaComandos_440C[0x4419 - 0x440C] < MinimasIteracionesC { return }
                        //0975
                        //obtiene la última orientación que se utilizó para encontrar al personaje en la rutina de búsqueda
                        OrientacionNuevaC = TablaComandos_440C[0x4418 - 0x440C]
                        //escribe un comando para avanzar en la nueva orientación del personaje
                        //If PunteroPilaHL = 0x9CD0 Then Stop
                        GenerarComandos_47E6(PersonajeIY: PersonajeIY, OrientacionNuevaC: OrientacionNuevaC, NumeroRutina: 0x464F, PunteroPilaCaminoHL: PunteroPilaHL)
                        //vuelve a llamar al comportamiento de adso
                    } else {
                        //097f
                        //aquí llega si adso no está en zona de la pantalla que se muestra
                        //va a por Guillermo, que no está en la misma zona de pantalla que se muestra (iy a por ix)
                        //si la cámara apunta a adso mientras sigue a guillermo, pero guillermo no está en en la misma habitación, también pasa por aquí
                        if !BuscarCaminoGeneral_098A(PersonajeIY, 0x3038) { return }
                        //si encontró un camino, vuelve a ejecutar el movimiento de adso
                        flipe = flipe + 1
                        if flipe > 5 {
                            ErrorExtraño()
                            return
                        }
                    }
                }
            } else {
                //073C
                GenerarMovimiento_073C(PersonajeOrigenIY: PersonajeIY, PersonajeObjetoIX: PunteroDatosAdsoIX)
                return
            }
        }
    }

    public func RotarGraficosMonjes_36C4() {
        //si hay que girar el gráfico de algún monje, lo hace
        var PersonajeIY:Int
        var PunteroCarasMonjesHL:Int
        var PunteroCaraMonjeDE:Int
        var Contador:UInt8
        PersonajeIY = 0x3054 //apunta a las caracteristicas de malaquías
        PunteroCarasMonjesHL = 0x3097 //apunta a la tabla con las caras de los monjes
        //repite 4 veces (para malaquías, el abad, berengario y severino)
        //36CD
        for Contador in 0...3 {
            //36cf
            //lee una dirección y la guarda en de
            PunteroCaraMonjeDE = Leer16(TablaPunterosCarasMonjes_3097, PunteroCarasMonjesHL - 0x3097)
            PunteroCarasMonjesHL = PunteroCarasMonjesHL + 2
            //36D5
            //si hay que girar el monje
            if TablaCaracteristicasPersonajes_3036[PersonajeIY + 6 - 0x3036] != 0 {
                //36DB
                //indica que los gráficos no están girados
                TablaCaracteristicasPersonajes_3036[PersonajeIY + 6 - 0x3036] = 0
                //gira en xy una serie de datos gráficos que se le pasan en hl
                //ancho = 5, numero = 20
                GirarGraficosRespectoX_3552(Tabla: &DatosMonjes_AB59, PunteroTablaHL: PunteroCaraMonjeDE - 0xAB59, AnchoC: 5, NGraficosB: 0x14)
            }
            //36E6
            PersonajeIY = PersonajeIY + 0x0F //avanza a la siguiente entrada
            //36ED
        }
    }

    public func RotarGraficosCambiarCaraCambiarPosicion_40A2(PunteroCaraHL:Int, PunteroMonjesDE:Int, PersonajeObjetoHL:Int, Bytes:[UInt8]) {
        //rota los gráficos de los monjes si fuera necesario y modifica la cara apuntada por hl con
        //la que se le pasa en de. además, cambia la posición del personaje indicado
        RotarGraficosMonjes_36C4() //rota los gráficos de los monjes si fuera necesario
        //409D
        //[hl] = de
        Escribir16(&TablaPunterosCarasMonjes_3097, PunteroCaraHL - 0x3097, PunteroMonjesDE)
        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: PersonajeObjetoHL, Bytes: Bytes)
    }

    public func CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL:Int, Bytes:[UInt8]) {
        var Contador:UInt8
        //copia a la dirección indicada despues de la pila 5 bytes que siguen a la dirección (pero del llamante)
        for Contador in 0...4 {
            EscribirBytePersonajeObjeto(PersonajeObjetoHL + Contador, Bytes[Contador])
        }
    }

    public func InicializarLampara_3FF7() {
        //le quita la lámpara a adso y reinicia los contadores de la lámpara
        var MalaquiasTieneLamparaA:Bool = false
        var TiempoUsoLamparaHL:Int
        //lee si malaquías tiene la
        if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosMalaquias_2DFA - 0x2DEC, 7) { MalaquiasTieneLamparaA = true }
        //obtiene el tiempo de uso de la lámpara
        TiempoUsoLamparaHL = Leer16(TablaVariablesLogica_3C85, TiempoUsoLampara_3C87 - 0x3C85)
        //3FFF
        //si malaquías no tiene la lámpara y no se ha usado, sale
        if !MalaquiasTieneLamparaA && TiempoUsoLamparaHL == 0 { return }
        //4002
        //indica que se ha usado la lámpara
        TablaVariablesLogica_3C85[LamparaEnCocina_3C91 - 0x3C85] = 0
        //pone a a 0 el contador de uso de la lámpara
        Escribir16(&TablaVariablesLogica_3C85, TiempoUsoLampara_3C87 - 0x3C85, 0)
        //indica que no se está usando la lámpara
        TablaVariablesLogica_3C85[LamparaEncendida_3C8B - 0x3C85] = 0
        //indica que adso no tiene la lámpara
        ClearBitArray(&TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7)
        //indica que malaquías no tiene la lámpara
        ClearBitArray(&TablaObjetosPersonajes_2DEC, ObjetosMalaquias_2DFA - 0x2DEC, 7)
        //copia en 0x3030 -> 00 00 00 00 00 (limpia los datos de posición de la lámpara)
        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3030, Bytes: [0, 0, 0, 0, 0])
    }

    public func ImprimirFrase_4FEE( _ Bytes:[UInt8]) {
        //imprime la frase que sigue a la llamada en la posición de pantalla actual
        var Contador:UInt8
        for Contador in 0..<Bytes.count {
            //ajusta el caracter entre 0 y 127
            ImprimirCaracter_3B19(CaracterA: Bytes[Contador] & 0x7F, AjusteColorC: 0xFF)
        }
    }

    public func EscribirBorrar_S_N_5065() {
        //imprime S:N o borra S:N dependiendo de 0x3c99
        //coloca la posición (116, 164)
        PunteroCaracteresPantalla_2D97 = 0xA41D
        if (TablaVariablesLogica_3C85[ContadorRespuestaSN_3C99 - 0x3C85] & 0x01) != 0 {
            ImprimirFrase_4FEE([0x20, 0x20, 0x20]) //3 espacios
        } else {
            ImprimirFrase_4FEE([0x53, 0x3A, 0x4E])
        }
    }

    public func EscribirFraseMarcador_5026(NumeroFrase:UInt8) -> Bool {
        //pone una frase en pantalla e inicia su sonido (siempre y cuando no esté poniendo una)
        //parámetro = byte leido después de la dirección desde la que se llamó a la rutina
        var EscribirFraseMarcador_5026:Bool
        var PunteroNotasHL:Int
        var PunteroFrasesHL:Int
        var NotaOctavaA:UInt8
        var Contador:Int
        var Valor:UInt8
        EscribirFraseMarcador_5026 = false
        //si se está reproduciendo alguna frase, sale
        if ReproduciendoFrase_2DA1 { return EscribirFraseMarcador_5026 }
        //502E
        //apunta a la tabla de octavas y notas para las frases del juego
        PunteroNotasHL = 0x5659 + Int(NumeroFrase)
        //lee la nota y octava de la voz y la graba
        NotaOctavaA = TablaNotasOctavasFrases_5659[PunteroNotasHL - 0x5659]
        //modifican la nota y la octava de la voz del canal3
        TablaTonosNotasVoces_1388[0x14B7 - 0x1388] = NotaOctavaA
        //503F
        //inicia la reproducción de la voz
        ReproduciendoFrase_2DA1 = true
        ReproduciendoFrase_2DA2 = true
        PalabraTerminada_2DA0 = true
        //504A
        //apunta a la tabla de frases
        PunteroFrasesHL = 0xBB00
        //505C
        //avanza hasta la frase que se va a decir
        for Contador in 0..<NumeroFrase {
            repeat {
                Valor = TablaCaracteresPalabrasFrases_B400[PunteroFrasesHL - 0xB400]
                PunteroFrasesHL = PunteroFrasesHL + 1
            } while Valor != 0xFF
        }
        //5052
        //guarda el puntero a la frase
        PunteroFraseActual_2D9E = PunteroFrasesHL
        //pone a 0 los caracteres en blanco que quedan por salir para que la frase haya salido totalmente por pantalla
        CaracteresPendientesFrase_2D9B = 0
        EscribirFraseMarcador_5026 = false
        return EscribirFraseMarcador_5026
    }

    public func LimpiarFrasesMarcador_5001() {
        //limpia la parte del marcador donde se muestran las frases
        var Contador:UInt8
        var Contador2:UInt8
        var PunteroPantallaHL:Int
        PunteroPantallaHL = 0xE658 //apunta a pantalla (96, 164)
        for Contador in 0...7 { //8 líneas de alto
            for Contador2 in 0..<0x20 { //repite hasta rellenar 128 pixels de esta línea
                //5008
                PantallaCGA[PunteroPantallaHL + Contador2 - 0xC000] = 0xFF
                cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL + Contador2 - 0xC000, Color: 0xFF)
            }
            //5013
            //pasa a la siguiente línea de pantalla
            PunteroPantallaHL = 0xC000 + DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL - 0xC000)
            //5018
        }
    }

    public func EscribirFraseMarcador_501B(NumeroFrase:UInt8) -> Bool {
        //pone una frase en pantalla e inicia su sonido (si hay otra frase puesta, se interrumpe)
        //parámetro = byte leido después de la dirección desde la que se llamó a la rutina
        //indica que no se está reproduciendo ninguna voz
        ReproduciendoFrase_2DA1 = false
        ReproduciendoFrase_2DA2 = false
        //limpia la parte del marcador donde se muestran las frases
        LimpiarFrasesMarcador_5001()
        //pone una frase en pantalla e inicia su sonido (siempre y cuando no esté poniendo una)
        return EscribirFraseMarcador_5026(NumeroFrase: NumeroFrase)
    }

    public func CompararDistanciaGuillermo_3E61(PersonajeIY:Int) -> UInt8 {
        //compara la distancia entre guillermo y el personaje que se le pasa en iy
        //si está muy cerca, devuelve 0, en otro caso devuelve algo != 0
        //parametros: iy = datos del personaje

        //tabla de valores para el computo de la distancia entre personajes, indexada según la orientación del personaje.
        //Cada entrada tiene 4 bytes
        //byte 0: valor a sumar a la distancia en x del personaje
        //byte 1: valor umbral para para decir que el personaje está cerca en x
        //byte 2: valor a sumar a la distancia en y del personaje
        //byte 3: valor umbral para para decir que el personaje está cerca en y
        //3D9F:     06 18 06 0C -> usado cuando la orientación del personaje es 0 (mirando hacia +x)
        //        06 0C 0C 18 -> usado cuando la orientación del personaje es 1 (mirando hacia -y)
        //        0C 18 06 0C -> usado cuando la orientación del personaje es 2 (mirando hacia -x)
        //        06 0C 06 18 -> usado cuando la orientación del personaje es 3 (mirando hacia +y)
        var CompararDistanciaGuillermo_3E61:UInt8
        var AlturaGuillermoA:UInt8
        var AlturaPersonajeA:UInt8
        var AlturaPlantaGuillermoB:UInt8
        var AlturaPlantaPersonajeB:UInt8
        var OrientacionPersonajeA:UInt8
        var PosicionXGuillermoA:UInt8
        var PosicionXPersonajeA:UInt8
        var PosicionYGuillermoA:UInt8
        var PosicionYPersonajeA:UInt8
        var PunteroDistanciaPersonajesHL:Int
        var DistanciaA:Int
        //a = altura de guillermo
        AlturaGuillermoA = TablaCaracteristicasPersonajes_3036[0x303A - 0x3036]
        //b = altura base de la planta en la que está guillermo
        AlturaPlantaGuillermoB = LeerAlturaBasePlanta_2473(AlturaGuillermoA)
        //a = altura del personaje
        AlturaPersonajeA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 4 - 0x3036]
        //b = altura base de la planta en la que está el personaje
        AlturaPlantaPersonajeB = LeerAlturaBasePlanta_2473(AlturaPersonajeA)
        //si los personajes no están en la misma planta, sale
        if AlturaPlantaGuillermoB != AlturaPlantaPersonajeB {
            CompararDistanciaGuillermo_3E61 = 0xFF //AlturaPlantaPersonajeB
            //parche para que
            return CompararDistanciaGuillermo_3E61
        }
        //3E71
        //obtiene la orientación del personaje
        OrientacionPersonajeA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 1 - 0x3036]
        //indexa en la tabla valores de distancia permisibles según la orientación
        PunteroDistanciaPersonajesHL = 4 * Int(OrientacionPersonajeA) + 0x3D9F
        //3E7C
        //obtiene la posición x de guillermo
        PosicionXGuillermoA = TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036]
        //le suma una constante según la orientación
        DistanciaA = Int(PosicionXGuillermoA) + Int(TablaDistanciaPersonajes_3D9F[PunteroDistanciaPersonajesHL - 0x3D9F])
        PunteroDistanciaPersonajesHL = PunteroDistanciaPersonajesHL + 1
        PosicionXPersonajeA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 2 - 0x3036]
        //le resta la posición x del personaje
        DistanciaA = DistanciaA - Int(PosicionXPersonajeA)
        //3E84
        //si la distancia en x entre la posición del personaje y de guillermo supera el umbral, sale
        if DistanciaA < 0 || DistanciaA >= TablaDistanciaPersonajes_3D9F[PunteroDistanciaPersonajesHL - 0x3D9F] {
            CompararDistanciaGuillermo_3E61 = 0xFF
            return CompararDistanciaGuillermo_3E61
        }
        //3E87
        PunteroDistanciaPersonajesHL = PunteroDistanciaPersonajesHL + 1
        //obtiene la posición y de guillermo
        PosicionYGuillermoA = TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036]
        //le suma una constante según la orientación
        DistanciaA = Int(PosicionYGuillermoA) + Int(TablaDistanciaPersonajes_3D9F[PunteroDistanciaPersonajesHL - 0x3D9F])
        PunteroDistanciaPersonajesHL = PunteroDistanciaPersonajesHL + 1
        PosicionYPersonajeA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 3 - 0x3036]
        //le resta la posición y del personaje
        DistanciaA = DistanciaA - Int(PosicionYPersonajeA)
        //3e90
        //si la distancia en y entre la posición del personaje y de guillermo supera el umbral, sale
        if DistanciaA < 0 || DistanciaA >= TablaDistanciaPersonajes_3D9F[PunteroDistanciaPersonajesHL - 0x3D9F] {
            CompararDistanciaGuillermo_3E61 = 0xFF
        } else { //si no, devuelve 0
            CompararDistanciaGuillermo_3E61 = 0
        }
        return CompararDistanciaGuillermo_3E61
    }

     public func BuscarEntradaTablaPalabras_3C3A(PunteroPalabrasHL:Int, NumeroPalabraB:UInt8) -> Int {
        //busca la entrada número b de la tabla de palabras
        var ContadorB:UInt8
        var PunteroPalabrasHL:Int = PunteroPalabrasHL
        for ContadorB in 0..<NumeroPalabraB {
             //busca el fin de la palabra actual
             while !LeerBitArray(TablaCaracteresPalabrasFrases_B400, PunteroPalabrasHL - 0xB400, 7) {
                 PunteroPalabrasHL = PunteroPalabrasHL + 1
             } //repite hasta que se acabe la entrada actual
             PunteroPalabrasHL = PunteroPalabrasHL + 1
         } //repite hasta encontrar la entrada
         return PunteroPalabrasHL
    }

     public func RealizarScrollFrase_3B9D(CaracterA:UInt8) {
         //realiza el scroll de la parte del marcador relativa a las frases y pinta el caracter que esté en a
         var PunteroPantallaHL:Int
         var ContadorB:UInt8
         var ContadorC:UInt8
         var Pixels:UInt8
         var ValorAnteriorPunteroCaracteresPantalla_2D97:Int
         //hl apunta a la parte de pantalla de las frases (104, 164)
         PunteroPantallaHL = 0xE65A
         for ContadorB in 0...7 { //b = 8 lineas
             for ContadorC in 0..<0x1E { //c = 30 bytes
                 //3BA4
                 Pixels = PantallaCGA[PunteroPantallaHL + ContadorC - 0xC000]
                 PantallaCGA[PunteroPantallaHL - 2 + ContadorC - 0xC000] = Pixels
                 cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL - 2 + ContadorC - 0xC000, Color: Pixels)
             }
             //3BAE
             PunteroPantallaHL = 0xC000 + DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL - 0xC000)
         }
         //3BB5
         //posición (h = y en pixels, l = x en bytes) (184, 164)
         PunteroPantallaHL = 0xA42E
         //fija la posición en la que debe dibujar el caracter (usado por la rutina 0x3b13)
         ValorAnteriorPunteroCaracteresPantalla_2D97 = PunteroCaracteresPantalla_2D97
         PunteroCaracteresPantalla_2D97 = PunteroPantallaHL
         //¿es un espacio en blanco?
         //modifica la tabla de envolventes y cambios de volumen para la voz
         if CaracterA == 0x20 {
             //si es un espacio en blanco, pone 0
             TablaTonosNotasVoces_1388[0x13C2 - 0x1388] = 0
         } else {
             TablaTonosNotasVoces_1388[0x13C2 - 0x1388] = 6
         }
         //3BC7
         ImprimirCaracter_3B19(CaracterA: CaracterA, AjusteColorC: 0xFF)
         //restaura el valor de esta variable, ya que ha sido modificado
         PunteroCaracteresPantalla_2D97 = ValorAnteriorPunteroCaracteresPantalla_2D97
     }

     public func ActualizarFrase_3B54() {
         //escribe las frases en el marcador
         struct Estatico {
             static var Contador_2D9A:UInt8 = 0
         }
         var CaracterA:UInt8
         var TonoA:UInt8
         var PunteroFraseHL:Int
         var PunteroPalabraHL:Int
         var ValorC:UInt8
         //tabla de símbolos de puntuación
         //38E2:     C0 -> 0x00 (0xfa) -> ¿
         //        BF -> 0x01 (0xfb) -> ?
         //        BB -> 0x02 (0xfc) -> ;
         //        BD -> 0x03 (0xfd) -> .
         //        BC -> 0x04 (0xfe) -> ,
         Estatico.Contador_2D9A = Estatico.Contador_2D9A + 1
         //si no es 45 sale
         if Estatico.Contador_2D9A < 0x4 { return }
         //3B5F
         Estatico.Contador_2D9A = 0 //mantiene entre 0 y 44
         //si no está mostrando una frase, sale
         if !ReproduciendoFrase_2DA2 { return }
         //3B68
         ReproducirSonidoVoz_1020()
         //3B76
         while true {
             if !PalabraTerminada_2DA0 {
                 //3B7C
                 //obtiene el texto que se está poniendo en el marcador
                 if PunteroPalabraMarcador_2D9C >= 0xB400 {
                     //lee el carácter de la tabla de caracteres
                     CaracterA = TablaCaracteresPalabrasFrases_B400[PunteroPalabraMarcador_2D9C - 0xB400]
                 } else {
                     //lee el carácter de la tabla de símbolos
                     CaracterA = TablaSimbolos_38E2[PunteroPalabraMarcador_2D9C - 0x38E2]
                 }
                 //si tiene puesto el bit 7
                 if LeerBitByte(CaracterA, 7) {
                     PalabraTerminada_2DA0 = true //indica que ha terminado la palabra
                 }
                 //3B88
                 //se queda con los 3 bits menos significativos de la letra actual
                 TonoA = CaracterA & 0x07
                 //modifica los tonos de la voz
                 TablaTonosNotasVoces_1388[0x1389 - 0x1388] = TonoA
                 TablaTonosNotasVoces_1388[0x138F - 0x1388] = TonoA
                 TablaTonosNotasVoces_1388[0x138C - 0x1388] = Z80Neg(TonoA)
                 //3b96
                 //obtiene los 7 bits menos significativos de la letra actual
                 CaracterA = CaracterA & 0x7F
                 //actualiza el puntero a los datos del texto
                 PunteroPalabraMarcador_2D9C = PunteroPalabraMarcador_2D9C + 1
                 //realiza el scroll de la parte del marcador relativa a las frases y pinta el caracter que esté en a
                 RealizarScrollFrase_3B9D(CaracterA: CaracterA)
                 return
             } else {
                 //3BD7
                 while true {
                     //aqui llega si se ha terminado una palabra (0x2da0 = 1)
                     if CaracteresPendientesFrase_2D9B != 0 {
                         //3BDD
                         //decrementa los caracteres que quedan por decir
                         CaracteresPendientesFrase_2D9B = CaracteresPendientesFrase_2D9B - 1
                         if CaracteresPendientesFrase_2D9B > 0 {
                             //3BE1
                             //realiza el scroll de la parte del marcador relativa a las frases y pinta un espacio en blanco
                             RealizarScrollFrase_3B9D(CaracterA: 0x20)
                         } else {
                             //3BE5
                             //si la frase ha terminado (caracteres por decir = 0), lo indica y sale
                             ReproduciendoFrase_2DA2 = false
                         }
                         return
                     } else {
                         //3BEC
                         //aquí llega si aún quedan caracteres por decir
                        //PalabraTerminada_2DA0 = CaracteresPendientesFrase_2D9B
                         if CaracteresPendientesFrase_2D9B > 0 {
                            PalabraTerminada_2DA0 = true
                         } else {
                            PalabraTerminada_2DA0 = false
                         }
                         //obtiene el puntero a los datos de la voz actual
                         PunteroFraseHL = PunteroFraseActual_2D9E
                         //lee un byte
                         CaracterA = TablaCaracteresPalabrasFrases_B400[PunteroFraseHL - 0xB400]
                         //si han terminado los datos de la voz
                         if CaracterA == 0xFF {
                             //3BF7
                             //indica que quedan 11 caracteres por mostrar
                             CaracteresPendientesFrase_2D9B = 0x11
                             //indica que se ha terminado la palabra
                             PalabraTerminada_2DA0 = true
                         } else {
                             //3C03
                             if CaracterA < 0xFA {
                                 //3C07
                                 PunteroFraseHL = PunteroFraseHL + 1
                                 if CaracterA >= 0xF9 {
                                     //3C0E
                                     //c = 00, ningún espacio en blanco
                                     ValorC = 0
                                     //si el valor leido es 0xf9, hay que decir la siguiente palabra siguiendo a la actual
                                     CaracterA = TablaCaracteresPalabrasFrases_B400[PunteroFraseHL - 0xB400]
                                     PunteroFraseHL = PunteroFraseHL + 1
                                 } else {
                                     //c = espacio en blanco
                                     ValorC = 0x20
                                 }
                                 //3C12
                                 PunteroFraseActual_2D9E = PunteroFraseHL
                                 PunteroPalabraHL = 0xB580 //apunta a la tabla de palabras
                                 //si el byte leido no era 0, busca la entrada correspondiente en la tabla de palabras
                                 if CaracterA != 0 {
                                    PunteroPalabraHL = BuscarEntradaTablaPalabras_3C3A(PunteroPalabrasHL: PunteroPalabraHL, NumeroPalabraB: CaracterA)
                                 }
                                 //guarda la dirección de la palabra
                                 PunteroPalabraMarcador_2D9C = PunteroPalabraHL
                                 if ValorC == 0 {
                                     //3C22
                                     //vuelve al principio a procesar el caracter siguiente
                                     break
                                 } else {
                                     //3C25
                                     //realiza el scroll de la parte del marcador relativa a las frases y pinta el caracter que esté en a
                                    RealizarScrollFrase_3B9D(CaracterA: ValorC)
                                     return
                                 }
                             } else {
                                 //3C28
                                 //aquí llega si el valor leido es mayor o igual que 0xfa
                                 CaracterA = CaracterA - 0xFA
                                 PunteroFraseHL = PunteroFraseHL + 1
                                 //actualiza la dirección de los datos de la frase
                                 PunteroFraseActual_2D9E = PunteroFraseHL
                                 //hl apunta a la tabla de símbolos de puntuación
                                 //cambia la dirección del texto que se está poniendo en el marcador
                                 PunteroPalabraMarcador_2D9C = 0x38E2 + Int(CaracterA)
                                 break
                             }
                         }
                     }
                }
             }
        }
     }

     
     public func ProcesarLogicaAdso_5DA1() {
         //TablaVariablesLogica_3C85[DondeVaAdso_3d13 - 0x3C85] = 0xFF //sigue a guillermo
         //TablaVariablesLogica_3C85[DondeVaAdso_3d13 - 0x3C85] = 0x1 //va al refectorio.
         //TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0x0 //va a la iglesia
         //Exit Sub
         //cambio de posición predefinida 0
         //TablaVariablesLogica_3C85[0x3D14 - 0x3C85] = 0x88
         //TablaVariablesLogica_3C85[0x3D15 - 0x3C85] = 0x88
         //TablaVariablesLogica_3C85[0x3D16 - 0x3C85] = 0x02

         //inicio de la lógica de adso
         //si guillermo tiene el pergamino
         if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) {
             //5da9
             //lo indica
             TablaVariablesLogica_3C85[EstadoPergamino_3C90 - 0x3C85] = 0
         }
         //5dac
         //si se está acabando la noche, informa de ello
         if TablaVariablesLogica_3C85[NocheAcabandose_3C8C - 0x3C85] == 1 {
             //5DB2
             //pone en el marcador la frase
             //PRONTO AMANECERA, MAESTRO
             EscribirFraseMarcador_5026(NumeroFrase: 0x27)
         }
         //5DB6
         //si ha cambiado el estado de la lámpara a 1
         if TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85] == 1 {
             //5DBC
             //indica que se procesado el cambio de estado de la lámpara
             TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85] = 0
             //escribe en el marcador la frase
             //LA LAMPARA SE AGOTA
             EscribirFraseMarcador_501B(NumeroFrase: 0x28)
         }
         //5DC3
         //si ha cambiado el estado de la lámpara a 2
         if TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85] == 2 {
             //5DC9
             //indica que se procesado el cambio de estado de la lámpara
             TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85] = 0
             //inicia el contador del tiempo que pueden ir a oscuras
             TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] = 0x32
             //indica que la lámpara ya no se está usando?
             TablaVariablesLogica_3C85[LamparaEncendida_3C8B - 0x3C85] = 0
             //oculta el área de juego
             PintarAreaJuego_1A7D(ColorFondo: 0xFF)
             //le quita la lámpara a adso y reinicia los contadores?
             InicializarLampara_3FF7()
             EscribirFraseMarcador_501B(NumeroFrase: 0x2A)
         }
         //5DDC
         //si guillermo no ha muerto
         if TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] == 0 {
             //5DE2
             //si se ha activado el contador del tiempo a oscuras
             if TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] >= 1 {
                 //5DE8
                 //altura en el escenario de guillermo < 0x18, es decir, si ha salido de la la biblioteca
                 if TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] < 0x18 {
                     //5DEF
                     //pone el contador a 0
                     TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] = 0
                     return
                 }
                 //5DF3
                 //aquí llega si sigue en la biblioteca
                 //decrementa el contador del tiempo que pueden ir a oscuras
                 TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] = TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] - 1
                 //si llega a 1
                 if TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] == 1 {
                     //5DFE
                     //indica que guillermo ha muerto
                     TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
                     //escribe en el marcador la frase
                     //JAMAS CONSEGUIREMOS SALIR DE AQUI
                     EscribirFraseMarcador_501B(NumeroFrase: 0x2B)
                     return
                 }
                 //5E06
                 //aquí llega si está activo el contador del tiempo que pueden ir a oscuras, pero aún no se ha terminado
             } else {
                 //5E08
                 //aquí llega si no se ha activado el contador del tiempo a oscuras
                 //si la altura de adso >= 0x18 (si adso acaba de entrar en la biblioteca)
                 if TablaCaracteristicasPersonajes_3036[0x3049 - 0x3036] >= 0x18 {
                     //5E0F
                     //indica que adso siga a guillermo
                     TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0xFF
                     //si adso no tiene la lámpara
                     if !LeerBitArray(TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7) {
                         //5E1A
                         //escribe en el marcador la frase
                         //DEBEMOS ENCONTRAR UNA LAMPARA, MAESTRO
                         EscribirFraseMarcador_501B(NumeroFrase: 0x13)
                         //activa el contador del tiempo que pueden a oscuras
                         TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] = 0x64
                         return
                     }
                     //5E22
                     //aqui se llega si adso tiene la lámpara y acaba de entrar a la biblioteca
                     //enciende la lámpara
                     TablaVariablesLogica_3C85[LamparaEncendida_3C8B - 0x3C85] = 1
                     return
                 }
                 //5E26
                 //aquí llega si adso no está en la biblioteca
                 //indica que la lámpara no se está usando
                 TablaVariablesLogica_3C85[LamparaEncendida_3C8B - 0x3C85] = 0
                 //anula el contador del tiempo que pueden ir a oscuras
                 TablaVariablesLogica_3C85[ContadorTiempoOscuras_3C8E - 0x3C85] = 0
             }
         }
         //5E2C
         //si está en sexta
         if MomentoDia_2D81 == 3 {
             //5E32
             //va al refectorio
             TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0x1
             //indica que falta algún monje en misa/refectorio
             TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 7
             //cambia la frase a mostrar por DEBEMOS IR AL REFECTORIO, MAESTRO
             NumeroFrase_3F0E = 0x0C
             //termina de procesar la lógica de adso
             ProcesarLogicaAdso_5EE5()
             return
         }
         //5E3E
         //si es prima o vísperas
         if MomentoDia_2D81 == 5 || MomentoDia_2D81 == 1 {
             //5E48
             //va a la iglesia
             TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0x0
             //indica que falta algún monje en misa/refectorio
             TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 1
             //cambia la frase a mostrar por DEBEMOS IR A LA IGLESIA, MAESTRO
             NumeroFrase_3F0E = 0x0B
             ProcesarLogicaAdso_5EE5()
             return
         }
         //5E54
         //aquí llega si no es prima ni vísperas ni sexta
         //si está en completas
         if MomentoDia_2D81 == 6 {
             //5E5A
             //cambia el estado de adso
             TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] = 6
             //ld   b,$D7  ???
             //se dirige a la celda
             TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 2
             return
         }
         //5E61
         //aquí llega si no es prima ni vísperas ni sexta ni completas
         //si es de noche
         if MomentoDia_2D81 == 0 {
             //5E68
             //si el estado es 4 (estaba en la celda esperando contestacion)
             if TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] == 4 {
                 //5E6E
                 //si se muestra la pantalla número 0x37 (la de fuera de nuestra celda)
                 if NumeroPantallaActual_2DBD == 0x37 {
                     //5E74
                     //se pasa al siguiente día
                     TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 2
                 }
                 //5E77
                 //si no se está reproduciendo una voz
                 if ReproduciendoFrase_2DA1 == false {
                     //5E7D
                     //si el contador para contestar es >= 100
                     if TablaVariablesLogica_3C85[ContadorRespuestaSN_3C99 - 0x3C85] >= 0x64 {
                         //5E83
                         //si tardamos en contestar, pasa al siguiente día
                         TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 2
                         return
                     }
                     //5E87
                     //incrementa el contador
                     TablaVariablesLogica_3C85[ContadorRespuestaSN_3C99 - 0x3C85] = TablaVariablesLogica_3C85[ContadorRespuestaSN_3C99 - 0x3C85] + 1
                     //imprime S:N o borra S:N dependiendo del bit 1 de 0x3c99
                     EscribirBorrar_S_N_5065()
                     //dependiendo del bit 1, lee el estado del teclado
                     if LeerBitArray(TablaVariablesLogica_3C85, ContadorRespuestaSN_3C99 - 0x3C85, 0) {
                         //5E97
                         //comprueba si se ha pulsado la S
                         if TeclaPulsadaNivel_3482(0x3C) {
                             //5EAA
                             //se avanza al siguiente día
                             TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 2
                             return
                         }
                         //5E9E
                         //comprueba si se ha pulsado la N
                         if TeclaPulsadaNivel_3482(0x2E) {
                             //5EA6
                             TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] = 5
                         }
                         return
                     }
                 }
                 //5EAD
                 return
             }
             //5EAE
             //aqui llega si es de noche y 0x3d12 no era 4
             //sigue a guillermo
             TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0xFF
             //si el estado es 5 (no dormimos)
             if TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] == 5 {
                 //5EB8
                 //si estamos en la pantalla 0x3e
                 if NumeroPantallaActual_2DBD == 0x3E {
                     //5EBF
                     return
                 }
                 //5EC0
                 //aquí llega si no estamos en nuestra celda
                 //si salimos de nuestra celda, cambia al estado 6
                 TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] = 6
             }
             //5EC3
             if TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] == 6 {
                 //5EC9
                 //compara la distancia entre guillermo y adso (si está muy cerca devuelve 0, en otro caso != 0)
                 if CompararDistanciaGuillermo_3E61(PersonajeIY: 0x3045) == 0 {
                     //5ECE
                     //si estamos en la pantalla 0x3e (nuestra celda)
                     if NumeroPantallaActual_2DBD == 0x3E {
                         //5ED5
                         teclado!.Inicializar() //resetea el estado de todas las teclas para evitar pulsaciones fantasma
                         //inicia el contador del tiempo de respuesta de guillermo a la pregunta de dormir
                         TablaVariablesLogica_3C85[ContadorRespuestaSN_3C99 - 0x3C85] = 0
                         //cambia el estado de adso
                         TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] = 4
                         //pone en el marcador la frase
                         //¿DORMIMOS?, MAESTRO
                         EscribirFraseMarcador_5026(NumeroFrase: 0x12)
                     }
                 }
                 //5EDF
                 return
             }
         }
         //5EE0
         //sigue a guillermo
         TablaVariablesLogica_3C85[DondeVaAdso_3D13 - 0x3C85] = 0xFF
     }

     public func ProcesarLogicaAdso_5EE5() {
         //parte final de la lógica de adso
         if TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] == TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] {
             //si son iguales, sale
             return
         }
         //5EEC
         if CompararDistanciaGuillermo_3E61(PersonajeIY: 0x3045) == 0 { //si está cerca de guillermo
             //5EF1
             //pone en el marcador una frase (la frase se cambia dependiendo del estado)
            EscribirFraseMarcador_5026(NumeroFrase: NumeroFrase_3F0E)
         }
         //5EF4
         TablaVariablesLogica_3C85[EstadoAdso_3D12 - 0x3C85] = TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85]
     }

     public func ComprobarDestinoAvanzarEstado_3E98(PunteroVariablesLogicaIX:Int) {
         //si ha llegado al sitio al que quería llegar, avanza el estado
         //obtiene a donde va. lo compara con donde ha llegado
         if TablaVariablesLogica_3C85[PunteroVariablesLogicaIX - 1 - 0x3C85] != TablaVariablesLogica_3C85[PunteroVariablesLogicaIX - 3 - 0x3C85] {
             return //si no ha llegado donde quería ir, sale
         }
         //en otro caso avanza el estado
         TablaVariablesLogica_3C85[PunteroVariablesLogicaIX - 2 - 0x3C85] = TablaVariablesLogica_3C85[PunteroVariablesLogicaIX - 2 - 0x3C85] + 1
     }

     public func MatarMalaquias_4386() {
         //si está muriendo, avanza la altura de malaquías
         //438F
         //indica que malaquías está ascendiendo mientras se está muriendo
         MalaquiasAscendiendo_4384 = true
         //incrementa la altura de malaquías
         TablaCaracteristicasPersonajes_3036[0x3058 - 0x3036] = TablaCaracteristicasPersonajes_3036[0x3058 - 0x3036] + 1
         //si es < 20, sale
         if TablaCaracteristicasPersonajes_3036[0x3058 - 0x3036] < 0x20 { return }
         //439E
         //aquí llega cuando malaquías ha desaparecido de la pantalla
         //pone a 0 la posición x de malaquías
         TablaCaracteristicasPersonajes_3036[0x3056 - 0x3036] = 0
         //indica que malaquías ha muerto
         TablaVariablesLogica_3C85[MalaquiasMuriendose_3CA2 - 0x3C85] = 2
         //indica que malaquías ha llegado a la iglesia
         TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] = 0
     }

     public func DejarLlavePasadizo_4022() {
         //deja la llave del pasadizo en la mesa de malaquías
         //obtiene los objetos de malaquías
         //si no tiene la llave del pasadizo de detrás de la cocina, sale
         if !LeerBitArray(TablaObjetosPersonajes_2DEC, 0x2DFD - 0x2DEC, 1) { return }
         //4028
         //le quita la llave del pasadizo de detrás de la cocina
         ClearBitArray(&TablaObjetosPersonajes_2DEC, 0x2DFD - 0x2DEC, 1)
         //copia en 0x3026 -> 00 00 35 35 13 (pone la llave3 en la mesa)
         CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3026, Bytes: [0, 0, 0x35, 0x35, 0x13])
     }

     public func ActualizarMomentoDia_5527() {
         //comprueba si hay que pasar al siguiente momento del día
         //comprueba si ha cambiado el estado del enter
         if TeclaPulsadaFlanco_3472(CodigoTecla: 6) && depuracion.SaltarMomentoDiaEnter {
             //si se pulsó enter, avanza la etapa del día
             ActualizarMomentoDia_553E()
             return
         }
         //5531
         //si el contador para que pase el momento del día es 0, sale
         if TiempoRestanteMomentoDia_2D86 == 0 { return }
         //5537
         //decrementa el contador del momento del día y si llega a 0, actualiza el momento del día
         TiempoRestanteMomentoDia_2D86 = TiempoRestanteMomentoDia_2D86 - 1
         if TiempoRestanteMomentoDia_2D86 > 0 { return }
         ActualizarMomentoDia_553E()
     }

     public func ComprobarEstadoLampara_41FD() -> UInt8 {
         //comprueba si se está agotando la lámpara
         var ComprobarEstadoLampara_41FD:UInt8
         var EstadoLamparaC:UInt8
         var TiempoUsoLamparaHL:Int
         //lee el estado de la lámpara
         EstadoLamparaC = TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85]
         ComprobarEstadoLampara_41FD = EstadoLamparaC
         //si adso no tiene la lámpara, sale
         if !LeerBitArray(TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7) { return ComprobarEstadoLampara_41FD }
         //4207
         //si no ha entrado al laberinto/la lampara no se está usando, sale
         if TablaVariablesLogica_3C85[LamparaEncendida_3C8B - 0x3C85] == 0 { return ComprobarEstadoLampara_41FD }
         //420C
         //si la pantalla está iluminada, sale
         if !HabitacionOscura_156C { return ComprobarEstadoLampara_41FD }
         //4211
         //incrementa el tiempo de uso de la lámpara
         TiempoUsoLamparaHL = Leer16(TablaVariablesLogica_3C85, TiempoUsoLampara_3C87 - 0x3C85)
         TiempoUsoLamparaHL = TiempoUsoLamparaHL + 1
         Escribir16(&TablaVariablesLogica_3C85, TiempoUsoLampara_3C87 - 0x3C85, TiempoUsoLamparaHL)
         //si l no es 0, sale
         if (TiempoUsoLamparaHL % 256) != 0 { return ComprobarEstadoLampara_41FD }
         //421B
         //si no ha procesado el cambiado de estado de la lámpara, sale
         if EstadoLamparaC != 0 { return ComprobarEstadoLampara_41FD }
         //421E
         //si el tiempo de uso de la lámpara ha llegado a 0x3xx, sale con c = 1 (se está agotando la lámpara)
         if TiempoUsoLamparaHL >> 8 == 3 {
             ComprobarEstadoLampara_41FD = 1
             return ComprobarEstadoLampara_41FD
         }
         //si el tiempo de uso de la lámpara ha llegado a 0x6xx, sale con c = 2 (se ha agotado la lámpara)
         if TiempoUsoLamparaHL >> 8 == 6 {
             ComprobarEstadoLampara_41FD = 2
             return ComprobarEstadoLampara_41FD
         }
         return ComprobarEstadoLampara_41FD
    }

    public func ComprobarAcabandoNoche_422B() -> UInt8 {
        //comprueba si se está acabando la noche
        var ComprobarAcabandoNoche_422B:UInt8
        ComprobarAcabandoNoche_422B = 0
        //obtiene la cantidad de tiempo a esperar para que avance el momento del día
        //si es 0, sale
        if TiempoRestanteMomentoDia_2D86 == 0 { return ComprobarAcabandoNoche_422B }
        //4233
        //en otro caso, espera si la parte inferior del contador para que pase el momento del día no es 0, sale
        if (TiempoRestanteMomentoDia_2D86 & 0x000000FF) != 0 { return ComprobarAcabandoNoche_422B }
        //4236
        //si no es de noche, sale
        if MomentoDia_2D81 != 0 { return ComprobarAcabandoNoche_422B }
        //423B
        //si la parte superior del contador es 2, sale con c = 1
        if TiempoRestanteMomentoDia_2D86 >> 8 == 2 {
            ComprobarAcabandoNoche_422B = 1
            return ComprobarAcabandoNoche_422B
        }
        //4240
        //en otro caso, si no es 0, sale con c = 0
        if TiempoRestanteMomentoDia_2D86 != 0  { return ComprobarAcabandoNoche_422B }
        //si es 0, incrementa el momento del día y sale con c = 0
        TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
        return ComprobarAcabandoNoche_422B
    }

    public func ActualizarVariablesTiempo_55B6() {
        //comprueba si hay que modificar las variables relacionadas con el tiempo (momento del día, combustible de la lámpara, etc)
        var EstadoLamparaA:UInt8
        var AcabandoNocheA:UInt8
        //comprueba si hay que avanzar la etapa del día (si se ha pulsado enter también se cambia)
        ActualizarMomentoDia_5527()
        //comprueba si se está usando la lámpara, y si es así, si se está agotando
        EstadoLamparaA = ComprobarEstadoLampara_41FD()
        //actualiza el estado de la lámpara
        TablaVariablesLogica_3C85[EstadoLampara_3C8D - 0x3C85] = EstadoLamparaA
        //comprueba si se está acabando la noche
        AcabandoNocheA = ComprobarAcabandoNoche_422B()
        //actualiza la variable que indica si se está acabando la noche
        TablaVariablesLogica_3C85[NocheAcabandose_3C8C - 0x3C85] = AcabandoNocheA
    }

    public func LeerPosicionObjetoDejar_534F( _ PunteroPersonajeObjetoIX:Int, _ PosicionObjetoBC: inout Int, _ AlturaObjetoA: inout UInt8) {
        //obtiene la posición donde dejará el objeto y la altura a la que está el personaje que lo deja
        //modifica una rutina con los datos de posición del personaje y su orientación
        //devuelve  en bc la posición del personaje + 2*desplazamiento en según orientación
        var PunteroPersonajeDE:Int
        var PosicionX:UInt8
        var PosicionY:UInt8
        var Orientacion:UInt8
        var IncrementoX:Int
        var IncrementoY:Int
        var PosicionXPersonajeCoger:Int
        //On Error Resume Next
        //lee la dirección de los datos de posición del personaje
        PunteroPersonajeDE = Leer16(TablaObjetosPersonajes_2DEC, PunteroPersonajeObjetoIX + 1 - 0x2DEC) - 2
        //lee la orientación del personaje
        Orientacion = TablaCaracteristicasPersonajes_3036[PunteroPersonajeDE + 1 - 0x3036]
        //hl apunta a la tabla de desplazamiento a sumar si sigue avanzando en esa orientación
        //hl = hl + 8*a
        IncrementoX = Leer8Signo(TablaAvancePersonaje4Tiles_284D, 0x2853 + 8 * Int(Orientacion) - 0x284D)
        //lee la posición x del personaje
        PosicionX = TablaCaracteristicasPersonajes_3036[PunteroPersonajeDE + 2 - 0x3036]
        //le suma 2 veces el valor leido de la tabla y modifica una comparación
        PosicionXPersonajeCoger = Int(PosicionX) + 2 * Int(IncrementoX)
        if PosicionXPersonajeCoger < 0 { PosicionXPersonajeCoger = 0 }
        PosicionXPersonajeCoger_516E = UInt8(PosicionXPersonajeCoger)
        //5364
        //lee la posición y del personaje
        PosicionY = TablaCaracteristicasPersonajes_3036[PunteroPersonajeDE + 3 - 0x3036]
        IncrementoY = Leer8Signo(TablaAvancePersonaje4Tiles_284D, 0x2853 + 1 + 8 * Int(Orientacion) - 0x284D)
        //le suma 2 veces el valor leido de la tabla
        PosicionYPersonajeCoger_5173 = UInt8(Int(PosicionY) + 2 * Int(IncrementoY))
        //536D
        //modifica una resta
        AlturaPersonajeCoger_5167 = TablaCaracteristicasPersonajes_3036[PunteroPersonajeDE + 4 - 0x3036]
        PosicionObjetoBC = Int(PosicionYPersonajeCoger_5173) << 8 | Int(PosicionXPersonajeCoger_516E)
        AlturaObjetoA = AlturaPersonajeCoger_5167
    }

    public func DibujarObjeto_0D13(SpriteIX:Int, ObjetoIY:Int) {
        //salta a la rutina de redibujado de objetos para redibujar solo el objeto que se deja
        //llega con ix = sprite del objeto que se deja
        //llega con iy = datos del objeto que se deja
        //hace que solo procese un objeto de la lista
        //0DBB=rutina a la que saltar para procesar los objetos del juego
        //llama a la rutina para que se redibuje el objeto
        ProcesarObjetos_0D3B(0x0DBB, SpriteIX, ObjetoIY, ProcesarSoloUno: true)
    }

    public func DejarObjeto_5277( _ PunteroPersonajeObjetoIX:Int) {
        //deja algún objeto y marca el sprite del objeto para dibujar
        var ObjetosA:UInt8
        var ObjetoC:UInt8=0
        var PosicionObjetoBC:Int=0
        var PosicionObjetoX:UInt8=0
        var PosicionObjetoY:UInt8=0
        var AlturaObjetoA:UInt8=0
        var AlturaRelativa_52C1:UInt8
        var PunteroBufferAlturasIX:Int
        var AlturaA:UInt8
        var AlturaBaseObjetoB:UInt8
        var PunteroPersonajeHL:Int
        var OrientacionA:UInt8
        var Contador:UInt8
        var MascaraHL:Int
        var MascaraA:UInt8
        var PunteroSpritesIX:Int
        var PunteroPosicionObjetosIY:Int
        //lee los objetos que tenemos
        ObjetosA = TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX + 3 - 0x2DEC]
        for ContadorObjetoC:UInt8 in 1...8 { //8 objetos
            ObjetoC = ContadorObjetoC
            //si tiene el objeto que se está comprobando, salta
            if LeerBitByte(ObjetosA, 7) { break }
            if ObjetoC == 8 { return }
            ObjetosA = ObjetosA << 1
        } //comprueba para todos los objetos
        //5284
        //aquí llega cuando se pulsó espacio y tenía algún objeto (c = número de objeto)
        //decrementa el contador
        if TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX + 6 - 0x2DEC] != 0 {
            //si no era 0, sale
            DecByteArray(&TablaObjetosPersonajes_2DEC, PunteroPersonajeObjetoIX + 6 - 0x2DEC)
            return
        }
        //5294
        //obtiene la posición donde dejará el objeto y la altura a la que está el personaje
        LeerPosicionObjetoDejar_534F(PunteroPersonajeObjetoIX, &PosicionObjetoBC, &AlturaObjetoA)
        //altura relativa del objeto
        AlturaBaseObjetoB = LeerAlturaBasePlanta_2473(AlturaObjetoA)
        AlturaRelativa_52C1 = AlturaObjetoA - AlturaBaseObjetoB
        Integer2Nibbles(Value: PosicionObjetoBC, HighNibble: &PosicionObjetoY, LowNibble: &PosicionObjetoX)
        //52A7
        //si el objeto no se deja en la misma planta, salta
        //52A9
        //ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
        //si hay acarreo, la posición no está dentro del rectángulo visible, por lo que salta
        if AlturaBasePlantaActual_2DBA == AlturaBaseObjetoB && DeterminarPosicionCentral_279B(&PosicionObjetoX, &PosicionObjetoY) {
            //52AE
            //0cd4
            PunteroBufferAlturasIX = Int(PosicionObjetoY) * 24 + Int(PosicionObjetoX) + PunteroBufferAlturas_2D8A
            //52B1
            //obtiene la entrada correspondiente del buffer de alturas
            AlturaA = LeerByteBufferAlturas(PunteroBufferAlturasIX)
            //si hay algún personaje en esa posición, sale
            if (AlturaA & 0xF0) != 0 { return }
            //52B9
            //si se deja en una posición con una altura >= 0x0d, sale
            if AlturaA >= 0x0D { return }
            //52C0
            //si la altura de la posición donde se deja - altura del personaje que deja el objeto >= 0x05, sale
            if (Int(AlturaA) - Int(AlturaRelativa_52C1)) >= 5 { return }
            //52C6
            AlturaA = AlturaA & 0x0F
            //la compara con la de sus vecinos y si no es igual, sale
            if AlturaA != LeerByteBufferAlturas(PunteroBufferAlturasIX - 1) { return }
            if AlturaA != LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x18) { return }
            if AlturaA != LeerByteBufferAlturas(PunteroBufferAlturasIX - 0x19) { return }
            //a = altura total de la posición en la que se deja el objeto
            AlturaA = AlturaA + AlturaBasePlantaActual_2DBA
        } else {
            //52E5
            //aquí llega si el objeto no se deja en la misma planta que la de la pantalla en la que se está o no se deja en la misma habitación
            //obtiene la dirección de la posición del personaje
            PunteroPersonajeHL = Leer16(TablaObjetosPersonajes_2DEC, PunteroPersonajeObjetoIX + 1 - 0x2DEC)
            //de = posición global del personaje
            PosicionObjetoBC = Leer16(TablaCaracteristicasPersonajes_3036, PunteroPersonajeHL - 0x3036)
            //a = altura global del personaje
            AlturaA = TablaCaracteristicasPersonajes_3036[PunteroPersonajeHL + 2 - 0x3036]
        }
        //52F3
        //aquí también llega si el objeto está en la misma habitación que se muestra en pantalla
        //obtiene la dirección de la posición del personaje
        PunteroPersonajeHL = Leer16(TablaObjetosPersonajes_2DEC, PunteroPersonajeObjetoIX + 1 - 0x2DEC)
        PunteroPersonajeHL = PunteroPersonajeHL - 1
        if depuracion.BugDejarObjetoPresente {
            //52FC
            //guarda la altura del objeto en h
            PunteroPersonajeHL = (PunteroPersonajeHL & 0x000000FF) | (Int(AlturaA) << 8)
            //¡fallo del juego! quiere obtener la orientación del personaje pero ha sobreescrito h
            OrientacionA = LeerByteTablaCualquiera(PunteroPersonajeHL)
        } else {
            OrientacionA = TablaCaracteristicasPersonajes_3036[PunteroPersonajeHL - 0x3036]
        }
        //52FE
        OrientacionA = OrientacionA ^ 0x02
        //inicia el contador para coger/dejar objetos
        TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX + 6 - 0x2DEC] = 0x10
        //5307
        //empieza a comprobar si tiene el objeto indicado por el bit 7
        MascaraHL = 0x8000
        for Contador in 1..<ObjetoC {
            MascaraHL = MascaraHL >> 1
        }
        //5313
        MascaraA = UInt8(MascaraHL & 0x000000FF)
        //el bit del objeto que se deja está a 0 y el resto de bits a 1
        MascaraA = MascaraA ^ 0xFF
        //combina los objetos que tenía para eliminar el que deja
        TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX - 0x2DEC] = MascaraA & TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX - 0x2DEC]
        //531B
        MascaraA = UInt8((MascaraHL & 0x0000FF00) >> 8)
        //el bit del objeto que se deja está a 0 y el resto de bits a 1
        MascaraA = MascaraA ^ 0xFF
        //combina los objetos que tenía para eliminar el que deja
        TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX + 3 - 0x2DEC] = MascaraA & TablaObjetosPersonajes_2DEC[PunteroPersonajeObjetoIX + 3 - 0x2DEC]
        //5323
        //apunta a los sprites de los objetos
        PunteroSpritesIX = 0x2F1B
        //apunta a los datos de posición de los objetos
        PunteroPosicionObjetosIY = 0x3008
        for Contador in 1..<ObjetoC {
            PunteroSpritesIX = PunteroSpritesIX + 0x14 //avanza el siguiente sprite
            PunteroPosicionObjetosIY = PunteroPosicionObjetosIY + 5 //avanza al siguiente dato de posición
        }
        //533B
        //indica que no se tiene el objeto
        ClearBitArray(&TablaPosicionObjetos_3008, PunteroPosicionObjetosIY - 0x3008, 7)
        //guarda la altura de destino del objeto
        TablaPosicionObjetos_3008[PunteroPosicionObjetosIY + 4 - 0x3008] = AlturaA
        //guarda la orientación del objeto
        TablaPosicionObjetos_3008[PunteroPosicionObjetosIY + 1 - 0x3008] = OrientacionA
        //guarda la posición global de destino del objeto
        Integer2Nibbles(Value: PosicionObjetoBC, HighNibble: &PosicionObjetoY, LowNibble: &PosicionObjetoX)
        TablaPosicionObjetos_3008[PunteroPosicionObjetosIY + 2 - 0x3008] = PosicionObjetoX
        TablaPosicionObjetos_3008[PunteroPosicionObjetosIY + 3 - 0x3008] = PosicionObjetoY
        //534C
        //salta a la rutina de redibujado de objetos para redibujar solo el objeto que se deja
        DibujarObjeto_0D13(SpriteIX: PunteroSpritesIX, ObjetoIY: PunteroPosicionObjetosIY)
    }

    public func ComprobarColocacionGuillermo_43C4(PosicionReferenciaDE:Int) -> UInt8 {
        //comprueba que guillermo esté en una posición determinada (de la planta baja) indicada por de, con la orientación = 1
        //devuelve en c 0, si no está en la habitación de la posición, 2 si está en la habitación de la posición y 1 si está en la posición indicada y con la orientación correcta
        var ComprobarColocacionGuillermo_43C4:UInt8
        var AlturaGuillermoA:UInt8
        var PosicionGuillermoX:UInt8
        var PosicionGuillermoY:UInt8
        var ValorA:UInt8
        var PosicionReferenciaD:UInt8=0
        var PosicionReferenciaE:UInt8=0
        //c = 0, no está en su sitio
        ComprobarColocacionGuillermo_43C4 = 0
        //obtiene la altura de guillermo
        AlturaGuillermoA = TablaCaracteristicasPersonajes_3036[0x303A - 0x3036]
        //si  está en la planta baja (altura < 0x0b)
        if AlturaGuillermoA < 0x0B {
            //43CD
            Integer2Nibbles(Value: PosicionReferenciaDE, HighNibble: &PosicionReferenciaD, LowNibble: &PosicionReferenciaE)
            //lee la posición en x
            PosicionGuillermoX = TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036]
            //lee la posición en y
            PosicionGuillermoY = TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036]
            ValorA = (PosicionGuillermoX ^ PosicionReferenciaE) | (PosicionGuillermoY ^ PosicionReferenciaD)
            //43D7
            //si la posición está en la misma habitación (a < 0x10)
            if ValorA < 0x10 {
                //43DB
                //c = 0x02, en la habitación pero no en la posición correcta
                ComprobarColocacionGuillermo_43C4 = 2
                //43DD
                //si Guillermo está en la misma habitación que la posición de referencia
                if ValorA == 0 {
                    //43E0
                    //si la orientación del personaje es 1
                    if TablaCaracteristicasPersonajes_3036[0x3037 - 0x3036] == 1 {
                        //Guillermo está en la posición indicada con la orientación = 1
                        ComprobarColocacionGuillermo_43C4 = 1
                    }
                }
            }
        }
        //43E8
        //graba el resultado
        TablaVariablesLogica_3C85[GuillermoBienColocado_3C9B - 0x3C85] = ComprobarColocacionGuillermo_43C4
        return ComprobarColocacionGuillermo_43C4
    }

    public func ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498() {
        //rellena 3c96 con el destino combinado de Berengario/Bernardo, Adso, Severino y Malaquías
        //llamado el día 1, 2 y 4
        TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] =
            TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] |
            TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] |
            TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] |
            TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85]
    }

    public func ComprobarPresenciaAdsoSeverinoMalaquias_64A2() {
        //rellena 3c96 con el destino combinado de Adso, Severino y Malaquías
        //llamado el día 3
        TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] =
            TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] |
            TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] |
            TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85]
    }

    public func ComprobarPresenciaAdso_64BC() {
        //rellena 3c96 con el destino de Adso
        //llamado el día 6
        TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85]
    }

    public func QuitarPergamino_40B9() {
        //el abad deja el pergamino, si lo tiene
        //si el abad no tiene el pergamino, sale
        if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) { return }
        //40BF
        //modifica la máscara de objetos para no coger el pergamino
        TablaObjetosPersonajes_2DEC[MascaraObjetosAbad_2E06 - 0x2DEC] = 0
        //apunta a la tabla de datos de los objetos del abad
        //deja el pergamino
        DejarObjeto_5277(0x2E01)
        //pone a 0 el contador que se incrementa si no pulsamos los cursores
        TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = 0
    }

    public func ComprobarColocacionGuillermoMisa_43AC() {
        //comprueba que guillermo esté en la posición correcta de misa
        if ComprobarColocacionGuillermo_43C4(PosicionReferenciaDE: 0x4B84) != 0 { return }
        //posición imposible
        ComprobarColocacionGuillermo_43C4(PosicionReferenciaDE: 0x3080)
    }

    public func PresenciarMuerteMalaquias_64AA() {
        //si malaquías está muriéndose
        if TablaVariablesLogica_3C85[MalaquiasMuriendose_3CA2 - 0x3C85] >= 1 {
            //64B0
            //frase = MALAQUIAS HA MUERTO
            NumeroFrase_3F0E = 0x20
            //indica que ya están todos en su sitio
            TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 0
            return
        }
        //64B8
        //indica que aún no están todos en su sitio
        TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 1
    }

    public func ComprobarPresenciaPersonajesMisa_6487(DiaC:UInt8) {
        //comprueba que han llegado a misa de vísperas los personajes necesarios según el día
        //###depuración
        //ComprobarPresenciaAdso_64BC()
        //Exit Sub
        switch DiaC {
            case 1:
                ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498()
            case 2:
                ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498()
            case 3:
                ComprobarPresenciaAdsoSeverinoMalaquias_64A2()
            case 4:
                ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498()
            case 5:
                PresenciarMuerteMalaquias_64AA()
            case 6:
                ComprobarPresenciaAdso_64BC()
            default:
                break
        }
    }

    public func EsperarColocacionPersonajes_6520() {
        //espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
        //si el abad ha llegado a donde iba
        if TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] {
            //6526
            //si los monjes están listos para empezar la misa
            if TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] == 0 {
                //652C
                //si guillermo por lo menos ha llegado a la habitación
                if TablaVariablesLogica_3C85[GuillermoBienColocado_3C9B - 0x3C85] >= 1 {
                    //6532
                    //si se ha superado el contador de puntualidad
                    if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0x32 {
                        //6538
                        //reinicia el contador
                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                        //pone en el marcador la frase
                        //LLEGAIS TARDE, FRAY GUILLERMO
                        EscribirFraseMarcador_5026(NumeroFrase: 6)
                        //decrementa la vida de guillermo en 2 unidades
                        DecrementarObsequium_55D3(Decremento: 2)
                        return
                    } else {
                        //6544
                        //si no se está reproduciendo una voz
                        if ReproduciendoFrase_2DA1 == false {
                            //654A
                            //si guillermo no está en su sitio
                            if TablaVariablesLogica_3C85[GuillermoBienColocado_3C9B - 0x3C85] == 2 {
                                //6550
                                //incrementa el contador
                                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                //si el contador pasa el límite
                                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0x1E {
                                    //655B
                                    //pone el contador a 0
                                    TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                                    //pone en el marcador la frase
                                    //OCUPAD VUESTRO SITIO, FRAY GUILLERMO
                                    EscribirFraseMarcador_5026(NumeroFrase: 0x2D)
                                    //decrementa la vida de guillermo en 2 unidades
                                    DecrementarObsequium_55D3(Decremento: 2)
                                    return
                                }
                                //6565
                                return
                            } else {
                                //6566
                                //pone en el marcador la frase que había guardado
                                //3F0B
                                EscribirFraseMarcador_5026(NumeroFrase: NumeroFrase_3F0E)
                                //indica que hay que avanzar el momento del día
                                TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                            }
                        }
                        //656C
                        //si hay que avanzar el momento del día y guillermo no está en su sitio
                        if TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] == 1 && TablaVariablesLogica_3C85[GuillermoBienColocado_3C9B - 0x3C85] == 2 {
                            //6576
                            //reinicia el contador
                            TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                            //indica que no hay que avanzar el momento del día
                            TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 0
                            //pone en el marcador la frase
                            //OCUPAD VUESTRO SITIO, FRAY GUILLERMO
                            EscribirFraseMarcador_5026(NumeroFrase: 0x2D)
                            //decrementa la vida de guillermo en 2 unidades
                            DecrementarObsequium_55D3(Decremento: 2)
                        }
                        //6583
                        return
                    }
                } else {
                    //6584
                    //aquí se llega cuando guillermo todavía no ha llegado a la iglesia
                    //si el contador supera el límite tolerable
                    if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0xC8 {
                        //658B
                        //cambia al estado de echarle
                        TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
                        //avanza el momento del día
                        TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                        return
                    } else {
                        //6592
                        //incrementa el contador
                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                        return
                    }
                }
            } else {
                //6597
                return
            }
        } else {
            //6599
            TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
            return
        }
    }

    public func ComprobarColocacionPersonajes_64C0(DiaC:UInt8) {
        //llamado si está en misa (prima) y se le pasa en c el día que es

        //###depuración
        //ComprobarPresenciaAdso_64BC()
        //Exit Sub

        switch DiaC {
            case 2:
                //frase = HERMANOS, VENACIO HA SIDO ASESINADO
                NumeroFrase_3F0E = 0x15
                ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498()
            case 3:
                //frase = HERMANOS, BERENGARIO HA DESAPARECIDO. TEMO QUE SE HAYA COMETIDO OTRO CRIMEN
                NumeroFrase_3F0E = 0x18
                ComprobarPresenciaAdsoSeverinoMalaquias_64A2()
            case 4:
                //frase = HERMANOS, HAN ENCONTRADO A BERENGARIO ASESINADO
                NumeroFrase_3F0E = 0x1A
                ComprobarPresenciaAdsoSeverinoMalaquias_64A2()
            case 5:
                ComprobarPresenciaBerengarioAdsoSeverinoMalaquias_6498()
            case 6:
                ComprobarPresenciaAdso_64BC()
            case 7:
                //frase = OREMOS
                ComprobarPresenciaAdso_64BC()
            default:
                break
        }
    }

    public func ComprobarColocacionGuillermoRefectorio_43B9() {
        //comprueba que guillermo esté en la posición correcta del refectorio
        if ComprobarColocacionGuillermo_43C4(PosicionReferenciaDE: 0x3938) != 0 { return }
        //posición imposible
        ComprobarColocacionGuillermo_43C4(PosicionReferenciaDE: 0x3020)
    }

    public func ComprobarPresenciaPersonajesRefectorio_64EA(DiaC:UInt8) {
        //llamado si está en el refectorio y se le pasa en c el día que es

        //###depuración
        if TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] == 1 {
            //indica que todos los monjes están listos
            TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 0
        }
        return

        if DiaC == 2 {
            //64FA
            //comprueba que estén Berengario, Adso y Severino
            if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 1 &&
                    TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] == 1 &&
                    TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 1 {
                //indica que todos los monjes están listos
                TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 0
            }
        } else if DiaC == 3 || DiaC == 4 {
            //650C
            //comprueba que estén Adso y Severino
            if TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] == 1 &&
                    TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 1 {
                //indica que todos los monjes están listos
                TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 0
            }
        } else if DiaC == 5 || DiaC == 6 {
            //si adso ha llegado al comedor
            if TablaVariablesLogica_3C85[DondeEstaAdso_3D11 - 0x3C85] == 1 {
                //indica que todos los monjes están listos
                TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 0
            }
        }
    }

    public func EcharBronca_Guillermo_646C() {
        //le echa una bronca a guillermo
        //si no tiene el bit 7 puesto
        if !LeerBitArray(TablaVariablesLogica_3C85, EstadoAbad_3CC7 - 0x3C85, 7) {
            //6474
            //decrementa la vida de guillermo en 2 unidades
            DecrementarObsequium_55D3(Decremento: 2)
            //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
            DescartarMovimientosPensados_08BE(PersonajeIY: 0x3063)
            //marca el estado de bronca
            SetBitArray(&TablaVariablesLogica_3C85, EstadoAbad_3CC7 - 0x3C85, 7)
            //escribe en el marcador la frase
            //OS ORDENO QUE VENGAIS
            EscribirFraseMarcador_501B(NumeroFrase: 8)
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
        }
    }

    public func DefinirEstadoAbad_63CF() {
        //acciones dependiendo del estado del abad
        //si está en el estado 0x10
        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x10 {
            //63D5
            //63E2
            //si malaquías o berengario/bernardo van a buscar al abad
            if TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] == 0xFE || TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] == 0xFE {
                //63EE
                //si el abad ha llegado a donde quería ir
                if TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] == TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] {
                    //63F4
                    //3E5B
                    //indica que el personaje no quiere buscar ninguna ruta
                    TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                    return
                } else {
                    //63F7
                    //se va a su celda
                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                    //si bernardo tiene el pergamino
                    if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosBerengario_2E0B - 0x2DEC, 4) {
                        //6402
                        //va a la entrada de la abadía
                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 3
                        return
                    } else {
                        //6405
                        return
                    }
                }
            } else {
                //6406
                //si el abad tiene el pergamino
                if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) {
                    //640E
                    //va a su celda
                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                }
                //6411
                //si el abad ha llegado donde quería ir
                if TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] == TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] {
                    //6417
                    //se mueve aleatoriamente
                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = (TablaVariablesLogica_3C85[ValorAleatorio_3C9D - 0x3C85] & 3) + 2
                    return
                } else {
                    //641F
                    return
                }
            }
        } else {
            //63D8
            //si es tercia
            if MomentoDia_2D81 == 2 {
                //63DE
                //6420
                //si está en el estado 0x0e
                if TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] == 0x0E {
                    //6426
                    //pone en el marcador la frase
                    //VENID AQUI, FRAY GUILLERMO
                    EscribirFraseMarcador_5026(NumeroFrase: 0x14)
                    //pasa al estado 0x11
                    TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x11
                }
                //642d
                //si está en el estado 0x11
                if TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] == 0x11 {
                    //6433
                    //si no está reproduciendo una frase
                    if !ReproduciendoFrase_2DA1 {
                        //6439
                        //pasa al estado 0x12
                        TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x12
                        //inicia el contador
                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                    }
                }
                //643F
                //si está en el estado 0x12
                if TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] == 0x12 {
                    //6445
                    //pasa al estado 0x0f
                    TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x0F
                    //va al altar de la iglesia
                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0
                    //pone en el marcador la frase correspondiente
                    //3F0B
                    EscribirFraseMarcador_5026(NumeroFrase: NumeroFrase_3F0E)
                    return
                } else {
                    //644F
                    //si está en el estado 0x0f
                    if TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] == 0x0F {
                        //6455
                        //si no está reproduciendo una voz
                        if !ReproduciendoFrase_2DA1 {
                            //645B
                            //pasa al estado 0x10
                            TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x10
                            return
                        } else {
                            //645F
                            //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                            //si guillermo está cerca, sale
                            if CompararDistanciaGuillermo_3E61(PersonajeIY: 0x3063) == 0 { return }
                            //6465
                            //pasa al estado 0x12
                            TablaVariablesLogica_3C85[0x3CC7 - 0x3C85] = 0x12
                            //le echa una bronca a guillermo
                            EcharBronca_Guillermo_646C()
                            return
                        }
                    } else {
                        //646B
                        return
                    }
                }
            } else {
                //63E1
                return
            }
        }
    }

    public func EjecutarComportamientoAbad_071E() {
        var PersonajeIY:Int
        var PunteroDatosAbadIX:Int
        //iy apunta a las características del abad
        PersonajeIY = 0x3063
        //apunta a las variables de movimiento del abad
        PunteroDatosAbadIX = 0x3CC9
        //indica que el personaje inicialmente si quiere moverse
        TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 0
        //ejecuta la lógica del abad
        ProcesarLogicaAbad_5FCB(PersonajeIY, PunteroDatosAbadIX)
        //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
        ActualizarTablaPuertas_3EA4(MascaraPuertasC: 0x3F)
        //apunta a la tabla para mover al abad
        //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        ActualizarDatosPersonaje_291D(0x2BCC)
        //apunta a las variables de movimiento del abad
        GenerarMovimiento_073C(PersonajeOrigenIY: PersonajeIY, PersonajeObjetoIX: 0x3CC9)
    }

    public func ProcesarLogicaAbad_5FCB( _ PersonajeIY:Int, _ PunteroDatosAbadIX:Int) {

        //(si la posición de guillermo es < 0x60) y (es el día 1 o es prima)
        if (TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] < 0x60) && (NumeroDia_2D80 == 1 || MomentoDia_2D81 == 1) {
            //5FD7
            //cambia el estado del abad para que eche a guillermo de la abadía
            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
        }
        //5fdc
        //si guillermo sube a la biblioteca cuando no es por la noche
        if MomentoDia_2D81 >= 1 && TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] >= 0x16 {
            //5FE6
            //indica que el abad va a la puerta del pasillo que va a la biblioteca
            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 9
            //cambia el estado del abad para que eche a guillermo de la abadía
            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
            return
        } else {
            //5FED
            //si el abad está en el estado de expulsar a guillermo de la abadia
            if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0B {
                //5FF3
                //indica que el abad persigue a guillermo
                TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                //comprueba si el abad está cerca de guillermo
                if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                    //5FFC
                    //si Guillermo está muerto, sale
                    if TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] == 1 { return }
                    //6003
                    //aquí llega si guillermo está cerca del abad cuando lo va a echar, pero aún está vivo
                    if !ReproduciendoFrase_2DA1 {
                        //6009
                        //pone en el marcador la frase
                        //NO HABEIS RESPETADO MIS ORDENES. ABANDONAD PARA SIEMPRE ESTA ABADIA
                        EscribirFraseMarcador_5026(NumeroFrase: 0x0E)
                        //mata a guillermo
                        TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
                        return
                    }
                    //6010
                    return
                } else {
                    //6010
                    return
                }
            } else {
                //6011
                //c = 0 si la pantalla que se está mostrando actualmente es la celda del abad y la cámara sigue a guillermo
                if (NumeroPantallaActual_2DBD == 0x0D) && TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] == 0 {
                    //6019
                    //comprueba si el abad está cerca de guillermo
                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                        //601E
                        //si está cerca de guillermo
                        //pone en el marcador la frase HABEIS ENTRADO EN MI CELDA
                        EscribirFraseMarcador_5026(NumeroFrase: 0x29)
                        //va a por guillermo
                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                        //pone al abad en estado de expulsar a guillermo de la abadia
                        TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
                        return
                    } else {
                        //602A
                        //va a su celda
                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                        return
                    }
                } else {
                    //602E
                    //si ha llegado a su celda y tiene el pergamino
                    if (TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85]) && TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 2 && LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) {
                        //603E
                        //indica que guillermo no tiene el pergamino
                        TablaVariablesLogica_3C85[EstadoPergamino_3C90 - 0x3C85] = 1
                        //deja el pergamino
                        QuitarPergamino_40B9()
                        //si está en el estado 0x15 y no tiene el pergamino
                        if (TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x15) && !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) {
                            //604E
                            //indica que hay que avanzar el momento del día
                            TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                            //pasa al estado 0x10
                            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x10
                        }
                    }
                    //6054
                    //si está en el estado 0x15
                    if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x15 {
                        //605A
                        //se va a su celda
                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                        return
                    } else {
                        //605E
                        //si el abad tiene puesto el bit 7 de su estado
                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] >= 0x80 {
                            //6065
                            //si no está reproduciendo una frase
                            if !ReproduciendoFrase_2DA1 {
                                //606B
                                //quita el bit 7 de su estado
                                ClearBitArray(&TablaVariablesLogica_3C85, EstadoAbad_3CC7 - 0x3C85, 7)
                            } else {
                                //6072
                                //va a por guillermo
                                TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                return
                            }
                        }
                        //6077
                        //si está en vísperas
                        if MomentoDia_2D81 == 5 {
                            //607D
                            //pasa al estado 5
                            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 5
                            //comprueba que guillermo esté en la posición correcta de misa (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
                            ComprobarColocacionGuillermoMisa_43AC()
                            //va al altar
                            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0
                            //frase = OREMOS
                            NumeroFrase_3F0E = 0x17
                            //salta a una rutina para comprobar que personajes deben haber llegado
                            ComprobarPresenciaPersonajesMisa_6487(DiaC: NumeroDia_2D80)
                            //espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
                            EsperarColocacionPersonajes_6520()
                            return
                        } else {
                            //6094
                            //si está en prima
                            if MomentoDia_2D81 == 1 {
                                //609A
                                //pasa al estado 0x0e
                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0E
                                //comprueba que guillermo esté en la posición correcta de misa (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
                                ComprobarColocacionGuillermoMisa_43AC()
                                //va a misa
                                TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0
                                //frase = OREMOS
                                NumeroFrase_3F0E = 0x17
                                //comprueba si los monjes han llegado a su sitio
                                ComprobarColocacionPersonajes_64C0(DiaC: NumeroDia_2D80)
                                //espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
                                EsperarColocacionPersonajes_6520()
                                return
                            } else {
                                //60B1
                                //si es sexta
                                if MomentoDia_2D81 == 3 {
                                    //60B7
                                    //va al refectorio
                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 1
                                    //comprueba si guillermo está en la posición adecuada del receptorio (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
                                    ComprobarColocacionGuillermoRefectorio_43B9()
                                    //pasa al estado 0x10
                                    TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x10
                                    //frase = PODEIS COMER, HERMANOS
                                    NumeroFrase_3F0E = 0x19
                                    //indica que la comprobacion es negativa inicialmente
                                    TablaVariablesLogica_3C85[MonjesListos_3C96 - 0x3C85] = 1
                                    //salta a una rutina para comprobar si han llegado los monjes dependiendo de c (día)
                                    ComprobarPresenciaPersonajesRefectorio_64EA(DiaC: NumeroDia_2D80)
                                    //espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
                                    EsperarColocacionPersonajes_6520()
                                    return
                                } else {
                                    //60D1
                                    //si es completas y está en estado 5
                                    if MomentoDia_2D81 == 6 && TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 5 {
                                        //60DB
                                        //pasa al estado 6
                                        TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 6
                                        //si se muestra la pantalla de misa
                                        if NumeroPantallaActual_2DBD == 0x22 {
                                            //60E4
                                            //pone en el marcador la frase PODEIS IR A VUESTRAS CELDAS
                                            EscribirFraseMarcador_5026(NumeroFrase: 0x0D)
                                        }
                                        //60E8
                                        return
                                    } else {
                                        //60E9
                                        //si berengario le ha avisado de que guillermo ha cogido el pergamino
                                        if TablaVariablesLogica_3C85[BerengarioChivato_3C94 - 0x3C85] == 1 {
                                            //60EF
                                            //va a por guillermo
                                            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                            //a = 0x10 (pergamino)
                                            //si el abad tiene el pergamino
                                            if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) {
                                                //60FE
                                                //estado = 0x15
                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x15
                                                //indica que ha llegado a donde estaba guillermo
                                                TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] = 0xFF
                                                //limpia el aviso de berengario
                                                TablaVariablesLogica_3C85[BerengarioChivato_3C94 - 0x3C85] = 0
                                                return
                                            } else {
                                                //6109
                                                //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                    //610E
                                                    //si está cerca de guillermo
                                                    //si el contador ha pasado el límite
                                                    if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0xC8 {
                                                        //6115
                                                        //decrementa la vida de guillermo en 2 unidades
                                                        //55CE
                                                        DecrementarObsequium_55D3(Decremento: 2)
                                                        //pone en el marcador la frase
                                                        //DADME EL MANUSCRITO, FRAY GUILLERMO
                                                        EscribirFraseMarcador_5026(NumeroFrase: 5)
                                                        //reinicia el contador
                                                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                                                    }
                                                    //611F
                                                    TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                                    return
                                                } else {
                                                    //6126
                                                    //pone el contador al máximo
                                                    TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0xC9
                                                    return
                                                }
                                            }
                                        } else {
                                            //612B
                                            //si es completas
                                            if MomentoDia_2D81 == 6 {
                                                //6132
                                                //si está en estado 0x06
                                                if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 6 {
                                                    //6138
                                                    //si no se está mostrando una frase
                                                    if !ReproduciendoFrase_2DA1 {
                                                        //613E
                                                        //limpia el contador
                                                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                                                        //se va a la posición para que entremos a nuestra celda
                                                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 5
                                                        //si ha llegado al sitio al que quería llegar, avanza el estado
                                                        ComprobarDestinoAvanzarEstado_3E98(PunteroVariablesLogicaIX: PunteroDatosAbadIX)
                                                    }
                                                    //6147
                                                    return
                                                } else {
                                                    //6148
                                                    //si está en estado 0x07
                                                    if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 7 {
                                                        //614E
                                                        //si guillermo está en su celda
                                                        if NumeroPantallaActual_2DBD == 0x3E {
                                                            //6155
                                                            //pasa al estado 0x09
                                                            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 9
                                                            return
                                                        } else {
                                                            //6159
                                                            //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                            if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                //615E
                                                                //si está cerca
                                                                //pasa al estado 0x08
                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 8
                                                                //pone en el marcador la frase
                                                                //ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
                                                                EscribirFraseMarcador_5026(NumeroFrase: 0x10)
                                                                return
                                                            } else {
                                                                //6166
                                                                //avanza el contador
                                                                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                                                //si el contador pasa el límite tolerable
                                                                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0x32 {
                                                                    //6171
                                                                    //pasa al estado 0x08
                                                                    TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 8
                                                                }
                                                                //6174
                                                                return
                                                            }
                                                        }
                                                    } else {
                                                        //6175
                                                        //si está en el estado 0x08
                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 8 {
                                                            //617B
                                                            //si guillermo ha entrado en su celda
                                                            if NumeroPantallaActual_2DBD == 0x3E {
                                                                //6182
                                                                //pasa al estado 0x09
                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 9
                                                                return
                                                            } else {
                                                                //6186
                                                                //incrementa el contador
                                                                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                                                //si ha pasado el límite, lo mantiene
                                                                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0x32 {
                                                                    //6191
                                                                    TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0x32
                                                                }
                                                                //6194
                                                                //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                                if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                    //6199
                                                                    //si el contador está al límite
                                                                    if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] == 0x32 {
                                                                        //619F
                                                                        //decrementa la vida de guillermo en 2 unidades
                                                                        //55CE
                                                                        DecrementarObsequium_55D3(Decremento: 2)
                                                                        //pone en el marcador la frase
                                                                        //ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
                                                                        EscribirFraseMarcador_5026(NumeroFrase: 0x10)
                                                                        //reinicia el contador
                                                                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                                                                    }
                                                                    //61A9
                                                                    return
                                                                } else {
                                                                    //61AA
                                                                    //va a por guillermo
                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                                                    return
                                                                }
                                                            }
                                                        } else {
                                                            //61AF
                                                            //si está en el estado 0x09
                                                            if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 9 {
                                                                //61B5
                                                                //si la pantalla que se está mostrando es la de la celda de guillermo
                                                                if NumeroPantallaActual_2DBD == 0x3E {
                                                                    //61BC
                                                                    //se mueve hacia la puerta
                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 6
                                                                    //si ha llegado al sitio al que quería llegar, avanza el estado
                                                                    ComprobarDestinoAvanzarEstado_3E98(PunteroVariablesLogicaIX: PunteroDatosAbadIX)
                                                                    return
                                                                } else {
                                                                    //61C4
                                                                    //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
                                                                    DescartarMovimientosPensados_08BE(PersonajeIY: PersonajeIY)
                                                                    //cambia de estado
                                                                    TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 8
                                                                    //va a por guillermo
                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                                                    return
                                                                }
                                                            } else {
                                                                //61CF
                                                                //si está en el estado 0x0a
                                                                if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0A {
                                                                    //61D5
                                                                    //indica que hay que avanzar el momento del día
                                                                    TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                                                                    //modifica la máscara de puertas que pueden abrirse para que no pueda abrirse la puerta de al lado del a celda de guillermo
                                                                    TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] = TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] & 0xF7
                                                                }
                                                                //61DE
                                                                return
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                //61DF
                                                //si es de noche
                                                if MomentoDia_2D81 == 0 {
                                                    //61E6
                                                    //va a su celda
                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                                                    //si está en estado 0x0a y ha llegado a su celda
                                                    if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0A && TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 2 {
                                                        //61F3
                                                        //pone el contador a 0
                                                        TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                                                        //pasa a estado 0x0c
                                                        TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0C
                                                    }
                                                    //61F9
                                                    //si está en estado 0x0c
                                                    if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0C {
                                                        //61FF
                                                        //si guillermo no está en el ala izquierda de la abadía
                                                        if TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] >= 0x60 {
                                                            //6205
                                                            //incrementa el contador
                                                            TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                                            //si el contador ha superado el límite, o es el quinto día y tenemos la llave de la habitación del abad
                                                            if (TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] >= 0xFA) || (NumeroDia_2D80 == 5 && LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 3)) {
                                                                //621B
                                                                //cambia al estado 0x0d
                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0D
                                                            }
                                                        }
                                                        //621e
                                                        return
                                                    } else {
                                                        //621F
                                                        //si está en el estado 0x0d
                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0D {
                                                            //6225
                                                            //si guillermo está en el ala izquierda de la abadía o en su celda
                                                            if TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] < 0x60 || NumeroPantallaActual_2DBD == 0x3E {
                                                                //6230
                                                                //cambia al estado 0x0c
                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0C
                                                                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0x32
                                                                return
                                                            } else {
                                                                //6237
                                                                //compara la distancia entre guillermo y el abad (si está muy cerca, devuelve 0, en otro caso devuelve algo != 0)
                                                                if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                    //623C
                                                                    //cambia al estado para echarlo de la abadía
                                                                    TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
                                                                }
                                                                //623F
                                                                //va a por guillermo
                                                                TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                                                return
                                                            }
                                                        } else {
                                                            //6244
                                                            return
                                                        }
                                                    }
                                                } else {
                                                    //6245
                                                    //si es el primer día
                                                    if NumeroDia_2D80 == 1 {
                                                        //624C
                                                        //si es nona
                                                        if MomentoDia_2D81 == 4 {
                                                            //6253
                                                            //si está en el estado 0x04
                                                            if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 4 {
                                                                //6259
                                                                //va a su celda
                                                                TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 2
                                                                //si ha llegado a su celda
                                                                if TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 2 {
                                                                    //6262
                                                                    //indica que hay que avanzar el momento del día
                                                                    TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                                                                }
                                                                //6265
                                                                return
                                                            } else {
                                                                //6266
                                                                //si está en el estado 0x00
                                                                if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0 {
                                                                    //626C
                                                                    //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                        //6271
                                                                        //pone en el marcador la frase
                                                                        //BIENVENIDO A ESTA ABADIA, HERMANO. OS RUEGO QUE ME SIGAIS. HA SUCEDIDO ALGO TERRIBLE
                                                                        EscribirFraseMarcador_5026(NumeroFrase: 1)
                                                                        //cambia al estado 0x01
                                                                        TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 1
                                                                        //va a por guillermo
                                                                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0xFF
                                                                        return
                                                                    } else {
                                                                        //627F
                                                                        //va a la entrada de la abadía
                                                                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 3
                                                                        return
                                                                    }
                                                                } else {
                                                                    //6283
                                                                    //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                        //6289
                                                                        //si está en el estado 0x01
                                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 1 {
                                                                            //628F
                                                                            //si va a la primera parada y no se está reproduciendo ninguna frase
                                                                            if (TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] == 4) && !ReproduciendoFrase_2DA1 {
                                                                                //6297
                                                                                //cambia al estado 0x02
                                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 2
                                                                            } else {
                                                                                //629C
                                                                                //si no se está reproduciendo una frase
                                                                                if !ReproduciendoFrase_2DA1 {
                                                                                    //62A2
                                                                                    //va a la primera parada durante el discurso de bienvenida
                                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 4
                                                                                    //pone en el marcador la frase
                                                                                    //TEMO QUE UNO DE LOS MONJES HA COMETIDO UN CRIMEN. OS RUEGO QUE LO ENCONTREIS ANTES DE QUE LLEGUE BERNARDO GUI, PUES    NO DESEO QUE SE MANCHE EL NOMBRE DE ESTA ABADIA
                                                                                    EscribirFraseMarcador_5026(NumeroFrase: 2)
                                                                                }
                                                                            }
                                                                        }
                                                                        //62A9
                                                                        //si está en el estado 0x02
                                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 2 {
                                                                            //62AF
                                                                            //va a la primera parada durante el discurso de bienvenida
                                                                            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 4
                                                                            //si ha llegado a la primera parada y no está reproduciendo una frase
                                                                            if (TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 4) && !ReproduciendoFrase_2DA1 {
                                                                                //62BA
                                                                                //pasa al estado 0x03
                                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 3
                                                                            }
                                                                        }
                                                                        //62BD
                                                                        //si está en el estado 0x03
                                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 3 {
                                                                            //62C3
                                                                            //si va hacia nuestra celda y no está reproduciendo una voz
                                                                            if (TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] == 5) && !ReproduciendoFrase_2DA1 {
                                                                                //62CB
                                                                                //cambia al estado 0x1f
                                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x1F
                                                                            } else {
                                                                                //62D0
                                                                                //si no está reproduciendo una voz
                                                                                if !ReproduciendoFrase_2DA1 {
                                                                                    //62D6
                                                                                    //va a la entrada de nuestra celda
                                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 5
                                                                                    //pone en el marcador la frase
                                                                                    //DEBEIS RESPETAR MIS ORDENES Y LAS DE LA ABADIA. ASISTIR A LOS OFICIOS Y A LA COMIDA. DE NOCHE DEBEIS ESTAR EN VUESTRA CELDA
                                                                                    EscribirFraseMarcador_5026(NumeroFrase: 3)
                                                                                }
                                                                            }
                                                                        }
                                                                        //62DD
                                                                        //si está en el estado 0x1f
                                                                        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x1F {
                                                                            //62E3
                                                                            //va a la entrada de nuestra celda
                                                                            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 5
                                                                            //si ha llegado a la entrada de nuestra celda y no está reproduciendo una voz
                                                                            if (TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 5) && !ReproduciendoFrase_2DA1 {
                                                                                //62EE
                                                                                //pasa al estado 0x04
                                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 4
                                                                                //pone en el marcador la frase
                                                                                //ESTA ES VUESTRA CELDA, DEBO IRME
                                                                                EscribirFraseMarcador_5026(NumeroFrase: 7)
                                                                            }
                                                                        }
                                                                        //62F5
                                                                        return
                                                                    } else {
                                                                        //62F6
                                                                        //le echa una bronca a guillermo
                                                                        EcharBronca_Guillermo_646C()
                                                                        return
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            //62F9
                                                            return
                                                        }
                                                    } else {
                                                        //62FA
                                                        //si es el segundo día
                                                        if NumeroDia_2D80 == 2 {
                                                            //6300
                                                            //frase = DEBEIS SABER QUE LA BIBLIOTECA ES UN LUGAR SECRETO. SOLO MALAQUIAS PUEDE ENTRAR. PODEIS IROS
                                                            NumeroFrase_3F0E = 0x16
                                                            DefinirEstadoAbad_63CF()
                                                            return
                                                        } else {
                                                            //6306
                                                            //si es el tercer día
                                                            if NumeroDia_2D80 == 3 {
                                                                //630C
                                                                //si está en el estado 0x10 y el momento del día es tercia
                                                                if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x10 && MomentoDia_2D81 == 2 {
                                                                    //6316
                                                                    //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                        //631B
                                                                        //va a la pantalla en la que presenta a jorge
                                                                        TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 0x07
                                                                        return
                                                                    } else {
                                                                        //631F
                                                                        //si el estado de jorge >= 0x1e (ya ha presentado a guillermo ante jorge)
                                                                        if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] >= 0x1E {
                                                                            //6325
                                                                            //cambia de estado
                                                                            TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] - 1
                                                                        }
                                                                        //632A
                                                                        //no hay que avanzar el momento del día
                                                                        TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 0
                                                                        EcharBronca_Guillermo_646C()
                                                                        return
                                                                    }
                                                                } else {
                                                                    //6330
                                                                    //frase = QUIERO QUE CONOZCAIS AL HOMBRE MAS VIEJO Y SABIO DE LA ABADIA
                                                                    NumeroFrase_3F0E = 0x30
                                                                    DefinirEstadoAbad_63CF()
                                                                    return
                                                                }
                                                            } else {
                                                                //6336
                                                                //si es el cuarto día
                                                                if NumeroDia_2D80 == 4 {
                                                                    //633C
                                                                    //frase = HA LLEGADO BERNARDO, DEBEIS ABANDONAR LA INVESTIGACION
                                                                    NumeroFrase_3F0E = 0x11
                                                                    DefinirEstadoAbad_63CF()
                                                                    return
                                                                } else {
                                                                    //6342
                                                                    //si es el quinto día
                                                                    if NumeroDia_2D80 == 5 {
                                                                        //6348
                                                                        //si es nona
                                                                        if MomentoDia_2D81 == 4 {
                                                                            //634E
                                                                            //si ha llegado a la puerta de la celda de severino
                                                                            if TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] == 8 {
                                                                                //6354
                                                                                //si no se ha iniciado el contador
                                                                                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] == 0 {
                                                                                    //635A
                                                                                    //pone un sonido
                                                                                    ReproducirSonidoPuertaSeverino_102A()
                                                                                }
                                                                                //635D
                                                                                //incrementa el contador
                                                                                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                                                                                //si el contador es < 0x1e, sale
                                                                                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] < 0x1E { return }
                                                                                //cambia al estado 0x10
                                                                                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x10
                                                                                //pone en el marcador la frase
                                                                                //DIOS SANTO... HAN ASESINADO A SEVERINO Y LE HAN ENCERRADO
                                                                                EscribirFraseMarcador_5026(NumeroFrase: 0x1C)
                                                                                //avanza el momento del día
                                                                                TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                                                                                return
                                                                            } else {
                                                                                //6374
                                                                                //si el abad va a la celda de severino o está en el estado 0x13
                                                                                if (TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] == 8) || (TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x13) {
                                                                                    //637E
                                                                                    //no permite avanzar el momento del día
                                                                                    TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 0
                                                                                    //si está en el estado 0x13
                                                                                    if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x13 {
                                                                                        //6387
                                                                                        //compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
                                                                                        if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                                                                                            //638C
                                                                                            //va a la puerta de la celda de severino
                                                                                            TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 8
                                                                                            return
                                                                                        } else {
                                                                                            //6390
                                                                                            //le echa una bronca a guillermo
                                                                                            EcharBronca_Guillermo_646C()
                                                                                            return
                                                                                        }
                                                                                    } else {
                                                                                        //6393
                                                                                        //si no se está reproduciendo una voz
                                                                                        if !ReproduciendoFrase_2DA1 {
                                                                                            //6399
                                                                                            //pasa al estado 0x13
                                                                                            TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x13
                                                                                        }
                                                                                        //639C
                                                                                        return
                                                                                    }
                                                                                } else {
                                                                                    //639F
                                                                                    //escribe en el marcador la frase
                                                                                    //VENID, FRAY GUILLERMO, DEBEMOS ENCONTRAR A SEVERINO
                                                                                    EscribirFraseMarcador_501B(NumeroFrase: 0x1B)
                                                                                    //va a la puerta de la celda de severino
                                                                                    TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] = 8
                                                                                    return
                                                                                }
                                                                            }
                                                                        } else {
                                                                            //63A7
                                                                            //frase = BERNARDO ABANDONARA HOY LA ABADIA
                                                                            NumeroFrase_3F0E = 0x1D
                                                                            DefinirEstadoAbad_63CF()
                                                                            return
                                                                        }
                                                                    } else {
                                                                        //63AD
                                                                        //si es el sexto día
                                                                        if NumeroDia_2D80 == 6 {
                                                                            //63B3
                                                                            //frase = MAÑANA ABANDONAREIS LA ABADIA
                                                                            NumeroFrase_3F0E = 0x1E
                                                                            DefinirEstadoAbad_63CF()
                                                                            return
                                                                        } else {
                                                                            //63B9
                                                                            //si es el séptimo día
                                                                            if NumeroDia_2D80 == 7 {
                                                                                //63BF
                                                                                //frase = DEBEIS ABANDONAR YA LA ABADIA
                                                                                NumeroFrase_3F0E = 0x25
                                                                                //si es tercia
                                                                                if MomentoDia_2D81 == 2 {
                                                                                    //63C8
                                                                                    //indica que guillermo ha muerto
                                                                                    TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
                                                                                }
                                                                                //63CB
                                                                                DefinirEstadoAbad_63CF()
                                                                                return
                                                                            } else {
                                                                                //63CE
                                                                                return
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public func LeerPosicionPersonajeAbrirPuerta_0F7C( _ PermisoPuertaHL: inout Int) -> Int {
        //devuelve en ab lo que hay en [[hl]] e incrementa hl
        //[HL] es un puntero a un personaje
        //ab = [hl]
        var PersonajeAB:Int
        PersonajeAB = Leer16(TablaPermisosPuertas_2DD9, PermisoPuertaHL - 0x2DD9)
        PermisoPuertaHL = PermisoPuertaHL + 2
        return Leer16(TablaCaracteristicasPersonajes_3036, PersonajeAB - 0x3036)
    }

    public func ComprobarPermisosPuerta_0F6C( _ PosicionPuertaDE:Int, _ PuertasAbriblesA:UInt8, _ PuertaC:UInt8, _ PermisoPuertaHL:Int) -> Bool {
        //comprueba si el personaje se acerca a una puerta que no puede abrir
        //si es así, comprueba si hay alguien cerca que la pueda abrir.
        //si no es así, la cierra
        //devuelve true si no hay permiso para abrir
        var ComprobarPermisosPuerta_0F6C:Bool
        var PuertasAbriblesA:UInt8 = PuertasAbriblesA
        var PermisoPuertaHL:Int = PermisoPuertaHL
        var PersonajePermisoAB:Int //personaje con permiso para abrir la puerta
        var PersonajeX:UInt8 = 0 //coordenadas del personaje que puede abrir la puerta
        var PersonajeY:UInt8 = 0
        var PuertaX:UInt8 = 0 //coordenadas de la puerta
        var PuertaY:UInt8 = 0
        ComprobarPermisosPuerta_0F6C = false
        if depuracion.PuertasAbiertas { return ComprobarPermisosPuerta_0F6C }
        //combina las puertas a las que pueden entrar
        PuertasAbriblesA = PuertasAbriblesA | TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9]
        PermisoPuertaHL = PermisoPuertaHL + 1
        //si tienen permisos para abrir la puerta, sale
        if (PuertasAbriblesA & PuertaC) != 0 { return ComprobarPermisosPuerta_0F6C }
        //0F70
        PersonajePermisoAB = LeerPosicionPersonajeAbrirPuerta_0F7C(&PermisoPuertaHL)
        Integer2Nibbles(Value: PosicionPuertaDE, HighNibble: &PuertaY, LowNibble: &PuertaX)
        Integer2Nibbles(Value: PersonajePermisoAB, HighNibble: &PersonajeY, LowNibble: &PersonajeX)
        //compara la coordenada x del personaje con la coordenada x de la puerta. si no está cerca sale
        if Z80Sub(PersonajeX, PuertaX) >= 6 { return ComprobarPermisosPuerta_0F6C }
        //0F77
        //repite con la y
        if Z80Sub(PersonajeY, PuertaY) >= 6 { return ComprobarPermisosPuerta_0F6C }
        ComprobarPermisosPuerta_0F6C = true
        return ComprobarPermisosPuerta_0F6C
    }

    public func AbrirPuerta_0F22( _ PuertaIY:Int, _ CambiarOrientacion:Bool, _ EstadoAnteriorBC:Int) {
        //coloca en el buffer de alturas el valor que hace falta para poder atravesar la puerta
        var PunteroBufferAlturasBC:Int=0
        var PunteroBufferAlturasIX:Int=0
        var AlturaPuertaA:UInt8
        if CambiarOrientacion {
            //cambia la orientación de la puerta
            TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4] = Z80Add(TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4], 2)
        }
        //0F28
        //lee en bc el desplazamiento de la puerta para el buffer de alturas, y si la puerta es visible
        LeerDesplazamientoPuerta_0E2C(&PunteroBufferAlturasIX, PuertaIY, &PunteroBufferAlturasBC)
        //devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
        PunteroBufferAlturasIX = PunteroBufferAlturasIX + 2 * PunteroBufferAlturasBC
        //lee si hay algún personaje en la posición en la que se abre la puerta
        //si no es así, sale
        if (LeerByteBufferAlturas(PunteroBufferAlturasIX) & 0xF0) == 0 { return }
        //0F36
        //si hay algún personaje, restaura la configuración de la puerta
        Escribir16(&TablaDatosPuertas_2FE4, PuertaIY - 0x2FE4, EstadoAnteriorBC)
        //modifica una instrucción para que no haya que redibujar el sprite
        RedibujarPuerta_0DFF = false
        //obtiene la altura a la que está situada la puerta
        AlturaPuertaA = TablaDatosPuertas_2FE4[PuertaIY + 4 - 0x2FE4]
        //modifica el buffer de alturas con la altura de la puerta
        EscribirAlturaPuertaBufferAlturas_0E19(AlturaPuertaA, PuertaIY)
    }

    public func AbrirCerrarPuerta_0EAD( _ PuertaIY:Int) {
        //comprueba si hay que abrir o cerrar una puerta
        var PuertaC:UInt8
        var PuertasAbriblesA:UInt8
        var PosicionPuertaDE:Int
        var PuertaX:UInt8 = 0
        var PuertaY:UInt8 = 0
        var PermisoPuertaHL:Int
        var PersonajePermisoAB:Int
        var PersonajeX:UInt8 = 0
        var PersonajeY:UInt8 = 0
        var EstadoPuertaBC:Int
        var AlturaPuertaA:UInt8
        var CambiarOrientacion:Bool
        //iy apunta a los datos de la puerta
        PuertaC = TablaDatosPuertas_2FE4[PuertaIY + 1 - 0x2FE4]
        //si la puerta se queda fija, sale
        if LeerBitByte(PuertaC, 7) { return }
        //obtiene las coordenadas x e y de la puerta
        PosicionPuertaDE = Leer16(TablaDatosPuertas_2FE4, PuertaIY + 2 - 0x2FE4)
        Integer2Nibbles(Value: PosicionPuertaDE, HighNibble: &PuertaY, LowNibble: &PuertaX)
        PuertaX = PuertaX - 2
        PuertaY = PuertaY - 2
        PosicionPuertaDE = (Int(PuertaY) << 8) | Int(PuertaX)
        //0EBD
        //obtiene que puerta es
        PuertaC = PuertaC & 0x1F
        //puertas que se pueden abrir
        PuertasAbriblesA = TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85]
        //añade a la máscara la puerta del pasadizo detrás de la cocina
        PuertasAbriblesA = PuertasAbriblesA | 0x10
        //combina la máscara con la puerta actual
        PuertaC = PuertaC & PuertasAbriblesA
        //0EC8
        //lee las puertas a las que puede entrar adso
        PuertasAbriblesA = TablaPermisosPuertas_2DD9[0x2DDC - 0x2DD9]
        //apunta a las puertas a las que puede entrar guillermo
        PermisoPuertaHL = 0x2DD9
        //0ED1
        //comprueba si guillermo está cerca de una puerta que no tiene permisos para abrir
        if !ComprobarPermisosPuerta_0F6C(PosicionPuertaDE, PuertasAbriblesA, PuertaC, PermisoPuertaHL) {
            //0ED3
            //Guillermo tiene permiso para abrir
            //lee las puertas a las que puede entrar guillermo
            PuertasAbriblesA = TablaPermisosPuertas_2DD9[0x2DD9 - 0x2DD9]
            //apunta a las puertas a las que puede entrar adso
            PermisoPuertaHL = 0x2DDC
            //comprueba si adso está cerca de una puerta que no tiene permisos para abrir
            if !ComprobarPermisosPuerta_0F6C(PosicionPuertaDE, PuertasAbriblesA, PuertaC, PermisoPuertaHL) {
                //0EDE
                //Adso tiene permiso para abrir
                //apunta a los permisos del primer personaje
                PermisoPuertaHL = 0x2DD9
                PuertaX = PuertaX + 1
                PuertaY = PuertaY + 1
                PosicionPuertaDE = (Int(PuertaY) << 8) | Int(PuertaX)
                //0EE3
                while true {
                    PuertasAbriblesA = TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9]
                    PermisoPuertaHL = PermisoPuertaHL + 1
                    //si se han procesado todas las entradas, salta a ver si hay que cerrar la puerta
                    if PuertasAbriblesA == 0xFF { break }
                    if depuracion.PuertasAbiertas  { PuertasAbriblesA = 0xFF }
                    //0EE9
                    //si este personaje no tiene permisos para abrir esta puerta
                    if (PuertasAbriblesA & PuertaC) == 0 {
                        //0EEC
                        //avanza a las permisos de las puertas del siguiente personaje
                        PermisoPuertaHL = PermisoPuertaHL + 2
                    } else {
                        //0EF0
                        //aquí llega si alguien tiene permisos para abrir una puerta
                        //devuelve la posición del personaje que puede abrir la puerta
                        PersonajePermisoAB = LeerPosicionPersonajeAbrirPuerta_0F7C(&PermisoPuertaHL)
                        Integer2Nibbles(Value: PersonajePermisoAB, HighNibble: &PersonajeY, LowNibble: &PersonajeX)
                        //compara la coordenada x del personaje con la coordenada x de la puerta. si no está cerca sale
                        //si está cerca en X
                        if Z80Sub(PersonajeX, PuertaX) < 4 {
                            //0EF8
                            //si está cerca en Y
                            if Z80Sub(PersonajeY, PuertaY) < 4 {
                                //0EFE
                                //abrir puerta
                                //si la puerta está abierta, sale
                                if LeerBitArray(TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 6) { return }
                                //0F03
                                //guarda la orientación y el estado de la puerta por si hay que restaurarlo luego
                                EstadoPuertaBC = Leer16(TablaDatosPuertas_2FE4, PuertaIY - 0x2FE4)
                                //marca la puerta como abierta
                                SetBitArray(&TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 6)
                                //modifica una instrucción para que haya que redibujar un sprite
                                RedibujarPuerta_0DFF = true
                                //obtiene la altura a la que está situada la puerta
                                AlturaPuertaA = TablaDatosPuertas_2FE4[PuertaIY + 4 - 0x2FE4]
                                //modifica el buffer de alturas ya que cuando se abre la puerta se debe poder pasar
                                EscribirAlturaPuertaBufferAlturas_0E19(AlturaPuertaA, PuertaIY)
                                //0F19
                                //cambia la orientación de la puerta
                                TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4] = Z80Dec(TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4])
                                //0F1C
                                CambiarOrientacion = !LeerBitArray(TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 5)
                                AbrirPuerta_0F22(PuertaIY, CambiarOrientacion, EstadoPuertaBC)
                                return
                            }
                        }
                    }
                }
            }
        }
        //0F46
        //aqui llega para comprobar si hay que cerrar la puerta puerta
        //si la puerta está cerrada, sale
        if !LeerBitArray(TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 6) { return }
        //0F4B
        //guarda la orientación y el estado de la puerta por si hay que restaurarlo luego
        EstadoPuertaBC = Leer16(TablaDatosPuertas_2FE4, PuertaIY - 0x2FE4)
        //modifica una instrucción para que se redibuje el sprite
        RedibujarPuerta_0DFF = true
        //obtiene la altura a la que está situada la puerta
        AlturaPuertaA = TablaDatosPuertas_2FE4[PuertaIY + 4 - 0x2FE4]
        //modifica el buffer de alturas las posiciones ocupadas por la puerta para que deje pasar
        EscribirAlturaPuertaBufferAlturas_0E19(AlturaPuertaA, PuertaIY)
        //0F5D
        //indica que la puerta está cerrada
        ClearBitArray(&TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 6)
        //cambia la orientación de la puerta
        TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4] = Z80Dec(TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4])
        //0F64
        //si el bit 5 está puesto, modifica la orientación
        CambiarOrientacion = LeerBitArray(TablaDatosPuertas_2FE4, PuertaIY + 1 - 0x2FE4, 5)
        //salta para redibujar el sprite
        AbrirPuerta_0F22(PuertaIY, CambiarOrientacion, EstadoPuertaBC)
    }

    public func AbrirCerrarPuertas_0D67() {
        //comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites
        //de las puertas en consecuencia
        var SpriteIX:Int
        var PuertaIY:Int
        var PosicionX:UInt8 = 0
        var PosicionY:UInt8 = 0
        var PosicionZ:UInt8 = 0
        var PosicionYp:UInt8 = 0
        var PuertaA:UInt8
        //apunta a los sprites de las puertas
        SpriteIX = 0x2E8F
        //apunta a los datos de las puertas
        PuertaIY = 0x2FE4
        //indica que la puerta no requiere los gráficos flipeados
        PuertaRequiereFlip_2DAF = false
        //si ha llegado a la última entrada, sale
        //0D73
        while true {
            //If PuertaIY = 0x2FF3 Then Stop
            if TablaDatosPuertas_2FE4[PuertaIY - 0x2FE4] == 0xFF { return }
            //0D79
            //comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites en consecuencia
            //inicialmente no hay que redibujar el sprite
            RedibujarPuerta_0DFF = false
            //comprueba si hay que abrir o cerrar esta puerta
            AbrirCerrarPuerta_0EAD(PuertaIY)
            //devuelve la posición del objeto en coordenadas de pantalla. Si no es visible devuelve el CF = 1
            if ObtenerCoordenadasObjeto_0E4C(SpriteIX, PuertaIY, &PosicionX, &PosicionY, &PosicionZ, &PosicionYp) {
                //0D89
                //si la puerta es visible, dibuja el sprite (si ha cambiado el estado de la puerta) y marca las posiciones que ocupa la puerta para no poder avanzar a través de ella
                ProcesarPuertaVisible_0DD2(SpriteIX, PuertaIY, PosicionX, PosicionY, PosicionYp)
            }
            //0D8C
            //lee si se va a redibujar la pantalla
            if !CambioPantalla_2DB8 {
                //0D94
                //aquí llega si no se va a redibujar la pantalla
                PuertaA = TablaSprites_2E17[SpriteIX - 0x2E17]
                //si la puerta  es visible
                if PuertaA != 0xFE {
                    //0D9B
                    //si la puerta se redibuja
                    if LeerBitByte(PuertaA, 7) {
                        //0D9F
                        //si la puerta se redibuja, pone un sonido dependiendo de su estado
                        if LeerBitByte(PuertaA, 6) {
                            //0DA6
                            //si el bit 6 era 1, pone el sonido de abrir la puerta
                            ReproducirSonidoAbrir_101B()
                        } else {
                            //0DAA
                            //si el bit 6 era 0, pone el sonido de cerrar la puerta
                            ReproducirSonidoCerrar_1016()
                        }
                    }
                }
            }
            //0DAF
            //avanza a la siguiente puerta
            PuertaIY = PuertaIY + 5
            //avanza al siguiente sprite
            SpriteIX = SpriteIX + 0x14
        }
    }

    public func FlipearGraficosPuertas_0E66() {
        //comprueba si tiene que flipear los gráficos de las puertas
        //lee el estado de flipx que espera la puerta
        //lee si las puertas están flipeadas o no
        //si están en el estado que se necesita, sale
        if ((PuertaRequiereFlip_2DAF && !PuertasFlipeadas_2D78) || (!PuertaRequiereFlip_2DAF && PuertasFlipeadas_2D78)) == false { return } //PuertaRequiereFlip_2DAF xor PuertasFlipeadas_2D78
        //0E6F
        //en otro caso, flipea los gráficos
        PuertasFlipeadas_2D78 = !PuertasFlipeadas_2D78
        //flipea los gráficos de la puerta
        GirarGraficosRespectoX_3552(Tabla: &TablaGraficosObjetos_A300, PunteroTablaHL: 0xAA49 - 0xA300, AnchoC: 6, NGraficosB: 0x28)
    }

    public func Dibujar2Lineas_3FE6(PixelsA:UInt8, PosicionYH:UInt8, PosicionXL:UInt8) {
        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
        var PunteroPantallaHL:Int
        //dado hl (coordenadas Y,X), calcula el desplazamiento correspondiente en pantalla
        PunteroPantallaHL = ObtenerDesplazamientoPantalla_3C42(PosicionXL, PosicionYH)
        //graba a
        PantallaCGA[PunteroPantallaHL - 0xC000] = PixelsA
        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL - 0xC000, Color: PixelsA)
        //pasa a la siguiente línea de pantalla
        PunteroPantallaHL = 0xC000 + DireccionSiguienteLinea_3A4D_68F2(PunteroPantallaHL - 0xC000)
        //graba a
        PantallaCGA[PunteroPantallaHL - 0xC000] = PixelsA
        cga!.PantallaCGA2PC(PunteroPantalla: PunteroPantallaHL - 0xC000, Color: PixelsA)
    }

    public func DibujarEspiral_3F7F(Mascara:UInt8) {
        //dibuja la espiral del color indicado por e
        struct Estatico {
            static var PosicionYH:UInt8=0
            static var PosicionXL:UInt8=0
            static var Ancho_3F67:UInt8=0
            static var Alto_3F68:UInt8=0
            static var Ancho_3F69:UInt8=0
            static var Alto_3F6A:UInt8=0
            static var ContadorGlobalB:UInt8=0
            static var ContadorTiraB:UInt8=0
            static var PixelsA:UInt8=0
            static var Estado:UInt8=0
            static var MascaraE:UInt8=0
        }
        var Contador:Int
        switch Estatico.Estado {
            case 0:
                //posición inicial (00, 00)
                Estatico.MascaraE = Mascara
                Estatico.PosicionYH = 0
                Estatico.PosicionXL = 0
                Estatico.Ancho_3F67 = 0x3F //ancho de izquierda a derecha
                Estatico.Alto_3F68 = 0x4F //alto de arriba a abajo
                Estatico.Ancho_3F69 = 0x3F //ancho de derecha a izquierda
                Estatico.Alto_3F6A = 0x4E //alto de abajo a arriba
                //3F96
                Estatico.ContadorGlobalB = 0x20 //32 veces
                Estatico.PixelsA = 0
                Estatico.ContadorTiraB = Estatico.Ancho_3F67
                Estatico.Estado = 1
                SiguienteTick(Tiempoms: 1, NombreFuncion: "DibujarEspiral_3F7F")
            case 1:
                for Contador in 1...2 {
                    //3FA6
                    //dibuja una tira (de color a) de b*8 pixels de ancho y 2 de alto (de izquierda a derecha)
                    Estatico.Ancho_3F67 = Estatico.Ancho_3F67 - 1
                    //3FA9
                    repeat {
                        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
                        Dibujar2Lineas_3FE6(PixelsA: Estatico.PixelsA, PosicionYH: Estatico.PosicionYH, PosicionXL: Estatico.PosicionXL)
                        Estatico.PosicionXL = Estatico.PosicionXL + 1 //pasa al siguiente byte en X
                        Estatico.ContadorTiraB = Estatico.ContadorTiraB - 1
                    } while Estatico.ContadorTiraB != 0 //repite hasta que b = 0
                    //3FAF
                    //dibuja una tira (de color a) de 8 pixels de ancho y [ix+0x01]*2 de alto (de arriba a abajo)
                    Estatico.ContadorTiraB = Estatico.Alto_3F68
                    Estatico.Alto_3F68 = Estatico.Alto_3F68 - 2
                    //3FB8
                    repeat {
                        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
                        Dibujar2Lineas_3FE6(PixelsA: Estatico.PixelsA, PosicionYH: Estatico.PosicionYH, PosicionXL: Estatico.PosicionXL)
                        Estatico.PosicionYH = Estatico.PosicionYH + 2 //pasa a las 2 líneas siguientes en Y
                        Estatico.ContadorTiraB = Estatico.ContadorTiraB - 1
                    } while Estatico.ContadorTiraB != 0 //repite hasta que b = 0
                    //3FBF
                    //dibuja una tira (de color a) de [ix+0x02]*8 pixels de ancho y 2 de alto (de derecha a izquierda)
                    Estatico.ContadorTiraB = Estatico.Ancho_3F69
                    Estatico.Ancho_3F69 = Z80Sub(Estatico.Ancho_3F69, 2)
                    //3FC8
                    repeat {
                        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
                        Dibujar2Lineas_3FE6(PixelsA: Estatico.PixelsA, PosicionYH: Estatico.PosicionYH, PosicionXL: Estatico.PosicionXL)
                        Estatico.PosicionXL = Estatico.PosicionXL - 1 //retrocede en X
                        Estatico.ContadorTiraB = Estatico.ContadorTiraB - 1
                    } while Estatico.ContadorTiraB != 0 //repite hasta que b = 0
                    //3FCE
                    //dibuja una tira (de color a) de 8 pixels de ancho y [ix+0x03]*2 de alto (de abajo a arriba)
                    Estatico.ContadorTiraB = Estatico.Alto_3F6A
                    Estatico.Alto_3F6A = Estatico.Alto_3F6A - 2
                    //3FD7
                    repeat {
                        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
                        Dibujar2Lineas_3FE6(PixelsA: Estatico.PixelsA, PosicionYH: Estatico.PosicionYH, PosicionXL: Estatico.PosicionXL)
                        Estatico.PosicionYH = Estatico.PosicionYH - 2
                        Estatico.ContadorTiraB = Estatico.ContadorTiraB - 1
                    } while Estatico.ContadorTiraB != 0 //repite hasta que b = 0
                    //3FDE
                    //cambia el color de las tiras
                    Estatico.PixelsA = Estatico.PixelsA ^ Estatico.MascaraE
                    //ModPantalla.Refrescar()
                    Estatico.ContadorGlobalB = Estatico.ContadorGlobalB - 1

                    if Estatico.ContadorGlobalB == 0 {
                        //3FE2
                        //pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
                        Dibujar2Lineas_3FE6(PixelsA: Estatico.PixelsA, PosicionYH: Estatico.PosicionYH, PosicionXL: Estatico.PosicionXL)
                        Estatico.Estado = 0
                        SiguienteTick(Tiempoms: 5, NombreFuncion: "DibujarEspiral_3F6B")
                        return
                    } else {
                        //3F9F
                        Estatico.ContadorTiraB = Estatico.Ancho_3F67
                        Estatico.Ancho_3F67 = Estatico.Ancho_3F67 - 1
                    }
                }
                SiguienteTick(Tiempoms: 5, NombreFuncion: "DibujarEspiral_3F7F")
            default:
                break
        }

    }

    public func DibujarEspiral_3F6B() {
        //rutina encargada de dibujar y de borrar la espiral
        struct Estatico {
            static var Estado:UInt8 = 0
        }
        
        switch Estatico.Estado {
            case 0:
                DibujarEspiral_3F7F(Mascara: 0xFF) //dibuja la espiral
                Estatico.Estado = 1
            case 1:
                DibujarEspiral_3F7F(Mascara: 0) //borra la espiral
                Estatico.Estado = 2
            case 2:
                //si se ha programado un cambio de paleta
                if CambiarPaletaColores != 0xFF {
                    cga!.SeleccionarPaleta(Int(CambiarPaletaColores))
                    //limpia el flag
                    CambiarPaletaColores = 0xFF
                }
                PosicionXPersonajeActual_2D75 = 0 //indica un cambio de pantalla
                Estatico.Estado = 0
                SiguienteTick(Tiempoms: 100, NombreFuncion: "BuclePrincipal_25B7_EspiralDibujada")
            default:
                break
        }
    }

    public func ColocarLampara_4100() {
        //si la lámpara estaba desaparecida, aparece en la cocina
        //si no ha desaparecido la lámpara, sale
        if TablaVariablesLogica_3C85[LamparaEnCocina_3C91 - 0x3C85] != 0 { return }
        //4105
        //indicar que la lámpara no está desaparecida
        TablaVariablesLogica_3C85[LamparaEnCocina_3C91 - 0x3C85] = Z80Inc(TablaVariablesLogica_3C85[LamparaEnCocina_3C91 - 0x3C85])
        //pone la lámpara en la cocina
        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3030, Bytes: [0, 0, 0x5A, 0x2A, 0x04])
    }

    public func QuitarGafas_4037() {
        //desaparecen las lentes
        var MascaraLentes:UInt8
        MascaraLentes = 0xDF
        //quita las gafas de los objetos de Guillermo
        TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC] = MascaraLentes & TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC]
        //le quita las gafas a berengario
        TablaObjetosPersonajes_2DEC[ObjetosBerengario_2E0B - 0x2DEC] = MascaraLentes & TablaObjetosPersonajes_2DEC[ObjetosBerengario_2E0B - 0x2DEC]
        //dibuja los objetos que tenemos en el marcador
        DibujarObjetosMarcador_51D4()
        //copia en 0x3012 -> 00 00 00 00 00 (desaparecen las gafas)
        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3012, Bytes: [0, 0, 0, 0, 0])
    }

     public func DarLibroJorge_40F1() {
         //le da el libro a jorge
         SetBitArray(&TablaObjetosPersonajes_2DEC, ObjetosJorge_2E13 - 0x2DEC, 7)
         //deja el libro fuera de la abadía
         CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3008, Bytes: [0x80, 0, 0x0F, 0x2E, 0])
     }

    public func CambiarCaraBerengario_4078() {
        //cambia la cara de berengario por la de jorge y lo coloca al final del corredor de las celdas
        var ComandosBerengarioHL:Int
        var CaraBerengarioHL:Int
        var CaraJorgeDE:Int
        //lee la dirección de los datos que guían a berengario
        ComandosBerengarioHL = Leer16(TablaCaracteristicasPersonajes_3036, 0x307E - 0x3036)
        //escribe el valor para que piense un nuevo movimiento
        BufferComandosMonjes_A200[ComandosBerengarioHL - 0xA200] = 0x10
        //para el contador y el índice de los datos que guían al personaje
        TablaCaracteristicasPersonajes_3036[0x307C - 0x3036] = 0
        TablaCaracteristicasPersonajes_3036[0x308C - 0x3036] = 0
        //puntero a los datos gráficos de la cara de berengario
        CaraBerengarioHL = 0x309B
        //puntero a los datos gráficos de la cara de jorge
        CaraJorgeDE = 0xB2F7
        //modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
        RotarGraficosCambiarCaraCambiarPosicion_40A2(PunteroCaraHL: CaraBerengarioHL, PunteroMonjesDE: CaraJorgeDE, PersonajeObjetoHL: 0x3073, Bytes: [0, 0xC8, 0x24, 0, 0])
    }

    public func CambiarCaraBerengario_4058() {
        //aparece bernardo en la entrada de la iglesia
        var CaraBerengarioHL:Int
        var CaraBernardoDE:Int
        //puntero a los datos gráficos de la cara de berengario
        CaraBerengarioHL = 0x309B
        //puntero a los datos gráficos de la cara de bernardo gui
        CaraBernardoDE = 0xB293
        //modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
        RotarGraficosCambiarCaraCambiarPosicion_40A2(PunteroCaraHL: CaraBerengarioHL, PunteroMonjesDE: CaraBernardoDE, PersonajeObjetoHL: 0x3073, Bytes: [0, 0x88, 0x88, 2, 0])
    }

    public func CambiarCaraSeverino_4068() {
        //se cambia la cara de severino por la de jorge y aparece en la habitación del espejo
        var CaraSeverinoHL:Int
        var CaraJorgeDE:Int
        //puntero a los datos gráficos de la cara de berengario
        CaraSeverinoHL = 0x309D
        //puntero a los datos gráficos de la cara de bernardo gui
        CaraJorgeDE = 0xB2F7
        //modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
        RotarGraficosCambiarCaraCambiarPosicion_40A2(PunteroCaraHL: CaraSeverinoHL, PunteroMonjesDE: CaraJorgeDE, PersonajeObjetoHL: 0x3082, Bytes: [0x03, 0x12, 0x65, 0x18, 0])
    }

    public func AbrirPuertasAlaIzquierda_3585() {
        //abre las puertas del ala izquierda de la abadía
        Escribir16(&TablaDatosPuertas_2FE4, 0x2FFD - 0x2FE4, 0xE002)
        Escribir16(&TablaDatosPuertas_2FE4, 0x3002 - 0x2FE4, 0xC002)
    }

    public func ProcesarLogicaMomentoDia_5EF9() {
        //si ha cambiado el momento del día, ejecuta unas acciones dependiendo del momento del día
        //si no ha cambiado el momento del día, sale
        if MomentoDia_2D81 == TablaVariablesLogica_3C85[MomentoDiaUltimasAcciones_3C95 - 0x3C85] { return }

        //5F02
        //pone en 0x3c95 el momento del día
        TablaVariablesLogica_3C85[MomentoDiaUltimasAcciones_3C95 - 0x3C85] = MomentoDia_2D81
        //[0x3c93] = dato siguiente = 0?
        TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = 0
        //5F09
        switch MomentoDia_2D81 {
            case 0: //noche
                //5F1F
                switch NumeroDia_2D80 {
                    case 5: //si es el día 5
                        //5F25
                        //pone las gafas de guillermo en la habitación iluminada del laberinto
                        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3012, Bytes: [0, 0, 0x1B, 0x23, 0x18])
                        //pone la llave de la habitación del abad en el altar
                        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x301C, Bytes: [0, 0, 0x89, 0x3E, 0x08])
                    case 6: //si es el día 6
                        //5F31
                        //pone la llave de la habitación de severino en la mesa de malaquías
                        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3021, Bytes: [0, 0, 0x35, 0x35, 0x13])
                        //se cambia la cara de severino por la de jorge y aparece en la habitación del espejo
                        CambiarCaraSeverino_4068()
                        //indica que jorge está activo
                        TablaVariablesLogica_3C85[JorgeActivo_3CA3 - 0x3C85] = 0
                    default:
                        break
                }
                return
            case 1: //prima
                //5F3B
                //dibuja y borra la espiral
                DibujarEspiral_3F6B()
                //modifica la máscara de las puertas que pueden abrirse
                TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] = 0xEF
                //selecciona paleta 2
                //ModPantalla.SeleccionarPaleta(2)
                //programa el cambio de paleta para cuando termine de dibujar la espiral
                CambiarPaletaColores = 2
                //abre las puertas del ala izquierda de la abadía
                AbrirPuertasAlaIzquierda_3585()
                ReproducirSonidoCampanas_100C()
                //si hemos llegado al tercer día
                if NumeroDia_2D80 >= 3 {
                    //5F51
                    //le quita la lámpara a adso y reinicia los contadores de la lámpara
                    InicializarLampara_3FF7()
                    //si la lámpara estaba desaparecida, aparece en la cocina
                    ColocarLampara_4100()
                }
                //5F57
                switch NumeroDia_2D80 {
                    case 2: //día 2
                        //5F5D
                        //desaparecen las lentes
                        QuitarGafas_4037()
                    case 3: //día 3
                        //5F66
                        //le da el libro a jorge
                        DarLibroJorge_40F1()
                        //cambia la cara de berengario por la de jorge y lo coloca al final del corredor de las celdas
                        CambiarCaraBerengario_4078()
                        //berengario/jorge no tiene ningún objeto
                        TablaObjetosPersonajes_2DEC[ObjetosBerengario_2E0B - 0x2DEC] = 0
                        //el abad no tiene ningún objeto
                        TablaObjetosPersonajes_2DEC[ObjetosAbad_2E04 - 0x2DEC] = 0
                        //si guillermo no tiene el pergamino
                        if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) && !depuracion.PergaminoNoDesaparece {
                            //5F78
                            //pone el pergamino en la habitación detrás del espejo
                            CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3017, Bytes: [0, 0, 0x18, 0x64, 0x18])
                            //indica que guillermo no tiene el pergamino
                            TablaVariablesLogica_3C85[EstadoPergamino_3C90 - 0x3C85] = 1
                        }
                    case 5: //día 5
                        //5F7E
                        //si no tenemos la llave de la habitación del abad, ésta desaparece
                        if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 3) {
                            //5F88
                            //desaparece la llave de la habitación del abad
                            CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x301C, Bytes: [0, 0, 0, 0, 0])
                        }
                    default:
                        break
                }
                return
            case 2: //tercia
                //5F8C
                //dibuja y borra la espiral
                DibujarEspiral_3F6B()
                //pone en el canal 1 el sonido de las campanas
                ReproducirSonidoCampanillas_1011()
            case 3: //sexta
                //5F93
                ReproducirSonidoCampanas_100C()
                if NumeroDia_2D80 == 4 { //si es el cuarto día
                    //5F9C
                    //aparece bernardo en la entrada de la iglesia
                    CambiarCaraBerengario_4058()
                    //activa a bernardo
                    TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] = 0
                    //bernardo sólo puede coger el pergamino
                    TablaObjetosPersonajes_2DEC[MascaraObjetosBerengarioBernardo_2E0D - 0x2DEC] = 0x10
                }
            case 4: //nona
                //5FA6
                //dibuja y borra la espiral
                DibujarEspiral_3F6B()
                if NumeroDia_2D80 == 3 { //si es el tercer día
                    //5FAF
                    //jorge pasa a estar inactivo
                    TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] = 1
                    //desaparece jorge
                    TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] = 0
                }
                //5FB5
                //pone en el canal 1 el sonido de las campanillas
                ReproducirSonidoCampanillas_1011()
            case 5: //vísperas
                //5FB9
                ReproducirSonidoCampanas_100C()
            case 6: //completas
                //5FBD
                //dibuja y borra la espiral
                DibujarEspiral_3F6B()
                //fija la paleta 3
                //ModPantalla.SeleccionarPaleta(3)
                //programa el cambio de paleta de colores paracuando termina de dibujar la espiral
                CambiarPaletaColores = 3
                //bloquea las puertas del ala izquierda de la abadía
                TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] = 0xDF
                //pone en el canal 1 el sonido de las campanillas
                ReproducirSonidoCampanillas_1011()
            default:
                break
        }
    }

    public func EjecutarAccionesMomentoDia_3EEA() {
        //trata de ejecutar unas acciones dependiendo del momento del día
        //copia el estado de la reproducción de frases/voces
        struct Estatico {
            static var Contador:Int = 0
        }
        var nose:Int
        Estatico.Contador = Estatico.Contador + 1
        nose = Estatico.Contador
        ReproduciendoFrase_2DA1 = ReproduciendoFrase_2DA2
        //        If Contador < 12 Then
        //       ReproduciendoFrase_2DA1 = false
        //      //TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
        //     Else
        //    Stop
        //   End If

        //hl apunta a los datos del personaje que se muestra en pantalla
        //si está en medio de una animación, sale
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PunteroDatosPersonajeActual_2D88 - 0x3036, 0) { return }
        //3EF6
        //lee si hay que avanzar el momento del día
        if TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] == 0 {
            //3EFA
            //si no hay que avanzar el momento del día, trata de ejecutar las acciones programadas según el momento del día
            ProcesarLogicaMomentoDia_5EF9()
        } else {
            //3EFD
            //hay que avancar el momento del día, sólo si no se está reproduciendo ninguna voz
            if ReproduciendoFrase_2DA1 { return }
            //3F02
            //indica que ya no hay que avanzar el momento del día
            TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 0
            //avanza el momento del día
            ActualizarMomentoDia_553E()
            //si ha cambiado el momento del día, ejecuta unas acciones dependiendo del momento del día
            ProcesarLogicaMomentoDia_5EF9()
        }
    }

    public func EjecutarComportamientoPersonajes_2664() {
        if depuracion.PersonajesAdso { EjecutarComportamientoAdso_087B() }
        if depuracion.PersonajesAbad { EjecutarComportamientoAbad_071E() }
        if depuracion.PersonajesMalaquias { EjecutarComportamientoMalaquias_06FD() }
        if depuracion.PersonajesBerengario { EjecutarComportamientoBerengarioBernardoEncapuchadoJorge_0830() }
        if depuracion.PersonajesSeverino { EjecutarComportamientoSeverinoJorge_0851() }
    }

    public func EjecutarComportamientoMalaquias_06FD() {
        var PersonajeIY:Int
        var PunteroDatosMalaquiasIX:Int
        //apunta a las características de malaquías
        PersonajeIY = 0x3054
        //apunta a las variables de movimiento de malaquías
        PunteroDatosMalaquiasIX = 0x3CAB
        //indica que el personaje inicialmente si quiere moverse
        TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 0
        //ejecuta la lógica de malaquías (puede cambiar 0x3c9c)
        ProcesarLogicaMalaquias_575E(PersonajeIY, PunteroDatosMalaquiasIX)
        //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
        ActualizarTablaPuertas_3EA4(MascaraPuertasC: 0x3F)
        //apunta a la tabla de datos para mover a malaquías
        //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        ActualizarDatosPersonaje_291D(0x2BC2)
        //apunta a las variables de movimiento del abad
        GenerarMovimiento_073C(PersonajeOrigenIY: PersonajeIY, PersonajeObjetoIX: 0x3CAB)
    }

    public func EjecutarComportamientoBerengarioBernardoEncapuchadoJorge_0830() {
        var PersonajeIY:Int
        var PunterosBerengarioHL:Int //puntero a TablaPunterosPersonajes_2BAE
        var DatosLogicaBerengarioIX:Int //puntero a TablaVariablesLogica_3C85
        //apunta a los datos de posición de berengario
        PersonajeIY = 0x3072
        //apunta a las variables de movimiento de berengario
        DatosLogicaBerengarioIX = 0x3CEA
        //indica que el personaje inicialmente si quiere moverse
        TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 0
        //ejecuta la lógica de berengario
        ProcesarLogicaBerengarioBernardoEncapuchadoJorge_593F(PersonajeIY, DatosLogicaBerengarioIX)
        //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
        ActualizarTablaPuertas_3EA4(MascaraPuertasC: 0x3F)
        //apunta a la tabla de berengario
        //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        PunterosBerengarioHL = 0x2BD6
        ActualizarDatosPersonaje_291D(PunterosBerengarioHL)
        //apunta a las variables de movimiento de berengario
        GenerarMovimiento_073C(PersonajeOrigenIY: PersonajeIY, PersonajeObjetoIX: DatosLogicaBerengarioIX)
    }

    public func EjecutarComportamientoSeverinoJorge_0851() {
        var PersonajeIY:Int
        var PunterosSeverinoHL:Int //puntero a TablaPunterosPersonajes_2BAE
        var DatosLogicaSeverinoIX:Int //puntero a TablaVariablesLogica_3C85
        //apunta a los datos de posición de severino
        PersonajeIY = 0x3081
        //apunta a las variables de estado de severino
        DatosLogicaSeverinoIX = 0x3D02
        //indica que el personaje inicialmente si quiere moverse
        TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 0
        //ejecuta los cambios de estado de severino/jorge
        ProcesarLogicaSeverinoJorge_5BC6(PersonajeIY, DatosLogicaSeverinoIX)
        //modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
        ActualizarTablaPuertas_3EA4(MascaraPuertasC: 0x3F)
        //apunta a la tabla de severino
        //comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
        PunterosSeverinoHL = 0x2BE0
        ActualizarDatosPersonaje_291D(PunterosSeverinoHL)
        //apunta a las variables de movimiento de berengario
        GenerarMovimiento_073C(PersonajeOrigenIY: PersonajeIY, PersonajeObjetoIX: DatosLogicaSeverinoIX)
    }

    public func ProcesarLogicaMalaquias_575E( _ PersonajeIY:Int, _ PunteroDatosMalaquiasIX:Int) {
        //lógica de malaquías
        //si malaquías ha muerto
        if TablaVariablesLogica_3C85[MalaquiasMuriendose_3CA2 - 0x3C85] == 2 {
            //5764
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
            return
        }
        //5767
        //si está muriendo, avanza la altura de malaquías
        if TablaVariablesLogica_3C85[MalaquiasMuriendose_3CA2 - 0x3C85] == 1 {
            //576C
            MatarMalaquias_4386()
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
            return
        }
        //5773
        //si el abad está en el estado de echar a guillermo de la abadía
        if TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0B {
            //5779
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
            return
        }
        //577C
        //si es de noche o completas
        if (MomentoDia_2D81 == 0) || (MomentoDia_2D81 == 6) {
            //5786
            //va a su celda
            TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 7
            //pasa al estado 8
            TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 8
            return
        }
        //578D
        //si es vísperas
        if MomentoDia_2D81 == 5 {
            //5794
            //si está en el estado 0x0c
            if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 0x0C {
                //579A
                //va a buscar al abad
                TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 0xFE
                //si ha llegado a la posición del abad
                if TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] == 0xFE {
                    //57A5
                    //cambia el estado del abad para que eche a guillermo
                    TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x0B
                    //cambia al estado 6
                    TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 6
                }
                //57AB
                return
            }
            //57AC
            //si está en el estado 0
            if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 0 {
                //57B2
                //modifica la máscara de los objetos que puede coger malaquías (puede coger la llave del pasadizo)
                TablaObjetosPersonajes_2DEC[MascaraObjetosMalaquias_2DFF - 0x2DEC] = 2
                //va a la mesa del scriptorium a coger la llave
                TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 6
                //si ha llegado a la mesa del scriptorium donde está la llave
                if TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] == 6 {
                    //57BE
                    //pasa al estado 2
                    TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 2
                } else {
                    //57C3
                    return
                }
            }
            //57C4
            //si su estado es < 4
            if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] < 4 {
                //57CA
                //si la altura de guillermo es >= 0x0c
                if TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] >= 0x0C {
                    //57D0
                    //va a por guillermo
                    TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 0xFF
                    //57DA
                    //si está en el estado 2
                    if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 2 {
                        //57E0
                        //compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
                        if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                            //57E5
                            //escribe en el marcador la frase
                            //DEBEIS ABANDONAR EDIFICIO, HERMANO
                            EscribirFraseMarcador_501B(NumeroFrase: 9)
                            //pasa al estado 3
                            TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 3
                            //inicia el contador del tiempo que permite a guillermo estar en el scriptorium
                            TablaVariablesLogica_3C85[ContadorGuillermoDesobedeciendo_3C9E - 0x3C85] = 0
                            return
                        }
                    } else {
                        //57F0
                        //si está en el estado 3
                        if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 3 {
                            //57F6
                            //incrementa el contador
                            TablaVariablesLogica_3C85[ContadorGuillermoDesobedeciendo_3C9E - 0x3C85] = TablaVariablesLogica_3C85[ContadorGuillermoDesobedeciendo_3C9E - 0x3C85] + 1
                            //si el contador llega al límite tolerable
                            if TablaVariablesLogica_3C85[ContadorGuillermoDesobedeciendo_3C9E - 0x3C85] >= 0xFA {
                                //5802
                                //escribe en el marcador la frase
                                //ADVERTIRE AL ABAD
                                EscribirFraseMarcador_501B(NumeroFrase: 0x0A)
                                //cambia al estado 0x0c
                                TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0x0C
                            }
                            //5809
                            return
                        }
                    }
                } else {
                    //57D6
                    //pasa al estado 4
                    TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 4
                    return
                }
            }
            //580A
            //si está en el estado 4
            if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 4 {
                //5810
                //va a cerrar las puertas del ala izquierda de la abadía
                TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 4
                //si ha llegado a las puertas del ala izquierda de la abadía
                if TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] == 4 {
                    //5819
                    //si berengario o bernardo gui no han abandonado el ala izquierda de la abadía
                    if (TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] < 0x62) && (TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] == 0) {
                        //5821
                        //3E5B
                        //indica que el personaje no quiere buscar ninguna ruta
                        TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                        return
                    } else {
                        //5824
                        //pasa al estado 5
                        TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 5
                        //indica que las puertas ya no permanecen fijas
                        TablaDatosPuertas_2FE4[Puerta1_2FFE - 0x2FE4] = TablaDatosPuertas_2FE4[Puerta1_2FFE - 0x2FE4] & 0x7F
                        TablaDatosPuertas_2FE4[Puerta2_3003 - 0x2FE4] = TablaDatosPuertas_2FE4[Puerta2_3003 - 0x2FE4] & 0x7F
                    }
                }
                //5831
                return
            } else {
                //5832
                //si está en el estado 5
                if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 5 {
                    //5838
                    //se va a la mesa de la cocina de delante del pasadizo
                    TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 5
                    //bloquea las puertas del ala izquierda de la abadía
                    TablaVariablesLogica_3C85[PuertasAbribles_3CA6 - 0x3C85] = 0xDF
                    //si guillermo está en el ala izquierda de la abadía
                    if TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] < 0x60 {
                        //5845
                        //pasa al estado 0x0c para advertir al abad
                        TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0x0C
                    }
                    //5848
                    //si ha llegado al sitio al que quería llegar, avanza el estado
                    ComprobarDestinoAvanzarEstado_3E98(PunteroVariablesLogicaIX: PunteroDatosMalaquiasIX)
                    return
                } else {
                    //584B
                    //si está en el estado 6
                    if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 6 {
                        //5851
                        //va a la iglesia
                        TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 0
                        //si ha llegado al sitio al que quería llegar, avanza el estado
                        ComprobarDestinoAvanzarEstado_3E98(PunteroVariablesLogicaIX: PunteroDatosMalaquiasIX)
                    }
                    //5857
                    //si el estado de malaquías es el 0x0b
                    if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 0x0B {
                        //585D
                        //si no se está reproduciendo una frase
                        if !ReproduciendoFrase_2DA1 {
                            //5863
                            //indica que malaquías está muriendo
                            TablaVariablesLogica_3C85[MalaquiasMuriendose_3CA2 - 0x3C85] = 1
                        }
                        //5866
                        return
                    } else {
                        //5867
                        //si está en el estado 7
                        if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 7 {
                            //586D
                            //si es el quinto día
                            if NumeroDia_2D80 == 5 {
                                //5873
                                //si está en la iglesia (la comparación con 0x23 no es necesaria?)
                                if NumeroPantallaActual_2DBD == 0x22 || NumeroPantallaActual_2DBD == 0x23 {
                                    //587D
                                    //indica que no ha llegado a la iglesia todavía
                                    TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] = 1
                                    //pasa al estado 0x0b
                                    TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0x0B
                                    //escribe en el marcador la frase
                                    //ERA VERDAD, TENIA EL PODER DE MIL ESCORPIONES
                                    EscribirFraseMarcador_501B(NumeroFrase: 0x1F)
                                }
                            }
                            //5887
                            return
                        } else {
                            //5888
                            return
                        }
                    }
                }
            }
        }
        //5889
        //si es prima
        if MomentoDia_2D81 == 1 {
            //588F
            //cambia al estado 9
            TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 9
            //va a misa
            TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 0
            return
        }
        //5896
        //si malaquías ha llegado a su puesto en el scriptorium
        if TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] == 2 {
            //589C
            //cambia al estado 0
            TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0
            //modifica la máscara de los objetos que puede coger malaquías
            TablaObjetosPersonajes_2DEC[MascaraObjetosMalaquias_2DFF - 0x2DEC] = 0
            //deja la llave del pasadizo en la mesa de malaquías
            DejarLlavePasadizo_4022()
        }
        //58A5
        //si está en el estado 0
        if TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 0 {
            //58AC
            //compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
            if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                //58B2
                //si ha salido a cerrar el paso a guillermo
                if TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] == 3 {
                    //58B8
                    //si berengario no ha llegado a su puesto de trabajo
                    if !LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 7) {
                        //58BF
                        //si la posición y de guillermo < 0x38
                        if TablaCaracteristicasPersonajes_3036[0x3039 - 0x3036] < 0x38 {
                            //58C5
                            //???
                            SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 7)
                            //dice la frase
                            //LO SIENTO, VENERABLE HERMANO, NO PODEIS SUBIR A LA BIBLIOTECA
                            EscribirFraseMarcador_501B(NumeroFrase: 0x33)
                        }
                        //58CF
                        return
                    }
                    //58D1
                    if !LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 6) {
                        //58D8
                        //si es el segundo día y no se está reproduciendo ninguna frase
                        if (NumeroDia_2D80 == 2) && (!ReproduciendoFrase_2DA1) {
                            //58E0
                            SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 6)
                            //dice la frase
                            //SI LO DESEAIS, BERENGARIO OS MOSTRARA EL SCRIPTORIUM
                            EscribirFraseMarcador_5026(NumeroFrase: 0x34)
                            return
                        }
                        //58EB
                        return
                    }
                    //58ED
                    if !LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 4) {
                        //58F3
                        //compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
                        if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                            //58F8
                            //si está muy cerca, sale
                            return
                        }
                        //58F9
                        //aquí llega si está lejos, pero esto no puede ser, ya que esto está dentro de un (si guillermo está cerca...) (???)
                        SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 4)
                    }
                    //58FE
                    return
                }
                //58FF
                //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
                DescartarMovimientosPensados_08BE(PersonajeIY: PersonajeIY)
                //comprueba si está pulsado el cursor arriba
                if !TeclaPulsadaNivel_3482(0) {
                    //5908
                    //indica que el personaje no quiere buscar ninguna ruta
                    //3E5B
                    //indica que el personaje no quiere buscar ninguna ruta
                    TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                    return
                }
                //590B
                //sale a cerrar el paso a guillermo
                TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 3
                return
            }
            //590F
            //vuelve a su mesa
            TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 2
            return
        }
        //5913
        //si es tercia
        if MomentoDia_2D81 == 2 {
            //5919
            //si está en el estado 0x09 en el quinto día
            if (TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] == 9) && (NumeroDia_2D80 == 5) {
                //5923
                //va a la celda de severino
                TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 8
                //si malaquías y severino están en la celda de severino
                if (TablaVariablesLogica_3C85[DondeEstaMalaquias_3CA8 - 0x3C85] == 8) && (TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 2) {
                    //5930
                    //mata a severino/activa a jorge
                    TablaVariablesLogica_3C85[JorgeActivo_3CA3 - 0x3C85] = 1
                    //cambia al estado 0x0a
                    TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0x0A
                }
                //5936
                return
            }
            //5937
            //cambia al estado 0x0a
            TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] = 0x0A
            //va a su mesa de trabajo
            TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] = 2
            return
        }
        //593E
    }

     public func CambiarCaraBerengarioEncapuchado_4094() {
         //cambia la cara de berengario por la del encapuchado
         var CaraBerengarioHL:Int
         var CaraEncapuchadoDE:Int
         //rota los gráficos de los monjes si fuera necesario
         RotarGraficosMonjes_36C4()
         //puntero a los datos gráficos de la cara de berengario
         CaraBerengarioHL = 0x309B
         //puntero a los datos gráficos de la cara del encapuchado
         CaraEncapuchadoDE = 0xB35B
         //409D
         //[hl] = de
         Escribir16(&TablaPunterosCarasMonjes_3097, CaraBerengarioHL - 0x3097, CaraEncapuchadoDE)
     }

    public func ComprobarPergamino_43ED() -> Bool {
        //devuelve true si guillermo tiene el pergamino sin que el abad haya sido
        //advertido, o  si el pergamino está en la planta 0
        //devuelve false si el abad ha sido advertido de que guillermo tiene el
        //pergamino, o si el pergamino ha sido cogido por otro personaje
        var ComprobarPergamino_43ED:Bool
        var AlturaPergaminoA:UInt8
        var AlturaPlantaPergaminoB:UInt8
        ComprobarPergamino_43ED = false
        //si ha advertido al abad, sale
        if LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 0) { return ComprobarPergamino_43ED }
        //si guillermo tiene el pergamino, sale
        if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) {
            ComprobarPergamino_43ED = true
            return ComprobarPergamino_43ED
        }
        //si el pergamino está cogido, sale
        if LeerBitArray(TablaPosicionObjetos_3008, 0x3017 - 0x3008, 7) { return ComprobarPergamino_43ED }
        //obtiene la altura del pergamino
        AlturaPergaminoA = TablaPosicionObjetos_3008[0x301B - 0x3008]
        //dependiendo de la altura, devuelve la altura base de la planta en b
        AlturaPlantaPergaminoB = LeerAlturaBasePlanta_2473(AlturaPergaminoA)
        if AlturaPlantaPergaminoB == 0 { ComprobarPergamino_43ED = true }
       return ComprobarPergamino_43ED
   }

    public func ProcesarLogicaBerengarioBernardoEncapuchadoJorge_593F( _ PersonajeIY:Int, _ DatosBerengarioIX:Int) {
         //lógica de berengario/jorge/bernardo/encapuchado
         //si jorge no está haciendo nada, sale
         if TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] == 1 {
             //5945
             //3E5B
             //indica que el personaje no quiere buscar ninguna ruta
             TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
             return
         }
         //5948
         //si es el tercer día
         if NumeroDia_2D80 == 3 {
             //594E
             //si es prima
             if MomentoDia_2D81 == 1 {
                 //5954
                 //3E5B
                 //indica que el personaje no quiere buscar ninguna ruta
                 TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                 return
             }
             //5957
             //si es tercia
             if MomentoDia_2D81 == 2 {
                 //595D
                 //si está en el estado 0x1e
                 if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 0x1E {
                     //5963
                     //si no está reproduciendo una voz
                     if !ReproduciendoFrase_2DA1 {
                         //5969
                         //pasa al estado 0x1f
                         TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0x1F
                     }
                     //596C
                     //3E5B
                     //indica que el personaje no quiere buscar ninguna ruta
                     TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                     return
                 }
                 //596F
                 //si está en el estado 0x1f
                 if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 0x1F {
                     //5975
                     //compara la distancia entre guillermo y jorge (si está muy cerca devuelve 0, en otro caso != 0)
                     if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                         //597A
                         //pone en el marcador la frase
                         //SED BIENVENIDO, VENERABLE HERMANO; Y ESCUCHAD LO QUE OS DIGO. LAS VIAS DEL ANTICRISTO SON LENTAS Y TORTUOSAS. LLEGA CUANDO MENOS LO ESPERAS. NO DESPERDICIEIS LOS ULTIMOS DIAS
                         EscribirFraseMarcador_5026(NumeroFrase: 0x32)
                         //indica que hay que avanzar el momento del día
                         TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                     }
                     //5981
                     //3E5B
                     //indica que el personaje no quiere buscar ninguna ruta
                     TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                     return
                 }
                 //5984
                 //compara la distancia entre guillermo y jorge (si está muy cerca devuelve 0, en otro caso != 0)
                 if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                     //5989
                     //escribe en el marcador la frase
                     //VENERABLE JORGE, EL QUE ESTA ANTE VOS ES FRAY GUILLERMO, NUESTRO HUESPED
                     EscribirFraseMarcador_501B(NumeroFrase: 0x31)
                     //pasa al estado 0x1e
                     TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0x1E
                 }
                 //5990
                 //3E5B
                 //indica que el personaje no quiere buscar ninguna ruta
                 TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                 return
             }
             //5993
             //si es sexta
             if MomentoDia_2D81 == 3 {
                 //5999
                 //se va a la celda de los monjes
                 TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 3
                 //pasa al estado 0
                 TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0
                 //si la posición x de jorge ??? esto no tiene mucho sentido, porque es una frase que dice adso!!!
                 if TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] == 0x60 {
                     //59A5
                     //pone en el marcador la frase
                     //PRONTO AMANECERA, MAESTRO
                     EscribirFraseMarcador_5026(NumeroFrase: 0x27)
                 }
                 //59A9
                 //si ha llegado a su celda, lo indica
                 if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 3 {
                     //59AF
                     //indica que jorge no va a hacer nada más por ahora
                     TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] = 1
                 }
                 //59B2
                 return
             }
         }
         //59B3
         //aquí llega si no es el tercer día
         //si es sexta
         if MomentoDia_2D81 == 3 {
             //59B9
             //va al refectorio
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 1
             return
         }
         //59BD
         //si es prima
         if MomentoDia_2D81 == 1 {
             //59C3
             //va a la iglesia
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0
             return
         }
         //59C7
         //si es el quinto día
         if NumeroDia_2D80 == 5 {
             //59CD
             //si ha llegado a la salida de la abadía, lo indica
             if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 4 {
                 //59D3
                 //indica que Bernardo no va a hacer nada más por ahora?
                 TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] = 1
                 //posición x de berengario = 0
                 TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] = 0
             }
             //59D9
             //se va de la abadía
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 4
         }
         //59DC
         //si es completas
         if MomentoDia_2D81 == 6 {
             //59E2
             //se va a la celda de los monjes
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 3
             return
         }
         //59E6
         //si es de noche
         if MomentoDia_2D81 == 0 {
             //59ED
             //si es el tercer día
             if NumeroDia_2D80 == 3 {
                 //59F4
                 //si está en el estado 6
                 if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 6 {
                     //59FA
                     //modifica la máscara de los objetos que puede coger. sólo el libro
                     TablaObjetosPersonajes_2DEC[MascaraObjetosBerengarioBernardo_2E0D - 0x2DEC] = 0x80
                     //si está en su celda
                     if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 3 {
                         //5A04
                         //indica que va hacia las escaleras al pie del scriptorium
                         TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 5
                         return
                     }
                     //5A08
                     //se dirige hacia el libro
                     TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFD
                     //si tiene el libro
                     if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosBerengario_2E0B - 0x2DEC, 7) {
                         //5A16
                         //si ha llegado a la celda de severino
                         if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 6 {
                             //5A1C
                             //indica que hay que avanzar el momento del día
                             TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                         }
                         //5A1F
                         //se dirige a la celda de severino
                         TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 6
                     }
                     //5A22
                     return
                 }
                 //5A23
                 //si está en su celda
                 if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 3 {
                     //5A29
                     //pasa al estado 6
                     TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 6
                     //cambia la cara de berengario por la del encapuchado
                     CambiarCaraBerengarioEncapuchado_4094()
                     return
                 }
             }
             //5A30
             //se dirige a la celda de los monjes
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 3
             return
         }
         //5A34
         //si es visperas
         if MomentoDia_2D81 == 5 {
             //5A3A
             //si es el segundo día y malaquías no ha abandonado el scriptorium
             if (NumeroDia_2D80 == 2) && (TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] < 4) {
                 //5A44
                 //3E5B
                 //indica que el personaje no quiere buscar ninguna ruta
                 TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                 return
             }
             //5A47
             //pasa al estado 1
             TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 1
             //va a la iglesia
             TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0
             return
         }
         //5A4E
         //si es el primer o segundo día
         if NumeroDia_2D80 < 3 {
             //5A55
             //si está en el estado 4
             if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 4 {
                 //5A5B
                 //incrementa el tiempo que lleva guillermo con el pergamino
                 TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                 //si guillermo no tiene mucho tiempo el pergamino y no ha cambiado de pantalla
                 if (TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] < 0x41) && (NumeroPantallaActual_2DBD == 0x40) {
                     //5A6B
                     //si guillermo no tiene el pergamino
                     if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) {
                         //5A71
                         //cambia el estado de berengario
                         TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0
                     }
                     //5A74
                     return
                 }
                 //5A75
                 //cambia el estado de berengario
                 TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 5
                 //437D
                 //deshabilita el contador para que avance el momento del día de forma automática
                 TiempoRestanteMomentoDia_2D86 = 0
                 return
             }
             //5A7C
             //si está en el estado 5
             if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 5 {
                 //5A82
                 //va hacia la posición del abad
                 TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFE
                 //si berengario ha llegado a la posición del abad
                 if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 0xFE {
                     //5A8D
                     //pone el contador al valor máximo
                     TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0xC9
                     //cambia el estado de berengario
                     TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0
                     //indica que guillermo ha cogido el pergamino
                     TablaVariablesLogica_3C85[BerengarioChivato_3C94 - 0x3C85] = 1
                     //indica que el abad ha sido advisado de que guillermo ha cogido el pergamino
                     SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 0)
                 }
                 //5A9C
                 return
             }
             //5A9D
             //si ha llegado a su mesa del scriptorium
             if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 2 {
                 //5AA3
                 //comprueba el estado del pergamino
                 if ComprobarPergamino_43ED() {
                     //5AA8
                     //guillermo ha codigo el pergamino
                     //reinicia el contador
                     TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                     //pasa al estado 4
                     TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 4
                     //compara la distancia entre guillermo y berengario(si está muy cerca devuelve 0, en otro caso != 0)
                     if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                         //5AB3
                         //si está cerca de guillermo
                         //pone en el marcador la frase
                         //DEJAD EL MANUSCRITO DE VENACIO O ADVERTIRE AL ABAD
                         EscribirFraseMarcador_5026(NumeroFrase: 4)
                         return
                     }
                     //5AB9
                     //pasa al estado 5
                     TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 5
                     //437D
                     //deshabilita el contador para que avance el momento del día de forma automática
                     TiempoRestanteMomentoDia_2D86 = 0
                     return
                 }
             }
             //5AC0
             //si malaquías le ha dicho que berengario le puede enseñar el scriptorium y la altura de guillermo >= 0x0d
             if LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 6) && (TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] >= 0x0D) {
                 //5ACE
                 //si no le había dicho lo de los mejores copistas de occidente
                 if !LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 4) {
                     //5AD4
                     //berengario va a por guillermo
                     TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFF
                     //compara la distancia entre guillermo y berengario (si está muy cerca devuelve 0, en otro caso != 0)
                     if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                         //5ADD
                         //si no se está reproduciendo una frase
                         if !ReproduciendoFrase_2DA1 {
                             //5AE3
                             //indica que berengario ha llegado a donde está guillermo
                             TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] = 0xFF
                             //descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
                             DescartarMovimientosPensados_08BE(PersonajeIY: PersonajeIY)
                             //indica que ya le ha dicho lo de los mejores copistas de occidente
                             SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 4)
                             //pone en el marcador la frase
                             //AQUI TRABAJAN LOS MEJORES COPISTAS DE OCCIDENTE
                             EscribirFraseMarcador_5026(NumeroFrase: 0x35)
                         }
                         //5AF3
                         //3E5B
                         //indica que el personaje no quiere buscar ninguna ruta
                         TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                         return
                     }
                     //5AF6
                     return
                 }
                 //5AF9
                 //si no le ha dicho lo de venacio
                 if !LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 3) {
                     //5AFF
                     //va a su mesa del scriptorium
                     TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 2
                     //compara la distancia entre guillermo y berengario (si está muy cerca devuelve 0, en otro caso != 0)
                     if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                         //5B07
                         //si está cerca de guillermo
                         //si berengario ha llegado al scriptorium y no se estaba reproduciendo una frase
                         if (TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 2) && !ReproduciendoFrase_2DA1 {
                             //5B0F
                            //indica que ya le ha enseñado donde trabaja venacio
                            SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 3)
                            //pone en el marcador la frase
                            //AQUI TRABAJABA VENACIO
                            EscribirFraseMarcador_5026(NumeroFrase: 0x36)
                        }
                        //5B18
                        return
                    }
                    //5B19
                    //si ha llegado a su puesto en el scriptorium y guillermo no le ha seguido
                    if TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] == 2 {
                        //5B1F
                        //??? esto es un bug del juego??? creo que debería ser 0x08 en vez de 0x80
                        SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 7)
                    }
                }
            }
            //5B25
            //cambia el estado de berengario
            TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0
            //no se mueve de su puesto de trabajo
            TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 2
            return
        }
        //5B2C
        //si está en el estado 0x14
        if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 0x14 {
            //5B32
            //si ha llegado al sitio donde quería ir
            if TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] == TablaVariablesLogica_3C85[DondeEsta_Berengario_3CE7 - 0x3C85] {
                //5B38
                //se mueve de forma aleatoria por la abadía
                TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = TablaVariablesLogica_3C85[ValorAleatorio_3C9D - 0x3C85] & 0x03
            }
            //5B3D
            return
        }
        //5B3E
        //si es el cuarto día
        if NumeroDia_2D80 == 4 {
            //5B45
            //si bernardo va a por el abad y el abad tiene el pergamino
            if (TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] == 0xFE) && LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) {
                //5B52
                //cambia el estado de berengario
                TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0x14
                //va al refectorio
                TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 1
                //cambia el estado del abad
                TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] = 0x15
                return
            }
            //5B5C
            //si bernardo tiene el pergamino
            if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosBerengario_2E0B - 0x2DEC, 4) {
                //5B64
                //va a por el abad
                TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFE
                //437D
                //deshabilita el contador para que avance el momento del día de forma automática
                TiempoRestanteMomentoDia_2D86 = 0
                //cambia la máscara de los objetos que puede coger bernardo
                TablaObjetosPersonajes_2DEC[MascaraObjetosBerengarioBernardo_2E0D - 0x2DEC] = 0
                return
            }
            //5B6F
            //si el pergamino está a buen recaudo o el abad va a echar a guillermo
            if (TablaVariablesLogica_3C85[EstadoPergamino_3C90 - 0x3C85] == 1) || LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosAbad_2E04 - 0x2DEC, 4) || (TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0B) {
                //5B7F
                //va a su puesto en el scriptorium
                TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 2
                //cambia el estado de bernardo
                TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 0x14
                return
            }
            //5B86
            //indica que el pergamino no se le ha quitado a guillermo
            TablaVariablesLogica_3C85[EstadoPergamino_3C90 - 0x3C85] = 0
            //deshabilita el contador para que avance el momento del día de forma automática
            //437D
            //deshabilita el contador para que avance el momento del día de forma automática
            TiempoRestanteMomentoDia_2D86 = 0
            //si guillermo tiene el pergamino
            if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) {
                //5B94
                //si está en el estado 7
                if TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] == 7 {
                    //5B9A
                    //va a por guillermo
                    TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFF
                    //compara la distancia entre guillermo y bernardo gui (si está muy cerca devuelve 0, en otro caso != 0)
                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                        //5BA3
                        //si está cerca de guillermo
                        //si no está mostrando una frase
                        if !ReproduciendoFrase_2DA1 {
                            //5BA9
                            //pone en el marcador la frase
                            //DADME EL MANUSCRITO, FRAY GUILLERMO
                            EscribirFraseMarcador_5026(NumeroFrase: 5)
                            //decrementa la vida de guillermo en 2 unidades
                            //55CE
                            DecrementarObsequium_55D3(Decremento: 2)
                        }
                    }
                    //5BB0
                    return
                }
                //5BB2
                //compara la distancia entre guillermo y bernardo gui (si está muy cerca devuelve 0, en otro caso != 0)
                if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                    //5BB7
                    //va a la celda de los monjes
                    TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 3
                    return
                }
                //5BBB
                //cambia el estado de berengario
                TablaVariablesLogica_3C85[EstadoBerengario_3CE8 - 0x3C85] = 7
                return
            }
            //5BC1
            //va a por el pergamino
            TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] = 0xFC
        }
        //5BC5
    }

    public func DejarLibro_40AF() {
        //jorge dejael libro
        var ObjetosSeverinoJorgeIX:Int //apunta a TablaObjetosPersonajes_2DEC
        ObjetosSeverinoJorgeIX = 0x2E0F
        DejarObjeto_5277(ObjetosSeverinoJorgeIX)
    }

    public func ApagarLuzQuitarLibro_4248() {
        //apaga la luz de la pantalla y le quita el libro a guillermo
        var ObjetosGuillermoC:UInt8
        var MascaraA:UInt8
        //indica que la pantalla no está iluminada
        HabitacionOscura_156C = true
        //le quita el libro a guillermo
        ClearBitArray(&TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 7)
        ObjetosGuillermoC = TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC]
        MascaraA = 0x80
        //actualiza el marcador el marcador para que no se muestre el libro
        ActualizarMarcador_51DA(ObjetosC: ObjetosGuillermoC, MascaraA: MascaraA)
        //copia en 0x3008 -> 00 00 00 00 00 (hace desaparecer el libro)
        CopiarDatosPersonajeObjeto_4145(PersonajeObjetoHL: 0x3008, Bytes: [0, 0, 0, 0, 0])
    }

    public func ProcesarLogicaSeverinoJorge_5BC6( _ PersonajeIY:Int, _ DatosBerengarioIX:Int) {
        //lógica de severino/jorge
        if TablaVariablesLogica_3C85[JorgeActivo_3CA3 - 0x3C85] == 1 {
            //5BCC
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
            return
        }
        //5BCF
        //si está en el día 6 o 7, el personaje es jorge y no severino
        if NumeroDia_2D80 >= 6 {
            //5BD6
            //si está en el estado 0x0b
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x0B {
                //5BDC
                //si no está reproduciendo una voz
                if !ReproduciendoFrase_2DA1 {
                    //5BE2
                    //deja el libro
                    DejarLibro_40AF()
                    //cambia a estado 0c
                    TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x0C
                }
                //5BE8
                //3E5B
                //indica que el personaje no quiere buscar ninguna ruta
                TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                return
            }
            //5BEB
            //si está en el estado 0x0c
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x0C {
                //5BF1
                //si guillermo no tiene el libro
                if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 7) {
                    //5BF8
                    //3E5B
                    //indica que el personaje no quiere buscar ninguna ruta
                    TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                    return
                }
                //5BFB
                //pone en el marcador la frase
                //ES EL COENA CIPRIANI DE ARISTOTELES. AHORA COMPRENDEREIS POR QUE TENIA QUE PROTEGERLO. CADA PALABRA ESCRITA POR EL FILOSOFO HA DESTRUIDO UNA PARTE DEL SABER DE LA CRISTIANDAD. SE QUE HE ACTUADO SIGUIENDO LA VOLUNTAD DEL SEÑOR... LEEDLO, PUES, FRAY GUILLERMO. DESPUES TE LO MOSTRATE A TI MUCHACHO
                EscribirFraseMarcador_5026(NumeroFrase: 0x2E)
                //cambia al estado 0d
                TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x0D
                //3E5B
                //indica que el personaje no quiere buscar ninguna ruta
                TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                return
            }
            //5C05
            //si está en el estado 0x0d
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x0D {
                //5C0B
                //si guillermo no tiene los guantes
                if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 6) {
                    //5C12
                    //si guillermo sigue vivo
                    if TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] == 0 {
                        //5C18
                        //si ha salido a la habitación del espejo o ha terminado de reproducir la frase
                        if (NumeroPantallaActual_2DBD == 0x72) || !ReproduciendoFrase_2DA1 {
                            //5C20
                            //pone el contador para matar a guillermo en la siguiente ejecución de lógica por leer el libro sin los guantes
                            TablaVariablesLogica_3C85[ContadorLeyendoLibroSinGuantes_3C85 - 0x3C85] = 0xFF
                            //3E5B
                            //indica que el personaje no quiere buscar ninguna ruta
                            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                            return
                        }
                        //5C26
                        //inicia el contador para matar a guillermo por leer el libro sin los guantes
                        TablaVariablesLogica_3C85[ContadorLeyendoLibroSinGuantes_3C85 - 0x3C85] = 1
                    }
                    //5C29
                    //3E5B
                    //indica que el personaje no quiere buscar ninguna ruta
                    TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                    return
                }
                //5C2C
                //si no se está reproduciendo una frase
                if !ReproduciendoFrase_2DA1 {
                    //5C32
                    //pone en el marcador la frase
                    //VENERABLE JORGE, VOIS NO PODEIS VERLO, PERO MI MAESTRO LLEVA GUANTES.  PARA SEPARAR LOS FOLIOS TENDRIA QUE HUMEDECER LOS DEDOS EN LA LENGUA, HASTA QUE HUBIERA RECIBIDO SUFICIENTE VENENO
                    EscribirFraseMarcador_5026(NumeroFrase: 0x23)
                    //cambia al estado 0e
                    TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x0E
                }
                //5C39
                //3E5B
                //indica que el personaje no quiere buscar ninguna ruta
                TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                return
            }
            //5C3C
            //si está en el estado 0x0e
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x0E {
                //5C42
                //si no está reproduciendo una frase
                if !ReproduciendoFrase_2DA1 {
                    //5C48
                    //pone a cero el contador para apagar la luz
                    TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = 0
                    //cambia al estado 0f
                    TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x0F
                    //pone en el marcador la frase
                    //FUE UNA BUENA IDEA ¿VERDAD?; PERO YA ES TARDE
                    EscribirFraseMarcador_5026(NumeroFrase: 0x2F)
                }
                //5C52
                //3E5B
                //indica que el personaje no quiere buscar ninguna ruta
                TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                return
            }
            //5C55
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x0F {
                //5C5B
                //incrementa el contador para apagar la luz
                TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] = TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] + 1
                //si el contador ha llegado al límite
                if TablaVariablesLogica_3C85[Contador_3C98 - 0x3C85] == 0x28 {
                    //5C66
                    //oculta el área de juego
                    PintarAreaJuego_1A7D(ColorFondo: 0xFF)
                    //jorge va a la habitación donde muere
                    TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 4
                    //apaga la luz de la pantalla y le quita el libro a guillermo
                    ApagarLuzQuitarLibro_4248()
                    //cambia al estado 10
                    TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x10
                    return
                }
                //5C76
                //3E5B
                //indica que el personaje no quiere buscar ninguna ruta
                TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                return
            }
            //5C79
            //si está en estado 10
            if TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] == 0x10 {
                //5C7F
                //si jorge ha llegado a su destino y guillermo está en la habitación donde se va jorge con el libro y se acerca a éste
                if (TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 4) && (NumeroPantallaActual_2DBD == 0x67) && (TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] < 0x1E) {
                    //5C8D
                    //indica que se ha completado la investigación
                    TablaVariablesLogica_3C85[InvestigacionNoTerminada_3CA7 - 0x3C85] = 0
                    //indica que ha muerto jorge
                    TablaVariablesLogica_3C85[JorgeActivo_3CA3 - 0x3C85] = 1
                    //escribe en el marcador la frase
                    //SE ESTA COMIENDO EL LIBRO, MAESTRO
                    EscribirFraseMarcador_501B(NumeroFrase: 0x24)
                    //indica que la investigación ha concluido
                    TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
                }
                //5C9A
                return
            }
            //5C9B
            //si se está en la habitación de detrás del espejo, le da un bonus
            if NumeroPantallaActual_2DBD == 0x73 {
                //5CA1
                //obtiene un bonus
                Bonus2_2DBF = Bonus2_2DBF | 0x08
                //escribe en el marcador la frase
                //SOIS VOS, GUILERMO... PASAD, OS ESTABA ESPERANDO. TOMAD, AQUI ESTA VUESTRO PREMIO
                EscribirFraseMarcador_501B(NumeroFrase: 0x21)
                //inicia el estado de la secuencia final
                TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85] = 0x0B
            }
            //5CAD
            //3E5B
            //indica que el personaje no quiere buscar ninguna ruta
            TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
            return
        }
        //5CB0
        //aquí llega el día < 6 (si es severino)
        //si es de noche o completas
        if (MomentoDia_2D81 == 0) || (MomentoDia_2D81 == 6) {
            //5CBA
            //indica que ha llegado a su celda
            TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] = 2
            //se va a su celda
            TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 2
            return
        }
        //5CC1
        //si es prima
        if MomentoDia_2D81 == 1 {
            //5CC7
            //si está reproduciendo una voz y va a por guillermo, sale
            if ReproduciendoFrase_2DA1 && (TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] == 0xFF) {
                return
            }
            //5CD3
            //va a la iglesia
            TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0
            //si es el quinto día y guillermo ha sido avisado del libro en la celda de severino
            if (NumeroDia_2D80 == 5) && (TablaVariablesLogica_3C85[GuillermoAvisadoLibro_3CA4 - 0x3C85] == 0) {
                //5CE0
                //si guillermo está en el ala izquierda de la abadía
                if TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] < 0x60 {
                    //5CE6
                    //se ha perdido la oportunidad de avisar a guillermo
                    TablaVariablesLogica_3C85[GuillermoAvisadoLibro_3CA4 - 0x3C85] = 1
                    return
                }
                //5CEA
                //va a por guillermo
                TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0xFF
                //si ha llegado a donde está guillermo
                if TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 0xFF {
                    //5CF5
                    //escribe en el marcador la frase
                    //ESCUCHAD HERMANO, HE ENCONTRADO UN EXTRAÑO LIBRO EN MI CELDA
                    EscribirFraseMarcador_501B(NumeroFrase: 0x0F)
                    //indica que ya le ha dado el mensaje
                    TablaVariablesLogica_3C85[GuillermoAvisadoLibro_3CA4 - 0x3C85] = 1
                }
            }
            //5CFC
            return
        }
        //5CFD
        //si es sexta
        if MomentoDia_2D81 == 3 {
            //5D03
            //va al refectorio
            TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 1
            return
        }
        //5D07
        //si aun no es vísperas
        if MomentoDia_2D81 < 5 {
            //5D0E
            //si no va a su celda, si se está paseando, si el día es >= 2 y si el abad no va a por guillermo
            if (!LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 1)) && (TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] >= 2) && (NumeroDia_2D80 >= 2) && (TablaVariablesLogica_3C85[DondeVaAbad_3CC8 - 0x3C85] <= 0xFF) {
                //5D21
                //si severino no se ha presentado y no se está reproduciendo una voz
                if (!LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 2)) && !ReproduciendoFrase_2DA1 {
                    //5D29
                    //compara la distancia entre guillermo y severino (si está muy cerca devuelve 0, en otro caso != 0)
                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                        //5D2E
                        //si severino está cerca de guillermo
                        //se presenta
                        TablaVariablesLogica_3C85[EstadosVarios_3CA5 - 0x3C85] = 4
                        //va a por guillermo
                        TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0xFF
                        //pone en el marcador la frase
                        //VENERABLE HERMANO, SOY SEVERINO, EL ENCARGADO DEL HOSPITAL. QUIERO ADVERTIROS QUE EN ESTA ABADIA SUCEDEN COSAS MUY EXTRAÑAS. ALGUIEN NO QUIERE QUE LOS MONJES DECIDAN POR SI SOLOS LO QUE DEBEN SABER
                        EscribirFraseMarcador_5026(NumeroFrase: 0x37)
                        return
                    }
                }
                //5D3A
                //si se ha presentado severino, continúa
                if LeerBitArray(TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 2) {
                    //5D42
                    //sigue a guillermo
                    TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0xFF
                    //si ha terminado de hablar
                    if !ReproduciendoFrase_2DA1 {
                        //5D4C
                        //va a su celda
                        TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 2
                        //indica que severino está cerca de las celdas de los monjes
                        TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] = 3
                        //indica que va a su celda
                        SetBitArray(&TablaVariablesLogica_3C85, EstadosVarios_3CA5 - 0x3C85, 1)
                    }
                    //5D57
                    return
                }
            }
            //5D58
            //si ha llegado a la posición de guillermo
            if TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 0xFF {
                //5D5F
                //si no se está reproduciendo una voz
                if !ReproduciendoFrase_2DA1 {
                    //5D65
                    //pone en el marcador la frase
                    //ES MUY EXTRAÑO, HERMANO GUILLERMO. BERENGARIO TENIA MANCHAS NEGRAS EN LA LENGUA Y EN LOS DEDOS
                    EscribirFraseMarcador_5026(NumeroFrase: 0x26)
                    //indica que al acabar la frase avanza el momento del día
                    TablaVariablesLogica_3C85[AvanzarMomentoDia_3C9A - 0x3C85] = 1
                }
                //5D6C
                return
            }
            //5D6D
            //si ha llegado a su celda
            if TablaVariablesLogica_3C85[DondeEstaSeverino_3CFF - 0x3C85] == 2 {
                //5D73
                //si es el quinto día
                if NumeroDia_2D80 == 5 {
                    //5D79
                    //3E5B
                    //indica que el personaje no quiere buscar ninguna ruta
                    TablaVariablesLogica_3C85[PersonajeNoquiereMoverse_3C9C - 0x3C85] = 1
                    return
                }
                //5D7C
                //si es tercia del cuarto día
                if (MomentoDia_2D81 == 2) && (NumeroDia_2D80 == 4) {
                    //5D86
                    //va a por guillermo
                    TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0xFF
                    //compara la distancia entre guillermo y severino (si está muy cerca devuelve 0, en otro caso != 0)
                    if CompararDistanciaGuillermo_3E61(PersonajeIY: PersonajeIY) == 0 {
                        //5D8F
                        //pone en el marcador la frase
                        //ESPERAD, HERMANO
                        EscribirFraseMarcador_5026(NumeroFrase: 0x2C)
                    }
                    //5D93
                    return
                }
                //5D94
                //va a la habitación de al lado de las celdas de los monjes
                TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 3
                return
            }
            //5D99
            //va a su celda
            TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 2
            return
        }
        //5D9D
        //va a la iglesia
        TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] = 0
    }

    public func AñadirNumerosRomanosPergamino_5643( _ NumeroA:UInt8) {
        //copia a la cadena del pergamino los números romanos de la habitación del espejo
        var PunteroNumeroHL:Int
        var PunteroCadenaPergaminoDE:Int
        var Contador:Int
        var TablaNumerosRomanos_5621:[UInt8] = [0x49, 0x58, 0xD8, 0x58, 0x49, 0xD8, 0x58, 0x58, 0xC9]
        //5621:     49 58 D8 -> IXX
        //        58 49 D8 -> XIX
        //        58 58 C9 -> XXI
        //obtiene la entrada al número romano de las escaleras en las que hay que pulsar QR frente al espejo
        //cada entrada ocupa 3 bytes
        NumeroRomanoHabitacionEspejo_2DBC = NumeroA
        PunteroNumeroHL = (Int(NumeroRomanoHabitacionEspejo_2DBC) - 1) * 3
        //tabla con los números romanos de las escaleras de la habitación del espejo
        PunteroNumeroHL = PunteroNumeroHL + 0x5621
        //apunta a los datos de la cadena del pergamino
        PunteroCadenaPergaminoDE = 0xB59E
        //copia los números romanos a las cadena del pergamino
        for Contador in 0...2 {
            TablaCaracteresPalabrasFrases_B400[PunteroCadenaPergaminoDE + Contador - 0xB400] = TablaNumerosRomanos_5621[PunteroNumeroHL + Contador - 0x5621]
        }
    }

    public func GenerarNumeroEspejo_562E() {
        //si no se había generado el número romano del enigma de la habitación del espejo, lo genera
        var NumeroA:UInt8
        //si no se había calculado el número
        if NumeroRomanoHabitacionEspejo_2DBC == 0 {
            //5634
            //genera un número aleatorio entre 1 y 3
            NumeroA = UInt8(round(Float.random(in: 1...3)))
        } else {
            return
        }
        //563B
        //copia a la cadena del pergamino el número generado
        AñadirNumerosRomanosPergamino_5643(NumeroA)
        //pone en el marcador la frase
        //SECRETUM FINISH AFRICAE, MANUS SUPRA XXX AGE PRIMUM ET SEPTIMUM DE QUATOR
        //(donde XXX es el número generado)
        EscribirFraseMarcador_5026(NumeroFrase: 0)
    }

    public func ActualizarPuertasGuillermoAdso_5241() {
        //actualiza las puertas a las que pueden entrar guillermo y adso
        var PermisosC:UInt8
        var PermisosA:UInt8
        var PermisoPuertaHL:Int
        //lee los objetos de adso
        PermisosC = TablaObjetosPersonajes_2DEC[ObjetosAdso_2DF6 - 0x2DEC]
        //se queda con la llave 3
        PermisosC = PermisosC & 0x02
        //desplaza 3 posiciones a la izquierda
        PermisosC = PermisosC << 3
        //apunta a las puertas que puede abrir adso
        PermisoPuertaHL = 0x2DDC
        //se queda con el bit 4 (permiso para la puerta del pasadizo de detrás de la cocina)
        PermisosA = 0xEF & TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9]
        //combina con la llave3
        PermisosA = PermisosA | PermisosC
        //actualiza el valor
        TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9] = PermisosA
        //lee los objetos que tiene guillermo
        PermisosC = TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC]
        //se queda con la llave 1 y la llave 2
        PermisosC = PermisosC & 0x0C
        PermisosA = PermisosC
        //se queda sólo con la llave 1 en c
        ClearBit(&PermisosC, 2)
        //mueve la llave 1 al bit 0
        PermisosC = PermisosC >> 3
        //se queda con la llave 2 en a (bit 2)
        PermisosA = PermisosA & 0x04
        //combina a y c
        PermisosC = PermisosC | PermisosA
        //apunta a las puertas que puede abrir guillermo
        PermisoPuertaHL = 0x2DD9
        //actualiza las puertas que puede abrir guillermo según las llaves que tenga
        PermisosA = 0xFA & TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9]
        PermisosA = PermisosA | PermisosC
        TablaPermisosPuertas_2DD9[PermisoPuertaHL - 0x2DD9] = PermisosA
    }

    public func ComprobarDejarObjeto_526D() {
        //comprueba si dejamos algún objeto y si es así, marca el sprite del objeto para dibujar
        //si se estaba pulsando el espacio
        if TeclaPulsadaNivel_3482(0x2F) {
            //apunta a los datos de los objetos de guillermo
            DejarObjeto_5277(0x2DEC)
        }
    }

    public func CogerDejarObjetos_50F0( _ ObjetoIX:Int) {
        //comprueba si los personajes cogen algún objeto
        //ix apunta a la tabla relacionada con los objetos de los personajes
        var ObjetoIX:Int = ObjetoIX
        var PosicionObjetoBC:Int = 0
        var AlturaObjetoA:UInt8 = 0
        var ObjetosA:UInt8
        var MascaraA:UInt8
        var ObjetosHL:Int
        var NoPuedeQuitar_5154:Bool //el personaje no puede quitar objetos
        var SpriteIX:Int //apunta a TablaSprites_2E17
        var ObjetoIY:Int //apunta a TablaPosicionObjetos_3008
        var ObjetoCogible:Bool //objeto representado por el bit 15 de hl
        var ObjetoXL:UInt8 //posición del objeto que se coge/deja
        var ObjetoYH:UInt8
        var ObjetoZA:UInt8
        var ObjetoHL:Int //posición del objeto o dirección del personaje que lo tiene
        var ObjetosPersonajeHL:Int //si el objeto está cogido, dirección del personaje que lo tiene. apunta a TablaObjetosPersonajes_2DEC
        var Saltar_5166:Bool //true para no pasar por 5166 cuando salta desde 5156
        var MascaraObjetoHL:Int //máscara con un bit indicando el objeto que está siendo comprobado
        var MascaraObjetoH:UInt8 = 0 //nibbles de MascaraObjetoHL
        var MascaraObjetoL:UInt8 = 0
        var ValorA:UInt8
        while true {
            if TablaObjetosPersonajes_2DEC[ObjetoIX - 0x2DEC] == 0xFF { return }
            //50F6
            //decrementa el contador para no coger/dejar varias veces
            TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC] = Z80Dec(TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC])
            //si (ix+$06) era 0 al entrar
            if TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC] == 0xFF {
                //5101
                //restaura el contador
                TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC] = Z80Inc(TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC])
                //modifica una rutina con los datos de posición del personaje y su orientación
                LeerPosicionObjetoDejar_534F(ObjetoIX, &PosicionObjetoBC, &AlturaObjetoA)
                //lee los objetos que se pueden coger
                ObjetosA = TablaObjetosPersonajes_2DEC[ObjetoIX + 4 - 0x2DEC]
                //elimina de la lista los que ya tenemos
                ObjetosA = ObjetosA ^ TablaObjetosPersonajes_2DEC[ObjetoIX + 0 - 0x2DEC]
                //bits que indican los objetos que podemos coger (2)
                ObjetosA = ObjetosA & TablaObjetosPersonajes_2DEC[ObjetoIX + 4 - 0x2DEC]
                //lee la máscara de los objetos que podemos coger
                MascaraA = TablaObjetosPersonajes_2DEC[ObjetoIX + 5 - 0x2DEC]
                //elimina de la lista los que ya tenemos
                MascaraA = MascaraA ^ TablaObjetosPersonajes_2DEC[ObjetoIX + 3 - 0x2DEC]
                //bits que indican los objetos que podemos coger
                MascaraA = MascaraA & TablaObjetosPersonajes_2DEC[ObjetoIX + 5 - 0x2DEC]
                //bit 0 de (ix+00)
                NoPuedeQuitar_5154 = LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetoIX + 0 - 0x2DEC, 0)
                //5123
                //aquí llega con hl = máscara de los objetos que podemos coger
                ObjetosHL = Int(MascaraA) << 8 | Int(ObjetosA)
                //inicia la comprobación con el objeto representado por el bit 7 de hl
                MascaraObjetoHL = 0x8000
                Integer2Nibbles(Value: MascaraObjetoHL, HighNibble: &MascaraObjetoH, LowNibble: &MascaraObjetoL)
                //apunta a los sprites de los objetos
                SpriteIX = 0x2F1B
                //apunta a las posiciones de los objetos
                ObjetoIY = 0x3008
                //5132
                while true {
                    //inicia la comprobación con el objeto representado por el bit 15 de hl
                    ObjetoCogible = ((ObjetosHL & 0x8000) != 0)
                    ObjetosHL = (ObjetosHL << 1) & 0xFFFF
                    //si el bit era 1, podemos coger el objeto
                    if ObjetoCogible {
                        //5137
                        //comprueba si el objeto se está cogiendo/dejando
                        if !LeerBitArray(TablaPosicionObjetos_3008, ObjetoIY - 0x3008, 0) {
                            //513F
                            //aquí llega si el bit 0 es 0 el objeto se está cogiendo/dejando?
                            //si el bit 6 es 0 (se usa este bit???)
                            if !LeerBitArray(TablaPosicionObjetos_3008, ObjetoIY - 0x3008, 6) {
                                //5144
                                //posición del objeto
                                ObjetoYH = TablaPosicionObjetos_3008[ObjetoIY + 3 - 0x3008]
                                ObjetoXL = TablaPosicionObjetos_3008[ObjetoIY + 2 - 0x3008]
                                ObjetoZA = TablaPosicionObjetos_3008[ObjetoIY + 4 - 0x3008]
                                ObjetoHL = Leer16(TablaPosicionObjetos_3008, ObjetoIY + 2 - 0x3008)
                                //personaje que tiene el objeto, si está cogido
                                ObjetosPersonajeHL = Leer16(TablaPosicionObjetos_3008, ObjetoIY + 2 - 0x3008)
                                Saltar_5166 = false
                                //si el objeto  está cogido
                                if LeerBitArray(TablaPosicionObjetos_3008, ObjetoIY - 0x3008, 7) {
                                    //5153
                                    //si el objeto está cogido en (iy+$02) y en (iy+$03) se guarda la dirección del personaje que lo tiene
                                    //si al personaje puede quitar objetos
                                    if !NoPuedeQuitar_5154 {
                                        Saltar_5166 = false
                                        //5159
                                        //hl = dirección de datos del personaje que ha cogido el objeto
                                        ObjetoHL = Leer16(TablaObjetosPersonajes_2DEC, ObjetosPersonajeHL + 1 - 0x2DEC)
                                        //hl = posición del personaje que ha cogido el objeto
                                        ObjetoXL = TablaCaracteristicasPersonajes_3036[ObjetoHL - 0x3036]
                                        ObjetoYH = TablaCaracteristicasPersonajes_3036[ObjetoHL + 1 - 0x3036]
                                        //a = altura del personaje que ha cogido el objeto
                                        ObjetoZA = TablaCaracteristicasPersonajes_3036[ObjetoHL + 2 - 0x3036]
                                    } else {
                                        Saltar_5166 = true
                                        //jp 51b1
                                    }
                                }
                                if !Saltar_5166 {
                                    //5166
                                    //aqui llega con hl = posición del objeto o posición del personaje que tiene el objeto
                                    // si la diferencia de alturas es <= 5
                                    if Z80Sub(ObjetoZA, AlturaPersonajeCoger_5167) <= 5 {
                                        //516C
                                        //si el personaje está al lado del objeto y mirandolo en x
                                        if ObjetoXL == PosicionXPersonajeCoger_516E {
                                            //5171
                                            //si el personaje no está al lado del objeto y mirandolo en y, salta a procesar el siguiente objeto
                                            if ObjetoYH == PosicionYPersonajeCoger_5173 {
                                                //5176
                                                //si el objeto está cogido por un personaje
                                                if LeerBitArray(TablaPosicionObjetos_3008, ObjetoIY - 0x3008, 7) {
                                                    //517C

                                                    ValorA = TablaObjetosPersonajes_2DEC[ObjetosPersonajeHL + 0 - 0x2DEC]
                                                    //le quita al personaje el objeto que se está procesando
                                                    ValorA = ValorA ^ MascaraObjetoL
                                                    TablaObjetosPersonajes_2DEC[ObjetosPersonajeHL + 0 - 0x2DEC] = ValorA
                                                    ValorA = TablaObjetosPersonajes_2DEC[ObjetosPersonajeHL + 3 - 0x2DEC]
                                                    //le quita al personaje el objeto que se está procesando
                                                    ValorA = ValorA ^ MascaraObjetoH
                                                    TablaObjetosPersonajes_2DEC[ObjetosPersonajeHL + 3 - 0x2DEC] = ValorA
                                                }
                                                //5189
                                                //si el sprite es visible, indica que hay que redibujarlo e indica que pase a inactivo después de resturar la zona que ocupaba
                                                MarcarSpriteInactivo_2ACE(SpriteIX)
                                                //guarda la dirección de los datos del personaje que tiene el objeto donde antes se guardaba la posición del objeto
                                                Escribir16(&TablaPosicionObjetos_3008, ObjetoIY + 2 - 0x3008, ObjetoIX)
                                                //indica que el objeto se ha cogido
                                                TablaPosicionObjetos_3008[ObjetoIY + 0 - 0x3008] = 0x81
                                                //inicia el contador
                                                TablaObjetosPersonajes_2DEC[ObjetoIX + 6 - 0x2DEC] = 0x10
                                                //519F
                                                ValorA = TablaObjetosPersonajes_2DEC[ObjetoIX + 0 - 0x2DEC]
                                                //indica que el personaje tiene el objeto
                                                ValorA = ValorA | MascaraObjetoL
                                                TablaObjetosPersonajes_2DEC[ObjetoIX + 0 - 0x2DEC] = ValorA
                                                ValorA = TablaObjetosPersonajes_2DEC[ObjetoIX + 3 - 0x2DEC]
                                                //indica que el personaje tiene el objeto
                                                ValorA = ValorA | MascaraObjetoH
                                                TablaObjetosPersonajes_2DEC[ObjetoIX + 3 - 0x2DEC] = ValorA
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //51b1
                    //aquí llega para pasar al siguiente objeto
                    //pasa a la siguiente entrada del objeto
                    ObjetoIY = ObjetoIY + 5
                    //pasa al siguiente sprite del objeto
                    SpriteIX = SpriteIX + 0x14
                    //prueba el siguiente bit de hl
                    MascaraObjetoHL = MascaraObjetoHL >> 1
                    Integer2Nibbles(Value: MascaraObjetoHL, HighNibble: &MascaraObjetoH, LowNibble: &MascaraObjetoL)
                    //si se ha llegado al último objeto pasa al siguiente personaje
                    if TablaPosicionObjetos_3008[ObjetoIY + 0 - 0x3008] == 0xFF {
                        break
                    }
                } //sigue procesando el siguiente objeto
            }
            //51CC
            //apunta al siguiente personaje
            ObjetoIX = ObjetoIX + 7
        } //sigue procesando los objetos para el siguiente personaje

    }

    public func CogerDejarObjetos_5096() {
        //comprueba si los personajes cogen o dejan algún objeto, y si es una llave,
        //actualiza sus permisos y si puede leer el pergamino, lo lee
        var TablaObjetosIX:Int //apunta a TablaObjetosPersonajes_2DEC
        var ObjetosGuillermoAntesA:UInt8
        var ObjetosAdso1AntesA:UInt8
        var ObjetosAdso2AntesA:UInt8
        var ObjetosGuillermoDespuesA:UInt8
        var ObjetosAdso1DespuesA:UInt8
        var ObjetosAdso2DespuesA:UInt8
        var ObjetoHL:Int //apunta a TablaPosicionObjetos_3008
        //apunta a la tabla relacionada con los objetos de los personajes
        TablaObjetosIX = 0x2DEC
        //lee los objetos que tiene guillermo
        ObjetosGuillermoAntesA = TablaObjetosPersonajes_2DEC[TablaObjetosIX + 3 - 0x2DEC]
        //lee el primer byte de objetos de adso
        ObjetosAdso1AntesA = TablaObjetosPersonajes_2DEC[TablaObjetosIX + 7 - 0x2DEC]
        //lee el segundo byte de objetos de adso
        ObjetosAdso2AntesA = TablaObjetosPersonajes_2DEC[0x2DF6 - 0x2DEC]
        //comprueba si los personajes cogen algún objeto
        CogerDejarObjetos_50F0(TablaObjetosIX)
        //comprueba si se deja algún objeto
        ComprobarDejarObjeto_526D()
        //actualiza las puertas a las que pueden entrar guillermo y adso
        ActualizarPuertasGuillermoAdso_5241()
        //50B1
        //obtiene los objetos de adso
        ObjetosAdso2DespuesA = TablaObjetosPersonajes_2DEC[0x2DF6 - 0x2DEC]
        ObjetosAdso1DespuesA = TablaObjetosPersonajes_2DEC[0x2DF3 - 0x2DEC]
        //obtiene los objetos que tiene guillermo
        ObjetosGuillermoDespuesA = TablaObjetosPersonajes_2DEC[0x2DEF - 0x2DEC]
        if (ObjetosGuillermoAntesA != ObjetosGuillermoDespuesA) || (ObjetosAdso1AntesA != ObjetosAdso1DespuesA) || (ObjetosAdso2AntesA != ObjetosAdso2DespuesA) {
            //si han cambiado los objetos, reproduce un sonido
            if ObjetosGuillermoAntesA != ObjetosGuillermoDespuesA {
                ReproducirSonidoCogerDejar_5088(ObjetosGuillermoAntesA, ObjetosGuillermoDespuesA)
            }
            if ObjetosAdso1AntesA != ObjetosAdso1DespuesA {
                ReproducirSonidoCogerDejar_5088(ObjetosAdso1AntesA, ObjetosAdso1DespuesA)
            }
            if ObjetosAdso2AntesA != ObjetosAdso2DespuesA {
                ReproducirSonidoCogerDejar_5088(ObjetosAdso2AntesA, ObjetosAdso2DespuesA)
            }
        }
        //50D0
        //comprueba si hemos cogido las gafas y el pergamino
        if (ObjetosGuillermoDespuesA & 0x30) == 0x30 {
            //si no se había generado el número romano del enigma de la habitación del espejo, lo genera
            GenerarNumeroEspejo_562E()
        }
        //50DC
        //si han cambiado los objetos de guillermo
        if (ObjetosGuillermoAntesA != ObjetosGuillermoDespuesA) {
            //dibuja los objetos indicados por a en el marcador
            ActualizarMarcador_51DA(ObjetosC: ObjetosGuillermoDespuesA, MascaraA: ObjetosGuillermoAntesA ^ ObjetosGuillermoDespuesA)
        }
        //50E1
        //apunta a los datos de posición de los objetos
        ObjetoHL = 0x3008
        while true {
            if TablaPosicionObjetos_3008[ObjetoHL - 0x3008] == 0xFF { break }
            //limpia el bit 0, que indicaba que se estaba cogiendo/dejando
            ClearBitArray(&TablaPosicionObjetos_3008, ObjetoHL - 0x3008, 0)
            ObjetoHL = ObjetoHL + 5
        }
    }

    public func ComprobarQREscalerasEspejo_33F1() -> UInt8 {
        //comprueba si pulsa Q y R en alguna de las escaleras del espejo
        //e indica si se ha pulsado QR en alguna escalera y en que escalera se pulsa
        //inicialmente e vale 0
        var ComprobarQREscalerasEspejo_33F1:UInt8
        ComprobarQREscalerasEspejo_33F1 = 0
        //lee la posición x. si no está en el lugar apropiado, sale
        if TablaCaracteristicasPersonajes_3036[0x3036 + 2 - 0x3036] != 0x22 { return ComprobarQREscalerasEspejo_33F1 }
        //33FD
        //si no está en la altura apropiada, sale
        if TablaCaracteristicasPersonajes_3036[0x3036 + 4 - 0x3036] != 0x1A { return ComprobarQREscalerasEspejo_33F1 }
        //3403
        //si no se ha pulsado la tecla Q, sale
        if !TeclaPulsadaNivel_3482(0x43) { return ComprobarQREscalerasEspejo_33F1 }
        //si no se ha pulsado la tecla R, sale
        if !TeclaPulsadaNivel_3482(0x32) { return ComprobarQREscalerasEspejo_33F1 }
        //340F
        //lee la posición y de guillermo y modifica e según sea esta posición
        switch TablaCaracteristicasPersonajes_3036[0x3036 + 3 - 0x3036] {
            case 0x6D:
                //si está en la escalera de la izquierda, sale con e = 1
                ComprobarQREscalerasEspejo_33F1 = 1
            case 0x69:
                //si está en la escalera del centro, sale con e = 2
                ComprobarQREscalerasEspejo_33F1 = 2
            case 0x65:
                //si está en la escalera de la derecha, sale con e = 3
                ComprobarQREscalerasEspejo_33F1 = 3
            default:
                break
        }
        return ComprobarQREscalerasEspejo_33F1
    }

    public func ComprobarQREspejo_3311() {
        //comprueba si se pulsó QR en la habitación del espejo y actúa en consecuencia
        var EscaleraE:UInt8 //escalera sobre la que se pulsa QR
        //comprueba si se ha abierto el espejo. si ya se ha abierto, sale
        if !HabitacionEspejoCerrada_2D8C { return }
        //331F
        //comprueba si está delante del espejo y si es así, si se pulsó la Q y la R, devolviendo en e el resultado
        EscaleraE = ComprobarQREscalerasEspejo_33F1()
        //si no se pulsó QR en alguna escalera, sale
        if EscaleraE == 0 { return }
        //3325
        //apunta a los bonus
        //pone a 1 el bit que indica que se ha pulsado QR en alguna de las escaleras del espejo
        SetBit(&Bonus2_2DBF, 2)
        //si no coincide con la escalera del número romano, muere
        if NumeroRomanoHabitacionEspejo_2DBC != EscaleraE {
            //3334
            //si llega aquí, guillermo muere
            //indica que guillermo muere
            TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
            //cambia el estado de guillermo
            EstadoGuillermo_288F = 0x14
            //cambia los datos de un bloque de la habitación del espejo para que se abra una trampa y se caiga guillermo
            EscribirValorBloqueHabitacionEspejo_3372(0x6B, PunteroHabitacionEspejo_34E0 - 2)
            //escribe en el marcador la frase
            //ESTAIS MUERTO, FRAY GUILLERMO, HABEIS CAIDO EN LA TRAMPA
            EscribirFraseMarcador_501B(NumeroFrase: 0x22)
        } else {
            //334E
            //si llega aquí, guillermo sobrevive
            //modifica los datos de altura de la habitación del espejo
            //3365
            //EscribirValorBloqueHabitacionEspejo_3372(0xFF, PunteroDatosAlturaHabitacionEspejo_34D9)
            TablaAlturasPantallas_4A00[PunteroDatosAlturaHabitacionEspejo_34D9 - 0x4A00] = 0xFF
            //modifica los datos de la habitación del espejo para que el espejo esté abierto
            EscribirValorBloqueHabitacionEspejo_336F(0x51)
        }
        //335A
        //indica un cambio de pantalla
        PosicionXPersonajeActual_2D75 = 0
        //indica que se ha abierto el espejo
        HabitacionEspejoCerrada_2D8C = false
        //reproduce un sonido
        ReproducirSonidoAbrirEspejoCanal1_0FFD()
    }

    public func ProcesarLogicaBonusCamara_5691() {
        //cálculo de bonus y cambios de cámara
        //si berengario está vivo, va a por el libro y su posición X es <0x50, o va a por el abad
        if ((TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] == 0xFD) && (TablaCaracteristicasPersonajes_3036[0x3074 - 0x3036] < 0x050) && (TablaVariablesLogica_3C85[JorgeOBernardoActivo_3CA1 - 0x3C85] == 0)) || (TablaVariablesLogica_3C85[DondeVa_Berengario_3CE9 - 0x3C85] == 0xFE) {
            //56A3
            //indica que la cámara siga a berengario
            TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 4
            return
        }
        //56A7
        //si el momento del día es sexta y y el abad ha llegado a algún sitio interesante) o (el abad va a dejar el pergamino)
        //o (el abad va a perdirle a guillermo el pergamino)
        //o (si el abad va a echar a guillermo)
        if ((MomentoDia_2D81 == 3) && (TablaVariablesLogica_3C85[DondeEstaAbad_3CC6 - 0x3C85] >= 2)) || (TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x15) || (TablaVariablesLogica_3C85[BerengarioChivato_3C94 - 0x3C85] == 1) || (TablaVariablesLogica_3C85[EstadoAbad_3CC7 - 0x3C85] == 0x0B) {
            //56BD
            //indica que la cámara siga al abad
            TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 3
            return
        }
        //56C1
        //(si el momento del día es vísperas) y (el estado de malaquías  < 0x06)) o (si malaquías va a avisar al abad
        if ((MomentoDia_2D81 == 5) && (TablaVariablesLogica_3C85[EstadoMalaquias_3CA9 - 0x3C85] < 6)) || (TablaVariablesLogica_3C85[DondeVaMalaquias_3CAA - 0x3C85] == 0xFE) {
            //56D0
            //indica que la cámara siga a malaquías
            TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 2
            return
        }
        //56D4
        //si severino va a por guillermo
        if TablaVariablesLogica_3C85[DondeVaSeverino_3D01 - 0x3C85] == 0xFF {
            //56DB
            //indica que la cámara siga a severino
            TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 5
            return
        }
        //56DF
        //indica que la cámara siga a guillermo
        TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 0
        //si tenemos el pergamino
        if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 4) {
            //56EA
            //si es el tercer día y es de noche
            if (NumeroDia_2D80 == 3) && (MomentoDia_2D81 == 0) {
                //56F4
                //nos da un bonus
                SetBit(&Bonus2_2DBF, 4)
            }
            //56F9
            //si guillermo tiene las gafas
            if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 5) {
                //5703
                //nos da un bonus
                SetBit(&Bonus2_2DBF, 0)
            }
            //5708
            //si guillermo entra a la habitación del abad
            if (NumeroPantallaActual_2DBD == 0x0D) && (TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] == 0) {
                //5712
                //obtiene un bonus
                SetBit(&Bonus2_2DBF, 5)
            }
        }
        //5718
        //si es de noche y guillermo está en el ala izquierda de la abadía
        if (MomentoDia_2D81 == 0) && (TablaCaracteristicasPersonajes_3036[0x3038 - 0x3036] < 0x60) {
            //5722
            //obtiene un bonus
            SetBit(&Bonus1_2DBE, 0)
        }
        //5727
        //si guillermo sube a la biblioteca
        if TablaCaracteristicasPersonajes_3036[0x303A - 0x3036] >= 0x16 {
            //572D
            //si guillermo tiene las gafas
            if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 5) {
                //5737
                //obtiene un bonus
                SetBit(&Bonus1_2DBE, 7)
            }
            //573D
            //si adso tiene la lámpara
            if LeerBitArray(TablaObjetosPersonajes_2DEC, 0x2DF3 - 0x2DEC, 7) {
                //5747
                //obtiene un bonus
                SetBit(&Bonus1_2DBE, 5)
            }
            //574D
            //obtiene un bonus
            SetBit(&Bonus1_2DBE, 4)
        }
        //5752
        //si está en la habitación del espejo
        if NumeroPantallaActual_2DBD == 0x72 {
            //5758
            //obtiene un bonus
            SetBit(&Bonus2_2DBF, 1)
        }
        //575D
    }

    public func LeerEstadoJorgeGuantes_416F() -> Bool {
        //si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f (está hablando sobre el libro), sale con cf = 1, en otro caso con cf = 0
        var LeerEstadoJorgeGuantes_416F:Bool
        var EstadoJorgeA:UInt8
        LeerEstadoJorgeGuantes_416F = false
        //si no tenemos los guantes, sale
        if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 6) { return LeerEstadoJorgeGuantes_416F }
        //4175
        //si el estado de jorge es 0x0d, 0x0e o 0x0f, sale con cf = 1, en otro caso con cf = 0
        EstadoJorgeA = TablaVariablesLogica_3C85[EstadoSeverino_3D00 - 0x3C85]
        if EstadoJorgeA == 0x0D || EstadoJorgeA == 0x0E || EstadoJorgeA == 0x0F { LeerEstadoJorgeGuantes_416F = true }
        return LeerEstadoJorgeGuantes_416F
    }

    public func AjustarCamaraEstadoJorge_4150( _ GuantesGuillermo:Bool) -> Bool {
        //comprueba si se pulsaron los cursores (cf = 1)
        var AjustarCamaraEstadoJorge_4150:Bool
        AjustarCamaraEstadoJorge_4150 = false
        if GuantesGuillermo {
            //4152
            //aqui llega si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f
            //indica que no hay que esperar para mostrar a jorge
            TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = 0x32
            //indica que la cámara siga a jorge si no se mueve guillermo
            TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85] = 5
        } else {
            //415E
            //si no tenemos los guantes o el estado de jorge no es 0x0d, 0x0e o 0x0f, comprueba si se pulsaron los cursores de movimiento de guillermo
            if TeclaPulsadaNivel_3482(0) || TeclaPulsadaNivel_3482(8) || TeclaPulsadaNivel_3482(1) {
                AjustarCamaraEstadoJorge_4150 = true
            }
        }
        return AjustarCamaraEstadoJorge_4150
    }

    public func AjustarCamara_Bonus_4186() {
        //comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
        var GuillermoGuantes:Bool
        var Cursores:Bool
        var PersonajeCamaraA:UInt8
        //procesa la lógica de la cámara y calcula los bonus
        ProcesarLogicaBonusCamara_5691()
        //si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f, sale con cf = 1, en otro caso con cf = 0
        GuillermoGuantes = LeerEstadoJorgeGuantes_416F()
        //comprueba si se pulsaron los cursores (cf = 1)
        Cursores = AjustarCamaraEstadoJorge_4150(GuillermoGuantes)
        PersonajeCamaraA = 0
        //si no se ha pulsado el cursor arriba, izquierda o derecha
        if !Cursores {
            //4191
            TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] + 1
            //si es < 0x32, sale
            if TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] < 0x32 { return }
            //419D
            //deja el contador como estaba
            TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] - 1
            //si se está mostrando una frase, restaura el valor del contador de espera del bucle principal
            if ReproduciendoFrase_2DA1 {
                //41BF
                //restaura el valor del contador de espera del bucle principal
                VelocidadPasosGuillermo_2618 = 36
            } else {
                //41A8
                //en otro caso, pone a 0 el contador del bucle principal (para que no se espere nada)
                VelocidadPasosGuillermo_2618 = 0
            }
            //41AB
            //inicia un sonido en el canal 1
            ReproducirSonidoMelodia_1007()
            //obtiene el personaje al que sigue la cámara
            PersonajeCamaraA = TablaVariablesLogica_3C85[PersonajeSeguidoPorCamaraReposo_3C92 - 0x3C85]
            //lee el personaje al que se sigue si guillermo se está quieto
            //si son iguales, sale
            if PersonajeCamaraA == TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] { return }
        }
        //41B7
        //si se han pulsado los cursores o la cámara sigue a guillermo
        //hace que la cámara siga al personaje indicado en a
        TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] = PersonajeCamaraA
        //actualiza el contador con el valor introducido
        TablaVariablesLogica_3C85[ContadorReposo_3C93 - 0x3C85] = PersonajeCamaraA
        //si el personaje a seguir no es el nuestro, sale
        if PersonajeCamaraA != 0 { return }
        //41BF
        //restaura el valor del contador de espera del bucle principal
        VelocidadPasosGuillermo_2618 = 36
    }

    public func AjustarCamara_Bonus_41D6() {
        //comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
        var PersonajeDE:Int
        AjustarCamara_Bonus_4186()
        //de = dirección de los datos del personaje que sigue la camara
        PersonajeDE = 0x3036 + 0x0F * Int(TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85])
        PunteroDatosPersonajeActual_2D88 = PersonajeDE
    }

    public func ComprobarSaludGuillermo_42AC() {
        //actualiza los bonus si tenemos los guantes, las llaves y algo mas y si se está leyendo el libro sin los guantes, mata a guillermo
        var ObjetosB:UInt8
        //0x2dbe
        //        bit 7: si tiene las gafas estando en la biblioteca
        //        bit 6: a 1 si ha cogido los guantes
        //        bit 5: que adso tenga la lámpara en la biblioteca
        //        bit 4: que hayan subido a la biblioteca
        //        bit 3: a 1 si ha cogido la llave 1
        //        bit 2: a 1 si ha cogido la llave 2
        //        bit 1: a 1 si ha cogido la llave 3
        //        bit 0: llegar al ala izquierda de la abadía por la noche

        //    0x2dbf
        //        bit 7: no usado
        //        bit 6: no usado
        //        bit 5: entrar a la habitación del abad con el pergamino
        //        bit 4: tener el pergamino el tercer día por la noche
        //        bit 3: entrar en la habitación del espejo cuando jorge está esperándonos
        //        bit 2: a 1 si se ha abierto el espejo
        //        bit 1: entrar en la habitación de detrás del espejo
        //        bit 0: si guillermo tiene el pergamino y las gafas
        //lee los objetos de guillermo
        //se queda solo con los guantes y las 2 primeras llaves
        ObjetosB = TablaObjetosPersonajes_2DEC[ObjetosGuillermo_2DEF - 0x2DEC] & 0x4C
        //lee los objetos de adso
        //se queda con la llave 3
        ObjetosB = ObjetosB | (TablaObjetosPersonajes_2DEC[ObjetosAdso_2DF6 - 0x2DEC] & 0x02)
        //actualiza los bonus con los objetos que tenemos
        Bonus1_2DBE = Bonus1_2DBE | Int(ObjetosB)
        //42C1
        //si no tenemos el libro, sale
        if !LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 7) { return }
        //42C5
        //si tenemos los guantes, sale
        if LeerBitArray(TablaObjetosPersonajes_2DEC, ObjetosGuillermo_2DEF - 0x2DEC, 6) { return }
        //42C8
        //incrementa el contador del tiempo que está leyendo el libro sin guantes
        TablaVariablesLogica_3C85[ContadorLeyendoLibroSinGuantes_3C85 - 0x3C85] = Z80Inc(TablaVariablesLogica_3C85[ContadorLeyendoLibroSinGuantes_3C85 - 0x3C85])
        if TablaVariablesLogica_3C85[ContadorLeyendoLibroSinGuantes_3C85 - 0x3C85] != 0 { return }
        //42D0
        //estado de guillermo = posición en y del sprite de guillermo / 2
        EstadoGuillermo_288F = TablaSprites_2E17[0x2E19 - 0x2E17] >> 1
        //modifica una instrucción que hace que se sume a la posición y del sprite de guillermo -2
        AjustePosicionYSpriteGuillermo_28B1 = 0xFE
        //mata a guillermo
        TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] = 1
        //escribe en el marcador una frase
        //ESTAIS MUERTO, FRAY GUILLERMO, HABEIS CAIDO EN LA TRAMPA
        EscribirFraseMarcador_501B(NumeroFrase: 0x22)
    }

    public func CalcularPorcentajeJuegoResuelto_4269() -> [UInt8] {
        //calcula el porcentaje de misión completada y lo guarda en 0x431e
        var PuntuacionA:UInt8
        var BonusHL:Int
        var Contador:UInt8
        var Unidades:UInt8
        var Decenas:UInt8
        var Resultado:[UInt8] = [0x20, 0x30]
        //0x2dbe
        //        bit 7: si tiene las gafas estando en la biblioteca
        //        bit 6: a 1 si ha cogido los guantes
        //        bit 5: que adso tenga la lámpara en la biblioteca
        //        bit 4: que hayan subido a la biblioteca
        //        bit 3: a 1 si ha cogido la llave 1
        //        bit 2: a 1 si ha cogido la llave 2
        //        bit 1: a 1 si ha cogido la llave 3
        //        bit 0: llegar al ala izquierda de la abadía por la noche

        //    0x2dbf
        //        bit 7: no usado
        //        bit 6: no usado
        //        bit 5: entrar a la habitación del abad con el pergamino
        //        bit 4: tener el pergamino el tercer día por la noche
        //        bit 3: entrar en la habitación del espejo cuando jorge está esperándonos
        //        bit 2: a 1 si se ha abierto el espejo
        //        bit 1: entrar en la habitación de detrás del espejo
        //        bit 0: si guillermo tiene el pergamino y las gafas
        var CalcularPorcentajeJuegoResuelto_4269:[UInt8]
        CalcularPorcentajeJuegoResuelto_4269 = Resultado
        //si 0x3ca7 es 0, muestra el final
        if TablaVariablesLogica_3C85[InvestigacionNoTerminada_3CA7 - 0x3C85] == 0 {
            //señala que el juego ha sido completado y se pasa a la secuencia del pergamino final
            CalcularPorcentajeJuegoResuelto_4269 = [0xFF, 0xFF]
            DibujarPergaminoFinal_3868()
            return CalcularPorcentajeJuegoResuelto_4269
        }
        //4270
        PuntuacionA = 7 * (NumeroDia_2D80 - 1) + MomentoDia_2D81
        //lee los bonus conseguidos
        BonusHL = Int(Bonus2_2DBF) << 8 | Bonus1_2DBE
        //comprueba 16 bits
        for Contador in 1...16 {
            //por cada bonus, suma 4
            if (BonusHL & 0x8000) != 0 { PuntuacionA = PuntuacionA + 4 }
            BonusHL = BonusHL << 1
        }
        //428B
        //si no hemos obtenido una puntuación >= 5, pone la puntuación a 0
        if PuntuacionA < 5 { PuntuacionA = 0 }
        //4290
        //aquí llega con a = puntuación obtenida
        //convierte el valor en unidades y decenas
        Unidades = PuntuacionA
        Decenas = 0
        while Unidades >= 10 {
            Unidades = Unidades - 10
            Decenas = Decenas + 1
        }
        //pasa el valor a ascii
        Resultado[1] = Unidades + 0x30
        Resultado[0] = Decenas + 0x30
        return Resultado
    }

    public func MostrarResultadoJuego_42E7() -> Bool {
        //si guillermo está muerto, calcula el % de misión completado y lo muestra por pantalla
        var MostrarResultadoJuego_42E7:Bool
        var Puntuacion_431E:[UInt8]
        MostrarResultadoJuego_42E7 = false
        //lee si guillermo está vivo y si es así, sale
        if TablaVariablesLogica_3C85[GuillermoMuerto_3C97 - 0x3C85] == 0 { return MostrarResultadoJuego_42E7}
        //42EC
        //indica que la camara sigua a guillermo y que lo haga ya
        TablaVariablesLogica_3C85[PersonajeSeguidoPorCamara_3C8F - 0x3C85] = 0
        //si está mostrando una frase/reproduciendo una voz, sale
        if ReproduciendoFrase_2DA1 { return MostrarResultadoJuego_42E7}
        //42F6
        //oculta el área de juego
        PintarAreaJuego_1A7D(ColorFondo: 0xFF)
        //calcula el porcentaje de misión completada y lo guarda en 0x431e
        Puntuacion_431E = CalcularPorcentajeJuegoResuelto_4269()
        if Puntuacion_431E[0] == 0xFF && Puntuacion_431E[1] == 0xFF {
            //inidica juego completado y arranque del pergamino final
            MostrarResultadoJuego_42E7 = true
            return MostrarResultadoJuego_42E7
        }
        //42FC
        //(h = y en pixels, l = x en bytes) (x = 64, y = 32)
        //modifica la variable usada como la dirección para poner caracteres en pantalla
        PunteroCaracteresPantalla_2D97 = 0x2010
        //imprime la frase que sigue a la llamada en la posición de pantalla actual
        //HAS RESUELTO EL
        ImprimirFrase_4FEE([0x48, 0x41, 0x53, 0x20, 0x52, 0x45, 0x53, 0x55, 0x45, 0x4C, 0x54, 0x4F, 0x20, 0x45, 0x4C])
        //4315
        //(h = y en pixels, l = x en bytes) (x = 56, y = 48)
        //modifica la variable usada como la dirección para poner caracteres en pantalla
        PunteroCaracteresPantalla_2D97 = 0x300E
        //imprime la frase que sigue a la llamada en la posición de pantalla actual
        //  00 POR CIENTO
        ImprimirFrase_4FEE([0x20, 0x20, Puntuacion_431E[0], Puntuacion_431E[1], 0x20, 0x50, 0x4F, 0x52, 0x20, 0x43, 0x49, 0x45, 0x4E, 0x54, 0x4F])
        //432E
        //(h = y en pixels, l = x en bytes) (x = 48, y = 64)
        //modifica la variable usada como la dirección para poner caracteres en pantalla
        PunteroCaracteresPantalla_2D97 = 0x400C
        //imprime la frase que sigue a la llamada en la posición de pantalla actual
        //DE LA INVESTIGACION
        ImprimirFrase_4FEE([0x44, 0x45, 0x20, 0x4C, 0x41, 0x20, 0x49, 0x4E, 0x56, 0x45, 0x53, 0x54, 0x49, 0x47, 0x41, 0x43, 0x49, 0x4F, 0x4E])
        //434B
        //(h = y en pixels, l = x en bytes) (x = 24, y = 128)
        //modifica la variable usada como la dirección para poner caracteres en pantalla
        PunteroCaracteresPantalla_2D97 = 0x8006
        //imprime la frase que sigue a la llamada en la posición de pantalla actual
        //PULSA ESPACIO PARA EMPEZAR
        ImprimirFrase_4FEE([0x50, 0x55, 0x4C, 0x53, 0x41, 0x20, 0x45, 0x53, 0x50, 0x41, 0x43, 0x49, 0x4F, 0x20, 0x50, 0x41, 0x52, 0x41, 0x20, 0x45, 0x4D, 0x50, 0x45, 0x5A, 0x41, 0x52])
        SiguienteTick(Tiempoms: 100, NombreFuncion: "MostrarResultadoJuego_42E7_b")
        MostrarResultadoJuego_42E7_b()
        return MostrarResultadoJuego_42E7
    }

    public func MostrarResultadoJuego_42E7_b() {
        if TeclaPulsadaNivel_3482(0x2F) {
            InicializarPartida_2509()
        }
    }

    public func ComprobarEfectoEspejo_5374() {
        //si el espejo no está abierto, realiza el efecto del espejo
        var PersonajeIY:Int
        var SpriteIX:Int
        var BufferFlipHL:Int
        var AnimacionDE:Int
        var VariablesEspejoBC:Int
        //lee si está abierta la habitación secreta del espejo
        if !HabitacionEspejoCerrada_2D8C { return } //si está abierta, sale
        //5379
        //apunta a las características de guillermo
        PersonajeIY = 0x3036
        //apunta al sprite del abad
        SpriteIX = 0x2E53
        //apunta a un buffer para flipear los gráficos
        BufferFlipHL = 0x9ADC
        //apunta a la tabla de animaciones de guillermo
        AnimacionDE = 0x319F
        //apunta a un buffer con variables del espejo
        VariablesEspejoBC = 0x2D8D
        //hace el efecto del espejo en la habitación del espejo para guillermo
        HacerEfectoEspejo_539E(PersonajeIY, SpriteIX, BufferFlipHL, AnimacionDE, VariablesEspejoBC)
        //apunta a un buffer con variables del espejo
        VariablesEspejoBC = 0x2D92
        //apunta a un buffer para flipear los gráficos
        BufferFlipHL = 0x9BD6
        //apunta a la tabla de animaciones de adso
        AnimacionDE = 0x31BF
        //apunta a las características de adso
        PersonajeIY = 0x3045
        //apunta al sprite de berengario
        SpriteIX = 0x2E67
        //hace el efecto del espejo en la habitación del espejo para adso
        HacerEfectoEspejo_539E(PersonajeIY, SpriteIX, BufferFlipHL, AnimacionDE, VariablesEspejoBC)
    }

    public func HacerEfectoEspejo_539E( _ PersonajeIY:Int, _ SpriteIX:Int, _ BufferFlipHL:Int, _ AnimacionDE:Int, _ VariablesEspejoBC:Int) {
        //hace el efecto del espejo en la habitación del espejo para el personaje indicado
        //iy apunta a los datos de posición del personaje
        //ix apunta a un sprite
        //hl apunta a un buffer para flipear los gráficos
        //de apunta a la tabla de animaciones del personaje
        //bc apunta a un buffer con las variables del espejo
        var VisibilidadL:UInt8
        //hace el efecto del espejo en la habitación del espejo
        VisibilidadL = HacerEfectoEspejo_53AD(PersonajeIY, SpriteIX, BufferFlipHL, AnimacionDE, VariablesEspejoBC)
        //graba el estado de visibilidad del sprite
        TablaVariablesEspejo_2D8D[VariablesEspejoBC - 0x2D8D] = VisibilidadL
        //si el sprite es visible, sale
        if VisibilidadL != 0xFE { return }
        //53A8
        //indica que el sprite es de un monje
        ClearBitArray(&TablaSprites_2E17, SpriteIX + 0x0B - 0x2E17, 7)
    }

    public func HacerEfectoEspejo_53AD( _ PersonajeIY:Int, _ SpriteIX:Int, _ BufferFlipHL:Int, _ AnimacionDE:Int, _ VariablesEspejoBC:Int) -> UInt8 {
        //si el personaje está frente al espejo, rellena el sprite que se le pasa en ix para realizar el efecto del espejo
        //iy apunta a los datos de posición del personaje
        //ix apunta a un sprite
        //hl apunta a un buffer para flipear los gráficos
        //de apunta a la tabla de animaciones del personaje
        //bc apunta a un buffer con las variables del espejo
        var HacerEfectoEspejo_53AD:UInt8
        var EstadoAnterior_5453:UInt8
        var AlturaA:UInt8
        var AlturaPlantaB:UInt8
        var PosicionX:UInt8
        var PosicionY:UInt8
        var OrientacionC:UInt8
        var AnimacionA:UInt8
        var EstadoSpriteA:UInt8
        var VariableEspejoAnteriorHL:Int
        var VariableEspejoAnteriorDE:Int
        //guarda la dirección del buffer para flipear los sprites del espejo
        PunteroEspejo_5483 = BufferFlipHL
        //indica que inicialmente el sprite no es visible
        HacerEfectoEspejo_53AD = 0xFE
        //si no está en la habitación del espejo, sale
        if MinimaPosicionXVisible_27A9 != 0x1C { return HacerEfectoEspejo_53AD }
        //53B8
        //si no está en la habitación del espejo, sale
        if MinimaPosicionYVisible_279D != 0x5C { return HacerEfectoEspejo_53AD }
        //53BE
        //obtiene el estado anterior del sprite
        EstadoAnterior_5453 = TablaVariablesEspejo_2D8D[VariablesEspejoBC - 0x2D8D]
        //53C2
        //5444=bc+1
        //544C=bc+1
        VariableEspejoAnteriorHL = Leer16(TablaVariablesEspejo_2D8D, VariablesEspejoBC + 1 - 0x2D8D)
        //53CB
        //5448=bc+3
        //5450=bc+3
        VariableEspejoAnteriorDE = Leer16(TablaVariablesEspejo_2D8D, VariablesEspejoBC + 3 - 0x2D8D)
        //a = altura del personaje
        AlturaA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x04 - 0x3036]
        //dependiendo de la altura, devuelve la altura base de la planta en b
        AlturaPlantaB = LeerAlturaBasePlanta_2473(AlturaA)
        //si la altura sobre la base de la planta es >= 0x08, sale
        if (AlturaA - AlturaPlantaB) >= 8 { return HacerEfectoEspejo_53AD }
        //53DF
        //si no está en la segunda planta, sale
        if AlturaPlantaB != 0x16 { return HacerEfectoEspejo_53AD }
        //53E3
        //a = posición x del personaje
        PosicionX = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x02 - 0x3036]
        //si no está en la zona visible del espejo en x, sale
        if PosicionX < 0x20 || (PosicionX - 0x20) >= 0x0A { return HacerEfectoEspejo_53AD }
        //53ED
        PosicionY = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x03 - 0x3036]
        //si no está en la zona visible del espejo en y, sale
        if PosicionY < 0x62 || (PosicionY - 0x62) >= 0x0A { return HacerEfectoEspejo_53AD }
        //53F6
        //c = orientación del personaje
        OrientacionC = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x01 - 0x3036]
        //a = animación del personaje
        AnimacionA = TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x00 - 0x3036]
        //invierte la animación
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x00 - 0x3036] = AnimacionA ^ 0x02
        //5402
        //refleja la posición x con respecto al espejo
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x02 - 0x3036] = UInt8(0x21 - Int(PosicionX) + 0x21)
        //540D
        //refleja la orientación del personaje
        if LeerBitByte(OrientacionC, 0) == false {
            TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x01 - 0x3036] = OrientacionC ^ 0x02
        }
        //5417
        //si el personaje ocupa 2 posiciones
        if LeerBitArray(TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x05 - 0x3036, 7) != false {
            //decrementa la posición en x
            DecByteArray(&TablaCaracteristicasPersonajes_3036, PersonajeIY + 0x02 - 0x3036)
        }
        //5420
        //modifica la dirección de la rutina encargada de flipear los gráficos
        PunteroRutinaFlipPersonaje_2A59 = 0x5473
        //modifica la tabla de animaciones del personaje
        PunteroTablaAnimacionesPersonaje_2A84 = AnimacionDE
        //indica que no es un monje
        SetBitArray(&TablaSprites_2E17, SpriteIX + 0x0B - 0x2E17, 7)
        //542E
        //lee y preserva el estado del sprite
        EstadoSpriteA = TablaSprites_2E17[SpriteIX + 0x00 - 0x2E17]
        //avanza la animación del sprite y lo redibuja
        AvanzarAnimacionSprite_2A27(SpriteIX, PersonajeIY)
        //5436
        //lee la posición del sprite y actualiza las variables del espejo
        TablaVariablesEspejo_2D8D[VariablesEspejoBC + 1 - 0x2D8D] = TablaSprites_2E17[SpriteIX + 0x01 - 0x2E17]
        TablaVariablesEspejo_2D8D[VariablesEspejoBC + 2 - 0x2D8D] = TablaSprites_2E17[SpriteIX + 0x02 - 0x2E17]
        //lee el ancho y el alto del sprite  y actualiza las variables del espejo
        TablaVariablesEspejo_2D8D[VariablesEspejoBC + 3 - 0x2D8D] = TablaSprites_2E17[SpriteIX + 0x05 - 0x2E17]
        TablaVariablesEspejo_2D8D[VariablesEspejoBC + 4 - 0x2D8D] = TablaSprites_2E17[SpriteIX + 0x06 - 0x2E17]
        //5452
        //si el sprite no es visible, no cambia los registros
        if TablaVariablesEspejo_2D8D[VariablesEspejoBC + 0 - 0x2D8D] == 0xFE {
            //escribe la posición anterior y el anterior ancho y alto del sprite
            TablaSprites_2E17[SpriteIX + 0x03 - 0x2E17] = TablaSprites_2E17[SpriteIX + 0x01 - 0x2E17]
            TablaSprites_2E17[SpriteIX + 0x04 - 0x2E17] = TablaSprites_2E17[SpriteIX + 0x02 - 0x2E17]
            TablaSprites_2E17[SpriteIX + 0x09 - 0x2E17] = TablaSprites_2E17[SpriteIX + 0x05 - 0x2E17]
            TablaSprites_2E17[SpriteIX + 0x0A - 0x2E17] = TablaSprites_2E17[SpriteIX + 0x06 - 0x2E17]
        } else {
            Escribir16(&TablaSprites_2E17, SpriteIX + 0x03 - 0x2E17, VariableEspejoAnteriorHL)
            Escribir16(&TablaSprites_2E17, SpriteIX + 0x09 - 0x2E17, VariableEspejoAnteriorDE)
        }
        //5465
        //restaura la orientación del personaje y la posición en x
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x02 - 0x3036] = PosicionX
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x01 - 0x3036] = OrientacionC
        //restaura el contador de animación del personaje
        TablaCaracteristicasPersonajes_3036[PersonajeIY + 0x00 - 0x3036] = AnimacionA
        //indica que el sprite es visible
        HacerEfectoEspejo_53AD = 0
        return HacerEfectoEspejo_53AD
    }

    public func DibujarPergaminoFinal_3868() {
        viewController?.definirModo(modo: 1) //fija el modo 1 (256x192 4 colores, sin marcos)
        teclado!.Inicializar() //borra cualquier pulsación existente
        cga!.SeleccionarPaleta(0) //pone una paleta de colores negra
        TempoMusica_1086 = 0x08 //###pendiente de ajustar bien
        TempoMusica_1086 = 0x08
        ReproducirSonidoPergaminoFinal()
        DibujarPergaminoIntroduccion_659D(0x8330) //dibuja el Pergamino y cuenta la introducción. De aquí vuelve al pulsar espacio
    }



 
}

