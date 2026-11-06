/// Rutas de todos los assets del juego.
///
/// Fuente unica de verdad: ningun componente debe escribir rutas a mano.
class AssetPaths {
  const AssetPaths._();

  /// Prefijo de las imagenes.
  static const String images = 'assets/images';

  /// Prefijo de las laminas para colorear.
  static const String canvas = '$images/canvas';

  /// Prefijo de los iconos de interfaz.
  static const String ui = '$images/ui';

  /// Prefijo de las pegatinas.
  static const String stickers = '$images/stickers';

  /// Prefijo de las calcas del vehiculo.
  static const String decals = '$images/decals';

  /// Prefijo de los personajes del vehiculo.
  static const String characters = '$images/characters';

  /// Prefijo de los coches.
  static const String cars = '$images/cars';

  /// Prefijo de las pistas.
  static const String tracks = '$images/tracks';

  /// Prefijo de los coleccionables.
  static const String items = '$images/items';

  /// Prefijo del audio (coincide con `FlameAudio.audioCache.prefix`).
  static const String audio = 'assets/audio';

  // -------------------------------------------------------------------------
  // Iconos de interfaz
  // -------------------------------------------------------------------------

  /// Icono de pincel.
  static const String iconBrush = '$ui/icono_pincel.png';

  /// Icono de coche.
  static const String iconCar = '$ui/icono_coche.png';

  /// Icono de play.
  static const String iconPlay = '$ui/icono_play.png';

  /// Icono de pausa.
  static const String iconPause = '$ui/icono_pausa.png';

  /// Icono de volver atras.
  static const String iconBack = '$ui/icono_atras.png';

  /// Icono de libro de pegatinas.
  static const String iconBook = '$ui/icono_libro.png';

  /// Icono de bote de pintura.
  static const String iconBucket = '$ui/icono_bote.png';

  /// Icono de borrador.
  static const String iconEraser = '$ui/icono_borrador.png';

  /// Icono de estrella.
  static const String iconStar = '$ui/icono_estrella.png';

  /// Logotipo de la app (el mismo que usan Android, iOS y la web).
  static const String appLogo = '$ui/app_logo.png';

  // -------------------------------------------------------------------------
  // Coches
  // -------------------------------------------------------------------------

  /// Coche rojo.
  static const String carRojo = '$cars/car_rojo.png';

  /// Coche azul.
  static const String carAzul = '$cars/car_azul.png';

  /// Coche amarillo.
  static const String carAmarillo = '$cars/car_amarillo.png';

  /// Coche verde.
  static const String carVerde = '$cars/car_verde.png';

  /// Coche violeta.
  static const String carVioleta = '$cars/car_violeta.png';

  /// Moto.
  static const String moto = '$cars/moto.png';

  /// Camion de bomberos.
  static const String camion = '$cars/camion.png';

  /// Furgoneta de reparto.
  static const String furgoneta = '$cars/furgoneta.png';

  /// Tractor.
  static const String tractor = '$cars/tractor.png';

  /// Bus escolar.
  static const String bus = '$cars/bus.png';

  /// Coche visto de lado (modo subidas).
  static const String sideCar = '$cars/coche_lateral.png';

  /// Rueda de perfil (modo subidas).
  static const String sideWheel = '$cars/rueda.png';

  // -------------------------------------------------------------------------
  // Pistas y mobiliario
  // -------------------------------------------------------------------------

  /// Pista de pradera.
  static const String trackPradera = '$tracks/track_pradera.png';

  /// Pista de playa.
  static const String trackPlaya = '$tracks/track_playa.png';

  /// Pista nocturna.
  static const String trackNoche = '$tracks/track_noche.png';

  /// Pista nevada.
  static const String trackNieve = '$tracks/track_nieve.png';

  /// Pista de bosque.
  static const String trackBosque = '$tracks/track_bosque.png';

  /// Pista urbana.
  static const String trackCiudad = '$tracks/track_ciudad.png';

  /// Pista del desierto.
  static const String trackDesierto = '$tracks/track_desierto.png';

  /// Pista de la selva.
  static const String trackSelva = '$tracks/track_selva.png';

  /// Pista del puerto.
  static const String trackPuerto = '$tracks/track_puerto.png';

  /// Pista del volcan.
  static const String trackVolcan = '$tracks/track_volcan.png';

  /// Pista del espacio.
  static const String trackEspacio = '$tracks/track_espacio.png';

  /// Pista del estadio.
  static const String trackEstadio = '$tracks/track_estadio.png';

  /// Asfalto de la carretera.
  static const String asphalt = '$tracks/asfalto.png';

  /// Asfalto de tierra (pistas de desierto y selva).
  static const String asphaltDirt = '$tracks/asfalto_tierra.png';

  /// Asfalto de piedra (pistas de montaña y bosque).
  static const String asphaltStone = '$tracks/asfalto_piedra.png';

  /// Asfalto de hielo (pistas de nieve y espacio).
  static const String asphaltIce = '$tracks/asfalto_hielo.png';

  /// Bordillo de la carretera.
  static const String curb = '$tracks/bordillo.png';

  /// Bordillo amarillo.
  static const String curbYellow = '$tracks/bordillo_amarillo.png';

  /// Bordillo de piedra.
  static const String curbStone = '$tracks/bordillo_piedra.png';

  /// Bordillo de hielo.
  static const String curbIce = '$tracks/bordillo_hielo.png';

  /// Cono de trafico.
  static const String cone = '$tracks/cono.png';

  /// Charco.
  static const String puddle = '$tracks/charco.png';

  /// Roca.
  static const String rock = '$tracks/roca.png';

  /// Bandera de meta (dibujada por el juego: no es un asset).
  static const String finishBanner = '$tracks/meta.png';

  /// Estrella coleccionable.
  static const String star = '$items/estrella.png';

  // -------------------------------------------------------------------------
  // Laminas para colorear
  // -------------------------------------------------------------------------

  /// Lamina del coche.
  static const String pageCoche = '$canvas/pagina_coche.png';

  /// Lamina del paisaje.
  static const String pagePaisaje = '$canvas/pagina_paisaje.png';

  /// Lamina de los animales.
  static const String pageAnimales = '$canvas/pagina_animales.png';

  /// Lamina de la casa.
  static const String pageCasa = '$canvas/pagina_casa.png';

  /// Lamina del dinosaurio.
  static const String pageDinosaurio = '$canvas/pagina_dinosaurio.png';

  /// Lamina de la ciudad.
  static const String pageCiudad = '$canvas/pagina_ciudad.png';

  /// Lamina de las frutas.
  static const String pageFrutas = '$canvas/pagina_frutas.png';

  /// Lamina de las verduras.
  static const String pageVerduras = '$canvas/pagina_verduras.png';

  /// Lamina del garaje de vehiculos.
  static const String pageGaraje = '$canvas/pagina_garaje.png';

  // -------------------------------------------------------------------------
  // Pegatinas
  // -------------------------------------------------------------------------

  /// Pegatina de la estrella.
  static const String stickerEstrella = '$stickers/pega_estrella.png';

  /// Pegatina del corazon.
  static const String stickerCorazon = '$stickers/pega_corazon.png';

  /// Pegatina del arcoiris.
  static const String stickerArcoiris = '$stickers/pega_arcoiris.png';

  /// Pegatina de la corona.
  static const String stickerCorona = '$stickers/pega_corona.png';

  /// Pegatina de la flecha.
  static const String stickerFlecha = '$stickers/pega_flecha.png';

  /// Pegatina del globo.
  static const String stickerGlobo = '$stickers/pega_globo.png';

  /// Pegatina del trofeo.
  static const String stickerTrofeo = '$stickers/pega_trofeo.png';

  /// Pegatina de la medalla.
  static const String stickerMedalla = '$stickers/pega_medalla.png';

  /// Pegatina del cohete.
  static const String stickerCohete = '$stickers/pega_cohete.png';

  /// Pegatina de la cometa.
  static const String stickerCometa = '$stickers/pega_cometa.png';

  /// Hoja de referencia de la paleta.
  static const String palette = '$images/palette/paleta.png';

  /// Calca de rayas.
  static const String decalStripes = '$decals/calca_rayas.png';

  /// Calca de estrella.
  static const String decalStar = '$decals/calca_estrella.png';

  /// Calca de llama.
  static const String decalFlame = '$decals/calca_llama.png';

  /// Calca de corazon.
  static const String decalHeart = '$decals/calca_corazon.png';

  /// Calca de numero de racing.
  static const String decalNumber = '$decals/calca_numero.png';

  /// Personaje gato.
  static const String characterCat = '$characters/personaje_gato.png';

  /// Personaje perro.
  static const String characterDog = '$characters/personaje_perro.png';

  /// Personaje conejo.
  static const String characterRabbit = '$characters/personaje_conejo.png';

  /// Personaje robot.
  static const String characterRobot = '$characters/personaje_robot.png';

  /// Musica de fondo (ruta relativa a `assets/audio`).
  static String music(String name) => 'music/$name.wav';

  /// Efecto de sonido (ruta relativa a `assets/audio`).
  static String sfx(String name) => 'sfx/$name.wav';
}
