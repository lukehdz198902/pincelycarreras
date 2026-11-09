# AGENTS.md — Pincel & Carreras

Reglas de trabajo para **cualquier agente** (humano o IA) que modifique este repositorio.
El juego es **infantil (3-8 años)**, **100 % offline**, construido con **Flutter + Flame**.

---

## 0. Idioma

- Toda la documentación (`docs/`, `README.md`, `AGENTS.md`) y todos los **textos visibles en pantalla**
  están en **español**.
- Los **identificadores técnicos** (clases, variables, funciones, claves de JSON, nombres de archivo)
  permanecen en **inglés**.
- Los **comentarios del código** están en español.
- En la UI del juego el texto es **opcional**: los niños de 3 años no leen. Se priorizan iconos.

---

## 1. Reglas de negocio inviolables (Child-Safe Design)

Estas reglas son **bloqueantes**. Ningún PR puede violarlas.

| Regla | Detalle |
|---|---|
| **Cero fricción** | Sin pantallas de carga, sin onboarding, sin tutoriales obligatorios, sin menús anidados. Máx. 2 toques para llegar a la acción. |
| **Sin fracaso** | Nunca hay "Game Over", cronómetro, vidas, puntuación negativa ni derrota. Si el niño choca, el juego se para 1 s y continúa. |
| **Sin dinero** | Cero anuncios, cero compras integradas, cero suscripciones, cero enlaces externos, cero seguimiento/analytics, cero red. |
| **Offline** | El juego debe funcionar al 100 % con el dispositivo en modo avión. Ninguna llamada HTTP, ni telemetry, ni notificaciones push. |
| **Persistencia local** | El progreso se guarda **solo** en `shared_preferences`. Nada de cuentas, nada de nube. |
| **Accesibilidad** | Todo botón táctil **≥ 60x60 dp** (objetivo 88x88 dp para el menú). Contraste alto. Compatible vertical y horizontal. |
| **Feedback inmediato** | Cada toque produce reacción **visual** (animación de escala) **y** **sonora** (SFX). Sin delay perceptible (< 100 ms). |
| **Táctil** | Controles que funcionen con el dedo, sin depender de precisión. Áreas de toque generosas. |

---

## 2. Stack y dependencias

- **Flutter** 3.44.x / **Dart** 3.12.x (SDK `^3.12.2`).
- **flame** `^1.38.2` → motor de juego (game loop, sprites, colisiones, tweens).
- **flame_audio** `^2.12.2` → música y SFX (envuelve `audioplayers`).
- **provider** `^6.1.5+1` → gestión de estado (`ChangeNotifier`).
- **shared_preferences** `^2.5.6` → persistencia local.
- **sensors_plus** `^7.1.1` → giroscopio (el "volante") y acelerómetro.
- **flutter_lints** `^6.0.0` → linting.

### Paquetes prohibidos / descartados

- ❌ **`flutter_painting_tools`** — abandonado, fija `sdk >=2.12.0 <3.0.0` y **no compila** con Dart 3.
  El lienzo de pintura se implementa con **`CustomPainter` propio** (`lib/game/coloring/`),
  lo que además permite un trazo grueso optimizado para manos de niños y un *bote de pintura*
  con relleno por flood-fill.
- ❌ Paquetes con red, publicidad, analítica o compras.

### Sensores

- **`sensors_plus`** es la **única** dependencia de hardware: da el giroscopio (el
  "volante") y, como respaldo, el acelerómetro.
- **Nunca** se asume que el sensor existe: el juego debe ser jugable sin él
  (arrastrando el coche con el dedo).
- Los sensores **no** se piden en `main()`: se empiezan al entrar en la pantalla de
  carreras y se paran al salir (mismo patrón que la música y el motor).
- En los tests hay que **simular los canales de plataforma**
  (`test/helpers/sensor_mock.dart`) o el test falla con `MissingPluginException`.

---

## 3. Estructura de carpetas

```
lib/
├── main.dart                 # Bootstrap: init de audio + provider + runApp
├── app.dart                  # MaterialApp, rutas, orientación, tema
├── core/
│   ├── constants/            # palette.dart, game_sizes.dart, asset_paths.dart
│   └── theme.dart            # Tema visual de la app
├── data/
│   ├── models/               # Objetos de dominio inmutables (Progress, LevelSpec, VehicleSpec, ...)
│   ├── providers/            # ProgressProvider (ChangeNotifier) y UnlockEvent
│   └── services/             # ProgressService (persistencia), AudioService, AssetService
├── game/                     # Lógica de juego (NO widgets de Flutter)
│   ├── coloring/             # paint_canvas.dart, brush.dart, flood_fill.dart
│   └── racing/               # racing_game.dart, race_timing.dart, car.dart, obstacle.dart,
│                             # collectible.dart, level_ambience.dart, track_generator.dart,
│                             # lane.dart, vehicle_trail.dart (efectos)
├── ui/                       # Menús y pantallas de Flutter (NO lógica de juego)
│   ├── screens/              # splash, menu, level_select, garage, studio, coloring, racing, sticker_book
│   └── widgets/              # MenuTile, BigButton, HelpButton, ColorPicker, ToolPicker, StarCounter
└── shared/                   # Utilidades transversales (context_extensions.dart)
```

Regla dura: **`game/` no importa `ui/` ni `flutter/material.dart`; `ui/` no contiene lógica de juego.**
La comunicación va por `services/`, por `providers/` y por callbacks.

`docs/` → `GDD.md`, `ARCHITECTURE.md`, `TEST_CHECKLIST.md`.
`assets/` → `images/`, `audio/` (generados por `tool/asset_studio/` y `tool/generate_audio.dart`).
`tool/` → generadores de assets (**fuera** de `lib/`, no forman parte de la app).

---

## 4. Convenciones de nomenclatura

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivos Dart | `snake_case.dart` | `racing_game.dart` |
| Clases | `PascalCase` | `RacingGame`, `Obstacle` |
| Widgets privados | `_MyWidget` | `_ColorPicker` |
| Funciones/métodos/vars | `camelCase` | `changeLane()`, `totalStars` |
| Constantes | `kConstante` en `core/constants` | `kMinButtonSize` |
| Enums | `PascalCase` | `ToolKind`, `GameMode` |
| Values de enum | `camelCase` | `brush`, `bucket` |
| Assets | `snake_case.png` / `snake_case.wav` | `car_rojo.png`, `painting_loop.wav` |
| Claves de `shared_preferences` | `snake_case` con prefijo de dominio | `progress_total_stars` |
| Tests | `*_test.dart`, describen comportamiento | `car_changes_lane_test.dart` |

---

## 5. Estilo de código Dart/Flutter

- `flutter_lints` activo (`analysis_options.yaml`). **Cero warnings ni errores de análisis.**
- `const` siempre que sea posible. `final` por defecto en variables locales.
- `prefer_single_quotes`, `always_declare_return_types`, `prefer_final_locals`.
- **Límite de longitud:** 80 columnas. Funciones ≤ 40 líneas. Clases ≤ 300 líneas.
- **Privacidad:** todo lo que no se use fuera de su archivo va con `_`.
- **Nombres en inglés, claridad sobre abreviaturas.** Nada de `x1`, `tmp2`, `dataArr`.
- **Documentación:** `///` en clases y métodos públicos. Comentarios `//` para el *por qué*.
- **Nada de `print` en producción.** Usar `debugPrint` con prefijo `[Pincel]`.
- **Errores:** no se tragan excepciones silenciosamente; se reportan con contexto y, cuando
  el juego debe continuar, se registra y se degrada de forma segura (el niño nunca ve un crash).
- **Comentarios de TODO** deben incluir la razón y el criterio de aceptación.

### Flame: buenas prácticas

- Un `Component` = una responsabilidad. Sin `Component` gigante.
- `update(dt)` solo con lógica, nunca con creación de objetos innecesarios.
- Colisiones con `HasCollisionDetection` + `CollisionCallbacks`.
- Tweeners para animaciones; nada de `Future.delayed` para lógica de juego (sí para UI no bloqueante).
- El `Game` no debe contener lógica de guardado: delega en `services/`.
- El modelo de velocidad de la pista vive en `lib/game/racing/race_timing.dart` (código puro):
  el mundo **siempre dura al menos un minuto** y la meta se calcula con esa función.
- **La velocidad la marca el niño**: `RacingGame.accelerating` / `RacingGame.braking` son
  flags que la UI escribe (el acelerador se **mantiene pulsado**). Si se cambia el modelo de
  velocidad, hay que cambiar **también** el control en pantalla: sin botón, el juego se
  queda parado y parece "lento".
- **Nada se acumula sin límite**: obstáculos, coleccionables y banderines tienen **topes**
  (`≤ 12 / ≤ 12 / ≤ 6`). Una escena que crece hace que el juego se ralentice con el uso.
- **El mundo del juego está girado 90°**: la pantalla de carreras usa un `RotatedBox` para
  que la pista se vea **en horizontal**. Por dentro `size.x` es la ALTURA de la pantalla y
  `size.y` su ANCHURA. La interfaz (barras, pedales, HUD) queda **fuera** del
  `RotatedBox`, para que se lea derecha.
- **La dirección es por sensor** (`TiltService`): no se gira el coche tocando la
  pantalla, porque cualquier toque (incluso la mano que sujeta el móvil) lo movía solo.

### Ciclo de vida (obligatorio)

Toda pantalla que abra un motor de juego o una pista de audio **debe parar ambos al salir**:

- `dispose()`: parar el motor (`halt()`) y la música (`AudioService.stopBgm()`).
- `WidgetsBindingObserver.didChangeAppLifecycleState`: pausar motor y música en
  `paused`/`inactive`/`hidden`; reanudarlos en `resumed`.
- La pausa manual pausa **motor y música** a la vez.

Motivo: sin esto el juego sigue corriendo (y sonando) en segundo plano. Es un bug
histórico de esta app y hay test de regresión (`test/ui/racing_screen_test.dart`).

---

## 6. Audio

- Música y SFX **deben** estar en `assets/audio/`.
- La música se reproduce en bucle (`loop`) y con volumen bajo (≤ 0.6) para no cansar.
- Los SFX son cortos (< 1.5 s) y **positivos**: nunca un sonido de error punitivo.
- **Nunca** superponer el mismo SFX más de 4 veces seguidas (cansancio auditivo): aplicar *cooldown*.
- El juego debe ser jugable en silencio: el audio es un plus, nunca un requisito.

---

## 7. Assets

- Todos los assets se **generan**, no se descargan ni se placeholdean.
- El generador vive en `tool/asset_studio/` y su salida va a `assets/`.
- Estilo visual obligatorio: **cartoon redondeado**, sin aristas, sombras suaves, contornos gruesos.
- Paleta: colores **vivos y contrastados**, verificados contra fondo claro y oscuro.
- Todo asset referenciado en el código debe **existir** en disco (fallo en build si no).

---

## 8. Flujo de trabajo obligatorio

1. Leer `docs/GDD.md` y `docs/ARCHITECTURE.md` **antes** de tocar código.
2. Planificar el cambio y declararlo antes de escribir archivos.
3. Implementar respetando la estructura y las convenciones de este documento.
4. **Verificar siempre antes de dar por terminado:**
   ```powershell
   flutter analyze
   flutter test
   flutter build apk --debug
   ```
5. Actualizar `docs/TEST_CHECKLIST.md` con lo realmente ejecutado (no lo planeado).
6. Responder **en español** con un resumen de archivos modificados.

---

## 9. Checklist de revisión (Definition of Done)

- [ ] `flutter analyze` sin issues.
- [ ] `flutter test` en verde.
- [ ] `flutter build apk --debug` genera APK.
- [ ] Cero texto que requiera lectura en el flujo principal.
- [ ] Botones ≥ 60x60 dp.
- [ ] Funciona en vertical **y** horizontal.
- [ ] Progreso persiste tras cerrar la app.
- [ ] Sin red, sin anuncios, sin compras.
- [ ] Sin `print`, sin TODOs sin resolver.
