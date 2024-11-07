import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/community_detail_page.dart';
import 'package:nolilteo/community/controllers/community_reply_page_controller.dart';
import 'package:nolilteo/community/models/reply.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/data/global_data.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_page/user_detail_page.dart';
import '../config/global_widgets/search_text_field.dart';
import '../config/s_text_style.dart';
import '../declare/declare_edit_page.dart';
import '../declare/model/declare.dart';
import '../repository/post_repository.dart';

class CommunityReplyPage extends StatelessWidget {
  CommunityReplyPage({Key? key, required this.replyID}) : super(key: key);

  final int replyID;

  final CommunityReplyPageController controller = Get.put(CommunityReplyPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(
          context,
          controller: controller.scrollController,
          title: '댓글',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16 * sizeUnit),
              child: Center(
                child: nolChips(text: '원문보기', onTap: () => Get.toNamed('${CommunityDetailPage.route}/${controller.reply.parentsID}')),
              ),
            ),
          ],
        ),
        body: GetBuilder<CommunityReplyPageController>(
            initState: (state) => controller.fetchData(replyID),
            builder: (_) {
              if (controller.loading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

              return GestureDetector(
                onTap: () => GlobalFunction.unFocus(context),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: controller.scrollController,
                        children: [
                          replyItem(
                            context: context,
                            reply: controller.reply,
                            isReplyReply: false,
                          ),
                        ],
                      ),
                    ),
                    buildTextField(context), // 텍스트 필드
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget replyItem({required BuildContext context, required Reply reply, required bool isReplyReply, EdgeInsetsGeometry? padding}) {
    RxBool isLike = reply.isLike.obs;

    return Container(
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
              nickNameWidget(
                reply.nickName,
                maxWidth: Get.width - (isReplyReply ? 128 * sizeUnit : 108 * sizeUnit),
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
                    showReplyBottomSheet(context, reply: reply, isReplyReply: isReplyReply);
                  }
                },
                child: SvgPicture.asset(GlobalAssets.svgVerticalThreeDotSmall, width: 20 * sizeUnit),
              ),
            ],
          ),
          SizedBox(height: 4 * sizeUnit), // lineHeight 때문에 조절함
          buildContents(reply: reply, isReplyReply: isReplyReply), // 내용
          if (!isReplyReply && controller.isNormal(reply)) ...[
            SizedBox(height: 8 * sizeUnit),
            Row(
              children: [
                Obx(() => IconAndCount(
                      iconPath: isLike.value ? GlobalAssets.svgLikeActive : GlobalAssets.svgLike,
                      count: reply.likesLength,
                      onTap: () => GlobalFunction.loginCheck(
                        callback: () async => isLike(await controller.replyLikeFunc()),
                      ),
                    )),
                SizedBox(width: 12 * sizeUnit),
                InkWell(
                  onTap: () => controller.focusNode.requestFocus(),
                  child: SizedBox(
                    width: 48 * sizeUnit,
                    height: 20 * sizeUnit,
                    child: Center(
                      child: Text('답글 쓰기', style: STextStyle.body5().copyWith(color: nolColorGrey)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!isReplyReply && reply.replyReplyList.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(left: 22 * sizeUnit, top: 12 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(
                      reply.replyReplyList.length,
                      (index) {
                        if (GlobalData.blockedUserIDList.contains(reply.replyReplyList[index].userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우

                        return replyItem(
                          context: context,
                          reply: reply.replyReplyList[index],
                          isReplyReply: true,
                          padding: EdgeInsets.only(bottom: index == reply.replyReplyList.length - 1 ? 0 : 12 * sizeUnit),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 내용
  Widget buildContents({required Reply reply, required bool isReplyReply}) {
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
              fontSize: controller.isNormal(reply) ? null : 12 * sizeUnit,
              color: controller.isNormal(reply) ? null : nolColorGrey,
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
  void showReplyBottomSheet(BuildContext context, {required Reply reply, required bool isReplyReply}) {
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
                      controller.focusNode.requestFocus();
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
                  callback: () => controller.userBan(),
                ),
              ),
            ],
            bottomSheetCancelButton(),
          ],
        );
      },
    );
  }

  // 텍스트 필드
  Column buildTextField(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => controller.showNickNameBox.value
              ? textFieldStateInfoBox(
                  text: controller.selectedModifyReply.value.id == nullInt
                      ? controller.reply.nickName
                      : controller.selectedModifyReply.value is ReplyReply
                          ? '답글 수정중..'
                          : '댓글 수정중..',
                  cancelFunc: () {
                    if (controller.selectedModifyReply.value.id != nullInt) controller.selectedModifyReply(Reply.nullReply);
                    controller.textEditingController.clear();
                    controller.replyContents('');
                    controller.showNickNameBox(false);
                    controller.focusNode.unfocus();
                  },
                )
              : const SizedBox.shrink(),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SearchTextField(
                  controller: controller.textEditingController,
                  textInputType: TextInputType.multiline,
                  focusNode: controller.focusNode,
                  hintText: '매너있는 댓글문화를 만들어요 :)',
                  onChanged: (value) => controller.replyContents(value),
                  maxLength: 500,
                  maxLines: 3,
                  style: STextStyle.body2().copyWith(height: 1.4),
                  onSubmitted: (value) => controller.writeReplyReply(),
                ),
              ),
              SizedBox(width: 4 * sizeUnit),
              InkWell(
                  onTap: () {
                    if (controller.selectedModifyReply.value.id == nullInt) {
                      controller.writeReplyReply(); // 답글 쓰기
                    } else {
                      if (controller.selectedModifyReply.value is ReplyReply) {
                        controller.modifyReplyReply(); // 답글 수정
                      } else {
                        controller.modifyReply(); // 댓글 수정
                      }
                    }
                  },
                  child: SizedBox(
                    width: 42 * sizeUnit,
                    height: 36 * sizeUnit,
                    child: Center(
                      child: Obx(
                        () => Text(
                          '입력',
                          style: STextStyle.body3().copyWith(color: controller.replyContents.value.isEmpty ? nolColorGrey : nolColorOrange),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // 텍스트 필드 상태 정보 박스
  Container textFieldStateInfoBox({required String text, required GestureTapCallback cancelFunc}) {
    return Container(
      width: double.infinity,
      height: 40 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 10 * sizeUnit),
      color: nolColorLightGrey,
      child: Row(
        children: [
          SvgPicture.asset(GlobalAssets.svgReplyArrow, width: 20 * sizeUnit),
          SizedBox(width: 4 * sizeUnit),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Get.width - 76 * sizeUnit),
            child: Text(
              text,
              style: STextStyle.body3().copyWith(color: nolColorGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: cancelFunc,
            child: SvgPicture.asset(GlobalAssets.svgCancel, width: 20 * sizeUnit),
          ),
        ],
      ),
    );
  }
}
