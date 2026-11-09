# ARCHITECTURE — Pincel & Carreras

Documento técnico complementario a [`GDD.md`](GDD.md) y a [`AGENTS.md`](../AGENTS.md).

**Stack:** Flutter 3.44 / Dart 3.12 · Flame 1.38 · flame_audio 2.12 · provider 6.1 · shared_preferences 2.5 · sensors_plus 7.1

---

## 1. Principios de arquitectura

| # | Principio | Consecuencia práctica |
|---|---|---|
| A1 | **Separar lógica de juego y UI** | `lib/game/` = lógica (Flame en carreras, `CustomPainter` en pintura). `lib/ui/` = Flutter puro, sin lógica de juego. |
| A2 | **Un solo sentido de dependencias** | `ui → providers/services → models`. `game → services`. La UI y el juego se comunican **solo** por callbacks. |
| A3 | **Modelo de dominio inmutable** | `Progress`, `Painting`, `PaintStroke`, `RegionFill` son datos puros, sin Flutter. Testeables sin widgets. |
| A4 | **Servicios sin estado global oculto** | `ProgressService` y `AudioService` se inyectan con `provider`; el estado del niño vive en `ProgressProvider`. |
| A5 | **Sin trabajo pesado en el frame** | La persistencia y el audio se lanzan fuera del `update()` de Flame; el guardado va *debounced*. |
| A6 | **Assets generados, nunca placeholders** | `tool/asset_studio/` produce `assets/images/`; `tool/generate_audio.dart` produce `assets/audio/`. |
| A7 | **Degradación segura** | Si el audio falla, el juego sigue **en silencio**. Si el guardado falla, el juego sigue en memoria. |

---

## 2. Vista general de capas

```
┌───────────────────────────────────────────────────────────────┐
│  ui/                SplashScreen · MenuScreen · LevelSelect    │
│                      ColoringScreen · RacingScreen             │
│                      StickerBookScreen                         │
│                      widgets/ MenuTile, BigButton, ...         │
└───────────────┬───────────────────────────────┬───────────────┘
                │ callbacks / provider           │
┌───────────────▼───────────────┐  ┌────────────▼──────────────┐
│ game/                          │  │ data/models/              │
│  coloring/  PaintCanvas       │  │   Progress, Painting,     │
│              Brush, FloodFill  │  │   PaintStroke, RegionFill │
│  racing/    RacingGame         │  │   CarSpec, TrackSpec,    │
│              Car, Obstacle...  │  │   PageSpec, StickerSpec  │
│              LevelAmbience     │  │   LevelSpec, LevelCatalog│
└───────────────┬───────────────┘  └────────────┬──────────────┘
                │                  ┌────────────▼──────────────┐
                │                  │ data/providers/           │
                │                  │   ProgressProvider        │
                │                  │ data/services/            │
                │                  │   ProgressService         │
                │                  │   AudioService            │
                │                  │   AssetService            │
                │                  └───────────────────────────┘
                │
┌───────────────▼───────────────────────────────────────────────┐
│ core/constants/  palette.dart · game_sizes.dart · asset_paths│
│ core/theme.dart                                            │
└───────────────────────────────────────────────────────────────┘
```

### 2.1 Decisión clave: dos motores, cada uno donde rinde

| Módulo | Motor | Motivo |
|---|---|---|
| **Carreras** | **Flame** (`FlameGame`) | Bucle de juego, componentes, colisiones, tweens, scroll infinito y `PanDetector` para el control táctil. Flame aporta de serie lo que el modo carreras necesita. |
| **Pintura** | **Flutter puro** (`CustomPainter`) | Un lienzo exige control total del gesto: trazo continuo con suavizado, relleno por región y borrado que **parte** los trazos. Flame solo añadiría fricción. El `CustomPainter` da coordenadas en espacio de lámina, cache de `Path` y `RepaintBoundary` de forma nativa. |

Por eso `lib/game/coloring/` **no** es Flame, pero sigue la regla dura:
**cero `material.dart`**, solo `widgets.dart` / `painting.dart`.

### 2.2 Contratos entre capas

| Productor | Consumidor | Contrato |
|---|---|---|
| `ui/RacingScreen` | `game/RacingGame` | `RacingGame(carAssetPath:, trackAssetPath:, onStarCollected:, onCrash:, onLapCompleted:, onRaceFinished:, ...)` + los flags `accelerating` / `braking` |
| `game/RacingGame` | `ui/RacingScreen` | `void Function(int)`, `VoidCallback` y los getters `currentSpeed` / `maxSpeed` / `progress` |
| `ui/ColoringScreen` | `game/coloring/PaintCanvas` | `PaintCanvas(brush:, painting:, onPaintingChanged:, onPaintFeedback:)` |
| `game/coloring/PaintCanvas` | `services/AudioService` | `AudioService.playSfx(SfxKind.pop)` |
| `ui/*` | `services/ProgressService` | `load()` / `save()` (debounce 500 ms) / `saveDrawing()` |
| `ui/*` | `providers/ProgressProvider` | Estado observable del progreso del niño |

---

## 3. Estructura de carpetas

```
lib/
├── main.dart                        # Bootstrap: bindings, services, provider, runApp
├── app.dart                         # MaterialApp, tema, escalado de texto acotado
├── core/
│   ├── constants/
│   │   ├── palette.dart             # Paleta maestra (16 colores + roles)
│   │   ├── game_sizes.dart          # Tamaños de UI (min 60 dp, lanes, grosores)
│   │   └── asset_paths.dart         # Rutas de assets (única fuente de verdad)
│   └── theme.dart                   # ThemeData de la app
├── data/
│   ├── models/
│   │   ├── progress.dart            # Progreso del niño + desbloqueos
│   │   ├── paint_stroke.dart        # PaintStroke, RegionFill y Painting
│   │   ├── vehicle_spec.dart        # Vehículo jugable + VehicleType
│   │   ├── track_spec.dart          # Especificación de una pista
│   │   ├── page_spec.dart           # Especificación de una lámina
│   │   ├── sticker.dart             # Definición de pegatina
│   │   ├── color_spec.dart          # Definición de color
│   │   ├── level_spec.dart          # LevelSpec + LevelEffect (ambiente)
│   │   ├── level_catalog.dart       # Catálogo de los 12 mundos
│   │   └── game_content.dart        # Catálogo completo + reglas de desbloqueo
│   ├── providers/
│   │   └── progress_provider.dart   # ChangeNotifier: estrellas y desbloqueos
│   └── services/
│       ├── progress_service.dart    # shared_preferences (debounce 500 ms)
│       ├── audio_service.dart       # FlameAudio: bgm + sfx con cooldown
│       ├── tilt_service.dart        # "Volante": giroscopio/acelerometro
│       └── asset_service.dart       # Carga de imágenes (rootBundle → ui.Image)
├── game/
│   ├── coloring/
│   │   ├── brush.dart               # ToolKind + modelo de pincel
│   │   ├── flood_fill.dart          # PageRaster: relleno de región por scanline
│   │   └── paint_canvas.dart        # CustomPainter + gestos + partículas
│   └── racing/
│       ├── racing_game.dart         # FlameGame: scroll, spawn, colisiones, meta
│       ├── race_timing.dart         # Modelo puro de velocidad y distancia
│       ├── vehicle_trail.dart       # Estela, líneas de viento y chispas
│       ├── car.dart                 # Componente del coche + carriles
│       ├── lane.dart                # Enum de 3 carriles
│       ├── obstacle.dart            # Cono / charco / roca
│       ├── collectible.dart         # Estrella
│       ├── level_ambience.dart      # Partículas ambientales por mundo
│       ├── track_generator.dart     # Generación con anti-bloqueo (testeable)
│       └── track_scroller.dart      # Fondo, asfalto y bordillos en scroll
├── ui/
│   ├── screens/
│   │   ├── splash_screen.dart       # Pantalla de inicio animada
│   │   ├── menu_screen.dart         # Menú con tarjetas animadas
│   │   ├── level_select_screen.dart # Mapa de los 12 mundos
│   │   ├── garage_screen.dart       # Garaje de vehículos
│   │   ├── studio_screen.dart       # Taller: calca, color y pasajero
│   │   ├── coloring_screen.dart
│   │   ├── racing_screen.dart
│   │   └── sticker_book_screen.dart
│   └── widgets/
│       ├── menu_tile.dart           # Tarjeta grande del menú (icono + etiqueta)
│       ├── big_button.dart          # Botón grande (rebote + SFX + háptica)
│       ├── help_button.dart         # Botón "?" de ayuda en pantalla
│       ├── color_picker.dart
│       ├── tool_picker.dart
│       ├── star_counter.dart
│       ├── thumbnails.dart          # Miniaturas de coche, pista y lámina
│       └── unlock_overlay.dart      # Aviso visual de recompensa
└── shared/
    └── context_extensions.dart      # Acceso seguro a servicios desde la UI

assets/
├── images/
│   ├── cars/       (12 sprites)
│   ├── tracks/     (12 fondos + 4 asfaltos + 4 bordillos + 3 obstáculos)
│   ├── items/      (estrella)
│   ├── canvas/     (9 láminas para colorear)
│   ├── stickers/   (10 pegatinas)
│   ├── ui/         (9 iconos + logo)
│   └── palette/    (paleta.png)
└── audio/
    ├── music/      (2 loops)
    └── sfx/        (8 efectos)

tool/
├── asset_studio/           # Paquete Flutter independiente: genera los PNG
│   ├── lib/studio.dart     # Utilidades de dibujo y paleta
│   ├── lib/sprites.dart    # Coches, obstáculos, iconos, pegatinas
│   ├── lib/backgrounds.dart# Pistas y láminas simples
│   ├── lib/pages.dart      # Láminas de escenas (coche, animales, ...)
│   ├── lib/pages_market.dart # Láminas de frutas, verduras y garaje
│   ├── lib/vehicles.dart   # Vehículos (moto, camión, bus, tractor)
│   ├── lib/customization.dart # Calcas y personajes del vehículo
│   ├── lib/app_logo.dart   # Logotipo e iconos de la app
│   └── test/               # Generadores + verificación del audio
└── generate_audio.dart     # Script Dart puro: síntesis PCM → WAV

docs/                 # GDD.md · ARCHITECTURE.md · TEST_CHECKLIST.md
test/                 # Unitarios, de widget y de integración
```

---

## 4. Componentes clave

### 4.1 `PaintCanvas` (Flutter, modo pintura)

- `StatefulWidget` con `CustomPaint` y `PaintCanvasPainter`.
- **Gestos**: `onPanStart/Update/End` (trazo y borrado) y `onTapDown` (bote y puntos).
- **Espacio de coordenadas**: los puntos se guardan en **espacio de lámina**
  (0..1024 × 0..768), no en píxeles de pantalla. Así el dibujo se ve igual
  en cualquier dispositivo y se serializa sin pérdida.
- **Trazo**: `PaintStroke` con lista de puntos; el render usa un `Path` con
  `quadraticBezierTo` entre puntos, de modo que un movimiento rápido del
  dedo deja una línea suave y sin "saltos".
- **Bote de pintura** (`flood_fill.dart`): `PageRaster` decodifica la lámina
  a RGBA y hace un *scanline flood fill* desde el punto tocado. El resultado
  es una lista de **tramos horizontales** (`Rect`) ordenados de forma canónica,
  que se guardan como `RegionFill`. Ventajas:
  - el relleno es **vectorial** (poco peso, guardado compacto);
  - dos toques en la misma región producen exactamente los mismos tramos, así
    que se puede detectar "ya está pintada" y no parpadear;
  - el bucket se pinta **debajo** de los trazos: el niño no pierde su pincelado.
- **Borrador**: no borra con `BlendMode.clear` (requeriría una capa
  aparte), sino que **parte** los trazos: los puntos próximos al dedo se
  eliminan y el resto se conserva en subtrazos.
- **Partículas**: chispas y estrellas de feedback (máx. ~40 vivas) pintadas
  por el mismo `CustomPainter` y animadas con un `AnimationController` que
  solo corre mientras hay partículas.
- **Cache**: el pintor guarda un `Map<RegionFill, Path>`; se invalida solo
  cuando cambian los rellenos, no en cada trazo.

### 4.2 `RacingGame` (Flame)

- `FlameGame with HasCollisionDetection, MultiTouchTapDetector, PanDetector`.
- Componentes:
  - `TrackScroller` → pinta el fondo tileable, el asfalto y los bordillos
    con **scroll infinito** (cada capa con su propio periodo vertical).
  - `Car` → `PositionComponent` con `CollisionCallbacks`; hijo
    `SpriteComponent` (dibujo) e hijo `RectangleHitbox` (colisión).
  - `Obstacle` → `SpriteComponent` + `RectangleHitbox`.
  - `Collectible` → `SpriteComponent` (gira) + `CircleHitbox`.
  - `VehicleTrail`, `SpeedStreaks`, `SparkField` → capa de **efectos** (ver §4.2 ter).
  - `_TrackBanner` → meta y banderines **dibujados por código** (ver §4.2 bis).
- **Colisión**: el `Car` implementa `onComponentTypeCheck` para aceptar solo
  `Obstacle` y `Collectible`, y resuelve en `onCollisionStart`.
- **Anti-bloqueo**: `TrackGenerator` garantiza que ninguna fila de obstáculos
  ocupe los 3 carriles y que dos filas consecutivas no bloqueen lo mismo.
- **Velocidad**: la marca el niño (§4.2 quater), no el juego.
- **Espaciado adaptativo**: las filas aparecen cada `velocidad × 1,15` px,
  es decir, siempre cada ~1,15 s sea cual sea la velocidad: la dificultad
  medida en *tiempo* es constante.
- **Rendimiento**: los componentes que salen por abajo se eliminan; las
  listas propias del juego evitan iterar el árbol de Flame. Además hay
  **topes de seguridad** (§4.2 quinquies) para que nada se acumule.
- **Cámara (importante)**: Flame 1.38 ancla el *viewfinder* en el **centro**
  del viewport, de modo que el origen `(0, 0)` del mundo aparece en el centro
  de la pantalla. Para un juego cenital eso deja la pista desplazada media
  pantalla y el coche fuera de la vista. Por eso `RacingGame` fuerza
  `camera.viewfinder.anchor = Anchor.topLeft` en `onLoad`: con esa ancla el
  mundo va de `(0, 0)` a `(ancho, alto)` en coordenadas de pantalla y todo el
  resto del juego (`roadLeft`, `size.x / 2`, carriles) sigue siendo válido.
- **Fondo de carga**: Flame usa negro puro por defecto (`Game.backgroundColor()`),
  lo que produce un destello negro al entrar. `RacingGame` lo sustituye por
  `AppPalette.ink`.

### 4.2 bis Mundos, vehículos y final de carrera

**Mundos.** `LevelSpec` + `LevelCatalog` describen los **12 mundos**: id estable, número,
nombre, pista, `LevelEffect`, velocidad, estrellas por tramo, número de tramos y
`targetSeconds`. `LevelCatalog.levels` **es** la progresión: el mundo *n* se abre al
completar el *n-1*.

**Ambiente.** `LevelEffect` (13 valores) decide qué partículas dibuja `LevelAmbience`:
pétalos, mariposas, burbujas, globos, luciérnagas, estrellas fugaces, confeti, nieve, hojas,
chispas, arena, olas y brasas. Se dibujan con **primitivas** (cero assets extra) y se
reciclan al salir de la pantalla.

**Vehículos.** `VehicleSpec` + `VehicleType` (coche, camión, moto, bus, tractor,
furgoneta) con **12 vehículos** en el catálogo. El tamaño en pista sale de
`widthFactor` y `heightFactor`:
`carWidth = laneWidth · 0,62 · widthFactor`. El sprite se dibuja con la misma
proporción que el canvas del asset, así que no se deforma.

**Final de carrera (el "minuto mínimo").** `lib/game/racing/race_timing.dart` es **código
puro** (sin Flutter) con el modelo de velocidad de la pista:

```dart
class RaceTiming {
  static const double maxSpeed = 180;      // px/s (x speedScale del mundo)
  static const double acceleration = 260;  // px/s^2
  static const double braking = 420;       // px/s^2
  static const double coasting = 190;      // px/s^2

  static double speedAt(double seconds, double speedScale);
  static double distanceAfter(double seconds, double speedScale);
  static double lapDistance({required int targetSeconds,
                              required int laps,
                              required double speedScale});
  static double timeForDistance(double distance, double speedScale);
}
```

- La distancia de cada tramo se calcula para que el recorrido completo dure
  `targetSeconds` (65–78 s) **acelerando siempre**. **Si el niño choca o suelta el
  acelerador, el mundo se para y la carrera dura más**, nunca menos.
- `timeForDistance` (bisección cerrada) permite verificar en los tests que **ningún mundo
  dura menos de un minuto**.
- En el juego, el último banderín es la **meta**; los anteriores son banderines que dan
  estrellas. Al cruzar la meta se dispara `onRaceFinished()` → resumen con estrellas,
  tiempo y récord.
- El récord se guarda en `Progress.bestTimes` (`progress_best_times`) y **solo mejora**
  (`ProgressProvider.recordBestTime`).

### 4.2 ter La meta y los banderines se dibujan por código

`_TrackBanner` es un `PositionComponent` que **dibuja la meta a cuadros y los banderines
con flechas** directamente en el `Canvas`.

- **Por qué**: como sprite se veían **pixeleados** al estirarlos por toda la carretera.
  Dibujados en el mundo son **nítidos a cualquier tamaño**.
- Lleva `priority = -1`, así que el coche pasa **por encima** de la línea.
- No hay assets `meta.png` ni `banderin.png`: el generador ya no los produce.

### 4.2 quater El acelerador (el modelo de "el niño marca el ritmo")

El cambio de diseño más importante de la ronda 5: **la velocidad ya no sube sola**.

`RacingGame` expone dos **flags** que la UI escribe directamente:

```dart
bool accelerating = false;   // el niño mantiene pulsado "Acelerar"
bool braking = false;        // el niño mantiene pulsado "Frenar"
```

Y en `update(dt)`:

```dart
if (accelerating) {
  _speed += RaceTiming.acceleration * dt;
} else if (braking) {
  _speed -= RaceTiming.braking * dt;
} else {
  _speed -= RaceTiming.coasting * dt;   // rueda y frena solo
}
_speed = _speed.clamp(0, maxSpeed);
```

- `currentSpeed` y `maxSpeed` son getters públicos: el **HUD** los lee para pintar la
  velocidad y la barra de progreso.
- El **HUD es un widget aparte** (`_RaceHud`) con **su propio `Ticker`**: así se
  repinta solo la chapa del marcador en cada frame, sin reconstruir la pantalla
  entera (que contiene el `GameWidget` de Flame). El ticker **se para** cuando la
  carrera está en pausa o terminada.
- El **freno manda** si los dos flags están a la vez (`else if`).
- La UI (`_PedalButton`) traduce el gesto en los flags con `onTapDown` / `onTapUp` /
  `onTapCancel`: hay que **mantener pulsado**.
- El SFX `motor` suena **solo al arrancar desde parado** (`currentSpeed < 20`), no en
  cada pulsación, para no cansar.

> **El bug que motivó el cambio**: al pasar a "acelerador mantenido" **no se añadió el
> botón**. El coche frenaba solo hasta pararse y el juego parecía "alentarse". El
> diagnóstico correcto fue: *falta el control*, no *falta rendimiento*.

### 4.2 quinquies Topes de seguridad (el juego no se ralentiza)

El síntoma era que **después de un rato de uso la animación se ralentizaba**. Las causas
posibles eran acumulación de componentes o de listeners. La defensa es **acotar el
número de elementos vivos**:

| Lista | Tope | Motivo |
|---|---|---|
| `_obstacles` | 24 | Los obstáculos que salen por abajo ya se eliminan; el tope cubre el caso de que el niño frene mucho |
| `_collectibles` | 20 | Ídem con las estrellas |
| `_banners` | 6 | Solo hay `laps` banderines por carrera |

Cuando se supera el tope, se elimina el más antiguo (`removeAt(0)` + `removeFromParent()`).

Además, la pantalla de carreras **recrea** el juego (`_restart()`) cuando se cambia de
vehículo desde el garaje, de modo que no quedan componentes viejos vivos.

### 4.2 sexies Efectos de carrera (`vehicle_trail.dart`)

Un solo fichero con tres `Component` de efectos, todos de **primitivas** (cero assets):

| Clase | Qué hace | Parámetro |
|---|---|---|
| `VehicleTrail` | Nubecinas de polvo en las ruedas | `speed` (crece con la velocidad) |
| `SpeedStreaks` | Rayas de viento por los lados | `intensity` = `speed / maxSpeed` |
| `SparkField` | Chispas al recoger una estrella | `burst(position:, color:)` |

- `SpeedStreaks.intensity` lo escribe `RacingGame.update` en cada frame.
- Las partículas se **reciclan** al morir (no crecen sin límite).

### 4.2 septies La vista horizontal: el mundo esta girado 90 grados

Las carreras se juegan **acostadas**: la pista corre de izquierda a derecha y el niño
sujeta el móvil como un volante.

**La decisión:** en lugar de reescribir el motor de carreras para que el mundo fuera
horizontal, se **gira el mundo entero** con un `RotatedBox` en la pantalla:

```dart
Positioned.fill(
  child: RotatedBox(
    quarterTurns: 1,
    child: GameWidget<RacingGame>(...),
  ),
)
```

| | Sin rotar (vertical) | Con `RotatedBox` (horizontal) |
|---|---|---|
| `size.x` del juego | ancho de la pantalla | **altura** de la pantalla |
| `size.y` del juego | alto de la pantalla | **ancho** de la pantalla |
| El coche | abajo, mirando arriba | **izquierda, mirando a la derecha** |
| Los obstáculos | vienen por arriba | **vienen por la derecha** |

- La rotación es **de sentido horario**: el mundo `y` grande (el coche, al fondo) queda a
  la **izquierda** de la pantalla y el mundo `y` pequeño (por donde aparecen los
  obstáculos) queda a la **derecha**. El sprite del coche, que apunta a `-y`, se ve
  **apuntando a la derecha** sin tocar ni un pixel del asset.
- **La interfaz no se gira**: la barra superior, los pedales y el HUD están fuera del
  `RotatedBox`, así que se leen derechos.
- La pantalla pide **orientación horizontal** al entrar (`SystemChrome
  .setPreferredOrientations`) y la recupera al salir. En web no se hace (la API no
  existe) y el juego funciona igual, girado.
- **El ambiente se corrige**: `LevelAmbience` dibuja las partículas en un espacio local
  girado (`translate` + `rotate(-π/2)`) para que la nieve caiga **hacia abajo** de la
  pantalla y no hacia el lado.
- La carretera ocupa el **58 %** de la altura de la pantalla (`GameSizes
  .roadWidthFraction`): el resto es decorado, para que se vea que el coche corre por un
  sitio y no por una pared.
- **Las coordenadas de los gestos siguen siendo correctas**: Flame usa
  `RenderBox.globalToLocal`, que aplica toda la cadena de transformaciones (incluida la
  del `RotatedBox`). Por eso arrastrar el dedo en vertical mueve el coche de un lado a
  otro de la carretera, que es justo lo que se ve en pantalla.

### 4.2 octies El volante: `TiltService`

`lib/data/services/tilt_service.dart` traduce el giro del móvil en un valor normalizado
(`-1` = todo a la izquierda, `0` = centrado, `+1` = todo a la derecha).

| Sensor | Qué mide | Por qué |
|---|---|---|
| **Giroscopio** (preferido) | La rotación alrededor del eje **normal a la pantalla** (`z`) | Es exactamente el gesto de **girar el móvil como un volante**, y **no depende** de si el móvil está en horizontal izquierdo o derecho |
| **Acelerómetro** (respaldo) | El componente de la gravedad en el eje vertical de la pantalla | Permite inclinar el móvil hacia delante o atrás si no hay giroscopio |

- El giroscopio se integra (velocidad angular × tiempo) en un **ángulo de volante**
  limitado a `maxWheelAngle` (0,55 rad ≈ 31°). Cuando el niño deja de girar, el ángulo
  **vuelve solo al centro** (`returnRate = 1,8`/s), así que no tiene que "desgirar".
- El servicio **nunca lanza**: si el sensor no existe (emulador, escritorio, web sin
  permiso), se queda neutro y el juego sigue siendo jugable **arrastrando** el coche.
- La pantalla de carreras **lo inyecta** en el juego (`RacingGame.tiltService`), así que
  el motor lee `tiltService.steering` en cada frame y llama a `Car.steerBy()`.

### 4.2 nonies Obstáculos: uno cada vez y nunca empalmados

El generador (`TrackGenerator`) ya no produce "filas": produce **elementos sueltos**.

| Método | Qué hace |
|---|---|
| `nextObstacleLane()` | Elige el carril del próximo obstáculo, **distinto** del anterior |
| `nextStarLane({forbiddenLane})` | Elige el carril de la próxima estrella, distinto del del obstáculo y de la estrella anterior |

Y el juego (`RacingGame._updateSpawning`) los separa en el **tiempo**:

| Constante | Valor | Significado |
|---|---|---|
| `obstacleSpacing` | 3,4 s | Un obstáculo cada 3,4 s (antes: filas cada 2,2 s con hasta 2 obstáculos) |
| `starSpacing` | 2,2 s | Una estrella cada 2,2 s |
| `minSeparation` | 1,4 s | **Una estrella nunca aparece pegada a un obstáculo** |

- Con **un solo obstáculo** por vez, siempre quedan **dos carriles libres**: es
  imposible quedarse atrapado.
- Los tamaños se reduzcan (obstáculo del 72 % al 62 % del carril, estrella del 62 % al
  50 %) para que además de no solaparse **se vean separados**.

### 4.2 decies El HUD en vivo

El HUD (`_RaceHud`) es un widget **aparte** con su **propio `Ticker`**:

- Si se leyera la velocidad en el `build` de la pantalla, el HUD se quedaría
  **congelado** en "0" (nada provoca un `setState` durante la carrera).
- Con su propio ticker se repinta **solo la chapa del marcador** en cada frame, sin
  reconstruir la pantalla entera (que contiene el `GameWidget` de Flame).
- El ticker **se para** cuando la carrera está en pausa o terminada.

### 4.3 `Car`
```dart
enum Lane { left, center, right }

class Car extends PositionComponent with CollisionCallbacks {
  Lane get currentLane;
  bool get isStunned;
  void steerTo(Lane lane);   // buffer de 1 entrada si hay transición
  void steerLeft();
  void steerRight();
  void steerBy(double normalized);  // el "volante": continuo, -1..1
  void stun([double seconds = 1]);
}
```
- La posición X se interpola en **220 ms** con `EaseOutCubic` (cambio de carril).
- Con el **volante** (`steerBy`) el coche se mueve de forma **continua** hacia el punto
  pedido: el niño ve que responde al instante, sin saltos entre carriles.
- El coche inclina ±12° al cambiar de carril y se inclina según la velocidad lateral
  cuando se mueve libre.
- Un choque aplica `stun(1 s)`: el mundo se detiene un segundo (nunca hay
  "game over") y el coche tiembla para que el impacto se entienda.

### 4.5 Taller (calca, color y pasajero)

- `VehicleCustomization` cataloga las **5 calcas** (dibujadas en blanco) y los
  **4 personajes**.
- `Progress` guarda `selectedDecal`, `selectedDecalColor` y `selectedCharacter`.
- En el juego, `_VehicleLivery` (un `PositionComponent` hijo del coche) dibuja:
  la calca con un `ColorFilter.mode(color, BlendMode.srcIn)` —un solo asset vale
  para los 12 colores— y el personaje encima del vehículo.

### 4.6 Servicios

**`ProgressService`**
```dart
class ProgressService {
  Progress load();
  void save(Progress progress);          // debounce 500 ms
  Future<void> flush();                  // escritura inmediata
  Painting loadDrawing(String pageId);
  Future<void> saveDrawing(String pageId, Painting painting);
  Future<void> clearDrawing(String pageId);
}
```
- Envuelve `SharedPreferences`.
- Las estrellas **nunca bajan**: el progreso es aditivo.

**`AudioService`**
```dart
class AudioService {
  Future<void> initialize();
  Future<void> playBgm(BgmTrack track);  // loop + auto-pause en background
  Future<void> pauseBgm();              // segundo plano
  Future<void> resumeBgm();
  Future<void> stopBgm();               // salir de la pantalla
  void playSfx(SfxKind kind);            // con cooldown por tipo
}
```
- `FlameAudio.bgm.play(path, volume: ≤ 0.35)` para la música.
- `FlameAudio.play(path, volume: 0.7)` para los SFX.
- **Cooldown**: máximo **4 reproducciones del mismo SFX por segundo**.
- **Degradación**: todo el audio va envuelto en `try/catch`; si el plugin
  falla, se registra con `debugPrint` y el juego continúa en silencio.
- `playBgm` **no reinicia** la misma pista: entrar dos veces en la misma pantalla
  no produce un corte audible.

### 4.4 bis Ciclo de vida (el bug de "el juego sigue en segundo plano")

El síntoma: al salir de una carrera, la música seguía sonando y las colisiones
seguían ocurriendo. La causa era que **nadie paraba el motor ni la música** al
desmontar la pantalla. La solución aplica las cuatro reglas:

| Regla | Dónde | Qué hace |
|---|---|---|
| Parada definitiva | `RacingGame.halt()` | Marca `_halted` y llama a `pauseEngine()`. El `update` deja de mover el coche aunque el `GameWidget` tarde en desmontarse. `onRemove` también marca `_halted`. |
| Parada al salir | `RacingScreen.dispose()` | `halt()` + `AudioService.stopBgm()`. |
| Parada en segundo plano | `WidgetsBindingObserver` | `didChangeAppLifecycleState` pausa motor y música en `paused/inactive/hidden` y los reanuda en `resumed`. |
| Parada manual | `RacingScreen._togglePause()` | Pausa y reanuda motor **y** música a la vez. |

El mismo patrón se aplica en `ColoringScreen` (música de pintura) para que el
estudio tampoco suene en el menú.

`AudioService` mantiene la pista actual (`_currentTrack`) y si está en pausa
(`_bgmPaused`), de modo que `resumeBgm()` solo actúa si realmente hace falta.

**`AssetService`**
- `rootBundle` + `ui.instantiateImageCodec` para obtener el `ui.Image` que
  necesita el lienzo y los sprites de Flame.

### 4.5 Estado global (`provider`)

```dart
class ProgressProvider extends ChangeNotifier {
  Progress get progress;
  int get totalStars;
  void load();
  void addStars(int n);        // recalcula desbloqueos y notifica
  void completeLap();
  void selectCar(String id);
  void selectTrack(String id);
  void selectPage(String id);
  bool isCarUnlocked(String id);      // y para track, page, color, sticker
  List<UnlockEvent> takePendingUnlocks();
}
```
- Es la **única** fuente de verdad del progreso para la UI.
- `addStars` recalcula la tabla de desbloqueos del GDD §5.7 y encola los
  `UnlockEvent` pendientes; el `UnlockOverlay` los consume y los muestra.

---

## 5. Flujos de datos

### 5.1 Flujo de pintado

```
Dedo en pantalla
  → GestureDetector (PaintCanvas)
    → _onPanUpdate: añade puntos al trazo actual
      → Painting.copyWith(strokes: [...])
        → setState → CustomPainter repinta
        → AudioService.playSfx(SfxKind.pop)   [cooldown 4/s]
        → _spawnSparkles → partículas (chispas + estrellas)
    → _onPanEnd: cierra el trazo
    → Timer de 4 s → ProgressService.saveDrawing(pageId, painting)
```

### 5.2 Flujo del bote de pintura

```
Toque (bote)
  → PageRaster.fillRegion(x, y)   [scanline sobre la lámina]
    → RegionFill(colorValue, spans)
      → si la región ya tenía ese color: no se hace nada (sin parpadeo)
      → si no: se añade el relleno y se dibuja DEBAJO de los trazos
        → onda de color + 6 chispas + SFX pop
```

### 5.3 Flujo de carrera

```
Girar el movil (giroscopio)
  → TiltService integra el giro → TiltService.steering (-1..1)
    → RacingGame.update(dt): car.steerBy(steering)
      → el coche se desliza de forma continua por la carretera

Mantener pulsado el acelerador
  → _PedalButton.onTapDown(true) → RacingScreen._setPedal(accelerating: true)
    → RacingGame.accelerating = true
      → update(dt): _speed += RaceTiming.acceleration * dt
        → el scroll avanza, la estela crece, las líneas de viento se alargan
        → (solo al arrancar desde parado) SFX engine

Soltar el acelerador / pulsar el freno
  → _PedalButton.onTapUp(false) / onTapCancel
    → RacingGame.accelerating = false, braking = true/false
      → update(dt): _speed -= RaceTiming.braking * dt  (o -= coasting * dt)
        → el coche rueda y frena solo

Arrastrar el dedo (respaldo si no hay sensor)
  → PanDetector.onPanUpdate
    → RacingGame._carDragX → el coche sigue al dedo por la carretera

Aparición de obstáculos y estrellas
  → _updateSpawning(dt): distancia desde el último obstáculo / estrella
    → si toca el obstáculo (3,4 s) → _spawnObstacle()  [un carril libre siempre]
    → si toca la estrella (2,2 s) y ha pasado 1,4 s → _spawnStar()

Colisión con estrella
  → Car.onCollisionStart → Collectible.collect()
    → ProgressProvider.addStars(1) → guardado debounced
    → SFX ding + pop del contador + chispas (SparkField.burst)

Colisión con obstáculo
  → Car.onCollisionStart → Obstacle.crush() + Car.stun(1 s)
    → el mundo se detiene 1 s (nunca hay "game over")
    → SFX crash (suave, no punitivo)

Cruce de banderín / meta
  → +1 estrella (banderín) o +3 estrellas y fin (meta)
    → onRaceFinished() → resumen con estrellas, tiempo y récord
```

### 5.3 bis Flujo del garaje (cambio de vehículo al instante)

```
Tocar el botón del vehículo en la pantalla de carreras
  → RacingScreen._openGarage() → Navigator.push(GarageScreen())

Elegir un vehículo en el garaje
  → GarageScreen._pick() → progress.selectVehicle(id)
    → Navigator.pop(vehicle.id)          ← devuelve el id

Volver a la pantalla de carreras
  → RacingScreen._openGaraje() recibe el id
    → _restart()  → se recrea el RacingGame con el sprite del vehículo nuevo
```

Antes el garaje solo guardaba la preferencia y el cambio **no se veía** hasta
salir y volver a entrar. Ahora `pop(vehicle.id)` + `_restart()` lo aplican al
instante.

### 5.4 Flujo de desbloqueo

```
ProgressProvider.addStars(n)
  → recalcula la tabla del GDD §5.7
    → si hay desbloqueo nuevo: encola UnlockEvent
      → ProgressService.save()
      → UnlockOverlay muestra la tarjeta + SFX unlock + vibración
```

---

## 6. Modelos de datos

```dart
@immutable
class Progress {
  final int totalStars;
  final int sessionStars;
  final Set<String> unlockedStickers, unlockedColors, unlockedCars, unlockedPages;
  final Set<String> completedLevels;
  final String selectedCar, selectedTrack, selectedPage, selectedLevel;
  final int bestLaps;

  Progress copyWith({...});
  Map<String, dynamic> toJson();
  factory Progress.fromJson(Map<String, dynamic> json);
}
```

```dart
@immutable
class Painting {
  final List<PaintStroke> strokes;  // trazos de pincel
  final List<RegionFill> fills;      // rellenos de bote (tramos)
}

@immutable
class PaintStroke {
  final List<Offset> points;   // coordenadas lógicas de la lámina
  final int colorValue;
  final double width;
  final PaintStrokeKind kind;  // brush | eraser
}

@immutable
class RegionFill {
  final int colorValue;
  final List<Rect> spans;      // tramos horizontales de la región
}
```

Las coordenadas se guardan en **espacio lógico de la lámina**
(independiente de la resolución de pantalla) para que el dibujo se vea igual
en cualquier dispositivo y se serialice de forma compacta.

---

## 7. Sistema de assets

- Todos los assets se **generan con código**, no se descargan ni se usan
  placeholders.
- **Imágenes**: paquete Flutter independiente (`tool/asset_studio/`) que
  renderiza con `dart:ui` (`PictureRecorder` → `Canvas` → `ui.Image` → PNG).
- **Logotipo e iconos**: `tool/asset_studio/lib/app_logo.dart` dibuja el emblema
  (estrella + coche + pincel sobre degradado azul-violeta). El mismo dibujo genera
  los iconos de **Android** (clásico, redondo y adaptativo con capa monocroma),
  **iOS** (los 15 tamaños del `appiconset`) y **web** (favicon y manifest), además
  del logo de la pantalla de inicio. Se regenera con
  `flutter test test/generate_app_icons_test.dart`.
- **Audio**: script Dart puro (`tool/generate_audio.dart`) que sintetiza PCM
  y escribe **WAV 16-bit mono 22050 Hz** (soportado por `audioplayers` en
  Android/iOS, sin encoder externo).
- `core/constants/asset_paths.dart` es la **única** fuente de verdad de las
  rutas.
- Regeneración:
  ```powershell
  cd tool/asset_studio
  flutter test                 # genera los PNG y verifica los WAV
  cd ../..
  dart run tool/generate_audio.dart
  ```
- **Ojo con `pubspec.yaml`**: Flutter solo empaqueta los ficheros que están
  **directamente** en la carpeta declarada, no sus subdirectorios. Hay que
  listar cada carpeta (`assets/images/cars/`, `assets/audio/sfx/`, ...).
  Si se olvida, el build **no falla**: el asset simplemente falta en el APK.

---

## 8. Decisiones técnicas y alternativas descartadas

| Decisión | Alternativa descartada | Motivo |
|---|---|---|
| `CustomPainter` propio para el lienzo | `flutter_painting_tools` | Abandonado, `sdk <3.0.0`, no compila con Dart 3.12; además no soporta relleno por región. |
| **Girar el mundo con `RotatedBox`** para la vista horizontal | Reescribir el motor de carreras en coordenadas horizontales | El motor, los obstaculos, las estrellas, el scroll y las colisiones ya funcionan en vertical: girarlo es **una línea** y no toca la lógica de juego. |
| **Giroscopio** para el volante | Acelerómetro | El giroscopio mide el giro alrededor de la normal de la pantalla (el gesto de "volante") y **no depende** de la orientación del móvil. |
| Quitar "tocar la pantalla para girar" | Dejarlo | Cualquier toque (incluso la mano que sujeta el móvil) movía el coche solo. El volante por sensor no puede pasar por alto. |
| Un **obstáculo** cada vez | Filas con 1 o 2 obstáculos | Con dos bloqueados y el tercero ocupado por una estrella, el niño se quedaba sin salida. |
| **Un solo carril** bloqueado por obstáculo | Hasta dos | Siempre quedan dos carriles libres: nunca hay un muro infranqueable. |
| Relleno por *scanline flood fill* sobre la lámina | Botón que rellena un rectángulo predefinido | El niño colorea formas reales, no cajas. El coste (~10-40 ms) se paga solo al tocar. |
| Borrador que **parte** los trazos | Borrador con `BlendMode.clear` | `clear` borraría también la lámina o exigiría una capa aparte. Partir conserva el resto del dibujo. |
| `provider` | Riverpod / Bloc | Estado mínimo (progreso del niño). `provider` es suficiente y sin boilerplate. |
| `shared_preferences` | sqflite / drift | El progreso es un blob pequeño (int + listas de ids + trazos). SQLite sería overkill. |
| WAV 16-bit 22050 Hz | MP3/OGG | No hay encoder disponible offline; WAV lo soporta `audioplayers` en Android/iOS y pesa ~2,2 MB en total. |
| Generar PNG con `dart:ui` en `flutter test` | Figma / ilustración manual | Pipeline reproducible, versionable y sin licencias de terceros. |
| Un solo gesto para cambiar de carril | Swipes + botones | Un niño de 3 años no domina el swipe. Un toque en cualquier parte es infalible. |
| **Acelerador mantenido** (flags `accelerating` / `braking`) | Velocidad automática | El niño **marca el ritmo**: es más "> juego" y da control real sin dejar de ser fácil. Requiere un botón grande y visible. |
| Meta y banderines **dibujados por código** (`_TrackBanner`) | Sprite `meta.png` | El sprite se **pixelaba** al estirarlo por toda la carretera; dibujado en el mundo es nítido a cualquier tamaño. |
| **Topes de seguridad** en obstáculos / coleccionables / banderines | Depurar solo al salir de pantalla | Con el niño acelerando y frenando, los elementos pueden quedarse "en cola": sin tope, la escena crece y el juego se ralentiza. |
| Flame solo para carreras | Flame para todo | El lienzo necesita control fino del gesto; Flame solo añadiría fricción. |
| Ancla del *viewfinder* en la esquina | Ancla por defecto (centro) | Flame 1.38 centra el mundo en el viewport: la pista quedaría desplazada y el coche saldría de pantalla. |
| Layout adaptable (`LayoutBuilder` + `FittedBox`) en las barras superiores | Tamaños fijos | En móviles de 320 dp las barras se desbordaban. El layout se adapta o se encoge, nunca se desborda. |
| `unawaited` para audio y orientación en `main()` | `await` | Ambas recursos pueden no responder nunca; esperarlos dejaría la app sin arrancar (criterio A9 del GDD). |

---

## 9. Estrategia de testing

| Nivel | Qué se prueba | Herramienta |
|---|---|---|
| **Unitario** | `Progress` (JSON), `ProgressService` (con `SharedPreferences.setMockInitialValues`), `ProgressProvider` (desbloqueos y progresión de niveles), `LevelCatalog` (12 niveles, ids únicos, ambientes únicos, pista válida), `TrackGenerator` (un obstáculo por vez, nunca el mismo carril, la estrella en un carril libre), `Car` (carriles, buffer, choque, **volante**), `RaceTiming` (mínima de 60 s), `PageRaster` (flood fill), `TiltService` (neutro sin sensor, se para sin errores) | `flutter_test` |
| **Widget** | `MenuScreen`: 4 tarjetas ≥ 60 dp, navegación a pintura, mapa, taller y libro, sin desbordes. `LevelSelectScreen`: 12 tarjetas, candados, apertura del siguiente nivel, navegación. `SplashScreen`: título, arranque automático y salto con un toque. `RacingScreen`: juego a pantalla completa, **el mundo está girado (pista horizontal)**, **el coche sale por la izquierda**, **el HUD se repinta en vivo**, **el acelerador mantenido**, **el volante mueve el coche**, **el garaje que devuelve el vehículo**, **parada del juego y de la música al salir**, pausa, panel de coches. `small_screen_test`: las pantallas sin desbordes (las carreras, en horizontal). `screen_capture_test`: cada pantalla se dibuja sin excepciones y se exporta a PNG | `flutter_test` |
| **Integración** | `flutter analyze` + `flutter test` + `flutter build apk` | CI local |
| **Assets** | Los WAV tienen señal real (pico y RMS dentro de rango) y los PNG se generan sin excepciones | `tool/asset_studio/test` |

> **Los sensores se simulan en los tests.** `sensors_plus` habla con un canal de
> plataforma que no existe en el entorno de pruebas: sin el stub de
> `test/helpers/sensor_mock.dart` el test falla con `MissingPluginException`.
> Además, la pantalla de carreras permite **inyectar** un `TiltService` falso, para
> comprobar el volante sin hardware.

Criterio: **0 fallos, 0 warnings de análisis**, y los tests deben poder
ejecutarse **sin red**.

El resultado actual y los bugs que estos tests destaparon están en
[`TEST_CHECKLIST.md`](TEST_CHECKLIST.md).

---

## 10. Puntos de extensión futuros

- **Más láminas**: añadir el PNG a `assets/images/canvas/` y su id al
  catálogo `GameContent.pages` + la tabla de desbloqueo.
- **Más pistas**: `TrackScroller` ya es genérico sobre el asset de fondo.
- **Multitáctil en pintura**: `PaintCanvas` separa los puntos por
  `PointerEvent.pointer`; solo hay que distinguir el puntero activo.
- **Exportar el dibujo**: `PaintCanvasPainter` puede renderizar a `ui.Image`
  y guardar un PNG en el directorio de documentos.
- **Niveles de dificultad**: `TrackGenerator` ya acepta parámetros
  (`densidad`, `distancia mínima`); está preparado para escalarlos **por
  edades**, nunca de forma punitiva.
- **Nube opcional**: `ProgressService` es la única capa que toca el
  almacenamiento; añadir sincronización no tocaría el juego.
