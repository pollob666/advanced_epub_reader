import 'package:flutter/material.dart';
import '../utils/reading_theme.dart';
import '../utils/theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography and Margins adjustment sheet
class TypographySheet extends StatefulWidget {
  final ReadingTheme theme;

  const TypographySheet({required this.theme, super.key});

  @override
  State<TypographySheet> createState() => _TypographySheetState();
}

class _TypographySheetState extends State<TypographySheet> {
  late double _fontSize;
  late String _fontFamily;
  late double _lineHeight;
  late double _margin;
  late String _readingStyle;

  @override
  void initState() {
    super.initState();
    _fontSize = ThemeManager.getCurrentFontSize();
    _fontFamily = ThemeManager.getCurrentFontFamily();
    _lineHeight = ThemeManager.getCurrentLineHeight();
    _margin = ThemeManager.getCurrentMargin();
    _readingStyle = ThemeManager.getCurrentReadingStyle();
  }

  /// Gets the appropriate TextStyle for the font family, using Google Fonts when available
  TextStyle _getFontTextStyle(String fontFamily, {double fontSize = 12.0}) {
    // Check if it's a Google Font
    if (_isGoogleFont(fontFamily)) {
      return _getGoogleFont(fontFamily, fontSize);
    }

    // Fallback to system fonts
    return TextStyle(fontFamily: fontFamily, fontSize: fontSize);
  }

  /// Checks if the font family is a Google Font
  bool _isGoogleFont(String fontFamily) {
    const googleFonts = ['Open Sans', 'Lato', 'Noto Sans', 'Merriweather'];
    return googleFonts.contains(fontFamily);
  }

  /// Gets the appropriate Google Font TextStyle
  TextStyle _getGoogleFont(String fontFamily, double fontSize) {
    switch (fontFamily) {
      case 'Open Sans':
        return GoogleFonts.openSans(fontSize: fontSize);
      case 'Lato':
        return GoogleFonts.lato(fontSize: fontSize);
      case 'Noto Sans':
        return GoogleFonts.notoSans(fontSize: fontSize);
      case 'Merriweather':
        return GoogleFonts.merriweather(fontSize: fontSize);
      default:
        return GoogleFonts.roboto(fontSize: fontSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: widget.theme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Typography & Margins',
                style: TextStyle(
                  color: widget.theme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Typography options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Font Size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Font Size',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_fontSize != 16.0) // Default is 16.0
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.theme.accentColor,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _fontSize = 16.0);
                                ThemeManager.setCurrentFontSize(16.0);
                              },
                              tooltip: 'Reset to default',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          Text(
                            '${_fontSize.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: widget.theme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: widget.theme.accentColor,
                      inactiveTrackColor: widget.theme.dividerColor,
                      thumbColor: widget.theme.accentColor,
                      overlayColor: widget.theme.accentColor.withOpacity(0.2),
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24.0,
                      ),
                    ),
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 32.0,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() => _fontSize = value);
                        ThemeManager.setCurrentFontSize(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Font Family
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Font Family',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_fontFamily != 'Roboto') // Default is Roboto
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.theme.accentColor,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _fontFamily = 'Roboto');
                                ThemeManager.setCurrentFontFamily('Roboto');
                              },
                              tooltip: 'Reset to default',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          Text(
                            _fontFamily,
                            style: _getFontTextStyle(_fontFamily, fontSize: 18)
                                .copyWith(
                                  color: widget.theme.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ThemeManager.getAvailableFontFamilies().length,
                      itemBuilder: (context, index) {
                        final font =
                            ThemeManager.getAvailableFontFamilies()[index];
                        final isSelected = font == _fontFamily;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              font,
                              style: _getFontTextStyle(font, fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                debugPrint('Font family selected: $font');
                                setState(() => _fontFamily = font);
                                ThemeManager.setCurrentFontFamily(font);
                                debugPrint('Font family set to: $font');
                              }
                            },
                            backgroundColor: widget.theme.backgroundColor,
                            selectedColor: widget.theme.accentColor.withOpacity(
                              0.2,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? widget.theme.accentColor
                                  : widget.theme.textColor,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? widget.theme.accentColor
                                  : widget.theme.dividerColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Line Height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Line Height',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_lineHeight != 1.5) // Default is 1.5
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.theme.accentColor,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _lineHeight = 1.5);
                                ThemeManager.setCurrentLineHeight(1.5);
                              },
                              tooltip: 'Reset to default',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          Text(
                            '${_lineHeight.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: widget.theme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: widget.theme.accentColor,
                      inactiveTrackColor: widget.theme.dividerColor,
                      thumbColor: widget.theme.accentColor,
                      overlayColor: widget.theme.accentColor.withOpacity(0.2),
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24.0,
                      ),
                    ),
                    child: Slider(
                      value: _lineHeight,
                      min: 1.0,
                      max: 2.5,
                      divisions: 15,
                      onChanged: (value) {
                        setState(() => _lineHeight = value);
                        ThemeManager.setCurrentLineHeight(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Margins
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Margins',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_margin != 24.0) // Default is 24.0
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.theme.accentColor,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _margin = 24.0);
                                ThemeManager.setCurrentMargin(24.0);
                              },
                              tooltip: 'Reset to default',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          Text(
                            '${_margin.toStringAsFixed(0)}px',
                            style: TextStyle(
                              color: widget.theme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: widget.theme.accentColor,
                      inactiveTrackColor: widget.theme.dividerColor,
                      thumbColor: widget.theme.accentColor,
                      overlayColor: widget.theme.accentColor.withOpacity(0.2),
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24.0,
                      ),
                    ),
                    child: Slider(
                      value: _margin,
                      min: 8.0,
                      max: 48.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() => _margin = value);
                        ThemeManager.setCurrentMargin(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reading Style
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reading Style',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_readingStyle != 'Scrolling')
                            IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: widget.theme.accentColor,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _readingStyle = 'Scrolling');
                                ThemeManager.setCurrentReadingStyle(
                                  'Scrolling',
                                );
                              },
                              tooltip: 'Reset to default',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          Text(
                            _readingStyle,
                            style: TextStyle(
                              color: widget.theme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          ThemeManager.getAvailableReadingStyles().length,
                      itemBuilder: (context, index) {
                        final style =
                            ThemeManager.getAvailableReadingStyles()[index];
                        final isSelected = style == _readingStyle;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(style, style: TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                debugPrint('Reading style selected: $style');
                                setState(() => _readingStyle = style);
                                ThemeManager.setCurrentReadingStyle(style);
                                debugPrint('Reading style set to: $style');
                              }
                            },
                            backgroundColor: widget.theme.backgroundColor,
                            selectedColor: widget.theme.accentColor.withOpacity(
                              0.2,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? widget.theme.accentColor
                                  : widget.theme.textColor,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? widget.theme.accentColor
                                  : widget.theme.dividerColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
