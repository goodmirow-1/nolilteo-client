import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/repository/post_repository.dart';
import '../../community/controllers/community_detail_controller.dart';

import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../config/global_page/user_detail_page.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../config/s_text_style.dart';
import '../../data/global_data.dart';
import '../../declare/declare_edit_page.dart';
import '../../declare/model/declare.dart';
import '../models/reply.dart';

class ReplyItem extends StatelessWidget {
  const ReplyItem({Key? key, required this.reply, this.onTap, required this.tag, this.isReplyReply = false, this.padding}) : super(key: key);

  final Reply reply;
  final bool isReplyReply;
  final GestureTapCallback? onTap;
  final String tag;
  final EdgeInsetsGeometry? padding;

  CommunityDetailController get controller => Get.find<CommunityDetailController>(tag: tag);

  bool get isNormal => (!reply.isBlind && reply.deleteType == deleteTypeShow); // 정상적인 글인지 (블라인드, 삭제 등이 아닌)

  @override
  Widget build(BuildContext context) {
    RxBool isLike = reply.isLike.obs;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: isReplyReply ? null : EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 8 * sizeUnit, vertical: 12 * sizeUnit),
        decoration: BoxDecoration(
          border: isReplyReply
              ? null
              : Border(
                  bottom: BorderSide(width: 1 * sizeUnit, color: nolColorLightGrey),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Get.to(() => UserDetailPage(userID: reply.userID)),
                  child: nickNameWidget(
                    reply.nickName,

                    maxWidth: Get.width - (isReplyReply ? 128 * sizeUnit : 108 * sizeUnit),
                  ),
                ),
                SizedBox(width: 8 * sizeUnit),
                Text(
                  GlobalFunction.timeCheck(GlobalFunction.replaceDate(reply.createdAt)),
                  style: STextStyle.body5().copyWith(color: nolColorGrey),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    if (reply.deleteType == 0) {
                      showReplyBottomSheet(context, isReplyReply: isReplyReply);
                    }
                  },
                  child: SvgPicture.asset(GlobalAssets.svgVerticalThreeDotSmall, width: 20 * sizeUnit),
                ),
              ],
            ),
            SizedBox(height: 4 * sizeUnit), // lineHeight 때문에 조절
            buildContents(), // 내용
            if (!isReplyReply && isNormal) ...[
              SizedBox(height: 8 * sizeUnit),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!controller.isMeeting) ...[
                    Obx(() => IconAndCount(
                          iconPath: isLike.value ? GlobalAssets.svgLikeActive : GlobalAssets.svgLike,
                          count: reply.likesLength,
                          onTap: () => GlobalFunction.loginCheck(
                            callback: () async => isLike(await controller.replyLikeFunc(reply)),
                          ),
                        )),
                    SizedBox(width: 12 * sizeUnit),
                  ],
                  InkWell(
                    onTap: () => controller.openReplyReplyTextField(reply),
                    child: SizedBox(
                        width: 48 * sizeUnit,
                        height: 20 * sizeUnit,
                        child: Center(
                          child: Text(
                            '답글 쓰기',
                            style: STextStyle.body5().copyWith(color: nolColorGrey),
                          ),
                        )),
                  ),
                ],
              ),
            ],
            if (!isReplyReply && reply.replyReplyList.isNotEmpty) ...[
              Obx(() => controller.showReplyReplyList.contains(reply.id)
                  ? Padding(
                      padding: EdgeInsets.only(left: 22 * sizeUnit, top: 12 * sizeUnit),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: List.generate(
                              reply.replyReplyList.length,
                              (index) {
                                if (GlobalData.blockedUserIDList.contains(reply.replyReplyList[index].userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우

                                return ReplyItem(
                                  reply: reply.replyReplyList[index],
                                  tag: tag,
                                  isReplyReply: true,
                                  padding: EdgeInsets.only(bottom: index == reply.replyReplyList.length - 1 ? 0 : 12 * sizeUnit),
                                );
                              },
                            ),
                          ),
                          if (reply.replyReplyList.length > 1) ...[
                            SizedBox(height: 6 * sizeUnit),
                            InkWell(
                              onTap: () => controller.showReplyReplyList.remove(reply.id),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 50 * sizeUnit),
                                height: 20 * sizeUnit,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '- 답글 접기',
                                  style: STextStyle.subTitle4().copyWith(color: nolColorOrange),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 6 * sizeUnit),
                      child: InkWell(
                        onTap: () => controller.showReplyReply(reply),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 100 * sizeUnit),
                          height: 20 * sizeUnit,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+ 답글 ${reply.replyReplyList.length}개 더 보기',
                            style: STextStyle.subTitle4().copyWith(color: nolColorOrange),
                          ),
                        ),
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }

  // 내용
  Widget buildContents() {
    final String text = reply.isBlind
        ? '신고누적으로 삭제된 ${isReplyReply ? '답글' : '댓글'}입니다.'
        : reply.deleteType == deleteTypeShow
            ? reply.contents
            : reply.deleteType == deleteTypeUser
                ? '삭제된 ${isReplyReply ? '답글' : '댓글'}입니다.'
                : '관리자에 의해 삭제된 ${isReplyReply ? '답글' : '댓글'}입니다.';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: STextStyle.body3().copyWith(
              fontSize: isNormal ? null : 12 * sizeUnit,
              color: isNormal ? null : nolColorGrey,
              height: 21 / 14,
            ),
          ),
          if (reply.isModify) ...[
            TextSpan(
              text: '  수정됨',
              style: STextStyle.body5().copyWith(color: nolColorGrey),
            ),
          ],
        ],
      ),
    );
  }

  // 댓글, 답글 바텀 시트
  void showReplyBottomSheet(BuildContext context, {required bool isReplyReply}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * sizeUnit),
          topRight: Radius.circular(20 * sizeUnit),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8 * sizeUnit),
            if (GlobalData.loginUser.id == reply.userID) ...[
              bottomSheetItem(
                text: '수정하기',
                onTap: () {
                  Get.back(); // 바텀 시트 끄기
                  controller.openModifyReplyTextField(reply);
                },
              ),
              bottomSheetItem(
                text: '삭제하기',
                onTap: () {
                  showCustomDialog(
                    title: '${isReplyReply ? '답글' : '댓글'}을 삭제하시겠어요?',
                    okFunc: () => controller.deleteReply(reply: reply, replyType: isReplyReply ? PostRepository.replyReplyType : PostRepository.replyType),
                    isCancelButton: true,
                    okText: '네',
                    cancelText: '아니오',
                  );
                },
              ),
            ] else ...[
              if (!isReplyReply) ...[
                bottomSheetItem(
                  text: '답글 쓰기',
                  onTap: () => GlobalFunction.loginCheck(
                    callback: () {
                      Get.back(); // 바텀 시트 끄기
                      controller.openReplyReplyTextField(reply);
                    },
                  ),
                ),
              ],
              bottomSheetItem(
                text: '프로필 보기',
                onTap: () => Get.to(() => UserDetailPage(userID: reply.userID)),
              ),
              bottomSheetItem(
                text: '${isReplyReply ? '답글' : '댓글'} 신고하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => Get.to(() => DeclareEditPage(declareType: isReplyReply ? Declare.declareTypeReplyReply : Declare.declareTypeReply, declaredID: reply.id)),
                ),
              ),
              bottomSheetItem(
                text: '사용자 신고하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypeUser, declaredID: reply.userID)),
                ),
              ),
              bottomSheetItem(
                text: '사용자 차단하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => controller.userBan(reply.userID),
                ),
              ),
            ],
            bottomSheetCancelButton(),
          ],
        );
      },
    );
  }
}
