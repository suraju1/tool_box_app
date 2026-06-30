import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebPriceRangeSelector extends StatefulWidget {
  final RangeValues initialValues;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final String label;

  const WebPriceRangeSelector({
    super.key,
    required this.initialValues,
    this.min = 0,
    this.max = 200000,
    required this.onChanged,
    this.label = 'Desired Price Range',
  });

  @override
  State<WebPriceRangeSelector> createState() => _WebPriceRangeSelectorState();
}

class _WebPriceRangeSelectorState extends State<WebPriceRangeSelector> {
  late RangeValues _currentRange;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  final NumberFormat _formatter = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    _currentRange = widget.initialValues;
    _minController =
        TextEditingController(text: _currentRange.start.toInt().toString());
    _maxController =
        TextEditingController(text: _currentRange.end.toInt().toString());
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _updateFromSlider(RangeValues values) {
    setState(() {
      _currentRange = values;
      _minController.text = values.start.toInt().toString();
      _maxController.text = values.end.toInt().toString();
    });
    widget.onChanged(values);
  }

  void _updateFromMinText(String value) {
    if (value.isEmpty) return;
    double? newValue = double.tryParse(value);
    if (newValue != null) {
      double clampedValue = newValue.clamp(widget.min, _currentRange.end);
      setState(() {
        _currentRange = RangeValues(clampedValue, _currentRange.end);
      });
      widget.onChanged(_currentRange);
    }
  }

  void _updateFromMaxText(String value) {
    if (value.isEmpty) return;
    double? newValue = double.tryParse(value);
    if (newValue != null) {
      double clampedValue = newValue.clamp(_currentRange.start, widget.max);
      setState(() {
        _currentRange = RangeValues(_currentRange.start, clampedValue);
      });
      widget.onChanged(_currentRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.label} : ₹${_formatter.format(_currentRange.start.toInt())} - ₹${_formatter.format(_currentRange.end.toInt())}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: FontFamily.openSans,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _currentRange,
          min: widget.min,
          max: widget.max,
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).dividerColor,
          onChanged: _updateFromSlider,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildPriceField(
                    'Min Price', _minController, _updateFromMinText)),
            const SizedBox(width: 24),
            Expanded(
                child: _buildPriceField(
                    'Max Price', _maxController, _updateFromMaxText)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Text('₹',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
