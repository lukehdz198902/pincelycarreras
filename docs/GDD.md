# GDD — Pincel & Carreras

**Versión:** 1.0 · **Estado:** Aprobado para implementación · **Plataforma:** Android + iOS (Flutter)
**Target:** 3–8 años · **Idioma de la UI:** Español (iconos + voz visual, sin texto obligatorio)

---

## 1. Concepto en una frase

> **Un tablero de arte y un circuito de cars**, unidos en una sola app offline, donde el niño
> elige (sin leer) pintar un dibujo o conducir un coche que recoge estrellas.

El juego **no compite, no cronometra y no castiga**. Solo ofrece dos actividades relajadas
que producen un resultado visible: un dibujo coloreado y una colección de estrellas.

### 1.1 La decisión de diseño central

El público (3–8 años) tiene dos capacidades muy distintas:

- A los **3 años** no leen, no controlan movimientos continuos con precisión y se frustran
  con pantallas de carga o menús.
- A los **8 años** ya leen,Comparan progreso y quieren "su" coche y "sus" colores.

La solución es un **único selector de dos botones gigantes con icono** que no depende de la
lectura, y una **economía de desbloqueos** que da sensación de avance al niño mayor sin
exigir lectura.

---

## 2. Principios de diseño (reglas inviolables)

| # | Principio | Cómo se implementa |
|---|---|---|
| P1 | **Cero fricción** | Menú → actividad en **1 toque**. Sin login, sin tutorial, sin "loading". |
| P2 | **Cero fracaso** | Sin Game Over, sin vidas, sin cronómetro, sin puntuación negativa. Chocar = pausa 1 s. |
| P3 | **Feedback inmediato** | Cada toque → escala del botón (0.92×) + SFX (< 100 ms). Cada acción → sonido. |
| P4 | **Autonomía** | No hay texto que leer para jugar. Iconos ≥ 88 dp en menú, ≥ 60 dp en juego. |
| P5 | **Progreso visible** | Estrellas acumuladas + pegatinas desbloqueables como única "moneda". |
| P6 | **Offline y seguro** | Sin red, sin anuncios, sin compras, sin enlaces externos, sin datos personales. |
| P7 | **Sesión corta o larga** | Pintura: sin límite (el niño para cuando quiere). Carreras: 45–90 s por vuelta. |

---

## 3. Arquitectura de la experiencia (mapa de pantallas)

```
        ┌──────────────────────┐
        │  PANTALLA DE INICIO │  (SplashScreen)
        │  logo + sonido       │  2,4 s, saltable con un toque
        └───────────┬──────────┘
                    │
                    ▼
             ┌──────────────────────┐
             │      MENÚ INICIAL    │  (MenuScreen)
             │ [🖌 Pintar] [🚗 Carreras]│
             │ [🎨 Taller] [⭐ Pegatinas]│
             └───────┬──────┬───────┘
                     │      │
       ┌─────────────┘      └─────────────┐
       ▼                                   ▼
┌────────────────────┐            ┌────────────────────┐
│  ESTUDIO PINTURA   │            │  MAPA DE MUNDOS   │
│  (ColoringScreen)  │            │ (LevelSelectScreen)│
│  lienzo + brochas  │            │  12 tarjetas       │
└─────────┬──────────┘            └─────────┬──────────┘
          │                                  │
          │                                  ▼
          │                       ┌──────────────────┐
          │                       │  CARRERAS        │
          │                       │  (RacingScreen)  │
          │                       │  top-down        │
          │                       │  ⭠ ➡ + pedales   │
          │                       └────────┬─────────┘
          │                                │
          │                                ├──▶ ┌──────────────┐
          │                                │    │  GARAJE      │
          │                                │    │ (GarageScreen)│
          │                                │    │ 12 vehículos │
          │                                │    └──────────────┘
          │                                │
          │                                ├──▶ ┌──────────────┐
          │                                │    │  TALLER      │
          │                                │    │(StudioScreen)│
          │                                │    │calca+color+  │
          │                                │    │personaje     │
          │                                │    └──────────────┘
          │                                │
          │                                └──▶ ┌──────────────┐
          │                                     │  LIBRO DE    │
          ▼                                     │  PEGATINAS   │
   ┌────────────────────┐                       │(StickerBook) │
   │  LIBRO DE PEGATINAS│                       └──────────────┘
   │  ★★★★░░░░ → 4/10  │
   └────────────────────┘
```

> El modo "Subidas" se **eliminó** del producto: la energía del desarrollo está
> en **Carreras**, que es el modo con el que más juega el niño.

**Regla de navegación:** siempre hay un botón **ATRÁS** (icono) visible, ≥ 60 dp, en la esquina
superior. En horizontal, en la esquina superior derecha. Nunca se pierde el niño en la app.

---

## 4. MODO 1 — ESTUDIO DE PINTURA

### 4.1 Objetivo
Colorear una lámina prediseñada de contorno grueso, sin límites de tiempo ni de cantidad.

### 4.2 Láminas disponibles (6 libres + 3 desbloqueables)

| Lámina | Asset | Estado inicial |
|---|---|---|
| **Mi coche** | `canvas/pagina_coche.png` | Libre desde el inicio |
| **Animales** | `canvas/pagina_animales.png` | Libre desde el inicio |
| **Frutas** | `canvas/pagina_frutas.png` | Libre desde el inicio |
| **Verduras** | `canvas/pagina_verduras.png` | Libre desde el inicio |
| **El garaje** | `canvas/pagina_garaje.png` | Libre desde el inicio |
| **El paisaje** | `canvas/pagina_paisaje.png` | Libre desde el inicio |
| **La casa** | `canvas/pagina_casa.png` | Se desbloquea con 10 estrellas |
| **El dinosaurio** | `canvas/pagina_dinosaurio.png` | Se desbloquea con 20 estrellas |
| **La ciudad** | `canvas/pagina_ciudad.png` | Se desbloquea con 30 estrellas |

Todas las láminas son **contornos grises sobre fondo crema**, con **líneas gruesas
(≥ 10 px)** y formas redondeadas para que el trazo del niño no se escape por las esquinas.

Cada lámina es una **escena completa** (no un objeto suelto): coche de carreras con sol,
colinas, circuito y bandera a cuadros; prado con gato, perro, conejo, pájaro, pez, mariposa,
abeja, estanque y árbol; puesto de fruta con toldo, cesta y ocho frutas; mercado de verduras
con mantel a cuadros; taller con coche, moto, camión, bus y herramientas; valle con
dinosaurio, volcán y palmera; ciudad con edificios, farola, paso de cebra y coches.
Los elementos están repartidos en rejilla para que **nada se solape** y el niño pueda
colorear cada zona por separado.

### 4.3 Herramientas (4)

| Herramienta | Icono | Comportamiento | Cómodo para |
|---|---|---|---|
| **Pincel** | 🖌 | Trazo continuo de grosor variable (3 grosores: fino 12 px, medio 24 px, gordo 40 px). Interpolación de puntos para que no queden "saltos" al mover rápido el dedo. | Todo el mundo |
| **Bote** | 🫙 (bote de pintura) | Rellena la **región cerrada** que contiene el punto tocado (flood fill por escaneo de filas, tolerance 32). Si la zona ya es del mismo color, no hace nada (evita "parpadeo"). | Zonas grandes: cielo, suelo,车身 |
| **Borrador** | 🧽 | Borra el trazo (no pinta de blanco) usando el mismo ancho de pincel. Radio de borrado 32 px. | Corregir errores |
| **Paleta grande** | 🎨 | Botón que abre/cierra el **selector de color a pantalla completa** (no un popup pequeño: los dedos pequeños fallan con popups). | Elegir color |

> El paquete `flutter_painting_tools` queda **descartado** (abandonado, incompatible con
> Dart 3). El lienzo se implementa con `CustomPainter` + `GestureDetector` propios
> (`lib/game/coloring/`), lo que permite además el *bote de pintura* real y el trazo grueso.

### 4.4 Selector de color

- Rejilla de **círculos de 64 dp** (6 colores × 2 filas en vertical, 6 × 3 en horizontal).
- El color seleccionado se marca con un **anillo blanco + borde del color**, y además se
  muestra en un **muestrario grande (80 dp)** arriba a la izquierda.
- **12 colores base**, todos con contraste alto sobre cualquier lámina:
  `#FF4757 #FF922B #FFD32A #2ED573 #A3E635 #18DCF0 #4D8DFF #9C5CFF #FF6BD6 #B07344 #2B2D42 #FFFFFF`
- **4 colores desbloqueables**: bronce `#CD7F32` (10 ★), esmeralda `#00C853` (15 ★),
  dorado `#FFD700` (20 ★) y plata `#C0C8D0` (30 ★) — ver §5.7.
- Los colores bloqueados se muestran en **gris con un candado**, pero siguen siendo
  seleccionables si hay estrellas suficientes (el candado desaparece al desbloquear).

### 4.5 Feedback al pintar (obligatorio)

| Acción | Feedback visual | Feedback sonoro |
|---|---|---|
| Trazo del pincel | Estrellitas (3-5) nacen en la punta del pincel y se desvanecen en 500 ms | SFX `pop` (pitch aleatorio ±8 %) |
| Relleno del bote | Onda de color expansiva + 6 chispas | SFX `pop` grave + `ding` corto |
| Borrado | Recorte del trazo + 2 chispas grises | SFX `swoosh` corto |
| Cambio de color | El muestrario rebota (scale 1.2 → 1.0) | SFX `ui_tap` |
| Cambio de herramienta | El botón baja (scale 0.9) y sube con rebote | SFX `ui_tap` |

Las chispas/estrellitas se implementan como un overlay de partículas ligero (máx. 40 vivas)
para no penalizar el frame rate en dispositivos baratos.

### 4.6 Guardado del dibujo

- El lienzo se guarda automáticamente **cada 4 s** y al salir de la pantalla.
- Se guardan: la lista de trazos (serializada), la lámina activa y el color de fondo.
- Si el niño vuelve a la misma lámina, **su dibujo sigue ahí** (sin sobrescribir).
- Botón "borrar todo" (🗑) con **confirmación de 2 toques** (no con diálogo de texto):
  1.er toque → el icono se pone rojo y hace shake; 2.º toque → borra.
- Botón 🖼 "cambiar lámina" → rejilla de láminas con miniaturas.

### 4.7 Layout de la pantalla de pintura

```
┌──────────────────────────────────────────────┐
│ [ATRÁS]   [🖼]        [🗑]        [🎨 COLOR] │  ← barra superior (48 dp)
├──────────────────────────────────────────────┤
│                                              │
│              L I E N Z O                      │
│         (CustomPainter, se adapta            │
│          a la relación de aspecto)           │
│                                              │
├──────────────────────────────────────────────┤
│  [🖌 Pincel] [🫙 Bote] [🧽 Borrador]  (1.2x)│  ← barra de herramientas (72 dp)
│      ○ ○ ○   ← grosores (12/24/40 px)        │
└──────────────────────────────────────────────┘
```

- En **vertical**: barras arriba y abajo, lienzo en el centro (relación de aspecto 4:3).
- En **horizontal**: barra de herramientas a la **izquierda** (vertical), color a la derecha.

---

## 5. MODO 2 — CARRERAS

### 5.1 Objetivo
Conducir un coche por una pista **horizontal** mientras el niño **inclina el móvil
como si fuera un volante**. El niño marca el ritmo manteniendo pulsado el acelerador y
dirige girando el teléfono. La pantalla está **acostada**: la pista corre de izquierda a
derecha, como en un juego de carreras de verdad.

### 5.2 Controles (volante, pedales y arrastre)

#### 5.2.1 El volante (control principal)

| Gesto | Resultado | Feedback |
|---|---|---|
| **Girar el móvil** como un volante (en horizontal) | El coche se desplaza **de forma continua** por la carretera | El coche se inclina y la estela se desvía |
| **Dejar el volante quieto** | El coche vuelve **solo** al centro de la carretera | El volante vuelve al centro con suavidad |

- El móvil se sujeta **en horizontal**, con las dos manos, como un volante de coche.
- Se usa el **giroscopo**: mide el giro alrededor del eje normal de la pantalla, así que
  el gesto funciona **igual** sujetando el móvil a la izquierda o a la derecha (no hay que
  invertir nada).
- Si el dispositivo **no tiene giroscopio**, se usa el **acelerómetro** (inclinar el móvil
  hacia delante o atrás). Si no hay ningún sensor, el niño puede **arrastrar el coche con
  el dedo**.
- En pantalla aparece una chapa con el texto **"Inclina"** para recordar el gesto.

> **Por qué se quitó "tocar la pantalla para girar":** cualquier toque en la carretera
> (incluida la mano que sujeta el móvil) hacía girar el coche, y se iba solo hacia un
> lado. Ahora la pantalla **no** gira el coche: solo se mueve con el móvil o arrastrando.

#### 5.2.2 Pedales

| Control | Gesto | Resultado | Feedback |
|---|---|---|---|
| **Acelerar** 🟢 | **Mantener pulsado** (76 dp) | El coche acelera hasta la velocidad máxima del mundo (180 px/s × multiplicador) | SFX `motor` al arrancar + líneas de viento que crecen con la velocidad |
| **Frenar** 🔴 | **Mantener pulsado** (60 dp) | El coche frena con fuerza (420 px/s²) hasta pararse | Las líneas de viento se acortan |
| **Soltar** | Levantar el dedo | El coche **rueda y frena solo** (190 px/s²) | La estela se desvanece |

- Los pedales están **siempre visibles** en la parte inferior derecha: el niño ve dónde
  tiene que apretar, sin tener que adivinarlo.
- El botón de **acelerar** es más grande que el de frenar: es el que se usa.
- Ambos botones tienen etiqueta con `FittedBox`, así que **no desbordan** ni
  siquiera en un móvil pequeño.
- El sonido de motor (`sfx/motor.wav`) suena **solo al arrancar desde parado**
  (no en cada pulsación), para no cansar.

#### 5.2.3 HUD (marcador)

Una chapa flotante arriba, en el centro, con:

| Elemento | Significado |
|---|---|
| 🏎 **Número** | Velocidad actual en px/s (redondeada) |
| 🟢 **Barra verde** | Cuánto de la velocidad máxima lleva puesto |
| 🟣 **Barra violeta** | **Progreso hacia la meta** (0 → 1) |

- La chapa se repinta **en cada frame** y **se congela** cuando la carrera está en pausa
  o terminada.

### 5.3 Física y mundo

- Vista **cenital (top-down)**, con la pista **en horizontal**: el coche avanza hacia la
  **derecha** de la pantalla y el mundo se desplaza hacia la izquierda.
- La pantalla está **acostada**: el juego pide orientación horizontal al entrar y la
  recupera al salir. La interfaz (barras, pedales y HUD) queda siempre **derecha**.
- El **mundo del juego está girado 90°**: por dentro la pista baja (como antes) y la
  pantalla la gira. Así el cambio de vista no obliga a reescribir el motor.
- **3 carriles**, separados 120 px, centrados.
- El coche: esquinas redondeadas, con sombra elíptica suave; su tamaño depende del
  vehículo (una moto es estrecha, un bus es enorme).
- Obstáculos y estrellas aparecen **por la derecha** y se desplazan hacia la izquierda a
  la **misma velocidad que el scroll**, de modo que el niño los ve venir con tiempo para
  reaccionar.

#### 5.3.1 Modelo de velocidad (`RaceTiming`)

El modelo es **puro** (sin Flutter) y vive en `lib/game/racing/race_timing.dart`:

| Constante | Valor | Significado |
|---|---|---|
| `maxSpeed` | 180 px/s | Velocidad máxima del mundo (× `speedScale`) |
| `acceleration` | 260 px/s² | Cuánto gana el coche acelerando |
| `braking` | 420 px/s² | Cuánto pierde el coche frenando |
| `coasting` | 190 px/s² | Cuánto pierde el coche al soltar el acelerador |

- La velocidad **nunca cambia sola**: depende del dedo del niño.
- `distanceAfter(t)` da la distancia máxima recorrida en `t` segundos acelerando
  siempre; es la base para calcular la distancia de la meta.
- `timeForDistance(d)` es la inversa (bisección cerrada) y permite verificar en los
  tests que **ningún mundo dura menos de un minuto**.

### 5.4 Elementos de la pista

| Elemento | Asset | Comportamiento | Valor |
|---|---|---|---|
| **Estrella** ⭐ | `items/estrella.png` | Gira y brilla | +1 estrella |
| **Cono** 🔺 | `tracks/cono.png` | Impacto | Frenazo 1 s |
| **Charco** 💧 | `tracks/charco.png` | Impacto | Frenazo 1 s |
| **Roca** 🪨 | `tracks/roca.png` | Impacto | Frenazo 1 s |
| **Banderín** 🏁 | *dibujado por código* | Avisa de que el mundo sigue | +1 estrella |
| **Meta** 🏁 | *dibujada por código* | Al cruzarla: carrera completada | +3 estrellas + destello |

- La **meta y los banderines se dibujan en el mundo**, no como sprite: así son
  nítidos a cualquier tamaño (los PNG se veían pixeleados al estirarlos por toda
  la carretera) y el coche pasa **por encima** de ellos (`priority = -1`).
- **Los obstáculos son "amables"**: al chocar, el coche se **detiene 1 segundo**, hace un
  *shake* de 300 ms, aparece una nubecina de polvo y **el juego continúa**. No se pierde
  nada, no hay sonido de error, no hay Game Over.
- El cono se **desvanece** tras el impacto (se "aplastan" y desaparecen).

#### 5.4.1 Cuántos obstáculos hay (lo importante para un niño de 3 años)

| Regla | Valor | Por qué |
|---|---|---|
| **Un solo obstáculo** cada vez | 1 | Antes llegaban filas con **dos** obstáculos: la pista se llenaba |
| Separación entre obstáculos | **3,4 s** | Tiempo de sobra para verlos venir y apartarse |
| Separación entre estrellas | **2,2 s** | Siempre hay algo que recoger |
| Separación mínima entre un obstáculo y una estrella | **1,4 s** | **Nunca se empalman**: la estrella nunca aparece pegada al obstáculo |
| Carriles bloqueados por un obstáculo | **1 de 3** | **Siempre quedan dos carriles libres**: es imposible quedarse atrapado |
| El obstáculo no repite carril | sí | El niño tiene que moverse en cada obstáculo |

- El cono ocupa el **62 %** del ancho de su carril (antes el 72 %) y la estrella el 50 %:
  hay más sitio entre ellos y no se solapan.

### 5.5 Pistas (12 mundos)

| Pista | Nombre | Ambiente | Asset |
|---|---|---|---|
| 1 | **Pradera** | Hierba verde clara, flores | `tracks/track_pradera.png` |
| 2 | **Playa** | Arena y conchas | `tracks/track_playa.png` |
| 3 | **Noche** | Azul oscuro con estrellas | `tracks/track_noche.png` |
| 4 | **Nieve** | Nieve fresca y montones | `tracks/track_nieve.png` |
| 5 | **Bosque** | Hierba densa, hojas y setas | `tracks/track_bosque.png` |
| 6 | **Ciudad** | Baldosas, parterres y bancos | `tracks/track_ciudad.png` |
| 7 | **Desierto** | Dunas, cactus y ripples | `tracks/track_desierto.png` |
| 8 | **Selva** | Hojas grandes y lianas | `tracks/track_selva.png` |
| 9 | **Puerto** | Agua, olas y espigones | `tracks/track_puerto.png` |
| 10 | **Volcán** | Roca con grietas de lava | `tracks/track_volcan.png` |
| 11 | **Espacio** | Estrellas y nebulosas | `tracks/track_espacio.png` |
| 12 | **Estadio** | Césped a franjas y focos | `tracks/track_estadio.png` |

- La pista la elige el **mundo**: el niño no tiene que decidarla.
- Las pistas tienen tiles que se repiten verticalmente con **scroll infinito**.

### 5.5 bis Mundos (12)

Los mundos son la **progresión** del niño: 12 escenarios con ambiente y velocidad propios.
Se desbloquean **en orden** (el mundo N+1 se abre al superar el N) y **nunca se pierden**.

| # | Mundo | Pista | Ambiente animado | Velocidad | Duración |
|---|---|---|---|---|---|
| 1 | Pradera | Pradera | Pétalos que caen | 0,85× | 65 s |
| 2 | Playa | Playa | Burbujas que suben | 0,88× | 66 s |
| 3 | Noche | Noche | Luciérnagas que parpadean | 0,92× | 68 s |
| 4 | Nieve | Nieve | Copos de nieve | 0,95× | 68 s |
| 5 | Bosque | Bosque | Hojas de otoño | 0,98× | 70 s |
| 6 | Ciudad | Ciudad | Chispas que titilan | 1,00× | 70 s |
| 7 | Desierto | Desierto | Granos de arena | 1,02× | 72 s |
| 8 | Selva | Selva | Mariposas | 1,05× | 72 s |
| 9 | Puerto | Puerto | Olas | 1,07× | 74 s |
| 10 | Volcán | Volcán | Brasas | 1,10× | 74 s |
| 11 | Espacio | Espacio | Estrellas fugaces | 1,13× | 76 s |
| 12 | Estadio | Estadio | Confeti de fiesta | 1,16× | 78 s |

- **Mapa de mundos** (`LevelSelectScreen`): rejilla de tarjetas con el número, la pista de
  fondo, el nombre, el ambiente y el **record** del niño (`m:ss`). El mundo siguiente al
  último superado lleva un botón de **play** para que el niño sepa cuál tocar sin leer.
  Los bloqueados muestran un candado.
- El ambiente se dibuja con **primitivas** (sin assets nuevos): partículas propias de
  Flame que se reciclan al salir de pantalla.

### 5.5 ter El final de la carrera

Cada carrera **tiene final**: el recorrido es una distancia calculada a partir del modelo
de velocidad de `RaceTiming` (`distanceAfter`), suponiendo que el niño **acelera siempre**.

- La **meta** (bandera a cuadros) aparece al final del recorrido y **cierra la carrera**.
- Antes de la meta hay **banderines** intermedios: cada uno da estrellas y es un aviso de
  que el mundo sigue.
- **Cada mundo dura al menos un minuto**: la distancia de la meta se calcula con
  `RaceTiming.lapDistance()` para que el recorrido dure entre 65 y 78 segundos. Si el niño
  choca o no acelera, el mundo se para y la carrera dura **más**, nunca menos.
- Al cruzar la meta aparece el **resumen**: estrellas recogidas, tiempo de la carrera y
  mejor tiempo, con tres botones: **repetir**, **siguiente mundo** y **mapa**.
- El récord se guarda por mundo (`progress_best_times`) y **solo mejora**: nunca empeora.

### 5.6 Vehículos (12)

El garaje (`GarageScreen`) ofrece coches y **otros vehículos**. Cada uno tiene su **tamaño
en pista** (una moto es estrecha, un bus es enorme), su propio dibujo, **conductor visible**
y **calca**.

| # | Vehículo | Tipo | Color | Estado | Tamaño |
|---|---|---|---|---|---|
| 1 | **Furioso** | Coche | Rojo `#FF4757` | Inicial | 1,00× |
| 2 | **Rayo** | Coche | Azul `#4D8DFF` | Inicial | 1,00× |
| 3 | **Tortuga** | Coche | Verde `#2ED573` | 5 estrellas | 1,00× |
| 4 | **Sol** | Coche | Amarillo `#FFD32A` | 10 estrellas | 1,00× |
| 5 | **Chispa** | Moto | Amarillo | 14 estrellas | 0,55× ancho |
| 6 | **Camión** | Camión de bomberos | Rojo | 18 estrellas | 1,10× ancho |
| 7 | **Policía** | Coche patrulla | Azul | 22 estrellas | 1,00× |
| 8 | **Furgoneta** | Furgoneta | Violeta | 26 estrellas | 1,10× ancho |
| 9 | **Ambulancia** | Ambulancia | Blanco | 30 estrellas | 1,15× ancho |
| 10 | **Tractor** | Tractor | Naranja | 34 estrellas | 1,05× ancho |
| 11 | **Bus escolar** | Bus | Amarillo | 38 estrellas | 1,20× ancho |
| 12 | **Cohete** | Coche | Violeta `#9C5CFF` | 42 estrellas | 1,00× |

- El vehículo se elige en el **garaje**, accesible desde el mapa de mundos y desde la
  pantalla de carreras (el botón con el vehículo, arriba a la izquierda).
- **El cambio se aplica al instante**: el garaje devuelve el vehículo elegido y la carrera
  se reinicia con el nuevo, sin salir de la pantalla.
- Todos los vehículos están **libres para el niño que ya tiene estrellas**: el candado
  desaparece en cuanto hay suficientes.
- El tamaño en pista se calcula con `widthFactor` y `heightFactor`: un bus es 1,2× más
  ancho que un coche y una moto ocupa la mitad.
- **Personaje y calca**: los vehículos grandes llevan **conductor visible** (la cabeza con
  gorro asomando por la cabina) y una **calca de estrella** en la carrocería. El bus lleva
  además a los pasajeros asomados por las ventanas. Así ningún vehículo va "vacío".

### 5.6 bis Efectos de carrera (lo que emociona)

La carrera no es estática: hay **cuatro capas de efectos** que reaccionan a lo que hace
el niño.

| Efecto | Qué es | Cuándo aparece |
|---|---|---|
| **Estela** (`VehicleTrail`) | Nubecinas de polvo que salen de las ruedas | Siempre; crecen con la velocidad |
| **Líneas de viento** (`SpeedStreaks`) | Rayas blancas que pasan por los lados | Cuanto más rápido va el coche, **más largas y más nombreuses** |
| **Chispas** (`SparkField`) | Explosión de chispas de color | Al **recoger una estrella** |
| **Meta a cuadros** (`_TrackBanner`) | Línea de meta nítida, dibujada por código | Al final del recorrido |

- El **HUD** (§5.2.3) cierra el conjunto: el niño ve su velocidad y su progreso.
- Todos los efectos son **primitivas** dibujadas por código (cero assets nuevos) y
  **se reciclan** cuando mueren: no crecen sin límite.

### 5.9 Taller: pintar y tunear el carrito

Sección propia (icono de bote) donde el niño personaliza su vehículo:

| Opción | Detalle |
|---|---|
| **Calca** | Rayas, estrella, llama, corazón o número (5) |
| **Color de la calca** | Los 12 colores de la paleta (la calca se tiñe en tiempo real) |
| **Pasajero** | Gato, perro, conejo o robot (4 personajes) |
| **Vehículo** | Los 12 vehículos del garaje |

- La calca y el personaje se dibujan **encima del vehículo** dentro de la carrera
  (`_VehicleLivery`), así que el niño ve su customization en la pista.
- Las calcas se generan **en blanco** y se tiñen con un filtro `srcIn`: un solo asset
  sirve para los 12 colores.

### 5.10 Incentivos

- **Medalla por mundo**: bronce al llegar a la meta, plata dentro del tiempo previsto y
  oro si lo supera con un 15 % de margen. Se ve en el mapa de mundos y en el resumen.
- **Estrellas de regalo**: superar un mundo por primera vez da **+5 estrellas**.
- **Récord por mundo**: se guarda el mejor tiempo y **solo mejora**.
- **12 vehículos, 9 láminas, 10 pegatinas y 12 mundos** para seguir desbloqueando.
- **Ayuda en pantalla**: un botón **?** en el menú y en las secciones explica con frases
  cortas cómo se usa cada parte (para el niño y para su familia).

### 5.11 Recompensas por estrellas

| Estrellas | Recompensa |
|---|---|
| **5** | Coche "Tortuga" (verde) + pegatina ⭐ |
| **10** | Coche "Sol" (amarillo) + lámina extra "La casa" + pegatina ❤️ + color bronce `#CD7F32` |
| **12** | Pegatina ➡️ |
| **14** | Moto "Chispa" |
| **15** | Pegatina 🌈 + color esmeralda `#00C853` |
| **18** | Camión de bomberos + pegatina 🎈 |
| **20** | Lámina "El dinosaurio" + color dorado `#FFD700` |
| **22** | Coche "Policía" |
| **25** | Pegatina 👑 |
| **26** | Furgoneta |
| **30** | Ambulancia + lámina "La ciudad" + color plata `#C0C8D0` + pegatina 🏆 |
| **34** | Tractor |
| **35** | Pegatina 🥇 |
| **38** | Bus escolar |
| **40** | Pegatina 🚀 |
| **42** | Coche "Cohete" (violeta) |
| **45** | Pegatina ☄️ |

- El contador de estrellas **siempre visible** durante la carrera (esquina superior derecha,
  64 dp, con animación de pop al sumar).
- Al desbloquear algo: **animación de pegatina entrando + sonido `unlock`** y una tarjeta
  visual grande con el icono (sin texto obligatorio).

---

## 6. Arte y estilo visual

### 6.1 Dirección de arte

- **Estilo:** cartoon vectorial redondeado, sin aristas, contornos gruesos, sombras suaves.
- **Perspectiva:** cenital en carreras; frontal/ligeramente isométrica en las láminas.
- **Proporciones:** todo redondeado, "cabeza grande, cuerpo pequeño", ojos grandes.
- **Sombras:** elípticas y difusas (offset 4-8 px, alpha 18 %), nunca sombras duras.

### 6.2 Paleta maestra

| Rol | Color | Hex |
|---|---|---|
| Primario | Rojo vivo | `#FF4757` |
| Secundario | Azul | `#4D8DFF` |
| Acento cálido | Naranja | `#FF922B` |
| Acento luminoso | Amarillo | `#FFD32A` |
| Acento verde | Verde | `#2ED573` |
| Acento lima | Lima | `#A3E635` |
| Acento cian | Turquesa | `#18DCF0` |
| Acento violeta | Violeta | `#9C5CFF` |
| Acento rosa | Rosa | `#FF6BD6` |
| Tierra | Marrón | `#B07344` |
| Texto/oscuro | Azul noche | `#2B2D42` |
| Fondo app | Crema | `#FFF6E9` |
| Superficie | Blanco | `#FFFFFF` |

Contraste verificado: todos los botones usan **sombra de color** (no gris) y borde de
2-3 px, y el texto/icono sobre ellos mantiene ratio ≥ 4.5:1.

### 6.3 Inventario de assets (todo generado, sin placeholders)

| Grupo | Archivos |
|---|---|
| Coches (5) | `cars/car_rojo.png` `car_azul.png` `car_amarillo.png` `car_verde.png` `car_violeta.png` |
| Vehículos (7) | `cars/moto.png` `camion.png` `policia.png` `furgoneta.png` `ambulancia.png` `tractor.png` `bus.png` |
| Pistas (12 + mobiliario) | `tracks/track_pradera.png` `track_playa.png` `track_noche.png` `track_nieve.png` `track_bosque.png` `track_ciudad.png` `track_desierto.png` `track_selva.png` `track_puerto.png` `track_volcan.png` `track_espacio.png` `track_estadio.png` `bordillo.png` `banderin.png` |
| Asaltos y bordillos (8) | `tracks/asfalto.png` `asfalto_tierra.png` `asfalto_piedra.png` `asfalto_hielo.png` `bordillo.png` `bordillo_amarillo.png` `bordillo_piedra.png` `bordillo_hielo.png` |
| Obstáculos (3) | `tracks/cono.png` `tracks/charco.png` `tracks/roca.png` |
| Coleccionable | `items/estrella.png` |
| Láminas (9) | `canvas/pagina_coche.png` `pagina_animales.png` `pagina_frutas.png` `pagina_verduras.png` `pagina_garaje.png` `pagina_paisaje.png` `pagina_casa.png` `pagina_dinosaurio.png` `pagina_ciudad.png` |
| Pegatinas (10) | `stickers/pega_estrella.png` `pega_corazon.png` `pega_arcoiris.png` `pega_corona.png` `pega_flecha.png` `pega_globo.png` `pega_trofeo.png` `pega_medalla.png` `pega_cohete.png` `pega_cometa.png` |
| Calcas (5) | `decals/calca_rayas.png` `calca_estrella.png` `calca_llama.png` `calca_corazon.png` `calca_numero.png` |
| Personajes (4) | `characters/personaje_gato.png` `personaje_perro.png` `personaje_conejo.png` `personaje_robot.png` |
| Iconos UI (9) | `ui/icono_pincel.png` `icono_coche.png` `icono_play.png` `icono_pausa.png` `icono_atras.png` `icono_libro.png` `icono_bote.png` `icono_borrador.png` `icono_estrella.png` |
| Paleta | `palette/paleta.png` |

> La **meta y los banderines no son assets**: se dibujan en el mundo por código
> (`_TrackBanner`), así que no se pixelan al estirarse por la carretera.

**Regla:** cada archivo referenciado en el código debe existir. El build falla si falta.

---

## 7. Audio

| Archivo | Tipo | Descripción | Volumen |
|---|---|---|---|
| `music/painting_loop.wav` | Música | Loop alegre y relajado, 24 s, 100 BPM, acordes de I–V–vi–IV en Do mayor con pads suaves + campana de aceite + glockenspiel. Sin letra, sinpercusión agresiva. | 0.35 |
| `music/racing_loop.wav` | Música | Loop rítmico pero suave, 20 s, 120 BPM, bombo suave + bajo + arpegio tipo xilófono. Nunca estridente. | 0.30 |
| `sfx/pop.wav` | SFX | "Pop" de burbuja al pintar, 90 ms, seno con barrido ascendente. | 0.7 |
| `sfx/swoosh.wav` | SFX | "Swoosh" al cambiar de carril, 180 ms, ruido filtrado con barrido. | 0.6 |
| `sfx/ding.wav` | SFX | "Ding" al recoger estrella, 400 ms, dos parciales con decaimiento. | 0.8 |
| `sfx/crash.wav` | SFX | "Thud" suave de choque, 250 ms, **no punitivo** (sin disonancia). | 0.5 |
| `sfx/unlock.wav` | SFX | Arpegio ascendente al desbloquear, 700 ms. | 0.8 |
| `sfx/ui_tap.wav` | SFX | Toque suave de interfaz, 70 ms. | 0.6 |
| `sfx/welcome.wav` | SFX | Campanilla de bienvenida de la pantalla de inicio, 1,3 s, arpegio en Do mayor. | 0.7 |
| `sfx/motor.wav` | SFX | "Vroom" del motor: zumbido que **sube de tono** en 1,2 s, con un poco de ruido de admisión. Suena **al arrancar a acelerar desde parado**. | 0.6 |

**Reglas de audio**
- Todos son **positivos**. No existe ningún sonido de "error" o "derrota".
- La música **para** al entrar en una pantalla con su propia música y **cambia** al salir.
- Cooldown: el mismo SFX no puede sonar más de 4 veces en 1 s (evita saturación).
- El juego es **jugable en silencio**: el audio nunca es obligatorio ni bloqueante.

---

## 8. Accesibilidad y UX

- **Tamaño mínimo de botón:** 60 × 60 dp (mínimo absoluto), **88 × 88 dp** en el menú.
- **Separación mínima entre botones:** 16 dp.
- **Contraste:** ≥ 4.5:1 para iconos/cifras sobre su fondo.
- **Orientación:** soportada vertical y horizontal; el layout se reorganiza, no se escala.
- **Móviles estrechos (320 dp):** las barras superiores se adaptan en vez de
  desbordarse. La barra de carreras compacta miniaturas y contador; el título
  del menú se encoge (`FittedBox`); los grosores de pincel pasan a una segunda
  fila. Nunca hay contenido cortado ni scroll no previsto.
- **Doble toque accidental:** cada acción tiene *cooldown* de 250 ms para evitar
  dobles pulsaciones del menú.
- **Sin texto obligatorio:** el 100 % de las acciones tienen icono.
- **Respuesta háptica:** vibración corta (`HapticFeedback.lightImpact`) en cada botón.

---

## 9. Persistencia

Todo en `shared_preferences`, con prefijo de dominio:

| Clave | Tipo | Contenido |
|---|---|---|
| `progress_total_stars` | int | Estrellas acumuladas (nunca se pierden) |
| `progress_session_stars` | int | Estrellas de la última carrera (para mostrar "¡+3!") |
| `progress_unlocked_stickers` | List\<String\> | IDs de pegatinas desbloqueadas |
| `progress_unlocked_colors` | List\<String\> | IDs de colores desbloqueados |
| `progress_unlocked_cars` | List\<String\> | IDs de coches desbloqueados |
| `progress_unlocked_pages` | List\<String\> | IDs de láminas desbloqueadas |
| `progress_completed_levels` | List\<String\> | IDs de mundos superados |
| `progress_best_times` | String (JSON) | Mejor tiempo en segundos de cada mundo |
| `progress_selected_vehicle` | String | Vehículo elegido |
| `progress_selected_car` | String | (nombre histórico) Vehículo elegido |
| `progress_selected_track` | String | Pista elegida |
| `progress_selected_page` | String | Lámina activa del estudio |
| `progress_selected_level` | String | Nivel activo en el mapa |
| `progress_best_laps` | int | Vueltas completadas (nunca penaliza) |
| `drawing_page_<id>` | String | Trazos serializados de cada lámina |

- Guardado **desbounced** (500 ms) y también al pausar/salir de la app.
- **Nunca se pierde progreso**: las estrellas son acumulativas y solo suman.

---

## 10. Alcance

### Incluido (MVP)
- Pantalla de inicio animada con sonido, menú con tarjetas, estudio de pintura, mapa de
  mundos, garaje de vehículos, carreras y libro de pegatinas.
- 4 herramientas, 16 colores, 9 láminas, 12 vehículos, 12 mundos, 3 obstáculos, 10 pegatinas.
- **12 mundos** con ambiente animado propio, desbloqueo progresivo y **final de carrera**
  de más de un minuto por mundo.
- **Acelerador mantenido** (con freno) como control principal de las carreras, **HUD** de
  velocidad y progreso, y **efectos** (estela, líneas de viento, chispas, meta nítida).
- Persistencia local completa (estrellas, mundos, récords, vehículo y láminas).

### Fuera de alcance (explícito)
- ~~Multijugador~~ · ~~Tienda~~ · ~~Ads~~ · ~~Cuentas~~ · ~~Modo historia~~
  · ~~Personajes con voz~~ · ~~Dificultad punitiva (vidas, derrota, cronómetro)~~
  · ~~Modo "Subidas"~~ (eliminado: el esfuerzo está en Carreras)

### Mejoras futuras (arquitectura prepared)
- Láminas descargables (paquete de assets) · más pistas · Multi-touch para pintar con 2 dedos
  · Modo "dibujar con la mano" (soporte de Apple Pencil) · Exportar el dibujo como PNG para
  compartir a la familia.

---

## 11. Criterios de aceptación (verificables)

| # | Criterio | Cómo se verifica |
|---|---|---|
| A1 | Desde el menú se llega a pintura y a carreras en **1 toque** (carreras → mapa → nivel = 2 toques) | Test de widget + captura |
| A2 | El coche cambia de posición en ≤ 250 ms al girar el volante | Test de widget del `Car` |
| A3 | Un choque **no** termina la partida ni resta estrellas | Test de integración de la escena |
| A4 | Pintar genera ≥ 1 partícula y reproduce `pop` | Test de widget |
| A5 | Las estrellas persisten tras reiniciar la app | Test de `ProgressService` con `SharedPreferences.setMockInitialValues` |
| A6 | No existe ninguna llamada de red en el código | `grep` de `http`/`dart:io` en `lib/` + análisis |
| A7 | `flutter analyze` sin issues y `flutter test` en verde | CI local |
| A8 | Todos los botones ≥ 60 dp | Test de widget que recorre los widgets con `GestureDetector` |
| A9 | La app arranca sin `await` a un recurso que bloquee > 500 ms | Test de arranque |
| A10 | Funciona en vertical y horizontal sin overflow | Test de widget en ambas orientaciones |
| A11 | Al salir de una carrera **se detienen** el motor del juego y la música | Test de widget con `AudioService` falso |
| A12 | Hay 12 mundos con ambientes distintos y desbloqueo progresivo | Test de `LevelCatalog` + `ProgressProvider` |
| A13 | Los **pedales** están **visibles** en la pantalla de carreras | Test de widget (`accelerate` / `brake`) |
| A14 | Cada carrera dura **al menos un minuto** y **tiene final** (meta) | Test de `RaceTiming` + test de widget de la pantalla de carreras |
| A15 | El garaje ofrece coches, moto, camión, bus, tractor, furgoneta, policía y ambulancia | Test de widget del garaje + test del catálogo |
| A16 | El coche **solo avanza si el niño mantiene pulsado el acelerador** | Test de widget: sin pedal la velocidad no sube; con pedal sí |
| A17 | Cambiar de vehículo en el garaje se aplica **al instante**, sin salir de la carrera | Test de widget: abrir garaje → elegir → la carrera usa el nuevo |
| A18 | El juego **no se ralentiza** con el tiempo de uso (nada se acumula sin límite) | Topes de seguridad (≤12 obstáculos, ≤12 coleccionables, ≤6 banderines) |
| A19 | El HUD muestra **velocidad y progreso** en vivo | Test de widget + captura de pantalla |
| A20 | La pista se ve **en horizontal** y la pantalla **acostada** | Test de widget: el mundo del juego está girado 90° y el coche sale por la izquierda |
| A21 | El niño dirige **inclinando el móvil** (volante), sin tocar la pantalla | Test de widget con un `TiltService` falso |
| A22 | Hay **un solo obstáculo** cada 3,4 s y **nunca** se empalma con una estrella | Test de las constantes de espaciado + test del generador |

---

## 12. Métricas de sesión (objetivo, no instrumentadas por privacidad)

- Sesión típica: 6–12 min.
- Proporción esperada: 55 % pintura / 45 % carreras.
- Mayor punto de abandono: la primera vez que el niño elige carril (por eso el control es
  un único gesto que funciona en cualquier parte de la pantalla).

