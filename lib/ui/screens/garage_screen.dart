import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/vehicle_spec.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';
import '../widgets/big_button.dart';
import '../widgets/help_button.dart';
import '../widgets/star_counter.dart';

/// Garaje: aqui se elige el vehiculo con el que se corre.
///
/// Hay coches, una moto, un camion, un bus, un tractor y una furgoneta.
/// Los que estan bloqueados se desbloquean con estrellas; los que ya estan
/// desbloqueados se pueden volver a elegir tantas veces como se quiera.
class GarageScreen extends StatelessWidget {
  /// Crea el garaje.
  const GarageScreen({super.key, this.onVehicleSelected});

  /// Se invoca con el id del vehiculo elegido.
  final ValueChanged<String>? onVehicleSelected;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Stack(
        children: [
          const _GarageBackground(),
          SafeArea(
            child: Column(
              children: [
                _GarageHeader(progress: progress),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 5
                          : constraints.maxWidth >= 640
                              ? 4
                              : constraints.maxWidth >= 420
                                  ? 3
                                  : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: GameContent.vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = GameContent.vehicles[index];
                          return _VehicleCard(
                            vehicle: vehicle,
                            unlocked: progress.isVehicleUnlocked(vehicle.id),
                            selected:
                                vehicle.id == progress.progress.selectedVehicle,
                            onTap: () => _pick(context, vehicle),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pick(BuildContext context, VehicleSpec vehicle) {
    final progress = context.read<ProgressProvider>();
    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
    if (!progress.isVehicleUnlocked(vehicle.id)) {
      return;
    }
    progress.selectVehicle(vehicle.id);
    if (onVehicleSelected != null) {
      onVehicleSelected!(vehicle.id);
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _GarageHeader extends StatelessWidget {
  const _GarageHeader({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          AppIconButton(
            assetPath: AssetPaths.iconBack,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Garaje',
                  style: TextStyle(
                    color: AppPalette.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          StarCounter(stars: progress.totalStars, size: 52),
          const SizedBox(width: 8),
          HelpButton(
            size: 48,
            title: 'El garaje',
            tips: const [
              'Aquí eliges el vehículo con el que corres.',
              'Los que tienen candado se desbloquean con estrellas.',
              'Puedes cambiar de vehículo cuando quieras.',
              'Para pintar la calca y elegir pasajero, está el Taller.',
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final VehicleSpec vehicle;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: unlocked,
      label: '${vehicle.name}${unlocked ? '' : ', bloqueado'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: unlocked ? AppPalette.white : const Color(0xFFE4DCCB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? vehicle.color : const Color(0x22000000),
              width: selected ? 5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: vehicle.color.withValues(alpha: selected ? 0.3 : 0.12),
                offset: const Offset(0, 6),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: Image.asset(
                  vehicle.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vehicle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!unlocked)
                      Text(
                        '${vehicle.unlockStars} ★',
                        style: const TextStyle(
                          color: AppPalette.brown,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
              if (!unlocked)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.lock_rounded,
                    color: AppPalette.ink,
                    size: 28,
                  ),
                ),
              if (selected)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppPalette.green,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarageBackground extends StatelessWidget {
  const _GarageBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.cream, Color(0xFFFFF0D6)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -70,
          right: -50,
          child: _Blob(
            color: AppPalette.orange.withValues(alpha: 0.16),
            size: 240,
          ),
        ),
        Positioned(
          bottom: -90,
          left: -60,
          child: _Blob(
            color: AppPalette.blue.withValues(alpha: 0.14),
            size: 260,
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
