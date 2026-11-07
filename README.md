# Pincel & Carreras

Juego móvil 2D infantil (3-8 años) con **Flutter + Flame**. Dos modos de juego:

- **Estudio de pintura** — dibuja y colorea 9 láminas con pincel, bote de pintura (relleno por región) y borrador.
- **Carreras** — conducción top-down en 3 carriles con **acelerador que el niño mantiene pulsado**, **12 mundos**, **12 vehículos** (coches, moto, camión, bus, tractor, furgoneta, policía y ambulancia), flechas visibles en pantalla, HUD de velocidad y progreso y ambiente animado propio en cada mundo.

Además: un **taller** para pintar calcas y elegir pasajero, un **garaje** con 12 vehículos y un libro de pegatinas.

Cero texto en el flujo principal, cero anuncios, cero compras, cero red: **100 % offline**.

---

## 1. Requisitos

| Herramienta | Versión |
|---|---|
| Flutter | 3.44.x |
| Dart | 3.12.x (SDK `^3.12.2`) |
| Android Studio / Android SDK | API 21+ (para compilar APK) |
| Xcode | 15+ en macOS (para compilar iOS) |

Comprobar la instalación:

```bash
flutter --version
flutter doctor
```

---

## 2. Puesta en marcha

```bash
cd Game-PincelyCarreras
flutter pub get
flutter run
```

`flutter run` sin `-d` arranca en el dispositivo conectado. Opciones útiles:

```bash
flutter run -d chrome        # navegador (recomendado para revisión rápida)
flutter run -d windows       # escritorio Windows
flutter run --release        # modo release
```

---

## 3. Compilar

### Android

```bash
flutter build apk --debug        # APK de depuración  -> build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release      # APK de publicación
flutter build appbundle          # AAB para Google Play
flutter build apk --split-per-abi
```

### iOS

Requiere **macOS con Xcode**. En Windows no es posible (solo se valida el proyecto Xcode).

```bash
flutter build ios --debug          # build/ios/iphoneos
flutter build ios --release        # para distribución (firmado)
flutter build ipa --release        # IPA para TestFlight / App Store
```

### Web (opcional, solo para revisión)

```bash
flutter build web
flutter run -d web-server --web-port 8087
```

---

## 4. Cómo se juega

### Pantalla de inicio

Logo animado, sonido de bienvenida y una pista con un coche que se mueve: 2,4 segundos y
aparece el menú. Un toque la salta.

### Menú

Cuatro tarjetas grandes con icono: **Pintar**, **Carreras**, **Taller** y **Pegatinas**. Cada
tarjeta muestra un contador (láminas, niveles superados, pegatinas). En la esquina superior
derecha están el contador de estrellas, el **botón de sonido** y el **botón de ayuda (?)**.

### Estudio de pintura

| Acción | Resultado |
|---|---|
| Arrastrar el dedo | Pinta un trazo grueso del color seleccionado |
| Botón **bote** | Rellena por región toda la zona cerrada bajo el dedo |
| Botón **borrador** | Borra el trazo, **sin** damaging la lámina |
| Botón de color | Abre la paleta (16 colores; 4 se desbloquean con estrellas) |
| Botón de lámina | Cambia entre las 9 láminas (3 se desbloquean con estrellas) |
| Botón de papelera | Borra el dibujo (con confirmación) |

El dibujo se **guarda solo** cada 4 segundos y al salir de la pantalla. No hay tiempo
límite ni límite de trazos.

### Niveles

El botón **Carreras** abre el **mapa de mundos**: 12 tarjetas con el número, la pista de
fondo, el ambiente y el récord del niño. Los mundos se abren **en orden** al superar el
anterior; el siguiente lleva un botón de play. El botón con el vehículo (arriba a la
izquierda) abre el **garaje**.

| # | Mundo | Ambiente |
|---|---|---|
| 1-2 | Pradera · Playa | Pétalos · burbujas |
| 3-4 | Noche · Nieve | Luciérnagas · copos de nieve |
| 5-6 | Bosque · Ciudad | Hojas · chispas |
| 7-8 | Desierto · Selva | Arena · mariposas |
| 9-10 | Puerto · Volcán | Olas · brasas |
| 11-12 | Espacio · Estadio | Estrellas fugaces · confeti |

### Taller (tuning)

El botón **Taller** permite **pintar el carrito**: elegir una **calca** (rayas, estrella,
llama, corazón o número), su **color** (12 colores, se tiñe en el momento) y el
**personaje** que viaja con el niño (gato, perro, conejo o robot). Todo se ve en la pista.

### Carreras

| Acción | Resultado |
|---|---|
| **Mantener pulsado 🟢 Acelerar** | El coche acelera hasta la velocidad máxima del mundo |
| **Mantener pulsado 🔴 Frenar** | El coche frena con fuerza hasta pararse |
| **Soltar el acelerador** | El coche rueda y frena solo |
| **Flecha ⟵ / ⟶ en pantalla** | Cambia de carril (el niño ve dónde tocar) |
| **Arrastrar el dedo** | Mueve el coche de forma continua por toda la carretera |
| **Toque en la mitad izquierda / derecha** | También cambia de carril |
| **Botón de vehículo** (arriba izquierda) | Abre el **garaje**; el cambio se aplica **al instante** |
| **Botón de pausa** | Pausa la partida (toca la pantalla para seguir) |

- **El niño marca el ritmo**: la velocidad depende de si mantiene el acelerador pulsado.
  Suena un "vroom" (`motor.wav`) al arrancar desde parado.
- **HUD** arriba: número de velocidad, barra verde de velocidad y barra violeta de
  **progreso hacia la meta**.
- **Efectos**: polvo en las ruedas, **líneas de viento** que crecen con la velocidad y
  **chispas** al recoger una estrella.
- El vehículo **nunca se reinicia** al chocar: queda aturdido 1 s y continúa.
- Las **estrellas** se recogen al pasar por encima y suman al contador.
- Cada mundo **tiene final**: la meta cierra la carrera y aparece el resumen con las
  estrellas, el tiempo y el **récord** del niño.
- Cada carrera dura **más de un minuto** (65–78 s según el mundo; si choca o no acelera,
  más).
- El juego **no se ralentiza** con el tiempo de uso: los obstáculos, las estrellas y los
  banderines tienen topes (≤ 24, ≤ 20 y ≤ 6 vivos a la vez).
- La música de fondo cambia automáticamente según el modo y **se calla** al salir.

### Libro de pegatinas (trofeos)

Colección de **10 trofeos** que se desbloquean jugando (de 5 a 45 estrellas). Cada
pegatina dice **cuántas estrellas** necesitas y si ya la conseguiste.

### Ayuda

El botón **?** del menú y de las secciones explica con frases cortas **cómo se usa cada
parte** de la app, por si un niño (o su familia) tiene dudas.

---

## 5. Progreso y desbloqueos

El progreso se guarda **solo en local** con `shared_preferences`. No hay cuentas, ni nube,
ni analítica.

| Recurso | Se desbloquea con |
|---|---|
| Vehículo *Tortuga* | 5 estrellas |
| Pegatina *Estrella* | 5 estrellas |
| Vehículo *Sol* | 10 estrellas |
| Lámina *La casa* | 10 estrellas |
| Pegatina *Corazón* | 10 estrellas |
| Pegatina *Flecha* | 12 estrellas |
| Vehículo *Chispa* (moto) | 14 estrellas |
| Pegatina *Arcoíris* | 15 estrellas |
| Vehículo *Camión* | 18 estrellas |
| Pegatina *Globo* | 18 estrellas |
| Lámina *El dinosaurio* | 20 estrellas |
| Vehículo *Policía* | 22 estrellas |
| Pegatina *Corona* | 25 estrellas |
| Vehículo *Furgoneta* | 26 estrellas |
| Lámina *La ciudad* | 30 estrellas |
| Vehículo *Ambulancia* | 30 estrellas |
| Pegatina *Trofeo* | 30 estrellas |
| Vehículo *Tractor* | 34 estrellas |
| Pegatina *Medalla* | 35 estrellas |
| Vehículo *Bus escolar* | 38 estrellas |
| Pegatina *Cohete* | 40 estrellas |
| Vehículo *Cohete* (coche violeta) | 42 estrellas |
| Pegatina *Cometa* | 45 estrellas |

Además hay 4 colores de pintura extra (bronce, esmeralda, dorado y plata) que se
desbloquean con 10, 15, 20 y 30 estrellas.

Los **mundos** no usan estrellas: se abren uno detrás de otro al superarlos, así que
siempre hay un reto accesible aunque el niño no haya recogido ninguna estrella.

El progreso es **aditivo**: las estrellas nunca se pierden, y el niño nunca puede
"perder" un recurso ya desbloqueado.

---

## 6. Estructura del proyecto

```
Game-PincelyCarreras/
├── AGENTS.md                  # Reglas del repositorio (obligatorio leerlo)
├── docs/
│   ├── GDD.md                 # Diseño del juego: mecánicas, paleta, audio
│   ├── ARCHITECTURE.md        # Arquitectura implementada y decisiones
│   └── TEST_CHECKLIST.md      # Qué se ha verificado realmente
├── lib/
│   ├── main.dart              # Bootstrap: audio + provider + runApp
│   ├── app.dart               # MaterialApp, tema, rutas
│   ├── core/
│   │   ├── constants/         # palette.dart, game_sizes.dart, asset_paths.dart
│   │   └── theme.dart
│   ├── data/
│   │   ├── models/             # Objetos de dominio inmutables (Progress, LevelSpec, VehicleSpec, ...)
│   │   ├── providers/         # ProgressProvider (ChangeNotifier)
│   │   └── services/          # ProgressService, AudioService, AssetService
│   ├── game/                  # Lógica de juego (SIN material.dart)
│   │   ├── coloring/          # Lienzo, pincel, relleno por región (flood fill)
│   │   └── racing/            # RacingGame, RaceTiming, Car, LevelAmbience, VehicleTrail, ...
│   ├── ui/                    # Pantallas y widgets de Flutter
│   │   ├── screens/            # splash, menu, level_select, garage, studio, coloring, racing, sticker_book
│   │   └── widgets/            # MenuTile, BigButton, HelpButton, ColorPicker, ToolPicker, StarCounter
│   └── shared/                # Extensiones de BuildContext
├── assets/
│   ├── images/                # 75 PNG generados (cars, tracks, canvas, stickers, decals, characters, ui, ...)
│   └── audio/                 # 2 músicas + 8 SFX generados
├── tool/
│   ├── generate_audio.dart    # Sintetizador de la banda sonora
│   └── asset_studio/          # Generador de los PNG
└── test/                      # 16 ficheros, 122 casos de prueba
```

**Regla dura de arquitectura:** `lib/game/` **no** importa `flutter/material.dart` ni
`lib/ui/`. La capa de juego no sabe nada de widgets.

### Logotipo e iconos

La app tiene **logotipo propio**, generado por código (nunca descargado) y usado en:

| Plataforma | Ficheros |
|---|---|
| **Android** | `mipmap-*/ic_launcher.png` (5 densidades), `ic_launcher_round.png`, icono **adaptativo** (`ic_launcher.xml` + `ic_launcher_foreground.png` + `ic_launcher_monochrome.png` para los iconos con tema de Android 13+) y el logo en la pantalla de inicio |
| **iOS** | `AppIcon.appiconset` con los 15 tamaños que pide Xcode (de 20×20 a 1024×1024) y el logo en el *LaunchScreen* |
| **Web** | `favicon.png`, iconos de 192/512 y `manifest.json` |

El nombre visible en el menú de aplicaciones es **"Pincel & Carreras"** en Android, iOS y web.

Se regeneran con:

```bash
cd tool/asset_studio
flutter test test/generate_app_icons_test.dart
```

---

## 7. Generar los assets

Todos los assets son **generados por código**: no hay ficheros descargados ni
placeholders. Es reproducible y versionable.

### Gráficos (PNG)

```bash
cd tool/asset_studio
flutter pub get
flutter test        # escribe los PNG en assets/images/
```

### Audio (WAV)

```bash
dart run tool/generate_audio.dart    # escribe 2 músicas + 8 SFX en assets/audio/
```

Formato de salida: WAV PCM 16 bits mono a 22050 Hz, compatible con `audioplayers`.

> **Importante:** en `pubspec.yaml` hay que **declarar cada subcarpeta** de assets
> (`assets/images/cars/`, `assets/audio/sfx/`, ...). Flutter **no** incluye los
> subdirectorios de una carpeta declarada de forma recursiva.

---

## 8. Tests

```bash
flutter analyze        # debe salir: No issues found!
flutter test           # 122 casos
```

Cobertura actual:

| Fichero | Qué cubre |
|---|---|
| `test/game/car_test.dart` | Cambio de carril, colisiones, aturdimiento |
| `test/game/flood_fill_test.dart` | Relleno por región, regiones ya pintadas |
| `test/game/track_generator_test.dart` | Generación de obstáculos y estrellas |
| `test/game/race_timing_test.dart` | Modelo del acelerador y **cada mundo dura ≥ 1 minuto** |
| `test/models/progress_test.dart` | Cálculo de estrellas, récords y desbloqueos |
| `test/models/levels_test.dart` | 12 mundos, 12 vehículos y progresión |
| `test/services/progress_service_test.dart` | Persistencia en `shared_preferences` |
| `test/ui/menu_screen_test.dart` | Navegación del menú (4 secciones) |
| `test/ui/level_select_screen_test.dart` | Mapa de mundos y desbloqueos |
| `test/ui/garage_screen_test.dart` | Garaje: vehículos, candados y selección |
| `test/ui/studio_screen_test.dart` | Taller: calcas, colores y personajes |
| `test/ui/coloring_screen_test.dart` | **Cambio de lámina** (regresión del lienzo en blanco) |
| `test/ui/splash_screen_test.dart` | Pantalla de inicio y salto manual |
| `test/ui/racing_screen_test.dart` | Carreras: layout, cámara, flechas, **acelerador mantenido**, **HUD en vivo**, garaje, final, parada al salir |
| `test/ui/small_screen_test.dart` | Las pantallas sin desbordes en un móvil de 320 dp |
| `test/ui/screen_capture_test.dart` | Captura PNG de cada pantalla a `build/screenshots/` |
| `test/helpers/painting_fixture.dart` | Fixtures compartidos |

La checklist completa de verificación está en [`docs/TEST_CHECKLIST.md`](docs/TEST_CHECKLIST.md).

---

## 9. Reglas de diseño (resumen)

Todo el juego está diseñado para un niño de 3 a 8 años:

- **Cero fricción**: máximo 2 toques desde el menú para jugar. Sin onboarding.
- **Sin fracaso**: no hay Game Over, ni vidas, ni cronómetro, ni puntuación negativa.
  Si el niño choca, el juego se para 1 s y sigue.
- **Sin dinero**: sin anuncios, sin compras, sin suscripciones, sin enlaces externos.
- **Offline**: funciona al 100 % en modo avión. Ninguna llamada de red.
- **Botones ≥ 60x60 dp** (88x88 dp en el menú), áreas de toque generosas.
- **Feedback inmediato** en cada toque: visual (escala) + sonoro (SFX) en < 100 ms.
- **Vertical y horizontal**: ambas orientaciones están soportadas y adaptadas.
- **El juego es jugable en silencio**: el audio es un plus, nunca un requisito.

Las reglas completas están en [`AGENTS.md`](AGENTS.md) y [`docs/GDD.md`](docs/GDD.md).

---

## 10. Documentación

| Documento | Contenido |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Reglas del repositorio para cualquier agente |
| [`docs/GDD.md`](docs/GDD.md) | Game Design Document: mecánicas, desbloqueos, paleta, audio |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Arquitectura real, flujo de datos, decisiones descartadas |
| [`docs/TEST_CHECKLIST.md`](docs/TEST_CHECKLIST.md) | Qué se ha probado realmente y qué queda pendiente |
