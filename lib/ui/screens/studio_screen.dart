import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/vehicle_customization.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';
import '../widgets/big_button.dart';
import '../widgets/help_button.dart';
import '../widgets/star_counter.dart';

/// Taller: aqui el nino pinta su vehiculo y elige quien viaja con el.
///
/// Tres cosas se pueden cambiar, todo con un toque:
/// - la **calca** (rayas, estrella, llama, corazon o numero);
/// - el **color** de la calca (12 colores);
/// - el **personaje** que viaja en el vehiculo (gato, perro, conejo o robot).
class StudioScreen extends StatefulWidget {
  /// Crea el taller.
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final vehicle =
        GameContent.vehicleById(progress.progress.selectedVehicle) ??
            GameContent.vehicles.first;
    final decal = VehicleCustomization.decalById(
          progress.progress.selectedDecal,
        ) ??
        VehicleCustomization.decals.first;
    final character = VehicleCustomization.characterById(
          progress.progress.selectedCharacter,
        ) ??
        VehicleCustomization.characters.first;
    final decalColor =
        Color(progress.progress.selectedDecalColor);

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Stack(
        children: [
          const _StudioBackground(),
          SafeArea(
            child: Column(
              children: [
                _Header(progress: progress),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 700;
                      final preview = _Preview(
                        vehicleAssetPath: vehicle.assetPath,
                        decalAssetPath: decal.assetPath,
                        decalColor: decalColor,
                        characterAssetPath: character.assetPath,
                      );
                      final decals = _DecalPicker(
                        decals: VehicleCustomization.decals,
                        selectedId: decal.id,
                        color: decalColor,
                        onSelected: (id) => _select(
                          () => progress.selectDecal(id),
                        ),
                      );
                      final colors = _ColorPicker(
                        selected: decalColor,
                        onSelected: (color) => _select(
                          () => progress.selectDecalColor(
                            color.toARGB32(),
                          ),
                        ),
                      );
                      final characters = _CharacterPicker(
                        characters: VehicleCustomization.characters,
                        selectedId: character.id,
                        onSelected: (id) => _select(
                          () => progress.selectCharacter(id),
                        ),
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: preview),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.all(12),
                                children: [
                                  decals,
                                  const SizedBox(height: 12),
                                  colors,
                                  const SizedBox(height: 12),
                                  characters,
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          SizedBox(height: 260, child: preview),
                          const SizedBox(height: 12),
                          decals,
                          const SizedBox(height: 12),
                          colors,
                          const SizedBox(height: 12),
                          characters,
                        ],
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

  void _select(VoidCallback action) {
    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
    action();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});

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
                  'Taller',
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
            title: 'El taller',
            tips: const [
              'Elige la calca que quieres poner en la carrocería.',
              'Elige su color: se pinta al instante.',
              'Elige quién viaja contigo: gato, perro, conejo o robot.',
              'Todo esto se ve en tu coche durante la carrera.',
            ],
          ),
        ],
      ),
    );
  }
}

/// Vista previa del vehiculo con la calca y el personaje.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.vehicleAssetPath,
    required this.decalAssetPath,
    required this.decalColor,
    required this.characterAssetPath,
  });

  final String vehicleAssetPath;
  final String decalAssetPath;
  final Color decalColor;
  final String characterAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.blue, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                vehicleAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Image.asset(
                characterAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      decalColor,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      decalAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de calcas.
class _DecalPicker extends StatelessWidget {
  const _DecalPicker({
    required this.decals,
    required this.selectedId,
    required this.color,
    required this.onSelected,
  });

  final List<DecalSpec> decals;
  final String selectedId;
  final Color color;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Calca',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final decal in decals)
            GestureDetector(
              key: ValueKey<String>('decal_${decal.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(decal.id),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppPalette.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: decal.id == selectedId
                        ? AppPalette.violet
                        : const Color(0x22000000),
                    width: decal.id == selectedId ? 4 : 2,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                // Las calcas se generan en blanco para poder tintarlas:
                // aqui se muestran con el color elegido (si no, serian
                // invisibles sobre el fondo blanco).
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  child: Image.asset(
                    decal.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector de color de la calca.
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Color',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final color in GameContent.baseColors)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(color.color),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.color.toARGB32() == selected.toARGB32()
                        ? AppPalette.ink
                        : const Color(0x22000000),
                    width: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector de personaje.
class _CharacterPicker extends StatelessWidget {
  const _CharacterPicker({
    required this.characters,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CharacterSpec> characters;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Pasajero',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final character in characters)
            GestureDetector(
              key: ValueKey<String>('character_${character.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(character.id),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppPalette.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: character.id == selectedId
                        ? AppPalette.green
                        : const Color(0x22000000),
                    width: character.id == selectedId ? 4 : 2,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  character.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Seccion del taller.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x22000000), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StudioBackground extends StatelessWidget {
  const _StudioBackground();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppPalette.cream, Color(0xFFEAF3FF)],
          ),
        ),
      ),
    );
  }
}

