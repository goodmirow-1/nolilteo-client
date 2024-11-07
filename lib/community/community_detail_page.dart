import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/componets/post_card.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/config/global_widgets/search_text_field.dart';
import 'package:nolilteo/config/web_components/web_option_box.dart';
import 'package:nolilteo/meeting/participants_page.dart';
import 'package:nolilteo/network/firebaseNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../community/controllers/community_detail_controller.dart';
import '../../config/global_widgets/base_widget.dart';
import '../../config/global_widgets/get_extended_image.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';
import '../../declare/declare_edit_page.dart';

import '../config/constants.dart';
import '../config/global_function.dart';
import '../config/global_page/user_detail_page.dart';
import '../config/s_text_style.dart';
import '../declare/model/declare.dart';
import '../home/controllers/main_page_controller.dart';
import '../wbti/model/wbti_type.dart';
import 'board_page.dart';
import 'componets/reply_Item.dart';
import 'models/post.dart';
import 'models/reply.dart';

class CommunityDetailPage extends StatelessWidget {
  static const String route = '/post';
  static const String meetingRoute = '/meeting_post';

  CommunityDetailPage({Key? key, required this.isMeeting}) : super(key: key);

  final bool isMeeting;

  final CommunityDetailController controller = Get.put(CommunityDetailController(tag: GlobalData.detailPageCount.toString()), tag: GlobalData.detailPageCount.toString());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityDetailController>(
        tag: controller.tag,
        initState: (_) => controller.fetchData(isMeeting),
        builder: (_) {
          if (controller.fetchLoading) return const Material(color: Colors.white, child: Center(child: CircularProgressIndicator(color: nolColorOrange)));

          return BaseWidget(
              showSideSection: true,
              child: Scaffold(
                  appBar: buildAppBar(context),
                  body: GestureDetector(
                    onTap: () {
                      GlobalFunction.unFocus(context);
                      if (kIsWeb) controller.showWebOptionsBox(false);
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: customRefreshIndicator(
                                onRefresh: controller.onRefresh,
                                child: ListView(
                                  controller: controller.scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    buildPost(), // 게시글
                                    Divider(height: 8 * sizeUnit, thickness: 8 * sizeUnit, color: nolColorLightGrey),
                                    buildReply(), // 댓글
                                  ],
                                ),
                              ),
                            ),
                            if (controller.isParticipation) buildTextField(context), // 텍스트 필드
                          ],
                        ),
                        if (kIsWeb) ...[
                          Positioned(
                            right: 0,
                            child: Obx(() => controller.showWebOptionsBox.value ? webOptionBox() : const SizedBox.shrink()),
                          ),
                        ],
                      ],
                    ),
                  )));
        });
  }

  Column buildTextField(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.selectedReply.value.id != nullInt
            ? textFieldStateInfoBox(
                text: controller.selectedReply.value.nickName,
                cancelFunc: () {
                  controller.selectedReply(Reply.nullReply);
                  GlobalFunction.unFocus(context);
                },
              )
            : controller.selectedModifyReply.value.id != nullInt
                ? textFieldStateInfoBox(
                    text: controller.selectedModifyReply.value is ReplyReply ? '답글 수정중..' : '댓글 수정중..',
                    cancelFunc: () {
                      controller.selectedModifyReply(Reply.nullReply);
                      controller.textEditingController.clear();
                      GlobalFunction.unFocus(context);
                    },
                  )
                : const SizedBox.shrink()),
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
                  maxLength: controller.replyMaxLength,
                  maxLines: 3,
                  style: STextStyle.body2().copyWith(height: 1.4),
                  onSubmitted: (value) async {
                    if (controller.selectedReply.value.id == nullInt) {
                      final prefs = await SharedPreferences.getInstance();

                      if (kIsWeb || prefs.containsKey('agree')) {
                        controller.writeReply(FirebaseNotifications.isSubscribe);
                      } else {
                        showPostAlarm();
                      }
                    } else {
                      controller.writeReplyReply();
                    }
                  },
                ),
              ),
              SizedBox(width: 4 * sizeUnit),
              InkWell(
                  onTap: () async {
                    if (controller.selectedReply.value.id == nullInt && controller.selectedModifyReply.value.id == nullInt) {
                      final prefs = await SharedPreferences.getInstance();

                      if (kIsWeb || prefs.containsKey('agree')) {
                        controller.writeReply(FirebaseNotifications.isSubscribe); // 댓글 쓰기
                      } else {
                        showPostAlarm();
                      }
                    } else if (controller.selectedModifyReply.value.id != nullInt) {
                      if (controller.selectedModifyReply.value is ReplyReply) {
                        controller.modifyReplyReply(); // 답글 수정
                      } else {
                        controller.modifyReply(); // 댓글 수정
                      }
                    } else {
                      controller.writeReplyReply(); // 답글 쓰기
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

  void showPostAlarm() {
    showCustomDialog(
      title: '댓글 단 모든 게시물을 구독하고\n알림을 계속 받으시겠어요?',
      description: '마이페이지>설정>푸시알림설정에서 변경가능해요',
      okFunc: () async {
        Get.back();
        controller.writeReply(true);
      },
      cancelFunc: () async {
        Get.back();
        controller.writeReply(false);
      },
      isCancelButton: true,
      okText: '네',
      cancelText: '아니오',
    );
  }

  PreferredSize? buildAppBar(BuildContext context) {
    return customAppBar(
      context,
      controller: controller.scrollController,
      leadingWidth: double.infinity,
      leading: Row(
        children: [
          if (Responsive.isMobile(context)) ...[
            SizedBox(width: 12 * sizeUnit),
            InkWell(
              onTap: () => Get.back(),
              child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
            ),
            if (GlobalData.detailPageCount > 1) ...[
              SizedBox(width: Responsive.isMobile(context) ? 24 * sizeUnit : 12 * sizeUnit),
              InkWell(
                onTap: () {
                  GlobalFunction.goToMainPage(); // 메인 페이지로 이동
                  MainPageController.to.changePage(0);
                },
                child: SvgPicture.asset(GlobalAssets.svgHomeOutline, width: 24 * sizeUnit),
              ),
            ],
          ],
        ],
      ),
      actions: [
        if (controller.post.userID != GlobalData.loginUser.id) ...[
          if (controller.post.isSubscribe) ...[
            Center(
              child: InkWell(
                onTap: () async {
                  controller.insertOrDestroy(false);
                },
                child: SvgPicture.asset(
                  GlobalAssets.svgAlarmActive,
                  width: 24 * sizeUnit,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: InkWell(
                onTap: () async {
                  controller.insertOrDestroy(true);
                },
                child: SvgPicture.asset(
                  GlobalAssets.svgAlarm,
                  color: nolColorGrey,
                  width: 24 * sizeUnit,
                ),
              ),
            ),
          ],
        ],
        SizedBox(width: 24 * sizeUnit),
        Center(
          child: InkWell(
            onTap: () {
              if (kIsWeb) {
                controller.showWebOptionsBox.toggle();
              } else {
                showPostBottomSheet(context);
              }
            },
            child: SvgPicture.asset(
              GlobalAssets.svgVerticalThreeDot,
              width: 24 * sizeUnit,
            ),
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
      ],
    );
  }

  Widget buildPost() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 16 * sizeUnit, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  nolTag(controller.post.type == Post.postTypeWbti ? WbtiType.getType(controller.post.category).name : controller.post.category, tapCallback: () {
                    Get.offNamed('${BoardPage.route}/${GlobalFunction.encodeUrl(controller.post.category)}?type=${controller.post.type}');
                  }),
                  SizedBox(width: 4 * sizeUnit),
                  if (controller.post.tag.isNotEmpty) ...[
                    nolTag('#${controller.post.tag}', tapCallback: () {
                      Get.offNamed('${BoardPage.route}/${GlobalFunction.encodeUrl('#${controller.post.tag}')}?type=${controller.post.type}');
                    }),
                    SizedBox(width: 4 * sizeUnit),
                  ],
                  if (controller.isMeeting) ...[
                    nolTag('@${controller.meetingPost.location}'),
                  ] else ...[
                    const Spacer(),
                    IconAndCount(iconPath: GlobalAssets.svgEye, count: controller.post.hitCount, spaceWidth: 2 * sizeUnit),
                  ]
                ],
              ),
              if (controller.isMeeting) ...[
                SizedBox(height: 12 * sizeUnit),
                PostCard.meetingDateAndLimit(controller.meetingPost), // 미팅 날짜, 제한 사항
                if (controller.meetingPost.detailLocation != null) ...[
                  SizedBox(height: 4 * sizeUnit),
                  Row(
                    children: [
                      SvgPicture.asset(GlobalAssets.svgPinDrop, width: 20 * sizeUnit),
                      SizedBox(width: 4 * sizeUnit),
                      Text(controller.meetingPost.detailLocation!, style: STextStyle.body4()),
                    ],
                  ),
                ],
              ],
              SizedBox(height: 16 * sizeUnit),
              Text(controller.post.title, style: STextStyle.subTitle1().copyWith(height: 1.2)),
              if (controller.isMeeting) ...[
                SizedBox(height: 16 * sizeUnit),
                Text(
                  controller.post.contents,
                  style: STextStyle.body3().copyWith(height: 21 / 14),
                ),
                if (controller.post.imageUrlList.isNotEmpty) ...[
                  SizedBox(height: 12 * sizeUnit),
                  buildImage(), // 이미지
                ],
                SizedBox(height: 24 * sizeUnit),
                Center(
                  child: InkWell(
                    onTap: () {
                      if (controller.isParticipation) {
                        controller.goToLink(controller.meetingPost.url); // 모임링크
                      } else {
                        GlobalFunction.loginCheck(callback: () => controller.participate()); // 참가하기
                      }
                    },
                    child: Container(
                      width: 92 * sizeUnit,
                      height: 32 * sizeUnit,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: controller.isParticipation
                            ? controller.meetingPost.url.isEmpty
                                ? nolColorGrey
                                : nolColorOrange
                            : controller.meetingPost.isClosed
                                ? nolColorGrey
                                : controller.meetingPost.personnel == null
                                    ? nolColorOrange
                                    : controller.meetingPost.personnel! <= controller.meetingPost.meetingMembers.length
                                        ? nolColorGrey
                                        : nolColorOrange,
                        borderRadius: BorderRadius.circular(28 * sizeUnit),
                      ),
                      child: Text(
                        controller.isParticipation
                            ? '모임링크'
                            : controller.meetingPost.isClosed
                                ? '모짐 마감'
                                : '참가하기',
                        style: STextStyle.body2().copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * sizeUnit),
              ] else ...[
                SizedBox(height: 12 * sizeUnit),
                if (controller.contentsList.isEmpty) ...[
                  Text(
                    controller.post.contents,
                    style: STextStyle.body3().copyWith(height: 21 / 14),
                  ),
                ] else ...[
                  Column(
                    children: List.generate(controller.contentsWithURLList.length, (index) {
                      if (controller.contentsWithURLList[index].isURL == false) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.contentsWithURLList[index].contents,
                            style: STextStyle.body3().copyWith(height: 21 / 14),
                          ),
                        );
                      } else {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 4 * sizeUnit,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: nolColorLightGrey,
                                    border: Border.all(
                                      width: 0.5 * sizeUnit,
                                      color: nolColorLightGrey,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(14 * sizeUnit))),
                                child: LinkPreview(
                                  enableAnimation: true,
                                  onPreviewDataFetched: (data) => controller.onPreviewDataFetched(data, index: index),
                                  previewData: controller.previewDataList[index],
                                  text: controller.contentsWithURLList[index].contents,
                                  width: double.infinity,
                                  openOnPreviewImageTap: true,
                                  openOnPreviewTitleTap: true,
                                ),
                              ),
                              SizedBox(
                                height: 4 * sizeUnit,
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                  )
                ],
                SizedBox(height: 16 * sizeUnit),
                if (controller.post.imageUrlList.isNotEmpty) ...[
                  buildImage(), // 이미지
                ],
                SizedBox(height: controller.contentsList.isNotEmpty ? 16 * sizeUnit : 8 * sizeUnit),
              ],
              InkWell(
                onTap: () => Get.to(() => UserDetailPage(userID: controller.post.userID)),
                child: nickNameWidget(
                  controller.post.nickName,
                  maxWidth: Get.width - 32 * sizeUnit,
                ),
              ),
              SizedBox(height: 16 * sizeUnit),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
          child: buildLine(),
        ),
        SizedBox(height: 10 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Row(
            children: [
              Text(GlobalFunction.timeCheck(GlobalFunction.replaceDate(controller.post.createdAt)), style: STextStyle.body5().copyWith(color: nolColorGrey)),
              if (controller.post.isModify) ...[
                SizedBox(width: 4 * sizeUnit),
                Text('(수정됨)', style: STextStyle.body5().copyWith(color: nolColorGrey)),
              ],
              const Spacer(),
              if (controller.isMeeting) ...[
                personnelWidget(), // 인원
              ] else ...[
                likeWidget(), // 좋아요
              ],
              SizedBox(width: 8 * sizeUnit),
              IconAndCount(
                iconPath: controller.rxIsWriteReply.value ? GlobalAssets.svgReplyActive : GlobalAssets.svgReply,
                count: controller.post.repliesLength,
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * sizeUnit),
      ],
    );
  }

  // 인원
  Widget personnelWidget() {
    return InkWell(
      onTap: () {
        if (controller.isParticipation) {
          Get.to(() => ParticipantsPage(controller: controller));
        } else {
          if (!controller.meetingPost.isClosed) GlobalFunction.showToast(msg: '참가하기를 누르면 확인이 가능해요');
        }
      },
      child: Row(
        children: [
          SvgPicture.asset(
            GlobalAssets.svgGathering,
            width: 20 * sizeUnit,
            color: controller.isParticipation ? nolColorOrange : nolColorGrey,
          ),
          SizedBox(width: 4 * sizeUnit),
          Text(controller.meetingPost.meetingMembers.length > 99 ? '99+' : '${controller.meetingPost.meetingMembers.length}', style: STextStyle.body5()),
          if (controller.meetingPost.personnel != null) Text('/${controller.meetingPost.personnel}', style: STextStyle.body5()),
        ],
      ),
    );
  }

  // 좋아요
  Widget likeWidget() {
    RxBool rxIsLike = controller.post.isLike.obs; // 좋아요 여부

    return Obx(() => IconAndCount(
          iconPath: rxIsLike.value ? GlobalAssets.svgBigLikeActive : GlobalAssets.svgBigLike,
          count: controller.post.likesLength,
          onTap: () => GlobalFunction.loginCheck(
            callback: () async => rxIsLike(await controller.likeFunc()),
          ),
        ));
  }

  // 이미지
  Widget buildImage() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.post.imageUrlList.length,
      itemBuilder: (context, index) {
        final PostImage image = controller.post.imageUrlList[index];
        final double ratio = image.height / image.width;
        final double height = ((Responsive.isMobile(context) ? Get.width : webMaxWidth) - 32 * sizeUnit) * ratio;
        final List<String> urlList = GlobalFunction.checkURLList(controller.post.imageUrlList[index].description ?? '');
        List<ContentsWithURL> contentsList = [];
        List<TextSpan> textSpans = [];

        if (urlList.isNotEmpty) {
          contentsList = controller.generateContentsWithURL(urlList, controller.post.imageUrlList[index].description ?? '');

          textSpans = contentsList
              .map((e) => TextSpan(
                  text: e.contents,
                  style: e.isURL ? STextStyle.body3().copyWith(height: 21 / 14, color: Colors.blue, decoration: TextDecoration.underline) : STextStyle.body3().copyWith(height: 21 / 14),
                  recognizer: e.isURL ? (TapGestureRecognizer()..onTap = () => GlobalFunction.launchWebUrl(e.contents)) : null))
              .toList();
        }

        return Column(
          children: [
            if (index >= 1) ...[
              SizedBox(
                height: 12 * sizeUnit,
              )
            ],
            ClipRRect(
                borderRadius: BorderRadius.circular(8 * sizeUnit),
                child: InkWell(
                  onTap: () {
                    if (kIsWeb) {
                      if (controller.showWebOptionsBox.value) {
                        controller.showWebOptionsBox(false);
                      } else {
                        controller.showImageDialog(image.url);
                      }
                    } else {
                      controller.showImageDialog(image.url);
                    }
                  },
                  child: GetExtendedImage(
                    url: controller.post.imageUrlList[index].url,
                    fit: BoxFit.contain,
                    height: height,
                  ),
                )),
            if (controller.post.imageUrlList[index].description != null) ...[
              SizedBox(
                height: 4 * sizeUnit,
              ),
              if (urlList.isEmpty) ...[
                Align(alignment: Alignment.centerLeft, child: Text(controller.post.imageUrlList[index].description ?? '', style: STextStyle.body3().copyWith(height: 21 / 14))),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(TextSpan(children: textSpans)),
                )
              ]
            ]
          ],
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 16 * sizeUnit),
    );
  }

  // 댓글
  Widget buildReply() {
    // 참가한 모임이 아닌 경우
    if (controller.isMeeting && !controller.isParticipation) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: 60 * sizeUnit),
        child: Center(
          child: Text(
            '참가하기를 누르면 댓글이 활성화돼요',
            style: STextStyle.body4().copyWith(color: nolColorGrey),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.replyList.length,
      itemBuilder: (context, index) {
        final Reply reply = controller.replyList[index];
        if (GlobalData.blockedUserIDList.contains(reply.userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우

        return ReplyItem(
          reply: reply,
          tag: controller.tag,
        );
      },
    );
  }

  // 게시글 바텀 시트
  void showPostBottomSheet(BuildContext context) {
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
            if (GlobalData.loginUser.id == controller.post.userID) ...[
              bottomSheetItem(
                text: '수정하기',
                onTap: controller.modifyPost,
              ),
              bottomSheetItem(
                text: '삭제하기',
                onTap: () {
                  showCustomDialog(
                    title: '게시글을 삭제하시겠어요?',
                    okFunc: controller.deletePost,
                    isCancelButton: true,
                    okText: '네',
                    cancelText: '아니오',
                  );
                },
              ),
              if (controller.isMeeting && !controller.meetingPost.isClosed) ...[
                bottomSheetItem(
                  text: '참가인원 보기',
                  onTap: () => Get.to(() => ParticipantsPage(controller: controller)),
                ),
                bottomSheetItem(
                  text: '모집 마감하기',
                  onTap: () {
                    showCustomDialog(
                      title: '참가자 모집을 마감 하시겠어요?',
                      okFunc: controller.closeMeeting,
                      isCancelButton: true,
                      okText: '네',
                      cancelText: '아니오',
                    );
                  },
                ),
              ],
              bottomSheetItem(
                text: '공유하기',
                onTap: controller.shareButtonFunc,
              ),
            ] else ...[
              bottomSheetItem(
                text: '프로필 보기',
                onTap: () => Get.to(() => UserDetailPage(userID: controller.post.userID)),
              ),
              if (controller.isMeeting && controller.isParticipation) ...[
                bottomSheetItem(
                  text: '참가인원 보기',
                  onTap: () => Get.to(() => ParticipantsPage(controller: controller)),
                ),
              ],
              bottomSheetItem(
                text: '공유하기',
                onTap: controller.shareButtonFunc,
              ),
              bottomSheetItem(
                text: '게시글 신고하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypePost, declaredID: controller.post.id)),
                ),
              ),
              bottomSheetItem(
                text: '사용자 신고하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypeUser, declaredID: controller.post.userID)),
                ),
              ),
              bottomSheetItem(
                text: '사용자 차단하기',
                onTap: () => GlobalFunction.loginCheck(
                  callback: () => controller.userBan(controller.post.userID),
                ),
              ),
            ],
            bottomSheetCancelButton(),
          ],
        );
      },
    );
  }

  WebOptionBox webOptionBox() {
    return WebOptionBox(
      children: [
        if (GlobalData.loginUser.id == controller.post.userID) ...[
          WebOptionBoxItem(
            text: '수정하기',
            onTap: controller.modifyPost,
          ),
          WebOptionBoxItem(
            text: '삭제하기',
            onTap: () {
              showCustomDialog(
                title: '게시글을 삭제하시겠어요?',
                okFunc: controller.deletePost,
                isCancelButton: true,
                okText: '네',
                cancelText: '아니오',
              );
            },
          ),
          if (controller.isMeeting && !controller.meetingPost.isClosed) ...[
            WebOptionBoxItem(
              text: '참가인원 보기',
              onTap: () => Get.to(() => ParticipantsPage(controller: controller)),
            ),
            WebOptionBoxItem(
              text: '모집 마감하기',
              onTap: () {
                showCustomDialog(
                  title: '참가자 모집을 마감 하시겠어요?',
                  okFunc: controller.closeMeeting,
                  isCancelButton: true,
                  okText: '네',
                  cancelText: '아니오',
                );
              },
            ),
          ],
          WebOptionBoxItem(
            text: '공유하기',
            onTap: controller.shareButtonFunc,
          ),
        ] else ...[
          WebOptionBoxItem(
            text: '프로필 보기',
            onTap: () => Get.to(() => UserDetailPage(userID: controller.post.userID)),
          ),
          if (controller.isMeeting && controller.isParticipation) ...[
            WebOptionBoxItem(
              text: '참가인원 보기',
              onTap: () => Get.to(() => ParticipantsPage(controller: controller)),
            ),
          ],
          WebOptionBoxItem(
            text: '공유하기',
            onTap: controller.shareButtonFunc,
          ),
          WebOptionBoxItem(
            text: '게시글 신고하기',
            onTap: () => GlobalFunction.loginCheck(
              callback: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypePost, declaredID: controller.post.id)),
            ),
          ),
          WebOptionBoxItem(
            text: '사용자 신고하기',
            onTap: () => GlobalFunction.loginCheck(
              callback: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypeUser, declaredID: controller.post.userID)),
            ),
          ),
          WebOptionBoxItem(
            text: '사용자 차단하기',
            onTap: () => GlobalFunction.loginCheck(
              callback: () => controller.userBan(controller.post.userID),
            ),
          ),
        ],
      ],
    );
  }
}
