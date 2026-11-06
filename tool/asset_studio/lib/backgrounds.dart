// Generadores de fondos: pistas de carreras y laminas para colorear.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'studio.dart';

/// Dibuja un elemento que se repite en los bordes (tileable).
void drawWrapped(
  Canvas canvas,
  ui.Size size,
  void Function(Offset position) draw, {
  double wrapX = 0,
  double wrapY = 0,
}) {
  final offsets = <Offset>[Offset.zero];
  if (wrapX > 0) {
    offsets.add(Offset(wrapX, 0));
    offsets.add(Offset(-wrapX, 0));
  }
  if (wrapY > 0) {
    offsets.add(Offset(0, wrapY));
    offsets.add(Offset(0, -wrapY));
  }
  for (final offset in offsets) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (final position in _gridPositions(size)) {
      draw(position);
    }
    canvas.restore();
  }
}

List<Offset> _gridPositions(ui.Size size) => [
      for (var y = 0.0; y < size.height; y += 64)
        for (var x = 0.0; x < size.width; x += 64) Offset(x, y),
    ];

/// Cesped de la pista "Pradera" (tileable).
void drawGrass(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF7BC96F)));

  final random = math.Random(20240517);
  for (var i = 0; i < 120; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final length = 6 + random.nextDouble() * 8;
    final color = random.nextBool()
        ? const Color(0xFF6BB85F)
        : const Color(0xFF8FD77D);
    canvas.drawLine(
      Offset(x, y),
      Offset(x + (random.nextDouble() - 0.5) * 4, y - length),
      stroke(color, 3),
    );
  }

  // Flores pequenas.
  for (var i = 0; i < 14; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final petal = random.nextBool()
        ? const Color(0xFFFFF0A8)
        : const Color(0xFFFFD1E8);
    for (var p = 0; p < 5; p++) {
      final angle = p / 5 * 2 * math.pi;
      canvas.drawCircle(
        Offset(x + math.cos(angle) * 4, y + math.sin(angle) * 4),
        3,
        fill(petal),
      );
    }
    canvas.drawCircle(Offset(x, y), 2.4, fill(StudioPalette.orange));
  }
}

/// Arena de la pista "Playa" (tileable).
void drawSand(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFFF3D9A4)));

  final random = math.Random(19880712);
  for (var i = 0; i < 160; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final color = random.nextBool()
        ? const Color(0xFFE7C88C)
        : const Color(0xFFFAE7BE);
    canvas.drawCircle(Offset(x, y), 2 + random.nextDouble() * 2.5, fill(color));
  }

  // Conchas.
  for (var i = 0; i < 6; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final shell = Path()
      ..moveTo(x - 10, y)
      ..quadraticBezierTo(x, y - 14, x + 10, y)
      ..quadraticBezierTo(x, y + 8, x - 10, y)
      ..close();
    canvas.drawPath(shell, fill(const Color(0xFFFFB6C1)));
    canvas.drawPath(shell, stroke(const Color(0xFFE8879A), 2));
  }
}

/// Noche estrellada de la pista "Noche" (tileable).
void drawNight(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF1B2445)));

  // Degradado sutil.
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x332A3A6B), Color(0x001B2445)],
      ).createShader(Offset.zero & size),
  );

  final random = math.Random(31415926);
  for (var i = 0; i < 90; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 1 + random.nextDouble() * 1.6;
    final color = random.nextBool()
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFFFF3B0);
    canvas.drawCircle(Offset(x, y), radius, fill(color));
  }

  // Estrellas grandes con destello.
  for (var i = 0; i < 10; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final star = starPath(Offset(x, y), 7, 3, points: 4);
    canvas.drawPath(star, fill(const Color(0xCCFFFFFF)));
  }
}

/// Nieve de la pista "Nieve" (tileable).
void drawSnow(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFFE8F4FF)));

  // Degradado azulado muy suave.
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x33FFFFFF), Color(0x2200A5D8)],
      ).createShader(Offset.zero & size),
  );

  final random = math.Random(90210);
  // Montones de nieve.
  for (var i = 0; i < 22; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 10 + random.nextDouble() * 22;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(const Color(0xFFFFFFFF)),
    );
    canvas.drawCircle(
      Offset(x, y),
      radius,
      stroke(const Color(0x33FFFFFF), 2),
    );
  }

  // Copos de nieve en el aire.
  for (var i = 0; i < 60; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(
      Offset(x, y),
      1.6 + random.nextDouble() * 2.2,
      fill(const Color(0xFFFFFFFF)),
    );
  }
}

/// Bosque de la pista "Bosque" (tileable).
void drawForest(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF3E8E4E)));

  // Manchas de hierba clara y oscura.
  final random = math.Random(556677);
  for (var i = 0; i < 70; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 12 + random.nextDouble() * 26;
    final color = random.nextBool()
        ? const Color(0xFF4EA45C)
        : const Color(0xFF347A44);
    canvas.drawCircle(Offset(x, y), radius, fill(color));
  }

  // Briznas de hierba.
  for (var i = 0; i < 150; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final length = 6 + random.nextDouble() * 9;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + (random.nextDouble() - 0.5) * 5, y - length),
      stroke(
        random.nextBool()
            ? const Color(0xFF63BE6F)
            : const Color(0xFF2E6B3C),
        3,
      ),
    );
  }

  // Hojas secas.
  for (var i = 0; i < 16; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final leaf = Path()
      ..moveTo(x, y - 7)
      ..quadraticBezierTo(x + 7, y, x, y + 7)
      ..quadraticBezierTo(x - 7, y, x, y - 7)
      ..close();
    canvas.drawPath(leaf, fill(const Color(0xFFE8A33D)));
  }

  // Setas.
  for (var i = 0; i < 4; i++) {
    final x = 20 + random.nextDouble() * (size.width - 40);
    final y = 20 + random.nextDouble() * (size.height - 40);
    canvas.drawRect(
      Rect.fromLTWH(x - 3, y, 6, 9),
      fill(const Color(0xFFF6E7C8)),
    );
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCenter(center: Offset(x, y), width: 18, height: 14),
          math.pi,
          math.pi,
        ),
      fill(const Color(0xFFD9584E)),
    );
  }
}

/// Ciudad de la pista "Ciudad" (tileable).
void drawCity(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF6F7A8C)));

  // Baldosas de la acera.
  final random = math.Random(24680);
  for (var y = 0.0; y < size.height; y += 32) {
    for (var x = 0.0; x < size.width; x += 32) {
      final shade = random.nextInt(3);
      final color = switch (shade) {
        0 => const Color(0xFF7A8598),
        1 => const Color(0xFF66707F),
        _ => const Color(0xFF828D9F),
      };
      canvas.drawRect(
        Rect.fromLTWH(x + 1, y + 1, 30, 30),
        fill(color),
      );
    }
  }

  // Parterres con cesped.
  for (var i = 0; i < 3; i++) {
    final x = random.nextDouble() * (size.width - 60);
    final y = random.nextDouble() * (size.height - 60);
    canvas.drawCircle(
      Offset(x, y),
      16 + random.nextDouble() * 12,
      fill(const Color(0xFF4EA45C)),
    );
  }

  // Bancos.
  for (var i = 0; i < 3; i++) {
    final x = 24 + random.nextDouble() * (size.width - 60);
    final y = 24 + random.nextDouble() * (size.height - 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 26, 9),
        const Radius.circular(3),
      ),
      fill(const Color(0xFFB07A45)),
    );
  }
}

/// Desierto de la pista "Desierto" (tileable).
void drawDesert(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFFE8B96A)));

  // Dunas: manchas suaves de arena clara y oscura.
  final random = math.Random(112233);
  for (var i = 0; i < 26; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 14 + random.nextDouble() * 26;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(random.nextBool()
          ? const Color(0xFFF3D49A)
          : const Color(0xFFD9A24F)),
    );
  }

  // Ripas de arena.
  for (var i = 0; i < 40; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + 14 + random.nextDouble() * 12, y - 3),
      stroke(const Color(0xFFC98F3F), 3),
    );
  }

  // Cactus.
  for (var i = 0; i < 4; i++) {
    final x = 18 + random.nextDouble() * (size.width - 36);
    final y = 18 + random.nextDouble() * (size.height - 36);
    final height = 16 + random.nextDouble() * 14;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y - height, 7, height),
        const Radius.circular(4),
      ),
      fill(const Color(0xFF3E8E4E)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 7, y - height * 0.7, 7, 5),
        const Radius.circular(3),
      ),
      fill(const Color(0xFF3E8E4E)),
    );
  }
}

/// Selva de la pista "Selva" (tileable).
void drawJungle(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF2F7A45)));

  final random = math.Random(445566);
  for (var i = 0; i < 40; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 12 + random.nextDouble() * 22;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(random.nextBool()
          ? const Color(0xFF3E8E4E)
          : const Color(0xFF266738)),
    );
  }

  // Hojas grandes.
  for (var i = 0; i < 22; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final leaf = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x + 12, y - 10, x + 24, y)
      ..quadraticBezierTo(x + 12, y + 10, x, y)
      ..close();
    canvas.drawPath(
      leaf,
      fill(random.nextBool()
          ? const Color(0xFF57A85C)
          : const Color(0xFF7FC97F)),
    );
  }

  // Lianas colgantes.
  for (var i = 0; i < 6; i++) {
    final x = random.nextDouble() * size.width;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x + 5, 24 + random.nextDouble() * 30),
      stroke(const Color(0xFF2E6B3C), 4),
    );
  }
}

/// Puerto de la pista "Puerto" (tileable).
void drawHarbor(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF1E6E9B)));

  // Olas.
  final random = math.Random(778899);
  for (var i = 0; i < 30; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final width = 12 + random.nextDouble() * 16;
    final wave = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x + width * 0.3, y - 5, x + width * 0.6, y)
      ..quadraticBezierTo(x + width * 0.8, y + 4, x + width, y);
    canvas.drawPath(
      wave,
      stroke(const Color(0xFF57B6E8), 3),
    );
  }

  // Espigon de madera.
  for (var i = 0; i < 3; i++) {
    final x = random.nextDouble() * (size.width - 40);
    final y = random.nextDouble() * size.height;
    canvas.drawRect(
      Rect.fromLTWH(x, y, 34, 18),
      fill(const Color(0xFFB07A45)),
    );
    canvas.drawRect(
      Rect.fromLTWH(x, y, 34, 18),
      stroke(const Color(0xFF8A5A2E), 2),
    );
  }

  // Boyas.
  for (var i = 0; i < 4; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(Offset(x, y), 6, fill(const Color(0xFFFF6B6B)));
    canvas.drawCircle(
      Offset(x, y),
      6,
      stroke(const Color(0xFFB03A3A), 2),
    );
  }
}

/// Volcan de la pista "Volcan" (tileable).
void drawVolcano(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF3A2F38)));

  final random = math.Random(990011);
  // Roca basaltica: pocas rocas, no burbujas.
  for (var i = 0; i < 16; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 8 + random.nextDouble() * 12;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(random.nextBool()
          ? const Color(0xFF4A3B45)
          : const Color(0xFF2C232B)),
    );
  }

  // Grietas de lava.
  for (var i = 0; i < 9; i++) {
    final x = 12 + random.nextDouble() * (size.width - 40);
    final y = 12 + random.nextDouble() * (size.height - 60);
    final crack = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(
        x + (random.nextDouble() - 0.5) * 30,
        y + 14,
        x + (random.nextDouble() - 0.5) * 36,
        y + 28,
      );
    canvas.drawPath(crack, stroke(const Color(0xFF3A2F38), 11));
    canvas.drawPath(crack, stroke(const Color(0xFFFF7043), 6));
    canvas.drawPath(crack, stroke(const Color(0xFFFFD54F), 2));
  }

  // Brasas.
  for (var i = 0; i < 26; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(
      Offset(x, y),
      1.5 + random.nextDouble() * 2,
      fill(const Color(0xFFFFAB40)),
    );
  }
}

/// Espacio de la pista "Espacio" (tileable).
void drawSpace(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF141033)));

  final random = math.Random(13579);

  // Nebulosas.
  for (var i = 0; i < 14; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 20 + random.nextDouble() * 40;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(Color.fromRGBO(120, 90, 220, 0.16)),
    );
  }

  // Estrellas.
  for (var i = 0; i < 110; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 0.8 + random.nextDouble() * 1.8;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(random.nextBool()
          ? const Color(0xFFFFFFFF)
          : const Color(0xFFFFF3B0)),
    );
  }

  // Planetas lejanos.
  for (var i = 0; i < 3; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = 5 + random.nextDouble() * 7;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      fill(const Color(0xFF6C5CE7)),
    );
    canvas.drawCircle(
      Offset(x - radius * 0.3, y - radius * 0.3),
      radius * 0.35,
      fill(const Color(0xFFA29BFE)),
    );
  }
}

/// Estadio de la pista "Estadio" (tileable).
void drawStadium(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF3E8E4E)));

  // Franjas del cesped.
  for (var i = 0; i < 8; i++) {
    if (i.isEven) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * size.height / 8, size.width, size.height / 8),
        fill(const Color(0xFF48A05A)),
      );
    }
  }

  // Lineas del campo.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    stroke(const Color(0xCCFFFFFF), 4),
  );
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width * 0.16,
    stroke(const Color(0xCCFFFFFF), 4),
  );

  // Gradas de fondo.
  for (var i = 0; i < 3; i++) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * (0.04 + i * 0.05), size.width, 6),
      fill(const Color(0x553B72C4)),
    );
  }

  // Luces del focos.
  for (var i = 0; i < 8; i++) {
    final x = 10 + i * (size.width / 8);
    canvas.drawCircle(
      Offset(x, size.height * 0.06),
      3.5,
      fill(const Color(0xFFFFF3B0)),
    );
  }
}

/// Asfalto de tierra (pistas de arena y selva).
void drawDirtAsphalt(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF8C5A34)));

  final random = math.Random(31337);
  // Grava y tierra.
  for (var i = 0; i < 260; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(
      Offset(x, y),
      1 + random.nextDouble() * 2.4,
      fill(random.nextBool()
          ? const Color(0xFF9E6A40)
          : const Color(0xFF7A4D2C)),
    );
  }

  // Rodadas.
  for (final x in [size.width / 3, size.width * 2 / 3]) {
    canvas.drawRect(
      Rect.fromLTWH(x - 16, 0, 32, size.height),
      fill(const Color(0x22764A26)),
    );
  }

  // Lineas discontinuas.
  const dash = 48.0;
  const gap = 48.0;
  for (final x in [size.width / 3, size.width * 2 / 3]) {
    for (var y = 0.0; y < size.height; y += dash + gap) {
      canvas.drawRect(
        Rect.fromLTWH(x - 5, y, 10, dash),
        fill(const Color(0xFFE8DCC0)),
      );
    }
  }
}

/// Asfalto de piedra (pistas de montana).
void drawStoneAsphalt(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF6E6A66)));

  final random = math.Random(24680);
  // Losas.
  for (var y = 0.0; y < size.height; y += 48) {
    for (var x = 0.0; x < size.width; x += 48) {
      final offset = (y / 48).floor().isEven ? 0.0 : 24.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + offset + 2, y + 2, 44, 44),
          const Radius.circular(8),
        ),
        fill(random.nextBool()
            ? const Color(0xFF7A756F)
            : const Color(0xFF66625E)),
      );
    }
  }

  // Lineas continuas.
  for (final x in [size.width / 3, size.width * 2 / 3]) {
    canvas.drawRect(
      Rect.fromLTWH(x - 4, 0, 8, size.height),
      fill(const Color(0xFFF0EAD6)),
    );
  }
}

/// Asfalto de hielo (pistas de nieve y espacio).
void drawIceAsphalt(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(const Color(0xFF7FA8C9)));

  // Grietas de hielo.
  final random = math.Random(13579);
  for (var i = 0; i < 26; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + (random.nextDouble() - 0.5) * 40, y + 18),
      stroke(const Color(0x66FFFFFF), 3),
    );
  }

  // Lineas discontinuas.
  const dash = 48.0;
  const gap = 48.0;
  for (final x in [size.width / 3, size.width * 2 / 3]) {
    for (var y = 0.0; y < size.height; y += dash + gap) {
      canvas.drawRect(
        Rect.fromLTWH(x - 5, y, 10, dash),
        fill(const Color(0xFFFFFFFF)),
      );
    }
  }
}

/// Bordillo amarillo y negro.
void drawYellowCurb(Canvas canvas, ui.Size size) {
  const blocks = 2;
  final blockHeight = size.height / blocks;
  for (var i = 0; i < blocks; i++) {
    final isYellow = i.isEven;
    canvas.drawRect(
      Rect.fromLTWH(0, i * blockHeight, size.width, blockHeight),
      fill(isYellow ? StudioPalette.yellow : StudioPalette.ink),
    );
  }
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height),
    fill(const Color(0x22000000)),
  );
}

/// Bordillo de piedra.
void drawStoneCurb(Canvas canvas, ui.Size size) {
  canvas.drawRect(
    Offset.zero & size,
    fill(const Color(0xFF8D8578)),
  );
  final random = math.Random(97531);
  for (var y = 0.0; y < size.height; y += 20) {
    for (var x = 0.0; x < size.width; x += 26) {
      final offset = (y / 20).floor().isEven ? 0.0 : 13.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + offset + 1, y + 1, 24, 18),
          const Radius.circular(5),
        ),
        fill(random.nextBool()
            ? const Color(0xFF9A9184)
            : const Color(0xFF7E776C)),
      );
    }
  }
}

/// Bordillo de hielo.
void drawIceCurb(Canvas canvas, ui.Size size) {
  const blocks = 2;
  final blockHeight = size.height / blocks;
  for (var i = 0; i < blocks; i++) {
    canvas.drawRect(
      Rect.fromLTWH(0, i * blockHeight, size.width, blockHeight),
      fill(i.isEven ? const Color(0xFFDFF3FF) : const Color(0xFF9CCBE8)),
    );
  }
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height),
    fill(const Color(0x22000000)),
  );
}

/// Asfalto de la carretera (tileable vertical, 3 carriles).
void drawAsphalt(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(StudioPalette.asphalt));

  // Textura.
  final random = math.Random(777);
  for (var i = 0; i < 220; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(
      Offset(x, y),
      1 + random.nextDouble() * 1.8,
      fill(Color.fromRGBO(255, 255, 255, 0.05)),
    );
  }

  // Bordes laterales mas claros.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width * 0.04, size.height),
    fill(const Color(0x33455070)),
  );
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.96, 0, size.width * 0.04, size.height),
    fill(const Color(0x33455070)),
  );

  // Bordes de la carretera (solo el borde: la pista es ANCHA, el coche
  // puede moverse por toda ella, no por tres carriles).
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.03, 0, 6, size.height),
    fill(const Color(0x99FFFFFF)),
  );
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.97 - 6, 0, 6, size.height),
    fill(const Color(0x99FFFFFF)),
  );
}

/// Bordillo de la carretera (tileable vertical).
void drawCurb(Canvas canvas, ui.Size size) {
  const blocks = 2;
  final blockHeight = size.height / blocks;
  for (var i = 0; i < blocks; i++) {
    final isRed = i.isEven;
    canvas.drawRect(
      Rect.fromLTWH(0, i * blockHeight, size.width, blockHeight),
      fill(isRed ? StudioPalette.red : StudioPalette.white),
    );
  }
  canvas.drawRect(
    Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height),
    fill(const Color(0x22000000)),
  );
}

// ---------------------------------------------------------------------------
// Laminas para colorear
// ---------------------------------------------------------------------------

/// Rellena una region de lamina con el papel y la contorna.
void drawPageRegion(
  Canvas canvas,
  Path shape, {
  double outlineWidth = 14,
  Color fillColor = StudioPalette.paper,
}) {
  canvas.drawPath(shape, fill(fillColor));
  canvas.drawPath(shape, stroke(StudioPalette.outline, outlineWidth));
}

/// Dibuja el papel de fondo de una lamina.
void drawPaper(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(StudioPalette.paper));

  // Textura sutil de papel.
  final random = math.Random(4242);
  for (var i = 0; i < 400; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    canvas.drawCircle(
      Offset(x, y),
      1.2,
      fill(Color.fromRGBO(160, 140, 110, 0.12)),
    );
  }
}

/// Lamina 2: un paisaje con sol, nubes, colinas, casa y arbol.
void drawPageLandscape(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);

  // Sol con rayos.
  final sunCenter = Offset(size.width * 0.82, size.height * 0.18);
  for (var i = 0; i < 10; i++) {
    final angle = i / 10 * 2 * math.pi;
    final inner = Offset(
      sunCenter.dx + math.cos(angle) * size.width * 0.085,
      sunCenter.dy + math.sin(angle) * size.width * 0.085,
    );
    final outer = Offset(
      sunCenter.dx + math.cos(angle) * size.width * 0.125,
      sunCenter.dy + math.sin(angle) * size.width * 0.125,
    );
    canvas.drawLine(inner, outer, stroke(StudioPalette.outline, 9));
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: sunCenter,
          width: size.width * 0.14,
          height: size.width * 0.14,
        ),
      ),
    outlineWidth: 11,
  );

  // Nubes.
  for (final data in [
    [Offset(size.width * 0.26, size.height * 0.2), size.width * 0.26, size.height * 0.14],
    [Offset(size.width * 0.58, size.height * 0.1), size.width * 0.19, size.height * 0.1],
  ]) {
    drawPageRegion(
      canvas,
      cloudPath(data[0] as Offset, data[1] as double, data[2] as double),
      outlineWidth: 11,
    );
  }

  // Colinas.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.24, size.height * 1.02),
          width: size.width * 0.66,
          height: size.height * 0.62,
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.78, size.height * 1.06),
          width: size.width * 0.56,
          height: size.height * 0.5,
        ),
      ),
    outlineWidth: 13,
  );

  // Casa: tejado y cuerpo.
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(size.width * 0.24, size.height * 0.56),
      Offset(size.width * 0.42, size.height * 0.34),
      Offset(size.width * 0.6, size.height * 0.56),
    ]),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.28, size.height * 0.54, size.width * 0.28, size.height * 0.26),
          Radius.circular(size.width * 0.02),
        ),
      ),
    outlineWidth: 13,
  );

  // Puerta y ventanas.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.36, size.height * 0.66, size.width * 0.12, size.height * 0.14),
          Radius.circular(size.width * 0.02),
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.31, size.height * 0.6, size.width * 0.075, size.height * 0.08),
          Radius.circular(size.width * 0.015),
        ),
      ),
    outlineWidth: 11,
  );

  // Arbol.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.72, size.height * 0.66, size.width * 0.055, size.height * 0.16),
          Radius.circular(size.width * 0.015),
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.7475, size.height * 0.56),
          width: size.width * 0.22,
          height: size.height * 0.28,
        ),
      ),
    outlineWidth: 13,
  );

  // Flores.
  for (final data in <(Offset, double)>[
    (Offset(size.width * 0.12, size.height * 0.72), size.width * 0.05),
    (Offset(size.width * 0.17, size.height * 0.8), size.width * 0.04),
    (Offset(size.width * 0.9, size.height * 0.74), size.width * 0.045),
  ]) {
    final center = data.$1;
    final radius = data.$2;
    // Tallo.
    canvas.drawLine(
      Offset(center.dx, center.dy + radius),
      Offset(center.dx + radius * 0.3, center.dy + radius * 3),
      stroke(StudioPalette.outline, 8),
    );
    drawPageRegion(
      canvas,
      flowerPath(center, radius),
      outlineWidth: 9,
    );
  }
}

/// Lamina 4: una casa con arbol, sol y flores.
void drawPageHouse(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);

  // Chimenea.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.63, size.height * 0.28, size.width * 0.06, size.height * 0.13),
          Radius.circular(size.width * 0.012),
        ),
      ),
    outlineWidth: 11,
  );

  // Tejado.
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(size.width * 0.22, size.height * 0.48),
      Offset(size.width * 0.46, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.48),
    ]),
    outlineWidth: 13,
  );

  // Cuerpo de la casa.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.27, size.height * 0.46, size.width * 0.4, size.height * 0.34),
          Radius.circular(size.width * 0.02),
        ),
      ),
    outlineWidth: 13,
  );

  // Puerta.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.41, size.height * 0.58, size.width * 0.12, size.height * 0.22),
          Radius.circular(size.width * 0.02),
        ),
      ),
    outlineWidth: 11,
  );

  // Ventanas.
  for (final dx in [0.31, 0.52]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * dx,
              size.height * 0.52,
              size.width * 0.11,
              size.height * 0.1,
            ),
            Radius.circular(size.width * 0.018),
          ),
        ),
      outlineWidth: 10,
    );
  }

  // Sol.
  final sunCenter = Offset(size.width * 0.85, size.height * 0.17);
  for (var i = 0; i < 10; i++) {
    final angle = i / 10 * 2 * math.pi;
    canvas.drawLine(
      Offset(
        sunCenter.dx + math.cos(angle) * size.width * 0.08,
        sunCenter.dy + math.sin(angle) * size.width * 0.08,
      ),
      Offset(
        sunCenter.dx + math.cos(angle) * size.width * 0.115,
        sunCenter.dy + math.sin(angle) * size.width * 0.115,
      ),
      stroke(StudioPalette.outline, 9),
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: sunCenter,
          width: size.width * 0.13,
          height: size.width * 0.13,
        ),
      ),
    outlineWidth: 11,
  );

  // Nube.
  drawPageRegion(
    canvas,
    cloudPath(Offset(size.width * 0.2, size.height * 0.15), size.width * 0.22, size.height * 0.11),
    outlineWidth: 11,
  );

  // Arbol.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.79, size.height * 0.6, size.width * 0.055, size.height * 0.2),
          Radius.circular(size.width * 0.015),
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.8175, size.height * 0.5),
          width: size.width * 0.22,
          height: size.height * 0.3,
        ),
      ),
    outlineWidth: 13,
  );

  // Arbustos.
  for (final center in [
    Offset(size.width * 0.12, size.height * 0.78),
    Offset(size.width * 0.88, size.height * 0.82),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: center,
            width: size.width * 0.16,
            height: size.height * 0.13,
          ),
        ),
      outlineWidth: 11,
    );
  }
}

/// Hoja de referencia de la paleta.
void drawPaletteSheet(Canvas canvas, ui.Size size) {
  canvas.drawRect(Offset.zero & size, fill(StudioPalette.cream));

  const colors = [
    StudioPalette.red,
    StudioPalette.orange,
    StudioPalette.yellow,
    StudioPalette.green,
    StudioPalette.lime,
    StudioPalette.cyan,
    StudioPalette.blue,
    StudioPalette.violet,
    StudioPalette.pink,
    StudioPalette.brown,
    StudioPalette.ink,
    StudioPalette.white,
  ];

  const columns = 6;
  final cellWidth = size.width / columns;
  final cellHeight = size.height / 2;
  for (var i = 0; i < colors.length; i++) {
    final row = i ~/ columns;
    final col = i % columns;
    final center = Offset(
      cellWidth * (col + 0.5),
      cellHeight * (row + 0.5),
    );
    final radius = math.min(cellWidth, cellHeight) * 0.36;
    canvas.drawCircle(center, radius + 6, fill(StudioPalette.white));
    canvas.drawCircle(center, radius, fill(colors[i]));
    canvas.drawCircle(
      center,
      radius,
      stroke(darken(colors[i], 0.25), 4),
    );
  }
}
