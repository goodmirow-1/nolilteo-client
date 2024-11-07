import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../config/constants.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../wbti/model/wbti_type.dart';

class WbtiJustResultPage extends StatelessWidget {
  const WbtiJustResultPage({Key? key, required this.wbti}) : super(key: key);
  final WbtiType wbti;
  static const String route = '/wbti_just_result';

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showWebAppBar: false,
      child: Scaffold(
        // appBar: customAppBar(context, ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(children: [SizedBox(height: 16 * sizeUnit)]),
              characterBox(wbti),
              SizedBox(height: 16 * sizeUnit),
              descriptionBox(),
              SizedBox(height: 16 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }

  Widget characterBox(WbtiType wbtiType) {
    return Container(
      width: 328 * sizeUnit,
      height: 318 * sizeUnit,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(wbtiType.title, style: STextStyle.body4().copyWith(color: nolColorOrange, fontWeight: FontWeight.bold)),
          Row(children: [SizedBox(height: 12 * sizeUnit)]),
          Text(wbtiType.name, style: STextStyle.headline2()),
          SizedBox(height: 40 * sizeUnit),
          SvgPicture.asset(
            wbtiType.src,
            height: 150 * sizeUnit,
          ),
        ],
      ),
    );
  }

  Widget descriptionBox() {
    return Container(
      width: 328 * sizeUnit,
      decoration: BoxDecoration(
        color: nolColorOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      ),
      padding: EdgeInsets.all(24 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('성향과 업무 스타일', style: STextStyle.highlight3()),
          SizedBox(height: 8 * sizeUnit),
          Text(
            wbti.workStyle,
            style: STextStyle.body3().copyWith(height: 1.8),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 24 * sizeUnit),
          Text('협업 방법', style: STextStyle.highlight3()),
          SizedBox(height: 8 * sizeUnit),
          Text(
            wbti.howToCoWork,
            style: STextStyle.body3().copyWith(height: 1.8),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 24 * sizeUnit),
          Text('찰떡궁합 초콜릿', style: STextStyle.highlight3()),
          SizedBox(height: 16 * sizeUnit),
          matchCharBox(WbtiType.getType(wbti.perfectMatchType)),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget matchCharBox(WbtiType wbtiType) {
    return Container(
      width: 280 * sizeUnit,
      height: 280 * sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
      ),
      child: Column(
        children: [
          Row(children: [SizedBox(height: 24 * sizeUnit)]),
          Text(wbtiType.title, style: STextStyle.subTitle3().copyWith(color: nolColorOrange)),
          SizedBox(height: 8 * sizeUnit),
          Text(wbtiType.name, style: STextStyle.headline2()),
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                wbtiType.src,
                height: 150 * sizeUnit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
