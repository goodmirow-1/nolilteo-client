import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:nolilteo/community/community_detail_page.dart';
import 'package:nolilteo/data/tag_preview.dart';
import 'package:nolilteo/meeting/controller/meeting_controller.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';
import 'package:nolilteo/repository/post_repository.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../config/analytics.dart';
import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../config/global_widgets/responsive.dart';
import '../../data/global_data.dart';
import 'package:dio/dio.dart' as DIO;

import '../../wbti/controller/wbti_controller.dart';
import '../category_selection_page.dart';

class CommunityWriteOrModifyController extends GetxController {
  static get to => Get.find<CommunityWriteOrModifyController>();

  final TextEditingController tagController = TextEditingController();
  final FocusNode tagFocusNode = FocusNode();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  List<TextEditingController> imageDescEditController = List.generate(5, (index) => TextEditingController());
  final int tagMaxLength = 8; // 태그 maxLength
  final int imageMaxNum = 5; // 사진 최대 갯수
  final int contentsMaxLength = 1000; // 내용 maxLength

  int type = Post.postTypeTopic;
  RxString category = ''.obs; // 카테고리
  RxString tag = ''.obs; // 태그
  List<TagPreview> tagPreviewList = []; // 태그 검색결과 미리보기
  RxString location = ''.obs; // 지역
  RxString title = ''.obs; // 제목
  RxString contents = ''.obs; // 내용
  RxList imageList = [].obs; // 이미지 리스트

  String url = ''; // 모임링크
  RxString detailLocation = ''.obs; // 주소
  Rx<DateTime> meetingDate = DateTime(0).obs; // 날짜
  RxInt personnel = nullInt.obs; // 정원
  RxInt startAge = nullInt.obs; // 나이
  RxInt endAge = nullInt.obs; // 나이
  RxInt sex = MeetingPost.anyGender.obs; // 성별

  RxBool tagLoading = false.obs; // 태그 로딩

  RxString tagErrorText = ''.obs;
  RxBool focusContents = false.obs;

  RxBool isOk(bool isCommunity) {
    final bool titleCheck = GlobalFunction.removeSpace(title.value).isNotEmpty && title.value[0] != '#';
    final bool contentsCheck = imageList.isEmpty ? GlobalFunction.removeSpace(contents.value).isNotEmpty : true;
    final bool ok = category.isNotEmpty && titleCheck && contentsCheck && tagErrorText.isEmpty;
    if (isCommunity) {
      return ok.obs;
    } else {
      return (ok && location.value.isNotEmpty).obs;
    }
  }

  List imageFileList = []; // 이미지 파일 리스트
  List<int> removeIDList = []; // 삭제된 이미지 id 리스트
  List<int> imageIDList = []; // 유지되는 이미지 id 리스트
  List<int> imageIndexList = []; // 유지되는 이미지 index 리스트
  List<int> imageFileIndexList = []; // 추가되는 이미지 index 리스트
  List<int> imageFileWidthList = []; // 추가되는 이미지 width 리스트
  List<int> imageFileHeightList = []; // 추가되는 이미지 height 리스트

  @override
  void onInit() {
    super.onInit();

    tagSearch(); // 태그 검색
  }

  @override
  void onClose() {
    super.onClose();

    tagController.dispose();
    tagFocusNode.dispose();
    urlController.dispose();
    titleController.dispose();
    contentsController.dispose();
    addressController.dispose();

    for (var i = 0; i < imageDescEditController.length; ++i) {
      imageDescEditController[i].dispose();
    }
  }

  // 수정 데이터 세팅
  void setPostModifyData(Post post) {
    category(post.category); // 카테고리

    // 태그
    tagController.text = post.tag;
    tag(post.tag);

    // 제목
    titleController.text = post.title;
    title(post.title);

    // 내용
    contents(post.contents); // 내용
    contentsController.text = post.contents;

    imageList.addAll(post.imageUrlList); // 이미지
    for (var i = 0; i < imageList.length; ++i) {
      imageDescEditController[i].text = post.imageUrlList[i].description ?? '';
    }
  }

  // 수정 데이터 세팅
  void setMeetingPostModifyData(MeetingPost meetingPost) {
    category(meetingPost.category); // 카테고리

    location(meetingPost.location); // 지역

    // 태그
    tagController.text = meetingPost.tag;
    tag(meetingPost.tag);

    // 제목
    titleController.text = meetingPost.title;
    title(meetingPost.title);

    // 내용
    contents(meetingPost.contents);
    contentsController.text = meetingPost.contents;

    imageList.addAll(meetingPost.imageUrlList); // 이미지

    // url
    urlController.text = meetingPost.url;
    url = meetingPost.url;

    // 주소
    if (meetingPost.detailLocation != null) {
      addressController.text = meetingPost.detailLocation!;
      detailLocation(meetingPost.detailLocation);
    }

    // 날짜
    if (meetingPost.meetingDate != null) meetingDate(DateTime.parse(meetingPost.meetingDate!).add(const Duration(hours: 9)));

    // 인원
    if (meetingPost.personnel != null) personnel(meetingPost.personnel);

    // 나이
    if (meetingPost.startAge != null) startAge(meetingPost.startAge);
    if (meetingPost.endAge != null) endAge(meetingPost.endAge);

    // 성별
    sex(meetingPost.sex);
  }

  // 커뮤니티 글쓰기 or 수정하기
  void writeOrModifyPost({required int? id, required bool isWrite, required Post? post}) async {
    final CommunityController communityController = Get.find<CommunityController>();

    GlobalFunction.loadingDialog(); // 로딩 시작

    await setImageList(); // 이미지 리스트 가공
    List<String> descList = [];

    for (var i = 0; i < imageList.length; ++i) {
      descList.add(imageDescEditController[i].text);
    }

    final DIO.FormData formData = DIO.FormData.fromMap({
      'id': id,
      'userID': GlobalData.loginUser.id,
      'category': category.value,
      'tag': tag.value,
      'title': title.value,
      'location': '',
      'contents': contents.value,
      'type': type,
      'isCreate': isWrite ? 1 : 0,
      'accessToken': GlobalData.accessToken,
      'nickName': GlobalFunction.getFullNickName(GlobalData.loginUser),
      'images': imageFileList, // 추가되는 이미지 파일
      'removeidlist': removeIDList, // 삭제되는 이미지 id 리스트
      'imageurllist': imageIDList, // 유지되는 이미지 id 리스트
      'imageurlindexlist': imageIndexList, // 유지되는 이미지 index 리스트
      'filewidthlist': imageFileWidthList, // 추가되는 이미지 width 리스트
      'fileheightlist': imageFileHeightList, // 추가되는 이미지 height 리스트료
      'filedesclist': descList //추가되는 이미지 descList
    });

    Post? resultPost = await PostRepository.writeOrModify(formData: formData, isMeeting: false);

    if (resultPost != null) {
      if (isWrite) {
        if (type == Post.postTypeWbti) {
          final WbtiController wbtiController = Get.find<WbtiController>();
          wbtiController.addPost(0, resultPost);
          wbtiController.update();
        } else if (type == Post.postTypeTopic) {
          if (!communityController.isJob) {
            // 전체보기거나, 관심목록에 포함된 카테고리나 태그면 리스트에 insert
            if (communityController.isAllView || communityController.interestList.contains(resultPost.category) || communityController.interestList.contains(resultPost.tag)) {
              communityController.addPost(0, resultPost);
              communityController.update();
            }
          }
        } else {
          if (communityController.isJob) {
            // 전체보기거나, 관심목록에 포함된 카테고리나 태그면 리스트에 insert
            if (communityController.isAllView || communityController.interestList.contains(resultPost.category) || communityController.interestList.contains(resultPost.tag)) {
              communityController.addPost(0, resultPost);
              communityController.update();
            }
          }
        }
        Get.back(); // 로딩 끝
        Get.back(); // 커뮤니티 페이지로 이동
        Get.toNamed('${CommunityDetailPage.route}/${resultPost.id}')!.then((value) => GlobalFunction.syncPost()); // 디테일 페이지로 이동
        GlobalFunction.showToast(msg: '글을 작성했어요.');
        NolAnalytics.logEvent(name: 'post_write', parameters: {'postID': resultPost.id, 'type': resultPost.type}); // 애널리틱스 글쓰기
      } else {
        GlobalData.changedPost = resultPost; // 게시글 동기화

        Get.back(); // 로딩 끝
        Get.back(result: resultPost); // 디테일 페이지로 이동
        GlobalFunction.showToast(msg: '글을 수정했어요.');
        NolAnalytics.logEvent(name: 'post_modify', parameters: {'postID': resultPost.id, 'type': resultPost.type}); // 애널리틱스 글수정
      }
    } else {
      Get.back(); // 로딩 끝
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }
  }

  // 모여요 글쓰기 or 수정하기
  void writeOrModifyMeetingPost({required int? id, required bool isWrite, required MeetingPost? meetingPost}) async {
    GlobalFunction.loadingDialog(); // 로딩 시작

    await setImageList(); // 이미지 리스트 가공

    final DIO.FormData formData = DIO.FormData.fromMap({
      'id': id,
      'userID': GlobalData.loginUser.id,
      'category': category.value,
      'tag': tag.value,
      'title': title.value,
      'location': location.value,
      'contents': contents.value,
      'type': type,
      'isCreate': isWrite ? 1 : 0,
      'accessToken': GlobalData.accessToken,
      'nickName': GlobalFunction.getFullNickName(GlobalData.loginUser),
      'images': imageFileList, // 추가되는 이미지 파일
      'removeidlist': removeIDList, // 삭제되는 이미지 id 리스트
      'imageurllist': imageIDList, // 유지되는 이미지 id 리스트
      'imageurlindexlist': imageIndexList, // 유지되는 이미지 index 리스트
      'fileindexlist': imageFileIndexList, // 추가되는 이미지 index 리스트
      'filewidthlist': imageFileWidthList, // 추가되는 이미지 width 리스트
      'fileheightlist': imageFileHeightList, // 추가되는 이미지 height 리스트
      'detailLocation': detailLocation.value.isEmpty ? null : detailLocation.value,
      'date': meetingDate.value == DateTime(0) ? null : meetingDate.value.toString(),
      'maxMemberNum': personnel.value == nullInt ? null : personnel.value,
      'minAge': startAge.value == nullInt ? null : startAge.value,
      'maxAge': endAge.value == nullInt ? null : endAge.value,
      'needGender': sex.value,
      'link': url,
    });

    Post? resultPost = await PostRepository.writeOrModify(formData: formData, isMeeting: true);

    if (resultPost != null) {
      resultPost = resultPost as MeetingPost;

      if (isWrite) {
        if (Get.isRegistered<MeetingController>()) {
          // 관심지역, 관심목록 체크 후 모여라 리스트에 insert
          final MeetingController meetingController = Get.find<MeetingController>();
          final bool locationCheck = GlobalData.interestLocationList.contains(resultPost.location) || GlobalData.interestLocationList.contains('${resultPost.location.split(' ')[0]} ALL');
          final bool interestCheck = locationCheck
              ? meetingController.isAllView.value || meetingController.interestList.contains(resultPost.category) || meetingController.interestList.contains('#${resultPost.tag}')
              : false;

          if (locationCheck && interestCheck) {
            meetingController.postList.insert(0, resultPost);
            meetingController.update();
          }
        }
        Get.back(); // 로딩 끝
        Get.back(); // 모여요 페이지로 이동
        GlobalFunction.showToast(msg: '글이 등록되었어요.');
        Get.toNamed('${CommunityDetailPage.meetingRoute}/${resultPost.id}')!.then((value) => GlobalFunction.syncPost()); // 디테일 페이지로 이동
        NolAnalytics.logEvent(name: 'post_write', parameters: {'postID': resultPost.id, 'type': resultPost.type}); // 애널리틱스 글쓰기
      } else {
        GlobalData.changedPost = resultPost; // 게시글 동기화

        Get.back(); // 로딩 끝
        Get.back(result: resultPost); // 디테일 페이지로 이동
        GlobalFunction.showToast(msg: '글이 수정되었어요.');
        NolAnalytics.logEvent(name: 'post_modify', parameters: {'postID': resultPost.id, 'type': resultPost.type}); // 애널리틱스 글수정
      }
    } else {
      Get.back(); // 로딩 끝
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }
  }

  // 이미지 리스트 가공
  Future<void> setImageList() async {
    imageFileList.clear();
    imageIDList.clear();
    imageIndexList.clear();
    imageFileWidthList.clear();
    imageFileHeightList.clear();

    for (int i = 0; i < imageList.length; i++) {
      final image = imageList[i];

      if (image is XFile) {
        late final DIO.MultipartFile file;
        final String fileName = image.path.split('/').last;

        if (kIsWeb) {
          file = DIO.MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: '$fileName.${image.mimeType == null ? 'jpeg' : image.mimeType!.split('/').last}',
          );
        } else {
          file = await DIO.MultipartFile.fromFile(image.path, filename: fileName);
        }

        imageFileList.add(file);
        imageFileIndexList.add(i);

        // 이미지 width, height 리스트 가공
        final decodedImage = await decodeImageFromList(await image.readAsBytes());
        imageFileWidthList.add(decodedImage.width);
        imageFileHeightList.add(decodedImage.height);
      } else {
        imageIDList.add(image.id);
        imageIndexList.add(i);

        // 이미지 width, height 리스트 가공
        imageFileWidthList.add(image.width);
        imageFileHeightList.add(image.height);
      }
    }
  }

  // 이미지 삭제
  void deleteImage(int index) {
    final element = imageList[index];
    if (element is PostImage) removeIDList.add(element.id); // 원래 있던 파일 삭제한 경우 id add
    imageList.removeAt(index);
  }

  // 사진 가져오기
  Future getImageEvent({required bool isCamera}) async {
    final ImagePicker picker = ImagePicker();
    late final List<XFile>? selectedImages;

    if (isCamera) {
      if (imageList.isNotEmpty && imageList.length >= imageMaxNum) {
        GlobalFunction.showToast(msg: '사진은 최대 5장까지 등록 가능합니다.');
      }

      XFile? cameraImage = await picker.pickImage(source: ImageSource.camera);
      selectedImages = cameraImage == null ? null : [cameraImage];
    } else {
      selectedImages = await picker.pickMultiImage(imageQuality: 44);
    }

    if (selectedImages != null) {
      for (XFile xFile in selectedImages) {
        if (imageList.length >= imageMaxNum) {
          GlobalFunction.showToast(msg: '사진은 최대 5장까지 등록 가능합니다.');
          return; // 사진 최대 갯수까지만 추가
        }

        if (await GlobalFunction.isBigFile(xFile)) {
          return GlobalFunction.showToast(msg: '사진의 크기는 15mb를 넘을 수 없습니다.');
        } else {
          imageList.add(xFile);
        }
      }
    }
  }

  // 글쓰기 불가 안내
  void showFailInfo(bool isCommunity) {
    if (category.isEmpty) return GlobalFunction.showToast(msg: '카테고리를 선택해 주세요.');
    if (!isCommunity && location.value.isEmpty) return GlobalFunction.showToast(msg: '지역을 선택해 주세요.');
    if (tagErrorText.value.isNotEmpty) return GlobalFunction.showToast(msg: '태그에 특수문자는 사용할 수 없어요');
    if (GlobalFunction.removeSpace(title.value).isEmpty) return GlobalFunction.showToast(msg: '제목은 공백 제외 한 자 이상 입력해 주세요.');
    if (imageList.isEmpty && GlobalFunction.removeSpace(contents.value).isEmpty) return GlobalFunction.showToast(msg: '내용은 공백 제외 한 자 이상 입력해 주세요.');
  }

  // 성별 체크 이벤트
  void sexCheckEvent(int value) {
    if (sex.value == value) {
      sex(MeetingPost.anyGender);
    } else {
      sex(value);
    }
  }

  // 태그 검색
  void tagSearch() {
    try {
      debounce(tag, time: const Duration(milliseconds: 500), (callback) async {
        if (!tagFocusNode.hasFocus) return; // 포커스 없으면 리턴
        if(kDebugMode) print('tagSearch!');

        tagPreviewList.clear();
        tagPreviewList = await PostRepository.getTagSearch(index: 0, name: tag.value, type: type);

        tagLoading(false);
      });
    } catch (e) {
      if(kDebugMode) print(e.toString());
      tagLoading(false);
    }
  }

  void tagValidCheck() {
    RegExp regExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (regExp.hasMatch(tag.value)) {
      tagErrorText('특수문자는 사용할 수 없어요');
    } else {
      tagErrorText('');
    }
  }

  void checkExit(bool isWrite) {
    showCustomDialog(
      title: '${isWrite ? '글쓰기' : '수정하기'}를 취소하시겠어요?',
      description: '작성중인 게시물은 저장되지 않아요',
      isCancelButton: true,
      cancelText: '아니오',
      okText: '네',
      okFunc: () => Get.close(2), // 다이어로그, 뒤로가기
    );
  }

  // 카테고리 선택 페이지로 이동
  void goToCategorySelectionPage(BuildContext context) {
    final int categoryType = type != Post.postTypeMeeting
        ? type == Post.postTypeJob
            ? CategorySelectionPage.categoryTypeJob
            : CategorySelectionPage.categoryTypeTopic
        : CategorySelectionPage.categoryTypeAll;

    if (Responsive.isMobile(context)) {
      // 모바일인 경우
      Get.to(() => CategorySelectionPage(categoryType: categoryType))!.then((value) {
        if (value != null) category(value);
      });
    } else {
      // 웹인 경우
      Get.dialog(
        Center(
          child: SizedBox(
            width: 560 * sizeUnit,
            height: 711 * sizeUnit,
            child: CategorySelectionPage(categoryType: categoryType),
          ),
        ),
        barrierColor: Colors.transparent,
      ).then((value) {
        if (value != null) category(value);
        Get.delete<CategorySelectionController>();
      });
    }
  }
}
