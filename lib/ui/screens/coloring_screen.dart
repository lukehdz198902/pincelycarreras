import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/paint_stroke.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/asset_service.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/progress_service.dart';
import '../../game/coloring/brush.dart';
import '../../game/coloring/paint_canvas.dart';
import '../../shared/context_extensions.dart';
import '../widgets/big_button.dart';
import '../widgets/color_picker.dart';
import '../widgets/thumbnails.dart';
import '../widgets/tool_picker.dart';

/// Estudio de pintura.
///
/// Sin limites de tiempo ni de cantidad: el nino pinta hasta que quiere
/// parar. El dibujo se guarda solo, cada pocos segundos.
class ColoringScreen extends StatefulWidget {
  /// Crea el estudio de pintura.
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen>
    with WidgetsBindingObserver {
  Brush _brush = const Brush(
    kind: ToolKind.brush,
    colorValue: 0xFFFF4757,
  );
  Painting _painting = const Painting();
  ui.Image? _pageImage;
  Size _pageSize = const Size(1024, 768);
  bool _showColors = false;
  bool _showPages = false;
  bool _confirmClear = false;
  Timer? _saveTimer;
  Timer? _clearTimer;
  String _pageId = 'coche';
  ProgressService? _service;
  AudioService? _audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final provider = context.read<ProgressProvider>();
    _pageId = provider.progress.selectedPage;
    _service = context.read<ProgressService>();
    _audio = audioServiceOf(context);
    unawaited(_audio?.playBgm(BgmTrack.painting) ?? Future<void>.value());
    unawaited(_loadPage(_pageId));
    _saveTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _save(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_audio?.resumeBgm() ?? Future<void>.value());
    } else {
      unawaited(_audio?.pauseBgm() ?? Future<void>.value());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _clearTimer?.cancel();
    _save();
    _pageImage?.dispose();
    // La musica del estudio no debe seguir sonando en el menu.
    unawaited(_audio?.stopBgm() ?? Future<void>.value());
    super.dispose();
  }

  Future<void> _loadPage(String pageId) async {
    final spec = GameContent.pageById(pageId);
    if (spec == null) {
      return;
    }
    ui.Image? image;
    try {
      image = await AssetService.loadImage(spec.assetPath);
    } catch (error) {
      debugPrint('[Pincel] No se pudo cargar la lamina: $error');
      return;
    }
    if (!mounted) {
      image.dispose();
      return;
    }
    final painting = _service?.loadDrawing(pageId) ?? const Painting();
    final previous = _pageImage;
    final loaded = image;
    setState(() {
      _pageImage = loaded;
      _pageSize = Size(loaded.width.toDouble(), loaded.height.toDouble());
      _painting = painting;
      _pageId = pageId;
    });
    // La imagen anterior se libera DESPUES del frame: si se libera antes,
    // el lienzo puede llegar a pintarla y quedarse en blanco.
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  void _save() {
    final service = _service;
    if (service == null) {
      return;
    }
    unawaited(service.saveDrawing(_pageId, _painting));
  }

  void _onPaintingChanged(Painting painting) {
    setState(() => _painting = painting);
  }

  void _onPaintFeedback(Offset position, ToolKind kind) {
    final audio = audioServiceOf(context);
    switch (kind) {
      case ToolKind.brush:
        audio?.playSfx(SfxKind.pop);
      case ToolKind.bucket:
        audio?.playSfx(SfxKind.pop);
      case ToolKind.eraser:
        audio?.playSfx(SfxKind.swoosh);
    }
  }

  void _handleClear() {
    if (!_confirmClear) {
      setState(() => _confirmClear = true);
      _clearTimer?.cancel();
      _clearTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _confirmClear = false);
        }
      });
      return;
    }
    _clearTimer?.cancel();
    setState(() {
      _confirmClear = false;
      _painting = const Painting();
    });
    _save();
    audioServiceOf(context)?.playSfx(SfxKind.swoosh);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();
    final page = GameContent.pageById(_pageId);

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(page?.assetPath ?? AssetPaths.pageCoche),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _pageImage == null
                        ? const Center(child: CircularProgressIndicator())
                        : PaintCanvas(
                            pageImage: _pageImage!,
                            pageSize: _pageSize,
                            brush: _brush,
                            painting: _painting,
                            onPaintingChanged: _onPaintingChanged,
                            onPaintFeedback: _onPaintFeedback,
                          ),
                  ),
                ),
                ToolPicker(
                  brush: _brush,
                  onToolChanged: (kind) {
                    setState(() => _brush = _brush.copyWith(kind: kind));
                    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
                  },
                  onWidthChanged: (index) {
                    setState(() => _brush = _brush.copyWith(widthIndex: index));
                    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
                  },
                ),
              ],
            ),
          ),
          if (_showColors) _buildColorPanel(provider),
          if (_showPages) _buildPagePanel(provider),
        ],
      ),
    );
  }

  Widget _buildTopBar(String pageAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          AppIconButton(
            assetPath: AssetPaths.iconBack,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() => _showPages = true);
              audioServiceOf(context)?.playSfx(SfxKind.uiTap);
            },
            child: PageThumbnail(assetPath: pageAsset, size: 52),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _handleClear,
            child: Container(
              width: GameSizes.smallButtonSize,
              height: GameSizes.smallButtonSize,
              decoration: BoxDecoration(
                color: _confirmClear ? AppPalette.red : AppPalette.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33000000), width: 2),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                AssetPaths.iconEraser,
                width: GameSizes.smallButtonSize * 0.6,
                height: GameSizes.smallButtonSize * 0.6,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() => _showColors = true);
              audioServiceOf(context)?.playSfx(SfxKind.uiTap);
            },
            child: ColorSample(color: _brush.color),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPanel(ProgressProvider provider) {
    return Positioned.fill(
      child: Container(
        color: AppPalette.cream,
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppIconButton(
                  assetPath: AssetPaths.iconBack,
                  onPressed: () => setState(() => _showColors = false),
                ),
              ],
            ),
            Expanded(
              child: ColorPicker(
                colors: GameContent.allColors,
                selectedId: _brushColorId(provider),
                isUnlocked: provider.isColorUnlocked,
                onSelected: (spec) {
                  setState(() {
                    _brush = _brush.copyWith(colorValue: spec.color.toARGB32());
                  });
                  audioServiceOf(context)?.playSfx(SfxKind.uiTap);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _brushColorId(ProgressProvider provider) {
    for (final spec in GameContent.allColors) {
      if (spec.color.toARGB32() == _brush.colorValue) {
        return spec.id;
      }
    }
    return 'rojo';
  }

  Widget _buildPagePanel(ProgressProvider provider) {
    return Positioned.fill(
      child: Container(
        color: AppPalette.cream,
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppIconButton(
                  assetPath: AssetPaths.iconBack,
                  onPressed: () => setState(() => _showPages = false),
                ),
              ],
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  for (final spec in GameContent.pages)
                    _PageTile(
                      assetPath: spec.assetPath,
                      selected: spec.id == _pageId,
                      locked: !provider.isPageUnlocked(spec.id),
                      onTap: provider.isPageUnlocked(spec.id)
                          ? () {
                              context
                                  .read<ProgressProvider>()
                                  .selectPage(spec.id);
                              setState(() => _showPages = false);
                              unawaited(_loadPage(spec.id));
                              audioServiceOf(context)?.playSfx(SfxKind.uiTap);
                            }
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.assetPath,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String assetPath;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: locked ? const Color(0xFFE4DCCB) : AppPalette.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppPalette.blue : const Color(0x22000000),
            width: selected ? 5 : 2,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),
            if (locked)
              const Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 44,
                  color: AppPalette.ink,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
