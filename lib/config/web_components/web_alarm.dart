import 'package:flutter/material.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/notification/notification_page.dart';

import '../global_widgets/global_widget.dart';

class WebAlarm extends StatelessWidget {
  const WebAlarm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 56 * sizeUnit,
          right: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width * 0.1 : 0,
          child: Container(
            width: 388 * sizeUnit,
            height: 780 * sizeUnit,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14 * sizeUnit),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 16 * sizeUnit,
                ),
              ],
            ),
            child: const TotalNotificationPage(),
          ),
        ),
      ],
    );
  }
}
