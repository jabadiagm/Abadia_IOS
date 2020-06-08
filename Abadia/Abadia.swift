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
    
   
    func InicializarPartida() {
        
    }
    func BuclePrincipal() {
        
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
    
    func ActualizarDatosPersonaje_291D( _ Dato:Int) {
        
    }
    
    func EjecutarComportamientoPersonajes_2664() {
        
    }
    
    func ModificarCaracteristicasSpriteLuz_26A3() {
        
    }
    
    func FlipearGraficosPuertas_0E66() {
        
    }
    
    func ComprobarEfectoEspejo_5374() {
        
    }
    
    func DescartarMovimientosPensados_08BE( _ dato:Int) {
        
    }
    
    func ComprobarCambioPantalla_2355() {
        
    }
    
    func DibujarSprites_2674() {
        
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
        //Valor1 = ModFunciones.shr(X, 2) 'l / 4 (cada 4 pixels = 1 byte)
        Valor1 = X >> 2 //l / 4 (cada 4 pixels = 1 byte)
        Valor2 = Y & 0xF8 //obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
        Valor2 = Valor2 * 10 //dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
        Valor3 = Y & 7 //3 bits menos significativos en y (para calcular al banco de VRAM al que va)
        //Valor3 = shl(Valor3, 3)
        Valor3 = Valor3 << 3
        //Valor3 = shl(Valor3, 8) Or Valor2 'completa el cálculo del banco
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
        //AvanceY = ModFunciones.shr(Valor, 4) And &HF& 'avanza la posición y según los 4 bits más significativos del byte leido de dibujo del caracter
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
            //nX = ModFunciones.shr(Byte1, 5) And &H7 'longitud del elemento en x
            nX = (Byte1 >> 5) & 0x7 //longitud del elemento en x
            //1A2F
            Byte2 = DatosHabitaciones_4000[PunteroPantallaGlobal + 2]
            //1A32
            Y = Byte2 & 0x1F //pos en y del elemento (sistema de coordenadas del buffer de tiles)
            //1A36
            //nY = ModFunciones.shr(Byte2, 5) And &H7 'longitud del elemento en y
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
            //TablaCaracteristicasPersonajes_3036(&H3063 + 2 - &H3036) = &H89
            //guillermo en el espejo
            //TablaCaracteristicasPersonajes_3036(&H3036 + 1 - &H3036) = &H02
            //TablaCaracteristicasPersonajes_3036(&H3036 + 2 - &H3036) = &H26
            //TablaCaracteristicasPersonajes_3036(&H3036 + 3 - &H3036) = &H69
            //TablaCaracteristicasPersonajes_3036(&H3036 + 4 - &H3036) = &H18
            //adso
            //TablaCaracteristicasPersonajes_3036(&H3045 + 2 - &H3036) = &H8D
            //TablaCaracteristicasPersonajes_3036(&H3045 + 3 - &H3036) = &H85
            //TablaCaracteristicasPersonajes_3036(&H3045 + 4 - &H3036) = &H2
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
        //ValorLong = shl(ValorLong, 11) 'ajusta los 3 bits
        ValorLong = ValorLong << 11 //ajusta los 3 bits
        PunteroPantalla = PunteroPantalla | ValorLong //completa el cálculo del banco
        PunteroPantalla = PunteroPantalla | 0xC000
        PunteroPantalla = PunteroPantalla + Int(X) //suma el desplazamiento en x
        PunteroPantalla = PunteroPantalla + 8 //ajusta para que salga 32 pixels más a la derecha
        return PunteroPantalla
    }

    
}

