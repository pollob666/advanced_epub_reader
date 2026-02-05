import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final ReadingTheme theme;
  final bool autoApply;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.theme,
    this.autoApply = false,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late double _hue; // 0..360
  late double _saturation; // 0..1
  late double _value; // 0..1 (brightness)
  late Color _currentColor;

  // Debouncing for smooth interaction
  bool _isUpdating = false;

  /// Get a better accent color for the current theme
  Color _getBetterAccentColor(ReadingTheme theme) {
    final themeName = theme.name.toLowerCase();

    if (themeName.contains('dark')) {
      return Colors.orange.shade400;
    }
    if (themeName.contains('high contrast')) {
      return Colors.yellow;
    }
    if (themeName.contains('sepia')) {
      return const Color(0xFF8D6E63);
    }
    if (themeName.contains('green')) {
      return const Color(0xFF4CAF50);
    }
    if (themeName.contains('purple')) {
      return const Color(0xFF9C27B0);
    }
    if (themeName.contains('orange')) {
      return const Color(0xFFFF9800);
    }
    if (themeName.contains('blue light')) {
      return const Color(0xFF16213E);
    }
    if (themeName.contains('light')) {
      // For light theme, use a more appropriate color than the default blue
      return const Color(
        0xFF1976D2,
      ); // Material Blue 700 - darker and more professional
    }
    // Default fallback
    return theme.accentColor;
  }

  @override
  void initState() {
    super.initState();
    _initializeFromColor(widget.initialColor);
  }

  void _initializeFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _currentColor = color;
  }

  void _updateColor({bool callCallback = true}) {
    if (_isUpdating) return;

    _isUpdating = true;
    _currentColor = HSVColor.fromAHSV(
      1.0,
      _hue.clamp(0.0, 360.0),
      _saturation.clamp(0.0, 1.0),
      _value.clamp(0.0, 1.0),
    ).toColor();

    if (mounted) {
      setState(() {});
    }

    if (widget.autoApply && callCallback) {
      widget.onColorChanged(_currentColor);
    }

    _isUpdating = false;
  }

  void _updateHueFromPosition(Offset localPosition, double width) {
    final x = localPosition.dx.clamp(0.0, width);
    _hue = (x / width) * 360.0;
    _updateColor();
  }

  void _updateToneFromPosition(
    Offset localPosition,
    double width,
    double height,
  ) {
    final x = localPosition.dx.clamp(0.0, width);
    final y = localPosition.dy.clamp(0.0, height);

    // horizontal -> saturation
    _saturation = (x / width).clamp(0.0, 1.0);

    // vertical -> value (brightness) where top = 1.0 and bottom = 0.0
    _value = (1.0 - (y / height)).clamp(0.0, 1.0);

    _updateColor();
  }

  String _hexFromColor(Color c) {
    // Format to #RRGGBB
    final hex = c.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    return '#$hex';
  }

  void _parseColorFromHex(String hexString) {
    try {
      // Remove # if present
      String hex = hexString.replaceAll('#', '');

      // Ensure it's 6 characters
      if (hex.length == 6) {
        // Parse the hex color
        final colorValue = int.parse('FF$hex', radix: 16);
        final color = Color(colorValue);

        // Update the color picker state
        final hsv = HSVColor.fromColor(color);
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _value = hsv.value;
        _currentColor = color;

        // Update the UI
        setState(() {});
      }
    } catch (e) {
      // Invalid hex color, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    const toneBoxHeight = 150.0;
    const hueBarHeight = 24.0;
    const indicatorSize = 16.0; // FIXED: now visible + controllable

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: preview, hex, apply
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: TextEditingController(
                    text: _hexFromColor(_currentColor),
                  ),
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.accentColor,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.backgroundColor,
                    hintText: '#000000',
                    hintStyle: TextStyle(
                      color: theme.secondaryTextColor.withOpacity(0.5),
                      fontFamily: 'monospace',
                    ),
                  ),
                  onChanged: (value) {
                    _parseColorFromHex(value);
                  },
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: _getBetterAccentColor(theme),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: TextButton(
                  onPressed: () => widget.onColorChanged(_currentColor),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.backgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tone box (Saturation x Value)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => _updateToneFromPosition(
                  details.localPosition,
                  width,
                  toneBoxHeight,
                ),
                onPanUpdate: (details) => _updateToneFromPosition(
                  details.localPosition,
                  width,
                  toneBoxHeight,
                ),
                onTapDown: (details) => _updateToneFromPosition(
                  details.localPosition,
                  width,
                  toneBoxHeight,
                ),
                child: Container(
                  height: toneBoxHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base hue color
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: HSVColor.fromAHSV(
                            1.0,
                            _hue,
                            1.0,
                            1.0,
                          ).toColor(),
                        ),
                      ),
                      // White overlay (saturation)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                      // Black overlay (value/brightness)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                      // Tone indicator
                      Positioned(
                        left: (_saturation * width) - (indicatorSize / 2),
                        top:
                            ((1.0 - _value) * toneBoxHeight) -
                            (indicatorSize / 2),
                        child: Container(
                          width: indicatorSize,
                          height: indicatorSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentColor,
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Hue bar
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final hueColors = const [
                Color(0xFFFF0000),
                Color(0xFFFF8000),
                Color(0xFFFFFF00),
                Color(0xFF80FF00),
                Color(0xFF00FF00),
                Color(0xFF00FFFF),
                Color(0xFF0080FF),
                Color(0xFF0000FF),
                Color(0xFF8000FF),
                Color(0xFFFF00FF),
                Color(0xFFFF0000),
              ];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) =>
                    _updateHueFromPosition(details.localPosition, width),
                onPanUpdate: (details) =>
                    _updateHueFromPosition(details.localPosition, width),
                onTapDown: (details) =>
                    _updateHueFromPosition(details.localPosition, width),
                child: Container(
                  height: hueBarHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                    gradient: LinearGradient(colors: hueColors),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: ((_hue / 360.0) * width) - (indicatorSize / 2),
                        top: (hueBarHeight / 2) - (indicatorSize / 2),
                        child: Container(
                          width: indicatorSize,
                          height: indicatorSize,
                          decoration: BoxDecoration(
                            color: _currentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
