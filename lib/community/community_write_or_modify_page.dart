import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_page/location_selection_page.dart';
import 'package:nolilteo/config/global_widgets/bottom_line_text_field.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/data/tag_preview.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';
import 'package:intl/intl.dart';
import 'package:nolilteo/wbti/controller/wbti_controller.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:reorderables/reorderables.dart';
import 'controllers/community_write_or_modify_controller.dart';
import 'models/post.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/custom_text_field.dart';
import '../config/global_widgets/get_extended_image.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/constants.dart';
import '../config/s_text_style.dart';

// ignore: must_be_immutable
class CommunityWriteOrModifyPage extends StatelessWidget {
  CommunityWriteOrModifyPage({Key? key, required this.isWrite, this.post, this.meetingPost, required this.type}) : super(key: key);

  final bool isWrite;
  final int type;
  final Post? post;
  final MeetingPost? meetingPost;

  final CommunityWriteOrModifyController controller = Get.put(CommunityWriteOrModifyController());
  final Color maxLengthColor = const Color(0xFFA0A0A0);
  bool initialize = false;

  @override
  Widget build(BuildContext context) {
    if (!initialize) {
      initialize = true;

      controller.type = type;

      if (!isWrite) {
        if (type != Post.postTypeMeeting) {
          controller.setPostModifyData(post!); // 수정 데이터 세팅
        } else {
          controller.setMeetingPostModifyData(meetingPost!); // 수정 데이터 세팅
        }
      } else {
        if (type == Post.postTypeWbti) {
          final WbtiController wbtiController = Get.find<WbtiController>();
          controller.category(wbtiController.selectedWbti.type.isEmpty ? GlobalData.loginUser.wbti: wbtiController.selectedWbti.type); // wbti 카테고리 세팅
        }
      }
    }

    return BaseWidget(
      onWillPop: () {
        controller.checkExit(isWrite);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: GestureDetector(
          onTap: () {
            GlobalFunction.unFocus(context);
            controller.tagPreviewList.clear(); // 태그 미리보기 리스트 클리어
            controller.tagLoading.toggle(); // obx 돌리는 용
            controller.tagLoading(false); // 로딩 끄기
          },
          child: Column(
            children: [
              buildLine(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                    child: Stack(
                      children: [
                        mainContents(context),
                        Obx(() => (!controller.tagLoading.value && controller.tagPreviewList.isEmpty)
                            ? const SizedBox.shrink()
                            : Positioned(
                                top: type != Post.postTypeMeeting
                                    ? 154 * sizeUnit + (controller.category.value.isNotEmpty ? 8 * sizeUnit : 0)
                                    : 230 * sizeUnit + (controller.category.value.isNotEmpty ? 8 * sizeUnit : 0) + (controller.location.value.isNotEmpty ? 8 * sizeUnit : 0),
                                left: 0,
                                right: 0,
                                child: tagPreviewWidget(),
                              )),

                      ],
                    ),
                  ),
                ),
              ),
              nolDivider(),
              Container(
                color: Colors.white,
                height: 48 * sizeUnit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (kIsWeb) {
                          controller.getImageEvent(isCamera: false);
                        } else {
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
                                  bottomSheetItem(
                                    text: '사진 선택',
                                    onTap: () {
                                      Get.back();
                                      controller.getImageEvent(isCamera: false);
                                    },
                                  ),
                                  bottomSheetItem(
                                    text: '사진 찍기',
                                    onTap: () {
                                      Get.back();
                                      controller.getImageEvent(isCamera: true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 24 * sizeUnit,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget mainContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16 * sizeUnit),
        buildTitle('카테고리', color: isWrite ? nolColorBlack : nolColorGrey),
        SizedBox(height: 16 * sizeUnit),
        if (isWrite) ...[
          type == Post.postTypeWbti
              ? nolChips(
                  text: WbtiType.getType(controller.category.value).name,
                  borderColor: nolColorGrey,
                  fontColor: nolColorGrey,
                )
              : Obx(
                  () => controller.category.isEmpty
                      ? InkWell(
                          onTap: () => controller.goToCategorySelectionPage(context),
                          borderRadius: BorderRadius.circular(12 * sizeUnit),
                          child: SvgPicture.asset(
                            GlobalAssets.svgPlusInCircle,
                            width: 24 * sizeUnit,
                          ),
                        )
                      : nolChips(
                          text: controller.category.value,
                          cancelFunc: () => controller.category(''),
                        ),
                ),
        ] else ...[
          nolChips(
            text: type == Post.postTypeWbti ? WbtiType.getType(controller.category.value).name : controller.category.value,
            borderColor: nolColorGrey,
            fontColor: nolColorGrey,
          )
        ],
        SizedBox(height: 24 * sizeUnit),
        if (type == Post.postTypeMeeting) ...[
          buildTitle('지역 등록', color: isWrite ? nolColorBlack : nolColorGrey),
          SizedBox(height: 24 * sizeUnit),
          if (isWrite) ...[
            Obx(() => controller.location.isEmpty
                ? InkWell(
                    onTap: () => Get.to(() => LocationSelectionPage(showInterestList: false, showAll: false))!.then((value) {
                      if (value != null) {
                        controller.location(value);
                      }
                    }),
                    borderRadius: BorderRadius.circular(12 * sizeUnit),
                    child: SvgPicture.asset(
                      GlobalAssets.svgPlusInCircle,
                      width: 24 * sizeUnit,
                    ),
                  )
                : nolChips(
                    text: '@${controller.location.value}',
                    cancelFunc: () => controller.location(''),
                  )),
          ] else ...[
            nolChips(
              text: '@${controller.location.value}',
              borderColor: nolColorGrey,
              fontColor: nolColorGrey,
            )
          ],
          SizedBox(height: 24 * sizeUnit),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTitle('#TAG(선택)', color: isWrite ? nolColorBlack : nolColorGrey),
            Obx(() => Text(
                  '${controller.tag.value.length}/8',
                  style: STextStyle.body4().copyWith(color: maxLengthColor, height: 16 / 12),
                ))
          ],
        ),
        if (isWrite) ...[
          Obx(() => BottomLineTextField(
                controller: controller.tagController,
                focusNode: controller.tagFocusNode,
                hintText: '태그를 입력해 주세요.',
                errorText: controller.tagErrorText.value.isEmpty ? null : controller.tagErrorText.value,
                maxLength: controller.tagMaxLength,
                onChanged: (value) {
                  if (value != controller.tag.value) {
                    controller.tag(value);
                    controller.tagLoading(true); // 로딩 시작
                  }
                  controller.tagValidCheck();
                },
              )),
        ] else ...[
          Container(
            width: double.infinity,
            height: 48 * sizeUnit,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: nolColorGrey,
                  width: 1 * sizeUnit,
                ),
              ),
            ),
            child: Text(
              controller.tag.value,
              style: STextStyle.body3().copyWith(color: nolColorGrey),
            ),
          ),
        ],
        SizedBox(height: 24 * sizeUnit),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTitle('제목'),
            Obx(() => Text(
                  '${controller.title.value.length}/32',
                  style: STextStyle.body4().copyWith(color: maxLengthColor, height: 16 / 12),
                ))
          ],
        ),
        Obx(() => BottomLineTextField(
              controller: controller.titleController,
              hintText: '제목을 입력해 주세요.',
              maxLength: 32,
              errorText: controller.title.isEmpty
                  ? null
                  : controller.title.value[0] == '#'
                      ? '제목의 첫 자는 \'#\'을 쓸 수 없어요'
                      : null,
              onChanged: (value) => controller.title(value),
            )),
        SizedBox(height: 24 * sizeUnit),
        buildTitle('내용'),
        SizedBox(height: 8 * sizeUnit),
        // CustomTextField(
        //   controller: controller.contentsController,
        //   textInputType: TextInputType.multiline,
        //   hintText: '내용을 입력해 주세요.',
        //   maxLength: controller.contentsMaxLength,
        //   maxLines: controller.contentsMaxLength,
        //   minLines: 6,
        //   onChanged: (value) => controller.contents(value),
        // ),
        Obx(() => Focus(
          onFocusChange: (bool hasFocus) => {
            controller.focusContents.value = hasFocus
          },
          child: buildWriteContents(controller.focusContents.value ? nolColorOrange :const Color(0xffbbbbbb)),
        )),
        SizedBox(height: 24 * sizeUnit),
        // Row(
        //   children: [
        //     buildTitle('사진(선택)'),
        //     SizedBox(width: 8 * sizeUnit),
        //     Text(
        //       '사진은 최대 ${controller.imageMaxNum}개까지 가능해요',
        //       style: STextStyle.body4().copyWith(
        //         color: maxLengthColor,
        //         height: 16 / 12,
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 24 * sizeUnit),
        // Obx(() {
        //   List<Widget> list = List.generate(controller.imageList.length + 1, (index) {
        //     if (controller.imageList.length == index) {
        //       if (controller.imageList.length >= controller.imageMaxNum) return const SizedBox.shrink();
        //       return buildAddBox(context);
        //     }
        //     return buildImageBox(image: controller.imageList[index], index: index);
        //   });
        //
        //   return ReorderableWrap(
        //     spacing: 8,
        //     runSpacing: 8,
        //     buildDraggableFeedback: (context, boxConstraints, widget) {
        //       return Material(type: MaterialType.transparency, child: widget);
        //     },
        //     onReorder: (int oldIndex, int newIndex) {
        //       if (oldIndex == controller.imageList.length) return; // 이미지 추가 박스일 때는 리턴
        //       if (newIndex == controller.imageList.length) return; // 이미지 추가 박스일 때는 리턴
        //
        //       final element = controller.imageList.removeAt(oldIndex);
        //       controller.imageList.insert(newIndex, element);
        //     },
        //     needsLongPressDraggable: false,
        //     children: list,
        //   );
        // }),
        // if (type == Post.postTypeMeeting) ...[
        //   SizedBox(height: 24 * sizeUnit),
        //   buildTitle('추가항목(선택)'),
        //   Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         SizedBox(height: 16 * sizeUnit),
        //         Row(
        //           children: [
        //             buildSubTitle('모임링크'),
        //             SizedBox(width: 8 * sizeUnit),
        //             Text(
        //               'ex) 네이버 밴드, 카카오톡 오픈채팅방',
        //               style: STextStyle.body4().copyWith(
        //                 color: maxLengthColor,
        //                 height: 16 / 12,
        //               ),
        //             )
        //           ],
        //         ),
        //         BottomLineTextField(
        //           controller: controller.urlController,
        //           hintText: '링크주소를 입력해 주세요.',
        //           onChanged: (value) => controller.url = value,
        //         ),
        //         SizedBox(height: 16 * sizeUnit),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             buildSubTitle('장소'),
        //             Obx(() => Text(
        //                   '${controller.detailLocation.value.length}/20',
        //                   style: STextStyle.body4().copyWith(color: maxLengthColor, height: 16 / 12),
        //                 )),
        //           ],
        //         ),
        //         BottomLineTextField(
        //           controller: controller.addressController,
        //           hintText: '장소를 입력해 주세요.',
        //           onChanged: (value) => controller.detailLocation(value),
        //           maxLength: 20,
        //         ),
        //         SizedBox(height: 8 * sizeUnit),
        //         SizedBox(
        //           height: 48 * sizeUnit,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               buildSubTitle('날짜'),
        //               InkWell(
        //                 onTap: () async => controller.meetingDate(await datePicker(context: context, initialDateTime: controller.meetingDate.value.year == 0 ? null : controller.meetingDate.value)),
        //                 child: Obx(() => Row(
        //                       children: [
        //                         Text(
        //                           controller.meetingDate.value.year == 0
        //                               ? '선택하기'
        //                               : '${DateFormat('M월 d일').format(controller.meetingDate.value)} ${GlobalFunction.changeDayOfTheWeekToKorean(DateFormat.E().format(controller.meetingDate.value))} ${DateFormat('HH:mm').format(controller.meetingDate.value)}',
        //                           style: STextStyle.subTitle2().copyWith(color: nolColorOrange),
        //                         ),
        //                         if (controller.meetingDate.value.year != 0) ...[
        //                           SizedBox(width: 8 * sizeUnit),
        //                           buildCancelButton(() => controller.meetingDate(DateTime(0))),
        //                         ],
        //                       ],
        //                     )),
        //               ),
        //             ],
        //           ),
        //         ),
        //         SizedBox(
        //           height: 48 * sizeUnit,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               buildSubTitle('인원'),
        //               InkWell(
        //                 onTap: () => personnelPicker(context),
        //                 child: Obx(() => Row(
        //                       children: [
        //                         Text(
        //                           controller.personnel.value == nullInt ? '선택하기' : '${controller.personnel.value}명',
        //                           style: STextStyle.subTitle2().copyWith(color: nolColorOrange),
        //                         ),
        //                         if (controller.personnel.value != nullInt) ...[
        //                           SizedBox(width: 8 * sizeUnit),
        //                           buildCancelButton(() => controller.personnel(nullInt)),
        //                         ],
        //                       ],
        //                     )),
        //               ),
        //             ],
        //           ),
        //         ),
        //         SizedBox(
        //           height: 48 * sizeUnit,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               buildSubTitle('나이'),
        //               InkWell(
        //                 onTap: () => agePicker(context),
        //                 child: Obx(() => Row(
        //                       children: [
        //                         Text(
        //                           MeetingPost.getAgeLimit(startAge: controller.startAge.value, endAge: controller.endAge.value) ?? '선택하기',
        //                           style: STextStyle.subTitle2().copyWith(color: nolColorOrange),
        //                         ),
        //                         if (controller.startAge.value != nullInt || controller.endAge.value != nullInt) ...[
        //                           SizedBox(width: 8 * sizeUnit),
        //                           buildCancelButton(
        //                             () {
        //                               controller.startAge(nullInt);
        //                               controller.endAge(nullInt);
        //                             },
        //                           ),
        //                         ],
        //                       ],
        //                     )),
        //               ),
        //             ],
        //           ),
        //         ),
        //         SizedBox(
        //           height: 48 * sizeUnit,
        //           child: Row(
        //             children: [
        //               Expanded(child: buildSubTitle('성별')),
        //               Obx(() => radioButton(
        //                     label: '남자만',
        //                     isChecked: controller.sex.value == MeetingPost.onlyMale,
        //                     onTap: () => controller.sexCheckEvent(MeetingPost.onlyMale),
        //                   )),
        //               SizedBox(width: 16 * sizeUnit),
        //               Obx(() => radioButton(
        //                     label: '여자만',
        //                     isChecked: controller.sex.value == MeetingPost.onlyFemale,
        //                     onTap: () => controller.sexCheckEvent(MeetingPost.onlyFemale),
        //                   )),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
        ConstrainedBox(constraints: BoxConstraints(minHeight: 16 * sizeUnit)),
      ],
    );
  }

  Container tagPreviewWidget() {
    return Container(
      height: controller.tagLoading.value ? 312 * sizeUnit : null,
      constraints: BoxConstraints(maxHeight: 312 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: nolColorOrange),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(14 * sizeUnit),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.tagLoading.value
              ? [SizedBox(height: 156 * sizeUnit), const CircularProgressIndicator(color: nolColorOrange)]
              : List.generate(
                  controller.tagPreviewList.length,
                  (index) {
                    final TagPreview tagPreview = controller.tagPreviewList[index];

                    return tagPreviewItem(
                      tagPreview,
                      onTap: () {
                        controller.tagFocusNode.unfocus(); // 포커스 끄기
                        controller.tagController.text = tagPreview.tag; // 텍스트 필드 세팅
                        controller.tag(tagPreview.tag); // 태그 세팅

                        controller.tagPreviewList.clear(); // 태그 미리보기 리스트 클리어
                        controller.tagLoading.toggle(); // obx 돌리는 용
                        controller.tagLoading(false); // 로딩 끄기
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget radioButton({required String label, required bool isChecked, required GestureTapCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(isChecked ? GlobalAssets.svgCheckCircle : GlobalAssets.svgCheckCircleEmpty),
          SizedBox(width: 8 * sizeUnit),
          Text(label, style: STextStyle.body3()),
        ],
      ),
    );
  }

  InkWell buildCancelButton(GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(GlobalAssets.svgCancelInCircle, width: 20 * sizeUnit),
    );
  }

  Text buildTitle(String title, {Color color = nolColorBlack}) => Text(title, style: STextStyle.subTitle1().copyWith(color: color));

  Text buildSubTitle(String title) => Text(title, style: STextStyle.subTitle2());

  PreferredSize? buildAppBar(BuildContext context) {
    return customAppBar(
      context,
      leadingWidth: Responsive.isMobile(context) ? null : 48 * sizeUnit,
      leading: InkWell(
        onTap: () => controller.checkExit(isWrite),
        child: Center(child: SvgPicture.asset(Responsive.isMobile(context) ? GlobalAssets.svgArrowLeft : GlobalAssets.svgCancel, width: 24 * sizeUnit)),
      ),
      title: isWrite
          ? type != Post.postTypeWbti
              ? type == Post.postTypeJob
                  ? '일터 글쓰기'
                  : '놀터 글쓰기'
              : 'WBTI 글쓰기'
          : '수정하기',
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: Center(
            child: InkWell(
              onTap: () {
                if (controller.isOk(type != Post.postTypeMeeting).value) {
                  if (type != Post.postTypeMeeting) {
                    showCustomDialog(
                      title: isWrite ? '글쓰기를 완료하시겠어요?' : '수정을 완료하시겠어요?',
                      description: isWrite ? '카테고리, TAG는 수정이 불가능해요' : '',
                      isCancelButton: true,
                      okFunc: () {
                        Get.back(); // 다이어로그 끄기
                        controller.writeOrModifyPost(id: post == null ? null : post!.id, isWrite: isWrite, post: post);
                      },
                    );
                  } else {
                    showCustomDialog(
                      title: isWrite ? '글쓰기를 완료하시겠어요?' : '수정을 완료하시겠어요?',
                      description: isWrite ? '카테고리, 지역 등록, TAG는 수정이 불가능해요' : '',
                      isCancelButton: true,
                      okFunc: () {
                        Get.back(); // 다이어로그 끄기
                        controller.writeOrModifyMeetingPost(id: meetingPost == null ? null : meetingPost!.id, isWrite: isWrite, meetingPost: meetingPost);
                      },
                    );
                  }
                } else {
                  controller.showFailInfo(type != Post.postTypeMeeting);
                }
              },
              child: Obx(() => Text(
                    '완료',
                    style: STextStyle.subTitle1().copyWith(color: controller.isOk(type != Post.postTypeMeeting).value ? nolColorOrange : nolColorGrey),
                  )),
            ),
          ),
        )
      ],
    );
  }

  Widget buildImageBox({required image, required int index, double size = 96}) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size * sizeUnit,
              height: size * sizeUnit,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14 * sizeUnit),
                border: Border.all(color: nolColorLightGrey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14 * sizeUnit),
                child: kIsWeb
                    ? image is XFile
                    ? GetExtendedImage(url: image.path)
                    : GetExtendedImage(url: image.url)
                    : image is XFile
                    ? Image(
                  image: FileImage(File(image.path)),
                  fit: BoxFit.cover,
                )
                    : GetExtendedImage(url: image.url),
              ),
            ),
            Positioned(
              top: 4 * sizeUnit,
              right: 4 * sizeUnit,
              child: InkWell(
                onTap: () => controller.deleteImage(index),
                child: SvgPicture.asset(GlobalAssets.svgCancelInCircleFill, width: 20 * sizeUnit),
              ),
            ),
          ],
        ),
        BottomLineTextField(
          controller: controller.imageDescEditController[index],
          hintText: '이미지에 대한 설명을 입력해주세요. (선택)',
          textInputType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          onChanged: (value) {
          },
        ),
        SizedBox(height: 24 * sizeUnit,)
      ],
    );
  }

  Widget buildAddBox(BuildContext context) {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          controller.getImageEvent(isCamera: false);
        } else {
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
                  bottomSheetItem(
                    text: '사진 선택',
                    onTap: () {
                      Get.back();
                      controller.getImageEvent(isCamera: false);
                    },
                  ),
                  bottomSheetItem(
                    text: '사진 찍기',
                    onTap: () {
                      Get.back();
                      controller.getImageEvent(isCamera: true);
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        width: 96 * sizeUnit,
        height: 96 * sizeUnit,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          border: Border.all(color: nolColorLightGrey),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(GlobalAssets.svgPlusInCircle, width: 24 * sizeUnit),
      ),
    );
  }

  // datePicker
  Future<DateTime> datePicker({required BuildContext context, DateTime? initialDateTime}) async {
    final DateTime now = DateTime.now();
    DateTime? date;
    late final DateTime time;

    await showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
              height: 200 * sizeUnit,
              child: CupertinoDatePicker(
                backgroundColor: Colors.white,
                initialDateTime: initialDateTime ?? now,
                mode: CupertinoDatePickerMode.date,
                maximumDate: DateTime(now.year, now.month + 6, now.day),
                maximumYear: now.month + 6 > 12 ? now.year + 1 : now.year,
                minimumDate: DateTime(now.year, now.month, now.day),
                minimumYear: now.year,
                onDateTimeChanged: (val) => date = val,
              ),
            ));

    date ??= initialDateTime ?? now;
    time = await timePicker(context: context, initialDateTime: initialDateTime);
    return DateTime(date!.year, date!.month, date!.day, time.hour, time.minute);
  }

  // timePicker
  Future<DateTime> timePicker({required BuildContext context, DateTime? initialDateTime}) async {
    final DateTime now = DateTime.now();
    DateTime? time;

    await showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
              height: 200 * sizeUnit,
              child: CupertinoDatePicker(
                backgroundColor: Colors.white,
                initialDateTime: initialDateTime ?? now,
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (val) => time = val,
              ),
            ));

    time ??= initialDateTime ?? now;
    return time!;
  }

  // 인원 선택
  void personnelPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) => SizedBox(
        height: 200 * sizeUnit,
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(
            initialItem: controller.personnel.value == nullInt ? 0 : controller.personnel.value - 2,
          ),
          backgroundColor: Colors.white,
          children: List.generate(
            98,
            (index) => Text(
              '${index + 2}',
              style: const TextStyle(height: 1.3),
            ),
          ),
          onSelectedItemChanged: (value) => controller.personnel(value + 2),
        ),
      ),
    ).then((value) {
      if (controller.personnel.value == nullInt) controller.personnel(2);
    });
  }

  // 나이 선택
  void agePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) => Container(
        height: 200 * sizeUnit,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: controller.startAge.value == nullInt ? 0 : controller.startAge.value,
                ),
                backgroundColor: Colors.white,
                children: List.generate(
                  100,
                  (index) {
                    if (index == 0) {
                      return const Text(
                        "이상",
                        style: TextStyle(height: 1.3),
                      );
                    }
                    return Text(
                      '$index',
                      style: const TextStyle(height: 1.3),
                    );
                  },
                ),
                onSelectedItemChanged: (value) => controller.startAge(value),
              ),
            ),
            Text(
              '~',
              style: STextStyle.subTitle1().copyWith(decoration: TextDecoration.none),
            ),
            Obx(() => Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: controller.endAge.value == nullInt ? 0 : controller.endAge.value,
                    ),
                    backgroundColor: Colors.white,
                    children: List.generate(
                      100,
                      (index) {
                        if (index == 0) {
                          return const Text(
                            "이하",
                            style: TextStyle(height: 1.3),
                          );
                        }
                        return Text(
                          '$index',
                          style: const TextStyle(height: 1.3),
                        );
                      },
                    ),
                    onSelectedItemChanged: (value) => controller.endAge(value),
                  ),
                )),
          ],
        ),
      ),
    ).then((value) {
      // 이상, 이하 처리
      if (controller.startAge.value == 0) controller.startAge(nullInt);
      if (controller.endAge.value == 0) controller.endAge(nullInt);

      // 최대 나이가 최소 나이보다 높을 때 최소 나이로 통일
      if (controller.startAge.value != nullInt && controller.endAge.value != nullInt) {
        if (controller.startAge.value > controller.endAge.value) controller.endAge(controller.startAge.value);
      }
    });
  }

  Widget buildWriteContents(Color focusColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(
            color: focusColor,
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
              controller: controller.contentsController,
              cursorColor: nolColorOrange,
              keyboardType: TextInputType.multiline,
              maxLines: controller.contentsMaxLength,
              minLines: controller.imageList.isNotEmpty ? 3 : 6,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '내용을 입력해 주세요.',
                hintStyle: STextStyle.body3().copyWith(height: 21 / 14).copyWith(color: const Color(0xffbbbbbb)),
              ),
              style: STextStyle.body3().copyWith(height: 21 / 14),
              onChanged: (value) => controller.contents(value),
            ),
            ListView.builder(
                itemCount: controller.imageList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) => buildImageBox(image: controller.imageList[index], index: index,size: 282)
            )
          ],
        ),
      ),
    );
  }
}
