import 'package:flutter/material.dart';
import 'package:nolilteo/config/constants.dart';
import '../global_widgets/global_widget.dart';
import '../s_text_style.dart';

class BottomLineTextField extends StatelessWidget {
  const BottomLineTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.errorText,
    this.focusNode,
    this.textInputType,
    this.textInputAction = TextInputAction.done,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.suffix,
    this.enable,
    this.widget,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int maxLines;
  final bool autofocus;
  final Widget? suffix;
  final bool? enable;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      cursorColor: nolColorOrange,
      cursorWidth: sizeUnit,
      style: STextStyle.body3().copyWith(height: maxLines > 1 ? 1.4 : 1),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: STextStyle.body3().copyWith(color: nolColorGrey),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: nolColorOrange),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1 * sizeUnit),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1 * sizeUnit),
        ),
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: STextStyle.error(),
        suffix: suffix,
        counterText: '',
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      enabled: enable,
    );
  }
}
