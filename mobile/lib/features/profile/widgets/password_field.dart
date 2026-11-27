import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/features/profile/widgets/profile_input_field.dart';

/// Password input field with an accessible visibility toggle button (>=44dp tap target).
class PasswordField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final bool isValid;
  final ValueChanged<String>? onChanged;
  final int visibilityResetTick;

  const PasswordField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    this.error,
    this.isValid = false,
    this.onChanged,
    this.visibilityResetTick = 0,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  void didUpdateWidget(covariant PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visibilityResetTick != oldWidget.visibilityResetTick) {
      _visible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileInputField(
      label: widget.label,
      placeholder: widget.placeholder,
      controller: widget.controller,
      focusNode: widget.focusNode,
      error: widget.error,
      isValid: widget.isValid,
      obscureText: !_visible,
      onChanged: widget.onChanged,
      rightAction: Semantics(
        button: true,
        label: _visible
            ? 'Sembunyikan ${widget.label}'
            : 'Tampilkan ${widget.label}',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _visible = !_visible),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              _visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: SplashColors.purpleDark,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
