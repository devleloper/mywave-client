import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'bounceable.dart';

class MyWaveTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const MyWaveTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  State<MyWaveTextField> createState() => _MyWaveTextFieldState();
}

class _MyWaveTextFieldState extends State<MyWaveTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    widget.controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isFocused ? AppTheme.tiffanyBlue : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: widget.prefixIcon,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: widget.suffixIcon ?? (hasText ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Bounceable(
                    onTap: _clear,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ) : null),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}
