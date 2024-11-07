import 'package:flutter/material.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:nolilteo/config/s_text_style.dart';

import 'my_link_preview.dart';

class URLBox extends StatefulWidget {
  final String url;
  PreviewData? previewData;

  URLBox({Key? key, required this.url,required this.previewData}) : super(key: key);

  @override
  State<URLBox> createState() => _URLBoxState();
}

class _URLBoxState extends State<URLBox> {
  void onPreviewDataFetched(PreviewData data) {
    widget.previewData = data;
    setState(() { });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.previewData != null && widget.previewData!.image == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * sizeUnit),
      child: MyLinkPreview(
        enableAnimation: false,
        onPreviewDataFetched: (data) => onPreviewDataFetched(data),
        previewData: widget.previewData,
        text: widget.url,
        width: 80 * sizeUnit,
        openOnPreviewImageTap: true,
        metadataTextStyle: STextStyle.body2().copyWith(fontSize: 0),
        metadataTitleStyle: STextStyle.body2().copyWith(fontSize: 0),
        linkStyle: STextStyle.body2().copyWith(fontSize: 0),
        padding: const EdgeInsets.all(0),
      ),
    );
  }
}
