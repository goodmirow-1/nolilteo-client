import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/global_widgets/get_extended_image.dart';
import './utils/my_utils.dart' show getPreviewData;


/// A widget that renders text with highlighted links.
/// Eventually unwraps to the full preview of the first found link
/// if the parsing was successful.
@immutable
class MyLinkPreview extends StatefulWidget {
  /// Creates [LinkPreview].
  const MyLinkPreview({
    super.key,
    this.animationDuration,
    this.corsProxy,
    this.enableAnimation = false,
    this.header,
    this.headerStyle,
    this.hideImage,
    this.imageBuilder,
    this.linkStyle,
    this.metadataTextStyle,
    this.metadataTitleStyle,
    this.onLinkPressed,
    required this.onPreviewDataFetched,
    this.openOnPreviewImageTap = false,
    this.openOnPreviewTitleTap = false,
    this.padding,
    required this.previewData,
    required this.text,
    this.textStyle,
    this.textWidget,
    this.userAgent,
    required this.width,
  });

  /// Expand animation duration.
  final Duration? animationDuration;

  /// CORS proxy to make more previews work on web. Not tested.
  final String? corsProxy;

  /// Enables expand animation. Default value is false.
  final bool? enableAnimation;

  /// Custom header above provided text.
  final String? header;

  /// Style of the custom header.
  final TextStyle? headerStyle;

  /// Hides image data from the preview.
  final bool? hideImage;

  /// Function that allows you to build a custom image.
  final Widget Function(String)? imageBuilder;

  /// Style of highlighted links in the text.
  final TextStyle? linkStyle;

  /// Style of preview's description.
  final TextStyle? metadataTextStyle;

  /// Style of preview's title.
  final TextStyle? metadataTitleStyle;

  /// Custom link press handler.
  final void Function(String)? onLinkPressed;

  /// Callback which is called when [PreviewData] was successfully parsed.
  /// Use it to save [PreviewData] to the state and pass it back
  /// to the [LinkPreview.previewData] so the [LinkPreview] would not fetch
  /// preview data again.
  final void Function(PreviewData) onPreviewDataFetched;

  /// Open the link when the link preview image is tapped. Defaults to false.
  final bool openOnPreviewImageTap;

  /// Open the link when the link preview title/description is tapped. Defaults to false.
  final bool openOnPreviewTitleTap;

  /// Padding around initial text widget.
  final EdgeInsets? padding;

  /// Pass saved [PreviewData] here so [LinkPreview] would not fetch preview
  /// data again
  final PreviewData? previewData;

  /// Text used for parsing.
  final String text;

  /// Style of the provided text.
  final TextStyle? textStyle;

  /// Widget to display above the preview. If null, defaults to a linkified [text].
  final Widget? textWidget;

  /// User agent to send as GET header when requesting link preview url.
  final String? userAgent;

  /// Width of the [LinkPreview] widget.
  final double width;

  @override
  State<MyLinkPreview> createState() => _MyLinkPreviewState();
}

class _MyLinkPreviewState extends State<MyLinkPreview>
    with SingleTickerProviderStateMixin {
  bool isFetchingPreviewData = false;
  bool shouldAnimate = false;

  late final Animation<double> _animation;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );

    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant MyLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!isFetchingPreviewData && widget.previewData == null) {
      _fetchData(widget.text);
    }

    if (widget.previewData != null && oldWidget.previewData == null) {
      setState(() {
        shouldAnimate = true;
      });
      _controller.reset();
      _controller.forward();
    } else if (widget.previewData != null) {
      setState(() {
        shouldAnimate = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewData = widget.previewData;

    if (previewData != null && _hasData(previewData)) {
      final aspectRatio = widget.previewData!.image == null
          ? null
          : widget.previewData!.image!.width /
          widget.previewData!.image!.height;

      return _containerWidget(
        animate: shouldAnimate,
        child: buildImageData(previewData),
        withPadding: aspectRatio == 1,
      );
    } else {
      return _containerWidget(animate: false);
    }
  }

  Widget buildImageData(PreviewData data){
    return InkWell(
      onTap: widget.openOnPreviewImageTap ? () => _onOpen(data.link!) : null,
      child: Column(
        children: [
          SizedBox(width: 16 * sizeUnit),
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * sizeUnit),
            child: widget.imageBuilder != null ?
            widget.imageBuilder!(data.image!.url) :
            GetExtendedImage(
              width: 80 * sizeUnit,
              height: 68 * sizeUnit,
              url: data.image!.url,
            ),
          )
        ],
      ),
    );
  }

  Widget _animated(Widget child) => SizeTransition(
    axis: Axis.vertical,
    axisAlignment: -1,
    sizeFactor: _animation,
    child: child,
  );

  Widget _containerWidget({
    required bool animate,
    bool withPadding = false,
    Widget? child,
  }) {
    final padding = widget.padding ??
        const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        );

    final shouldAnimate = widget.enableAnimation == true && animate;

    return Container(
      constraints: BoxConstraints(maxWidth: widget.width),
      padding: withPadding ? padding : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (withPadding && child != null)
                shouldAnimate ? _animated(child) : child,
            ],
          ),
          if (!withPadding && child != null)
            shouldAnimate ? _animated(child) : child,
        ],
      ),
    );
  }

  Future<PreviewData> _fetchData(String text) async {
    setState(() {
      isFetchingPreviewData = true;
    });

    final previewData = await getPreviewData(
      text,
      proxy: widget.corsProxy,
      userAgent: widget.userAgent,
    );
    _handlePreviewDataFetched(previewData);
    return previewData;
  }

  void _handlePreviewDataFetched(PreviewData previewData) async {
    await Future.delayed(
      widget.animationDuration ?? const Duration(milliseconds: 300),
    );

    if (mounted) {
      widget.onPreviewDataFetched(previewData);
      setState(() {
        isFetchingPreviewData = false;
      });
    }
  }

  bool _hasData(PreviewData? previewData) =>
      previewData?.title != null ||
          previewData?.description != null ||
          previewData?.image?.url != null;


  Future<void> _onOpen(String url) async {
    if (widget.onLinkPressed != null) {
      widget.onLinkPressed!(url);
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

}
