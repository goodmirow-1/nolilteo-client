import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:nolilteo/community/componets/url_box.dart';

import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import '../../config/global_widgets/get_extended_image.dart';

import '../../config/constants.dart';
import '../../config/global_widgets/global_widget.dart';
import '../models/post.dart';
import '../../config/global_function.dart';
import '../../config/s_text_style.dart';

// ignore: must_be_immutable
class PostCard extends StatelessWidget {
  PostCard({Key? key, required this.post, required this.onTap, this.meetingPost, this.showCrown = false}) : super(key: key);

  final Post post;
  final GestureTapCallback onTap;
  final MeetingPost? meetingPost;
  final bool showCrown;

  final TextStyle contentsTextStyle = STextStyle.body3().copyWith(height: 21 / 14);
  final double marginValue = 16 * sizeUnit;

  @override
  Widget build(BuildContext context) {

    var validURL = GlobalFunction.checkURL(post.contents);

    return InkWell(
      onTap: onTap,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.fromLTRB(marginValue, 0, marginValue, marginValue),
        padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 12 * sizeUnit),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: nolColorLightGrey, width: 1.5 * sizeUnit),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.isHot) ...[
                  nolTag('HOT', bgColor: nolColorOrange, fontColor: Colors.white),
                  SizedBox(width: 4 * sizeUnit),
                ],
                nolTag(post.type == Post.postTypeWbti ? WbtiType.getType(post.category).name : post.category),
                if (post.tag.isNotEmpty) ...[
                  SizedBox(width: 4 * sizeUnit),
                  nolTag('#${post.tag}'),
                ],
                if (meetingPost != null) ...[
                  SizedBox(width: 4 * sizeUnit),
                  nolTag('@${meetingPost!.location}'),
                ] else ...[
                  const Spacer(),
                  IconAndCount(iconPath: GlobalAssets.svgEye, count: post.hitCount, spaceWidth: 2 * sizeUnit),
                ],
              ],
            ),
            if (meetingPost != null) ...[
              SizedBox(height: 12 * sizeUnit),
              meetingDateAndLimit(meetingPost!), // 미팅 날짜, 제한 사항
              SizedBox(height: 12 * sizeUnit),
            ] else ...[
              SizedBox(height: 16 * sizeUnit),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: STextStyle.subTitle1(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8 * sizeUnit),
                      Text(
                        post.contents,
                        style: contentsTextStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (post.imageUrlList.isNotEmpty) ...[
                  SizedBox(width: 16 * sizeUnit),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                    child: GetExtendedImage(
                      width: 80 * sizeUnit,
                      height: 68 * sizeUnit,
                      url: post.imageUrlList.first.url,
                    ),
                  ),
                ] else if( validURL != "") ... [
                  URLBox(url: validURL, previewData: post.previewData,)
                ]
              ],
            ),
            SizedBox(height: showCrown ? 15 * sizeUnit : 16 * sizeUnit),
            Row(
              children: [
                if (showCrown) ...[
                  SvgPicture.asset(GlobalAssets.svgCrown, width: 14 * sizeUnit),
                  SizedBox(width: 4 * sizeUnit),
                ],
                nickNameWidget(post.nickName, maxWidth: Get.width - 68 * sizeUnit),
              ],
            ),
            SizedBox(height: 12 * sizeUnit),
            buildLine(),
            SizedBox(height: 12 * sizeUnit),
            Row(
              children: [
                if (meetingPost != null && meetingPost!.isClosed) ...[
                  nolTag('모집마감', bgColor: nolColorGrey, fontColor: Colors.white, borderColor: nolColorGrey),
                ] else ...[
                  Text(
                    GlobalFunction.timeCheck(GlobalFunction.replaceDate(post.createdAt)),
                    style: STextStyle.body5().copyWith(color: nolColorGrey),
                  ),
                ],
                const Spacer(),
                if (meetingPost != null) ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        GlobalAssets.svgGathering,
                        width: 20 * sizeUnit,
                        color: meetingPost!.userID == GlobalData.loginUser.id
                            ? nolColorOrange
                            : meetingPost!.meetingMembers.contains(GlobalData.loginUser.id)
                                ? nolColorOrange
                                : nolColorGrey,
                      ),
                      SizedBox(width: 4 * sizeUnit),
                      Text(
                        meetingPost!.meetingMembers.length > 99 ? '99+' : '${meetingPost!.meetingMembers.length}',
                        style: STextStyle.body5(),
                      ),
                      if (meetingPost!.personnel != null)
                        Text(
                          '/${meetingPost!.personnel}',
                          style: STextStyle.body5(),
                        ),
                    ],
                  ),
                ] else ...[
                  IconAndCount(
                    iconPath: post.isLike ? GlobalAssets.svgBigLikeActive : GlobalAssets.svgBigLike,
                    count: post.likesLength,
                  ),
                ],
                if (meetingPost == null) ...[
                  SizedBox(width: 8 * sizeUnit),
                  IconAndCount(
                    iconPath: post.isWriteReply ? GlobalAssets.svgReplyActive : GlobalAssets.svgReply,
                    count: post.repliesLength,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 미팅 날짜, 제한 사항
  static DefaultTextStyle meetingDateAndLimit(MeetingPost meetingPost) {
    final DateTime? formatDate = meetingPost.meetingDate == null ? null : DateTime.parse(meetingPost.meetingDate!).add(const Duration(hours: 9));

    return DefaultTextStyle(
      style: STextStyle.body4(),
      child: Row(
        children: [
          SvgPicture.asset(GlobalAssets.svgCalendar, width: 20 * sizeUnit),
          SizedBox(width: 4 * sizeUnit),
          if (meetingPost.meetingDate != null) ...[
            RichText(
              text: TextSpan(
                style: STextStyle.body4(),
                children: [
                  TextSpan(text: intl.DateFormat('M월 d일').format(formatDate!)),
                  TextSpan(text: ' ${GlobalFunction.changeDayOfTheWeekToKorean(intl.DateFormat.E().format(formatDate))} '),
                  TextSpan(text: intl.DateFormat('HH:mm').format(formatDate)),
                ],
              ),
            ),
          ] else ...[
            const Text('상시모집'),
          ],
          SizedBox(width: 12 * sizeUnit),
          if (meetingPost.startAge != null || meetingPost.sex != MeetingPost.anyGender) ...[
            SvgPicture.asset(GlobalAssets.svgBan, width: 20 * sizeUnit),
            SizedBox(width: 4 * sizeUnit),
          ],
          Text(MeetingPost.getAgeLimit(startAge: meetingPost.startAge, endAge: meetingPost.endAge) ?? ''),
          if ((meetingPost.startAge != null || meetingPost.endAge != null) && meetingPost.sex != MeetingPost.anyGender) const Text(' / '),
          if (meetingPost.sex != MeetingPost.anyGender) Text(meetingPost.sex == MeetingPost.onlyMale ? '남자만' : '여자만'),
        ],
      ),
    );
  }
}
