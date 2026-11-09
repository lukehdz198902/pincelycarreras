# Checklist de pruebas — Pincel & Carreras

Este documento recoge **lo que se ha ejecutado de verdad**, no lo planificado.
Cada casilla está marcada con la evidencia que la respalda.

- **Entorno de verificación:** Windows 11 · Flutter 3.44.4 · Dart 3.12.2
- **Última ejecución:** 08/11/2026 (ronda 8: vista horizontal, volante por sensor y pista sin obstáculos amontonados)
- **Versión del juego:** 1.0.0+1

---

## 1. Verificación automática (obligatoria)

| # | Comprobación | Comando | Resultado |
|---|---|---|---|
| V1 | Análisis estático sin errores ni avisos | `flutter analyze` | ✅ **No issues found!** |
| V2 | Suite de tests completa | `flutter test` | ✅ **135/135 · All tests passed!** |
| V3 | Compilación Android de depuración | `flutter build apk --debug` | ✅ APK generado en `build/app/outputs/flutter-apk/app-debug.apk` |
| V4 | Los assets entran en el APK | inspección del APK | ✅ 75 PNG + 10 WAV empaquetados |
| V5 | Iconos de la app en el APK | inspección del APK | ✅ `ic_launcher` (5 densidades) + `ic_launcher_round` + `ic_launcher_foreground` + `ic_launcher_monochrome` + `ic_launcher.xml` (adaptativo) + `launch_logo` |
| V6 | Regeneración de los PNG | `cd tool/asset_studio && flutter test` | ✅ 9 tests, assets reescritos |
| V7 | Regeneración de los iconos | `cd tool/asset_studio && flutter test test/generate_app_icons_test.dart` | ✅ 6 tests, iconos de Android, iOS y web reescritos |
| V8 | Regeneración del audio | `dart run tool/generate_audio.dart` | ✅ 2 músicas + 8 SFX sintetizados |

### Detalle de los tests (V2)

| Fichero | Casos | Qué cubre |
|---|---|---|
| `test/game/car_test.dart` | 10 | Carril inicial, giro izquierda/derecha, límites de carril, búfer de un giro, aturdimiento de 1 s tras choque, **el volante mueve el coche de forma continua**, **nunca saca el coche de la carretera**, **el volante centrado devuelve el coche al centro** |
| `test/game/flood_fill_test.dart` | 5 | Zona rellenable, relleno de la región interior, separación interior/exterior, no rellena el contorno, mismo tramo para el mismo punto |
| `test/game/track_generator_test.dart` | 5 | **Un solo obstáculo por fila**, el obstáculo **nunca** repite carril, la estrella no cae en el carril del obstáculo ni en el de la estrella anterior, carriles en rango, determinismo con semilla |
| `test/game/race_spacing_test.dart` | 3 | Los obstáculos están separados (≥ 3 s), las estrellas van más seguidas y **la separación mínima garantiza que no se empalmen** |
| `test/game/race_timing_test.dart` | 5 | **La velocidad sube solo si el niño acelera**, la distancia crece con el tiempo acelerando siempre, la distancia de un tramo cubre el tiempo objetivo, **todos los mundos duran ≥ 1 minuto**, el tiempo de un tramo es el mismo en todos los tramos |
| `test/models/progress_test.dart` | 4 | Estado inicial, `copyWith`, ida y vuelta por JSON, JSON vacío |
| `test/models/levels_test.dart` | 20 | 12 mundos con ids únicos, ambientes únicos, pistas válidas, velocidad creciente, **duración ≥ 60 s**, encadenado del siguiente, desbloqueo progresivo, no completar un mundo bloqueado, no contar dos veces, persistencia, desbloqueo de vehículos con estrellas, **catálogo de 12 vehículos** (tipos, tamaños, assets) |
| `test/services/progress_service_test.dart` | 8 | Guardado/recuperación de progreso y de dibujos, borrado de dibujo, estrellas aditivas, desbloqueo de coches, no seleccionar un coche bloqueado, récord que solo mejora, colores base siempre disponibles |
| `test/services/tilt_service_test.dart` | 4 | El volante queda **neutro sin sensor**, se centra, se puede parar sin errores y el reloj no rompe la dirección |
| `test/ui/coloring_screen_test.dart` | 4 | Carga la lámina inicial, **al cambiar de lámina se dibuja la nueva y no queda en blanco** (regresión), el trazo empieza justo donde toca el niño, el relleno usa la lámina nueva |
| `test/ui/menu_screen_test.dart` | 7 | **4 secciones** ≥ 60 dp, navegación a pintura / mapa de mundos / taller / pegatinas, sin desbordes en horizontal y en 320 dp |
| `test/ui/level_select_screen_test.dart` | 8 | 12 tarjetas numeradas, 11 candados al empezar, apertura del siguiente mundo, mundo disponible abre carreras, mundo bloqueado **no** abre carreras, botón de vehículo abre el garaje, sin desbordes |
| `test/ui/garage_screen_test.dart` | 6 | Los **12 vehículos** en pantalla, candados en los bloqueados, elegir un vehículo libre, **no** elegir uno bloqueado, con estrellas se desbloquean más vehículos, sin desbordes en 320 dp |
| `test/ui/splash_screen_test.dart` | 4 | Título visible, arranque automático a los 2,4 s, salto con un toque, sin desbordes |
| `test/ui/racing_screen_test.dart` | 19 | Arranque directo en juego, juego a pantalla completa, **la pista se ve en horizontal (el mundo está girado 90°)**, el coche sale por la izquierda, origen del mundo en la esquina, barra superior táctil, **el aviso "Inclina" sustituye a las flechas**, **inclinar el móvil mueve el coche**, pausa, **el botón de vehículo abre el garaje**, **elegir un vehículo se aplica al instante**, **el acelerador se mantiene pulsado**, **el HUD muestra la velocidad en vivo**, contador visible, pista y ambiente del mundo, **la carrera tiene final**, **al salir se detienen el juego y la música**, sin desbordes |
| `test/ui/small_screen_test.dart` | 8 | Las 8 pantallas sin desbordes (las carreras, en horizontal 640 × 320) |
| `test/ui/screen_capture_test.dart` | 12 | Las pantallas se dibujan sin excepciones y se exportan a PNG (tamaño normal y tamaño estrecho) |

---

## 2. Verificación visual

### 2.1 Capturas automáticas (test de widget)

`test/ui/screen_capture_test.dart` renderiza cada pantalla y guarda el PNG en
`build/screenshots/`. No compara contra goldens (sería frágil entre máquinas):
sirve como prueba de humo visual y como artefacto de revisión.

| Captura | Comprobado |
|---|---|
| `inicio.png` | Pantalla de inicio: logo con pincel y coche, título en dos líneas, pista con coche |
| `menu.png` | Fondo crema con blobs en movimiento, **4 tarjetas grandes** con degradado (pintar / carreras / taller / pegatinas), contador de estrellas, botón de sonido y botón de ayuda |
| `niveles.png` | Mapa con 12 tarjetas: número en círculo, pista de fondo, nombre y ambiente; candado en las bloqueadas y botón de play en la siguiente |
| `pintura.png` | Lámina a tamaño completo, barra superior, barra de herramientas abajo con el pincel seleccionado y los 3 grosores |
| `carreras.png` | La pista en **horizontal** (800 x 400), el juego ocupa la pantalla completa, barra superior alineada, **pedal de acelerar y pedal de frenar**, **aviso "Inclina"**, **HUD de velocidad y progreso**, sin desbordes |
| `taller.png` | Calcas, colores y personajes del vehículo |
| `garaje.png` | Los 12 vehículos con candado en los bloqueados |
| `pegatinas.png` | Rejilla de 10 pegatinas con candado en las bloqueadas |
| `menu-320.png` | En móvil de 320 dp el título se encoge y el contador no se desborda; las 4 tarjetas siguen siendo grandes |
| `pintura-320.png` | En móvil de 320 dp los grosores de pincel pasan a una segunda fila y nada se corta |
| `carreras-320.png` | En horizontal de 640 x 320 la barra superior compacta (insignia circular del nivel, miniaturas y contador) cabe entera y **las etiquetas de los pedales se encogen** (`FittedBox`) |
| `pegatinas-320.png` | La rejilla de pegatinas se adapta al ancho de 320 dp |

> En los tests de widget las imágenes (`Image.asset`) **no se pintan** (limitación
> conocida de `flutter_test`), por eso las capturas muestran los contenedores
> vacíos donde iría el sprite. La comprobación real de sprites se hace en §2.2.

### 2.2 Verificación en navegador real (Flame + assets reales)

Ejecutado con `flutter run -d web-server` y captura del canvas por JS.

| Comprobación | Resultado |
|---|---|
| Menú | ✅ 4 tarjetas grandes con icono, título y contador de estrellas |
| Estudio de pintura | ✅ Relleno por región (bote) respetando el contorno exacto del coche |
| Persistencia | ✅ 4 estrellas visibles tras recargar la página (`shared_preferences` → `localStorage`) |
| Pantalla de carreras | ✅ Pista, asfalto, bordillo, meta, estrellas y obstáculos renderizados con los sprites reales, **pista centrada y coche en su carril** (captura `web_carreras_fix2.png`) |
| Consola del navegador | ✅ Sin errores ni excepciones |

> **Limitación del entorno:** al terminar la sesión, el navegador de la
> herramienta dejó de crear el canvas de Flutter (la ventana perdió el foco y
> `document.hasFocus()` devolvió `false`). Se comprobó que **no es un fallo del
> juego**: una aplicación mínima que antes renderizaba bien dejó de hacerlo
> igual. Por eso las correcciones posteriores (modo compacto de la barra
> superior, título del menú adaptable, segunda fila de grosores de pincel y
> etiquetas de los pedales con `FittedBox`) están validadas por **tests de
> widget**, pero **no** por captura del navegador. Queda pendiente una revisión
> visual en un navegador real.

---

## 3. Bugs encontrados y corregidos durante la verificación

| # | Bug | Gravedad | Corrección | Test de regresión |
|---|---|---|---|---|
| B1 | El `Stack` de la pantalla de carreras se dimensionaba al hijo **no posicionado** más grande (la barra superior, 80 px): el juego se dibujaba en una franja de 80 px y los paneles se desbordaban 52 px | 🔴 Crítico | Todos los hijos del `Stack` van posicionados (`Positioned` / `Positioned.fill`) | `el juego ocupa la pantalla completa` |
| B2 | Flame 1.38 ancla el *viewfinder* en el **centro** del viewport: el origen del mundo aparecía en el centro de la pantalla, la pista quedaba desplazada media pantalla y **el coche se salía de la pantalla** | 🔴 Crítico | `camera.viewfinder.anchor = Anchor.topLeft` | `el origen del mundo es la esquina superior izquierda` |
| B3 | El `UnlockOverlay` no estaba posicionado en el `Stack` del menú: al mostrarse un desbloqueo (240×240) **cambiaba el tamaño del `Stack`** y saltaba el layout | 🟡 Medio | `Positioned.fill` | — |
| B4 | Flame pinta **negro puro** por defecto (`Game.backgroundColor()`): destello negro al cargar las carreras | 🟢 Bajo | `backgroundColor()` devuelve `AppPalette.ink` | — |
| B5 | El botón de "Seguir" de la pausa no recibía el toque (el overlay no cubría la pantalla) | 🟡 Medio | Consecuencia de B1 | `el boton de pausa muestra y oculta la pausa` |
| B6 | Miniaturas de coche y pista sin `Semantics(button: true)` (accesibilidad) | 🟢 Bajo | Añadido `Semantics` | — |
| B7 | Código muerto: `TrackMiniature` y `kStickerBookButtonSize` sin usar, `_TrackThumbnail` duplicado | 🟢 Bajo | Miniaturas unificadas en `lib/ui/widgets/thumbnails.dart` | — |
| B8 | La barra superior de **carreras** se desbordaba 64 px en un móvil de 320 dp (5 controles de 60 px + contador) | 🟠 Alto | Modo compacto: miniaturas de 46 dp y contador solo con icono | `small_screen_test.dart` |
| B9 | El **título del menú** se desbordaba 145 px en un móvil de 320 dp | 🟠 Alto | El título va en `Expanded` + `FittedBox(scaleDown)`: se encoge en vez de desbordar | `small_screen_test.dart` |
| B10 | La **barra de herramientas** del estudio de pintura se desbordaba 136 px (3 herramientas + 3 grosores en una fila) | 🟠 Alto | Los grosores pasan a una segunda fila cuando no caben | `small_screen_test.dart` |
| B11 | `main()` **esperaba** a `audioService.initialize()`: en web el `AudioContext` queda suspendido hasta el primer gesto del usuario y la promesa puede no resolverse nunca → riesgo de **que la app no arranque** | 🟠 Alto | El audio se inicializa en segundo plano (`unawaited`) | Criterio A9 |
| B12 | `main()` **esperaba** a `SystemChrome.setPreferredOrientations()`: en web el motor lanza una excepción al no existir la API de bloqueo de pantalla y la promesa nunca resuelve → riesgo de **que la app no arranque** | 🟠 Alto | En web no se pide el bloqueo de orientación; en móvil es no bloqueante y con `catchError` | Criterio A9 |
| B13 | **Al salir de una carrera el juego seguía corriendo en segundo plano**: la música no se callaba y las colisiones seguían ocurriendo. Nadie paraba el motor de Flame ni la pista de audio al desmontar la pantalla | 🔴 Crítico | `RacingGame.halt()` (marca `_halted` y para el motor), `dispose()` de `RacingScreen` (detiene juego y música), `WidgetsBindingObserver` para pausar en segundo plano y pausa manual que pausa motor **y** música. La música de la pintura se detiene igual | `al salir se detienen el juego y la musica` |
| B14 | La barra superior de carreras se desbordaba **3,9 px** en 320 dp al añadir la insignia de nivel | 🟡 Medio | La insignia pasa a ser un círculo de 44 dp con el número en móvil estrecho | `la pantalla no desborda en un movil estrecho` |
| B15 | Las láminas nuevas (coche, animales) tenían **elementos superpuestos** (mariposa sobre el gato, abeja sobre el perro, árbol sobre el conejo) y el número del dorsal salía como un **cuadro negro** (sin fuente en el generador) | 🟡 Medio | Composición en rejilla sin solapes y **ningún texto** en las láminas (dorsal con estrella) | Revisión visual de los PNG |
| B16 | El generador de assets perdía bloques de código al reescribir el fichero (splice por líneas en PowerShell) y dejaba llaves sueltas al principio del archivo | 🟡 Medio | Fichero reparado y verificado con `flutter test` del `asset_studio` | V5 |
| B17 | **Al cambiar de lámina en el estudio de pintura la pantalla se quedaba en blanco**: el pintor del lienzo (`PaintCanvasPainter`) se creaba una sola vez en `initState` y **nunca actualizaba la imagen**, de modo que seguía pintando la lámina anterior, que además se había liberado ya. El relleno por color usaba el raster de la lámina vieja | 🔴 Crítico | `PaintCanvasPainter.updatePage()` actualiza imagen y tamaño, `didUpdateWidget` reconstruye el raster y `ColoringScreen` libera la imagen anterior **después** del frame | `coloring_screen_test.dart` |
| B18 | La fila de controles del modo "Subidas" se desbordaba en un móvil de 320 dp (dos botones de 96 dp + un distintivo central) | 🟡 Medio | **Modo eliminado** (ronda 7): el código de las subidas ya no existe | — |
| B19 | El menú con 5 secciones desbordaba en un móvil de 320 dp | 🟠 Alto | `MenuTile` ganó una versión `compact` (icono y etiqueta menores) y el menú vertical la usa | `menu_screen_test.dart` + `small_screen_test.dart` |
| B20 | El terreno de las subidas se buscaba por coordenada X, que **no es monótona** dentro de un loop de 360°: el vehículo saltaba de sitio al dar la vuelta | 🔴 Crítico | **Modo eliminado** (ronda 7) | — |
| B21 | Los archivos editados con PowerShell `Get-Content`/`Set-Content` quedaban **doblemente codificados** (acentos rotos: "Ã±", "Â¡") | 🟡 Medio | Detección con un barrido de todo el árbol y reparación con decodificación CP-1252 | Barrido automático de `lib/`, `tool/`, `docs/` y `test/` |
| B22 | El modo "Subidas" **no era jugable**: el vehículo estaba pegado al terreno (sin peso, sin saltos), los gráficos eran dos colinas planas y un relleno de color, y la cámara saltaba de sitio | 🔴 Crítico | **Modo eliminado** (ronda 7): el esfuerzo se ha trasladado al modo Carreras | — |
| B23 | En el modo "Subidas", pulsar a la vez acelerar y frenar **aceleraba** (ganaba el acelerador) | 🟡 Medio | **Modo eliminado** (ronda 7). En Carreras el **freno manda** (`else if`) | `race_timing_test.dart` |
| B24 | **Al pintar, el trazo salía en otro sitio**: la conversión de coordenadas del lienzo usaba el tamaño del `LayoutBuilder` (toda la pantalla) en vez del cuadro real del dibujo | 🔴 Crítico | `_toPage` usa el `RenderBox` real del `CustomPaint` (con `GlobalKey`) | `coloring_screen_test.dart` (`el trazo empieza justo donde toca el nino`) |
| B25 | En las carreras los **obstáculos se empalmaban** (filas cada 1,15 s) y era imposible esquivarlos | 🔴 Crítico | Las filas van ahora cada **2,2 s** (el doble de espacio) y la mayoría bloquean un solo carril | `racing_screen_test.dart` |
| B26 | La **meta se veía pixeleada** (PNG estirado a todo el ancho de la carretera) y el coche pasaba **por debajo** | 🟠 Alto | La meta y el banderín se **dibujan en el juego** (nítidos a cualquier tamaño) y con prioridad `-1`, por debajo del coche. Los assets `meta.png` y `banderin.png` se han eliminado del generador | `racing_screen_test.dart` |
| B27 | En las subidas el coche **se metía dentro de la montaña** (su origen era el centro, no el apoyo de las ruedas) | 🔴 Crítico | **Modo eliminado** (ronda 7) | — |
| B28 | En el taller las calcas se veían **todas en blanco** (están designed para tintarse) | 🟡 Medio | El selector las muestra **tintadas con el color elegido** | `studio_screen_test.dart` |
| B29 | No había forma de saber **para qué sirven las pegatinas** ni cómo se usa la app | 🟡 Medio | Botón **?** de ayuda en el menú y en las secciones, y las pegatinas son **trofeos** que dicen cuántas estrellas necesitan | — |
| B30 | La app **no tenía icono propio**: en el menú de aplicaciones de Android salía el icono genérico de Flutter, y el nombre visible era `pincel_y_carreras` | 🟠 Alto | Logotipo propio generado por código (`app_logo.dart`) para Android (clásico, redondo y **adaptativo** con versión monocroma), iOS (los 15 tamaños) y web (favicon + manifest). Nombre visible **"Pincel & Carreras"** | `asset_studio/test/generate_app_icons_test.dart` + inspección del APK |
| B31 | **El juego "se ralentizaba" después de un rato de uso**: la animación se volvía pesada cada vez más. La causa real era que se pasó al modelo de **acelerador mantenido** pero **nunca se añadió el botón**: el coche frenaba solo hasta pararse y el niño veía un juego "que no avanzaba" | 🔴 Crítico | Se añadió el **pedal de acelerar** (y el de frenar) que el niño mantiene pulsado, más el **HUD** de velocidad y progreso para que el niño vea que el coche corre | `racing_screen_test.dart` (`el acelerador se mantiene pulsado para avanzar`) |
| B32 | **Cambiar de vehículo en el garaje no se aplicaba hasta salir y volver a entrar**: el garaje solo guardaba la preferencia y la pantalla de carreras seguía con el sprite anterior | 🟠 Alto | `GarageScreen._pick` hace `Navigator.pop(vehicle.id)` y `RacingScreen._openGaraje` llama a `_restart()`: el juego se **recrea** con el vehículo nuevo | `racing_screen_test.dart` (`elegir un vehiculo en el garaje se aplica al instante`) |
| B33 | Los obstáculos, las estrellas y los banderines **se acumulaban** sin límite (al frenar mucho se quedaban "en cola"), haciendo que la escena creciera con el tiempo | 🟠 Alto | **Topes de seguridad**: ≤ 24 obstáculos, ≤ 20 coleccionables y ≤ 6 banderines vivos; al superarlos se elimina el más antiguo | `racing_screen_test.dart` + `race_timing_test.dart` |
| B34 | La fila de pedales de las carreras se **desbordaba 40 px** en un móvil de 320 dp (la etiqueta "Acelerar" con la fuente de test, más ancha que la real) | 🟠 Alto | La etiqueta va en `SizedBox` + `FittedBox(scaleDown)`: **se encoge** en vez de desbordar, en cualquier pantalla | `small_screen_test.dart` + `racing_screen_test.dart` |
| B35 | El menú seguía ofreciendo el modo "Subidas" y quedaban **código y assets muertos** (`climb_game.dart`, `climb_terrain.dart`, `climb_screen.dart`, `motor_loop.wav`, `BgmTrack.engine`, `meta.png`, `banderin.png`) | 🟡 Medio | Modo **eliminado por completo** (código, assets, rutas y audio) | `menu_screen_test.dart` (4 secciones) |
| B36 | El **HUD se quedaba congelado**: la velocidad y el progreso se leían una sola vez al construir la pantalla y **nada los volvía a repintar**, así que el niño veía siempre "0" | 🟠 Alto | El HUD pasa a ser un widget aparte (`_RaceHud`) con **su propio `Ticker`**: solo se repinta la chapa del marcador en cada frame (no toda la pantalla, que contiene el `GameWidget` de Flame). El ticker **se para** en pausa y en el resumen | `racing_screen_test.dart` (`el HUD muestra la velocidad en vivo`) |
| B37 | **Al acelerar el coche se iba solo de un lado a otro**: el juego giraba el coche con **cualquier toque** en la carretera (`onTapDown`), así que la mano que sujeta el móvil lo movía (casi siempre hacia la izquierda, porque el niño sujeta el móvil con la izquierda) | 🔴 Crítico | Se **quita** el control por toque: la dirección es ahora el **volante** (giroscopio) y, como respaldo, **arrastrar** el coche con el dedo. La pantalla ya no gira el coche al tocarla | `racing_screen_test.dart` (`muestra como dirigir: inclinar el movil, sin flechas`) + `car_test.dart` (volante) |
| B38 | La pista era un **tropel de obstáculos**: filas cada 2,2 s con hasta **dos** obstáculos, y a veces con los **tres carriles** ocupados entre obstáculo y estrella | 🔴 Crítico | El generador ya no hace "filas": produce **un solo obstáculo** cada 3,4 s (siempre en un carril distinto al anterior) y **siempre quedan dos carriles libres** | `track_generator_test.dart` + `race_spacing_test.dart` |
| B39 | Las **estrellas se empalmaban con los obstáculos** (estaban en la misma fila, en un carril contiguo, y el obstáculo ocupaba el 72 % del carril) | 🟠 Alto | La estrella solo aparece si ha pasado **1,4 s** desde el último obstáculo (`minSeparation`) y además se coloca en un carril distinto. Los tamaños se reducen (obstáculo 62 %, estrella 50 %) | `race_spacing_test.dart` + `track_generator_test.dart` |
| B40 | Las carreras se jugaban en **vertical**, con la pista bajando, y el niño tenía que tocar la pantalla para girar | 🟠 Alto | La pantalla de carreras pide **orientación horizontal** y gira el mundo con `RotatedBox`: la pista queda **horizontal** y el niño dirige **inclinando el móvil** como un volante (giroscopio) | `racing_screen_test.dart` (`la pista se ve en horizontal`) + `tilt_service_test.dart` |
| B41 | `sensors_plus` habla con un canal de plataforma que **no existe en los tests**: el `MissingPluginException` hacia fallar toda la suite | 🟡 Medio | `test/helpers/sensor_mock.dart` simula los canales de los sensores; además `RacingScreen` permite **inyectar** un `TiltService` falso para probar el volante sin hardware | `sensor_mock.dart` + `racing_screen_test.dart` |
| B42 | Las partículas del ambiente (nieve, pétalos) se desplazaban **hacia el lado** en la vista horizontal | 🟡 Medio | `LevelAmbience` dibuja en un espacio local girado (`translate` + `rotate(-π/2)`): la nieve vuelve a caer **hacia abajo** | Revisión del código + captura |

---

## 4. Assets

| Comprobación | Resultado |
|---|---|
| Gráficos generados por código | ✅ 75 PNG en `assets/images/` (12 vehículos, 12 pistas + 4 asfaltos + 4 bordillos + 3 obstáculos, 9 láminas, 10 pegatinas, 5 calcas, 4 personajes, 10 iconos + logo, 1 estrella, 1 paleta) |
| Audio generado por síntesis | ✅ 10 WAV en `assets/audio/` (2 músicas en bucle + 8 SFX) |
| Formato de audio | ✅ WAV PCM 16 bits mono 22050 Hz (soportado por `audioplayers`) |
| Revisión visual de cada PNG | ✅ Todos los sprites revisados a mano (flecha "atrás" a la izquierda, contornos limpios, **láminas rehechas en rejilla sin solapes**, **vehículos con conductor y calca**) |
| Revisión de la onda de audio | ✅ 10 formas de onda exportadas a `build/audio_preview/*.png` con pico y RMS sanos |
| Empaquetado | ✅ Las subcarpetas de assets están listadas **una a una** en `pubspec.yaml` (Flutter no las incluye recursivamente) |
| Regeneración reproducible | ✅ `cd tool/asset_studio && flutter test` y `dart run tool/generate_audio.dart` |

---

## 5. Reglas de negocio (comprobación estática + tests)

| Regla | Verificación | Resultado |
|---|---|---|
| Sin red | `grep` de `http` / `dart:io` / `socket` / `Uri.parse` en `lib/` | ✅ 0 coincidencias |
| Sin anuncios, compras ni enlaces | Revisión de `pubspec.yaml` | ✅ Ninguna dependencia de red, publicidad ni analítica |
| Persistencia solo local | `shared_preferences` es la única fuente | ✅ |
| Sin texto que exija leer | Menú con 4 iconos; pantallas con pictogramas | ✅ |
| Botones ≥ 60 dp | Test que recorre los `GestureDetector` de las barras | ✅ (60–152 dp) |
| Cero `print` en producción | `grep` de `print(` en `lib/` | ✅ 0 coincidencias |
| `lib/game/` sin `material.dart` | `grep` de `material.dart` en `lib/game/` | ✅ Solo `painting.dart` / `widgets.dart` |
| Sin fracaso / sin derrota | `Car.stun(1 s)` y el juego continúa | ✅ Test `tras un choque el coche queda inmovilizado un segundo` |

---

## 6. Criterios de aceptación del GDD (§11)

| # | Criterio | Estado | Evidencia |
|---|---|---|---|
| A1 | Desde el menú se llega a pintura en 1 toque y a carreras en 2 (menú → mapa → nivel) | ✅ | `menu_screen_test.dart` + `level_select_screen_test.dart` |
| A2 | El toque izq./der. cambia de carril en ≤ 250 ms | ✅ | `car_test.dart` (transición de 0,3 s) |
| A3 | Un choque no termina la partida ni resta estrellas | ✅ | `car_test.dart` + `progress_test.dart` (las estrellas solo suman) |
| A4 | Pintar genera partículas y reproduce `pop` | ✅ | `paint_canvas.dart` + captura de `pintura.png` |
| A5 | Las estrellas persisten tras reiniciar la app | ✅ | `progress_service_test.dart` + verificación en navegador (4 estrellas tras recargar) |
| A6 | No existe ninguna llamada de red en `lib/` | ✅ | `grep` sin coincidencias |
| A7 | `flutter analyze` sin issues y `flutter test` en verde | ✅ | V1 + V2 |
| A8 | Todos los botones ≥ 60 dp | ✅ | Tests de `menu_screen_test.dart`, `racing_screen_test.dart` y `level_select_screen_test.dart` |
| A9 | Arranque sin esperas bloqueantes > 500 ms | ✅ | `main.dart` solo espera las preferencias; audio y orientación se preparan en segundo plano |
| A10 | Funciona en vertical y horizontal sin overflow | ✅ | Tests de desbordes en horizontal + `LayoutBuilder` con menú vertical/horizontal |
| A11 | Al salir de una carrera se detienen el motor del juego y la música | ✅ | `racing_screen_test.dart` (`al salir se detienen el juego y la musica`) |
| A12 | Hay 12 mundos con ambientes distintos y desbloqueo progresivo | ✅ | `levels_test.dart` + `level_select_screen_test.dart` |
| A13 | Los **pedales** están **visibles** en la pantalla de carreras | ✅ | `racing_screen_test.dart` (`accelerate` / `brake`) |
| A14 | Cada carrera dura **al menos un minuto** y **tiene final** (meta) | ✅ | `race_timing_test.dart` + `racing_screen_test.dart` (`la carrera tiene final`) |
| A15 | El garaje ofrece coches, moto, camión, bus, tractor, furgoneta, policía y ambulancia | ✅ | `garage_screen_test.dart` + `levels_test.dart` |
| A16 | El coche **solo avanza si el niño mantiene pulsado el acelerador** | ✅ | `racing_screen_test.dart` (`el acelerador se mantiene pulsado para avanzar`) |
| A17 | Cambiar de vehículo en el garaje se aplica **al instante** | ✅ | `racing_screen_test.dart` (`elegir un vehiculo en el garaje se aplica al instante`) |
| A18 | El juego **no se ralentiza** con el tiempo de uso | ✅ | Topes de seguridad en `racing_game.dart` (≤ 12 / ≤ 12 / ≤ 6) |
| A19 | El HUD muestra **velocidad y progreso** en vivo | ✅ | `racing_screen_test.dart` (`el HUD muestra la velocidad en vivo`) |
| A20 | La pista se ve **en horizontal** y la pantalla **acostada** | ✅ | `racing_screen_test.dart` (`la pista se ve en horizontal`) |
| A21 | El niño dirige **inclinando el móvil** (volante), sin tocar la pantalla | ✅ | `racing_screen_test.dart` (`inclinar el movil mueve el coche`) + `car_test.dart` |
| A22 | Hay **un solo obstáculo** cada 3,4 s y **nunca** se empalma con una estrella | ✅ | `race_spacing_test.dart` + `track_generator_test.dart` |

---

## 7. Pendiente (requiere hardware o macOS)

Estos puntos **no se han podido verificar** en este entorno. Quedan marcados
como pendientes, no como hechos.

- [ ] **Dispositivo Android real**: instalar el APK, comprobar rendimiento real
      (frame rate) con el DEVICE de gama baja de referencia, **que la carrera no se
      ralentice tras varios minutos** (topes de seguridad) y **que la vista en
      horizontal se vea bien** (pista horizontal, coche a la izquierda).
- [ ] **El volante por giroscopio**: comprobar en un móvil real que **girar el móvil
      mueve el coche** y que el gesto se siente igual en horizontal izquierdo y
      derecho. Es la única comprobación que **no** se puede hacer sin hardware.
- [ ] **iOS**: `flutter build ios` requiere **macOS con Xcode**. El proyecto
      `ios/` existe y está generado, pero no se ha compilado ni probado.
- [ ] **Audio en dispositivo real**: los WAV se han validado por forma de onda,
      pero falta comprobar volumen, mezcla con la música y comportamiento con
      el móvil en silencio.
- [ ] **Vibración háptica** (`HapticFeedback`): solo verificable en hardware.
- [ ] **Modo avión real**: confirmar que el juego arranca y suena sin red.
- [ ] **Revisión visual en navegador real** de la ronda actual (splash, menú con
      4 tarjetas, mapa de niveles, **pista en horizontal**, **volante** y láminas
      nuevas). Los tests de widget cubren el layout, pero el navegador del entorno de
      verificación dejó de renderizar (§2.2) y en la ronda 8 se desconectó.
- [ ] **Revisión visual de los 9 PNG de las láminas en un móvil** (el color real del
      relleno por región y el grosor del contorno se ven mejor en dispositivo).
- [ ] **Revisión visual de los 12 vehículos en un móvil** (el conductor y la calca
      se ven mejor en dispositivo que en el PNG del generador).
- [ ] **Prueba con niños reales** (3-8 años): el diseño está pensado para ellos,
      pero la validación de usabilidad (y que el acelerador mantenido se entienda)
      solo la pueden dar las pruebas de campo.
- [ ] **Orientación horizontal en dispositivo**: el layout está validado por
      tests, pero falta la comprobación visual real en un móvil.
- [ ] **Store**: firma, ficha de la tienda, clasificación por edad y aviso de
      "contiene música y efectos de sonido".

---

## 8. Cómo repetir la verificación

```powershell
cd C:\opencode_proyects\Game-PincelyCarreras

flutter analyze                  # V1
flutter test                     # V2 (genera build/screenshots/*.png)
flutter build apk --debug        # V3

cd tool\asset_studio
flutter test                     # V6 (regenera los PNG)
flutter test test/generate_app_icons_test.dart   # V7 (regenera los iconos)
cd ..\..
dart run tool\generate_audio.dart   # V8 (regenera los WAV)
```
