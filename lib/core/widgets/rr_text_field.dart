import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Premium styled text field with animated focus ring.
class RRTextField extends StatefulWidget {
  const RRTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool autofocus;

  @override
  State<RRTextField> createState() => _RRTextFieldState();
}

class _RRTextFieldState extends State<RRTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofocus: widget.autofocus,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      size: 20,
                    ),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
