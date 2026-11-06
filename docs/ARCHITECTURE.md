# ARCHITECTURE — Pincel & Carreras

Documento técnico complementario a [`GDD.md`](GDD.md) y a [`AGENTS.md`](../AGENTS.md).

**Stack:** Flutter 3.44 / Dart 3.12 · Flame 1.38 · flame_audio 2.12 · provider 6.1 · shared_preferences 2.5

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
| **Carreras** | **Flame** (`FlameGame`) | Bucle de juego, componentes, colisiones, tweens, scroll infinito y `MultiTouchTapDetector` para el control táctil. Flame aporta de serie lo que el modo carreras necesita. |
| **Pintura** | **Flutter puro** (`CustomPainter`) | Un lienzo exige control total del gesto: trazo continuo con suavizado, relleno por región y borrado que **parte** los trazos. Flame solo añadiría fricción. El `CustomPainter` da coordenadas en espacio de lámina, cache de `Path` y `RepaintBoundary` de forma nativa. |

Por eso `lib/game/coloring/` **no** es Flame, pero sigue la regla dura:
**cero `material.dart`**, solo `widgets.dart` / `painting.dart`.

### 2.2 Contratos entre capas

| Productor | Consumidor | Contrato |
|---|---|---|
| `ui/RacingScreen` | `game/RacingGame` | `RacingGame(onStarCollected:, onCrash:, onLapCompleted:, onLaneChange:)` |
| `game/RacingGame` | `ui/RacingScreen` | `void Function(int)` y `VoidCallback` |
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
│       └── asset_service.dart       # Carga de imágenes (rootBundle → ui.Image)
├── game/
│   ├── coloring/
│   │   ├── brush.dart               # ToolKind + modelo de pincel
│   │   ├── flood_fill.dart          # PageRaster: relleno de región por scanline
│   │   └── paint_canvas.dart        # CustomPainter + gestos + partículas
│   └── racing/
│       ├── racing_game.dart         # FlameGame: scroll, spawn, colisiones, meta
│       ├── race_timing.dart         # Modelo puro de velocidad y distancia
│       ├── climb_game.dart          # FlameGame del modo "Subidas" (vista de lado)
│       ├── climb_terrain.dart       # Terreno con colinas y loops de 360°
│       ├── vehicle_trail.dart       # Estela de polvo del vehículo
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
│   │   ├── climb_screen.dart        # Modo "Subidas" (acelerar / frenar)
│   │   ├── coloring_screen.dart
│   │   ├── racing_screen.dart
│   │   └── sticker_book_screen.dart
│   └── widgets/
│       ├── menu_tile.dart           # Tarjeta grande del menú (icono + etiqueta)
│       ├── big_button.dart          # Botón grande (rebote + SFX + háptica)
│       ├── color_picker.dart
│       ├── tool_picker.dart
│       ├── star_counter.dart
│       ├── thumbnails.dart          # Miniaturas de coche, pista y lámina
│       └── unlock_overlay.dart      # Aviso visual de recompensa
└── shared/
    └── context_extensions.dart      # Acceso seguro a servicios desde la UI

assets/
├── images/
│   ├── cars/       (5 sprites)
│   ├── tracks/     (6 fondos + asfalto + bordillo + 3 obstáculos + meta)
│   ├── items/      (estrella)
│   ├── canvas/     (6 láminas para colorear)
│   ├── stickers/   (6 pegatinas)
│   ├── ui/         (9 iconos)
│   └── palette/    (paleta.png)
└── audio/
    ├── music/      (2 loops)
    └── sfx/        (7 efectos)

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

- `FlameGame with HasCollisionDetection, MultiTouchTapDetector`.
- Componentes:
  - `TrackScroller` → pinta el fondo tileable, el asfalto y los bordillos
    con **scroll infinito** (cada capa con su propio periodo vertical).
  - `Car` → `PositionComponent` con `CollisionCallbacks`; hijo
    `SpriteComponent` (dibujo) e hijo `RectangleHitbox` (colisión).
  - `Obstacle` → `SpriteComponent` + `RectangleHitbox`.
  - `Collectible` → `SpriteComponent` (gira) + `CircleHitbox`.
- **Colisión**: el `Car` implementa `onComponentTypeCheck` para aceptar solo
  `Obstacle` y `Collectible`, y resuelve en `onCollisionStart`.
- **Anti-bloqueo**: `TrackGenerator` garantiza que ninguna fila de obstáculos
  ocupe los 3 carriles y que dos filas consecutivas no bloqueen lo mismo.
- **Velocidad**: `v = v0 + (vmax - v0) · (1 - e^(-t/18))`: aceleración suave
  hasta 420 px/s, sin saltos.
- **Espaciado adaptativo**: las filas aparecen cada `velocidad × 1,15` px,
  es decir, siempre cada ~1,15 s sea cual sea la velocidad: la dificultad
  medida en *tiempo* es constante.
- **Rendimiento**: los componentes que salen por abajo se eliminan; las
  listas propias del juego evitan iterar el árbol de Flame.
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

**Vehículos.** `VehicleSpec` + `VehicleType` (coche, camión, moto, bus, tractor y
furgoneta). El tamaño en pista sale de `widthFactor` y `heightFactor`:
`carWidth = laneWidth · 0,62 · widthFactor`. El sprite se dibuja con la misma
proporción que el canvas del asset, así que no se deforma.

**Final de carrera (el "minuto mínimo").** `lib/game/racing/race_timing.dart` es **código
puro** (sin Flutter) con el modelo de velocidad de la pista:

```dart
class RaceTiming {
  static double speedAt(double seconds, double speedScale);
  static double distanceAfter(double seconds, double speedScale);
  static double lapDistance({required int targetSeconds,
                              required int laps,
                              required double speedScale});
  static double timeForDistance(double distance, double speedScale);
}
```

- La distancia de cada tramo se calcula para que el recorrido completo dure
  `targetSeconds` (65–78 s). **Si el niño choca, el mundo se para y la carrera dura más**,
  nunca menos.
- `timeForDistance` (bisección) permite verificar en los tests que **ningún mundo dura menos
  de un minuto**.
- En el juego, el último banderín es la **meta** (`tracks/meta.png`); los anteriores son
  banderines (`tracks/banderin.png`) que dan estrellas. Al cruzar la meta se dispara
  `onRaceFinished()` → resumen con estrellas, tiempo y récord.
- El récord se guarda en `Progress.bestTimes` (`progress_best_times`) y **solo mejora**
  (`ProgressProvider.recordBestTime`).

### 4.3 `Car`
```dart
enum Lane { left, center, right }

class Car extends PositionComponent with CollisionCallbacks {
  Lane get currentLane;
  bool get isStunned;
  void steerTo(Lane lane);   // buffer de 1 entrada si hay transición
  void steerLeft();
  void steerRight();
  void stun([double seconds = 1]);
}
```
- La posición X se interpola en **220 ms** con `EaseOutCubic`.
- El coche inclina ±12° al cambiar de carril y vuelve a 0° al terminar.
- Un choque aplica `stun(1 s)`: el mundo se detiene un segundo (nunca hay
  "game over") y el coche tiembla para que el impacto se entienda.

### 4.4 bis Modo "Subidas" (vista de lado, tipo Hill Climb)

`lib/game/racing/climb_terrain.dart` genera el terreno como una lista de puntos con:

- `arcLengths`: la **longitud de arco** acumulada (siempre crece, incluso dentro de
  un loop, donde el vehículo va hacia la izquierda en pantalla). Es la coordenada
  real del recorrido y la que se usa para buscar el punto (búsqueda binaria sobre
  un array monótono: buscar por X **no** valdría dentro de un loop).
- `angles`: la tangente en cada punto (el vehículo se inclina con el terreno).

Tramos: `flat`, `hill`, `bump`, `ramp` y `loop`. El **loop** es una circunferencia
recorrida en sentido antihorario: el vehículo sube por la derecha, pasa por arriba
**del revés** y baja por la izquierda.

`ClimbGame` (FlameGame) usa esas dos funciones para colocar el vehículo y mueve la
cámara (`camera.viewfinder.position`), así que el loop se ve de verdad. La entrada
es `accelerating` / `braking` (botones que se mantienen pulsados; **el freno manda**
si se pulsan los dos) y la velocidad va de 0 a 210 px/s.

**Física del vehículo** (`_ClimbVehicle`): el coche **no está pegado al terreno**.

| Estado | Comportamiento |
|---|---|
| En el suelo | Sigue el terreno y el ángulo (suavizado, sin tirones) |
| Despegue | Si el terreno cae más de lo que permite la gravedad en un frame (`ClimbSpeed.shouldLeaveGround`), el vehículo queda en el aire: solo manda la gravedad |
| Aterrizaje | Al tocar el suelo: aplastamiento de la suspensión, polvo y temblor de cámara |

De ahí el ciclo "acelerar → despegar → volar → aterrizar" que hace que se sienta
como un juego de verdad. Los efectos son **ruedas que giran** (sprite aparte,
`cars/rueda.png`), **polvo** (`_ClimbDust`) y **zumbido de motor** en bucle
(`motor_loop.wav`, `BgmTrack.engine`).

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
Toque en pantalla (mitad izq/der)
  → MultiTouchTapDetector.onTapDown
    → RacingGame.steerLeft() / steerRight()
      → Car.steerTo(lane) → interpolación de 220 ms
        → AudioService.playSfx(SfxKind.swoosh)

Colisión con estrella
  → Car.onCollisionStart → Collectible.collect()
    → ProgressProvider.addStars(1) → guardado debounced
    → SFX ding + pop del contador

Colisión con obstáculo
  → Car.onCollisionStart → Obstacle.crush() + Car.stun(1 s)
    → el mundo se detiene 1 s (nunca hay "game over")
    → SFX crash (suave, no punitivo)

Cruce de meta
  → +3 estrellas, +1 vuelta, SFX unlock
```

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
| Relleno por *scanline flood fill* sobre la lámina | Botón que rellena un rectángulo predefinido | El niño colorea formas reales, no cajas. El coste (~10-40 ms) se paga solo al tocar. |
| Borrador que **parte** los trazos | Borrador con `BlendMode.clear` | `clear` borraría también la lámina o exigiría una capa aparte. Partir conserva el resto del dibujo. |
| `provider` | Riverpod / Bloc | Estado mínimo (progreso del niño). `provider` es suficiente y sin boilerplate. |
| `shared_preferences` | sqflite / drift | El progreso es un blob pequeño (int + listas de ids + trazos). SQLite sería overkill. |
| WAV 16-bit 22050 Hz | MP3/OGG | No hay encoder disponible offline; WAV lo soporta `audioplayers` en Android/iOS y pesa ~2,2 MB en total. |
| Generar PNG con `dart:ui` en `flutter test` | Figma / ilustración manual | Pipeline reproducible, versionable y sin licencias de terceros. |
| Un solo gesto para cambiar de carril | Swipes + botones | Un niño de 3 años no domina el swipe. Un toque en cualquier parte es infalible. |
| Flame solo para carreras | Flame para todo | El lienzo necesita control fino del gesto; Flame solo añadiría fricción. |
| Ancla del *viewfinder* en la esquina | Ancla por defecto (centro) | Flame 1.38 centra el mundo en el viewport: la pista quedaría desplazada y el coche saldría de pantalla. |
| Layout adaptable (`LayoutBuilder` + `FittedBox`) en las barras superiores | Tamaños fijos | En móviles de 320 dp las barras se desbordaban. El layout se adapta o se encoge, nunca se desborda. |
| `unawaited` para audio y orientación en `main()` | `await` | Ambas recursos pueden no responder nunca; esperarlos dejaría la app sin arrancar (criterio A9 del GDD). |

---

## 9. Estrategia de testing

| Nivel | Qué se prueba | Herramienta |
|---|---|---|
| **Unitario** | `Progress` (JSON), `ProgressService` (con `SharedPreferences.setMockInitialValues`), `ProgressProvider` (desbloqueos y progresión de niveles), `LevelCatalog` (10 niveles, ids únicos, ambientes únicos, pista válida), `TrackGenerator` (anti-bloqueo), `Car` (carriles, buffer, choque), `PageRaster` (flood fill) | `flutter_test` |
| **Widget** | `MenuScreen`: 3 tarjetas ≥ 60 dp, navegación a pintura, mapa y libro, sin desbordes. `LevelSelectScreen`: 10 tarjetas, candados, apertura del siguiente nivel, navegación. `SplashScreen`: título, arranque automático y salto con un toque. `RacingScreen`: juego a pantalla completa, ancla de la cámara, áreas táctiles, **controles visibles de dirección**, **parada del juego y de la música al salir**, pausa, panel de coches. `small_screen_test`: las 6 pantallas sin desbordes en un móvil de 320 × 640. `screen_capture_test`: cada pantalla se dibuja sin excepciones y se exporta a PNG | `flutter_test` |
| **Integración** | `flutter analyze` + `flutter test` + `flutter build apk` | CI local |
| **Assets** | Los WAV tienen señal real (pico y RMS dentro de rango) y los PNG se generan sin excepciones | `tool/asset_studio/test` |

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
