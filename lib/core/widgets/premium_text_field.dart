import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? helperText;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const PremiumTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.helperText,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.hintText,
    this.onChanged,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isHovered = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFocused = _focusNode.hasFocus;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isFocused ? theme.primaryColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (isFocused)
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                maxLines: widget.maxLines,
                onChanged: widget.onChanged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: theme.disabledColor, fontSize: 14),
                  filled: true,
                  fillColor: widget.readOnly 
                      ? theme.disabledColor.withOpacity(0.05)
                      : (_isHovered && !isFocused)
                          ? theme.hoverColor.withOpacity(0.05)
                          : theme.cardColor,
                  prefixIcon: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: 20,
                          color: isFocused ? theme.primaryColor : theme.iconTheme.color?.withOpacity(0.5),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _isHovered ? theme.dividerColor : theme.dividerColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          ),
          if (widget.helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
