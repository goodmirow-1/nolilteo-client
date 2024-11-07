import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/s_text_style.dart';

class WebOptionBox extends StatelessWidget {
  const WebOptionBox({Key? key, required this.children}) : super(key: key);

  final List<WebOptionBoxItem> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 194 * sizeUnit,
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 12 * sizeUnit, 16 * sizeUnit, 8 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(
          width: 1.5 * sizeUnit,
          color: nolColorOrange,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(children.length, (index) => children[index]),
      ),
    );
  }
}

class WebOptionBoxItem extends StatelessWidget {
  const WebOptionBoxItem({Key? key, required this.text, required this.onTap}) : super(key: key);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40 * sizeUnit,
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: STextStyle.body2()),
              ),
              SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }
}
