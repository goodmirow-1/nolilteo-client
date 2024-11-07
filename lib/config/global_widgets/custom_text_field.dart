import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../global_assets.dart';
import '../global_widgets/global_widget.dart';
import '../constants.dart';
import '../s_text_style.dart';
import 'get_extended_image.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
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
    this.minLines,
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
  final int? minLines;
  final Widget? suffixIcon;

  OutlineInputBorder outlinedInputBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1 * sizeUnit),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: nolColorOrange,
      keyboardType: textInputType,
      style: STextStyle.body3().copyWith(height: 21 / 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: STextStyle.body3().copyWith(color: nolColorGrey, height: 21 / 14),
        enabledBorder: outlinedInputBorder(nolColorGrey),
        focusedBorder: outlinedInputBorder(nolColorOrange),
        errorBorder: outlinedInputBorder(nolColorRed),
        contentPadding: EdgeInsets.all(16 * sizeUnit),
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: STextStyle.body5().copyWith(color: Colors.red),
        suffixIcon: suffixIcon,
        counterStyle: STextStyle.body4().copyWith(color: const Color(0xFFA0A0A0)),
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}

class CustomTextFieldWithContainer extends StatelessWidget {
  const CustomTextFieldWithContainer({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.errorText,
    this.focusNode,
    this.focusColor,
    this.textInputType,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.minLines,
    this.imageList
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final String? errorText;
  final FocusNode? focusNode;
  final Color? focusColor;
  final TextInputType? textInputType;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final Widget? suffixIcon;
  final List? imageList;

  OutlineInputBorder outlinedInputBorder(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1 * sizeUnit),
    borderRadius: BorderRadius.circular(14 * sizeUnit),
  );

  @override
  Widget build(BuildContext context) {
    Widget buildImageBox({required image, required int index}) {
      return Column(
        children: [
          Stack(
            children: [
              Container(
                width: 282 * sizeUnit,
                height: 282 * sizeUnit,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * sizeUnit),
                  border: Border.all(color: nolColorLightGrey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14 * sizeUnit),
                  child: kIsWeb
                      ? image is XFile
                      ? GetExtendedImage(url: image.path)
                      : GetExtendedImage(url: image)
                      : image is XFile
                      ? Image(
                    image: FileImage(File(image.path)),
                    fit: BoxFit.cover,
                  )
                      : GetExtendedImage(url: image.url),
                ),
              ),
              Positioned(
                top: 6 * sizeUnit,
                right: 8 * sizeUnit,
                child: InkWell(
                  onTap: () {

                  },
                  child: SvgPicture.asset(GlobalAssets.svgCancelInCircleFill, width: 20 * sizeUnit),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(
          color: focusColor!,
          width: 1 * sizeUnit,
          style: BorderStyle.solid
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 16 * sizeUnit, 8 * sizeUnit),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: nolColorOrange,
              keyboardType: textInputType,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText!,
                hintStyle: STextStyle.body3().copyWith(height: 21 / 14).copyWith(color: const Color(0xffbbbbbb)),
              ),
              style: STextStyle.body3().copyWith(height: 21 / 14),
              maxLines: maxLines,
              minLines: minLines,
              obscureText: obscureText,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
            ),
            if(imageList != null && imageList!.isNotEmpty) ... [
              ListView.builder(
                itemCount: imageList!.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) => buildImageBox(image: imageList![index], index: index)
              )
            ]
          ],
        ),
      ),
    );
  }
}