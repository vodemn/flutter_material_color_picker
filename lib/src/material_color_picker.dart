import 'package:flutter_material_color_picker/src/circle_color.dart';
import 'package:flutter_material_color_picker/src/colors.dart';
import 'package:flutter/material.dart';

class MaterialColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChange;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final double circleSize;
  final double spacing;
  final IconData iconSelected;
  final double elevation;

  const MaterialColorPicker({
    Key key,
    this.selectedColor,
    this.onColorChange,
    this.shrinkWrap = false,
    this.physics,
    this.iconSelected = Icons.check,
    this.circleSize = 45.0,
    this.spacing = 9.0,
    this.elevation,
  }) : super(key: key);

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  final _defaultValue = materialColors[0];

  List<ColorSwatch> _colors = materialColors;

  ColorSwatch _mainColor;
  Color _shadeColor;
  bool _isMainSelection = true;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @protected
  void didUpdateWidget(covariant MaterialColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    Color shadeColor = widget.selectedColor ?? _defaultValue;
    ColorSwatch mainColor = _findMainColor(shadeColor);
    if (mainColor == null) {
      mainColor = _colors[0];
      shadeColor = mainColor[500] ?? mainColor[400];
    } else {
      _mainColor = mainColor;
      _shadeColor = shadeColor;
    }
  }

  ColorSwatch _findMainColor(Color shadeColor) {
    for (final mainColor in _colors)
      if (_isShadeOfMain(mainColor, shadeColor)) return mainColor;

    return (shadeColor is ColorSwatch && _colors.contains(shadeColor))
        ? shadeColor
        : null;
  }

  bool _isShadeOfMain(ColorSwatch mainColor, Color shadeColor) {
    for (final shade in _getMaterialColorShades(mainColor)) {
      if (shade == shadeColor) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final listChildren = _isMainSelection ? _buildListMainColor(_colors) : _buildListShadesColor(_mainColor);

    // Size of dialog
    final double width = MediaQuery.of(context).size.width * .80;
    // Number of circle per line, depend on width and circleSize
    final int nbrCircleLine = width ~/ (widget.circleSize + widget.spacing);

    return Container(
      width: width,
      child: GridView.count(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: widget.spacing,
        mainAxisSpacing: widget.spacing,
        crossAxisCount: nbrCircleLine,
        children: listChildren,
      ),
    );
  }

  List<Widget> _buildListMainColor(List<ColorSwatch> colors) {
    return [
      for (final color in colors)
        CircleColor(
          color: color,
          circleSize: widget.circleSize,
          onColorChoose: () => _onMainColorSelected(color),
          isSelected: _mainColor == color,
          iconSelected: widget.iconSelected,
          elevation: widget.elevation,
        )
    ];
  }

  List<Color> _getMaterialColorShades(ColorSwatch color) {
    return <Color>[
      if (color[50] != null) color[50],
      if (color[100] != null) color[100],
      if (color[200] != null) color[200],
      if (color[300] != null) color[300],
      if (color[400] != null) color[400],
      if (color[500] != null) color[500],
      if (color[600] != null) color[600],
      if (color[700] != null) color[700],
      if (color[800] != null) color[800],
      if (color[900] != null) color[900],
    ];
  }

  List<Widget> _buildListShadesColor(ColorSwatch color) {
    return [
      for (final color in _getMaterialColorShades(color))
        CircleColor(
          color: color,
          circleSize: widget.circleSize,
          onColorChoose: () => _onShadeColorSelected(color),
          isSelected: _shadeColor == color,
          iconSelected: widget.iconSelected,
          elevation: widget.elevation,
        ),
    ];
  }
  
  void _onMainColorSelected(ColorSwatch color) {
    var isShadeOfMain = _isShadeOfMain(color, _shadeColor);
    final shadeColor = isShadeOfMain ? _shadeColor : (color[500] ?? color[400]);

    setState(() {
      _mainColor = color;
      _shadeColor = shadeColor;
    });
    if (widget.onColorChange != null) widget.onColorChange(shadeColor);
  }

  void _onShadeColorSelected(Color color) {
    setState(() => _shadeColor = color);
    if (widget.onColorChange != null) widget.onColorChange(color);
  }
}
