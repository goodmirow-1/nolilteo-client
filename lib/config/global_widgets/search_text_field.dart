import 'package:flutter/material.dart';
import '../global_widgets/global_widget.dart';
import '../constants.dart';
import '../s_text_style.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.errorText,
    this.focusNode,
    this.textInputType,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.autofocus = false,
    this.style,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final int? maxLength;
  final int maxLines;
  final Widget? suffixIcon;
  final bool autofocus;
  final TextStyle? style;

  OutlineInputBorder outlinedInputBorder (Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1.5 * sizeUnit),
    borderRadius: BorderRadius.circular(24 * sizeUnit),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: nolColorOrange,
      keyboardType: textInputType,
      style: style ?? STextStyle.body2(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: STextStyle.body2().copyWith(color: nolColorGrey, height: 1.1),
        enabledBorder: outlinedInputBorder(nolColorGrey),
        focusedBorder: outlinedInputBorder(nolColorOrange),
        errorBorder: outlinedInputBorder(nolColorRed),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 12 * sizeUnit),
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: STextStyle.body5().copyWith(color: Colors.red),
        suffixIcon: suffixIcon,
        counterText: '',
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      autofocus: autofocus,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
