import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscureText; // added
  final String? initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    required this.label,
    required this.hint,
    this.obscureText = false, // added
    this.initialValue,
    this.controller,
    this.validator,
    super.key,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _controller;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _obscure = widget.obscureText; // honor the widget's obscureText
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: MyColors.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          obscureText: _obscure,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
            // show eye icon only for obscureText fields
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.remove_red_eye, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
