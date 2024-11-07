import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../community/community_detail_page.dart';
import '../community/componets/post_card.dart';
import '../community/models/post.dart';
import '../config/constants.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../data/global_data.dart';
import '../meeting/model/meeting_post.dart';
import '../repository/post_repository.dart';
import 'controller/my_meeting_controller.dart';

class MyMeetingPost extends StatefulWidget {
  const MyMeetingPost({Key? key, required this.userID}) : super(key: key);

  final int userID;

  @override
  State<MyMeetingPost> createState() => _MyMeetingPostState();
}

class _MyMeetingPostState extends State<MyMeetingPost> {
  final MyMeetingController controller = Get.put(MyMeetingController(tag: GlobalData.myMeetingPageCount.toString()), tag: GlobalData.myMeetingPageCount.toString());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() => controller.maxScrollEvent(scrollController));
    controller.fetchData(widget.userID).then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        child: controller.loading.value
            ? const Center(child: CircularProgressIndicator(color: nolColorOrange))
            : Scaffold(
                appBar: customAppBar(context, title: '모여라 활동',centerTitle: false),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLine(),
                    Expanded(child: buildListView()),
                  ],
                )));
  }

  Widget buildListView() {
    return customRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.postList.length,
            itemBuilder: (context, index) {
              final MeetingPost post = controller.postList[index];

              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 16 * sizeUnit : 0),
                child: PostCard(
                  post: post,
                  meetingPost: post,
                  showCrown: post.userID == widget.userID,
                  onTap: () async {
                    exitFunc() async {
                      bool? result = await PostRepository.exitMeeting(post.meetingID);
                      if (result != null && result) {
                        post.meetingMembers.remove(GlobalData.loginUser.id); // 참가 리스트에서 삭제
                        controller.remove(index);
                        Get.back();
                      }
                    }

                    if (post.deleteType == 1) {
                      showCustomDialog(
                        title: '삭제된 게시글입니다.',
                        description: '모임을 나오시겠어요?',
                        okFunc: exitFunc,
                        isCancelButton: true,
                        okText: '네',
                        cancelText: '아니오',
                      );
                    } else if (post.deleteType == 2) {
                      showCustomDialog(
                        title: '신고누적으로 삭제된 게시글입니다.',
                        description: '모임을 나오시겠어요?',
                        okFunc: exitFunc,
                        isCancelButton: true,
                        okText: '네',
                        cancelText: '아니오',
                      );
                    } else if (post.deleteType == 3) {
                      showCustomDialog(
                        title: '관리자에 의해 삭제된 게시글입니다.',
                        description: '모임을 나오시겠어요?',
                        okFunc: exitFunc,
                        isCancelButton: true,
                        okText: '네',
                        cancelText: '아니오',
                      );
                    } else {
                      Get.toNamed('${CommunityDetailPage.meetingRoute}/${post.id}')!.then((value) => GlobalFunction.syncPost());
                    }
                  }, // 게시글 동기화
                ),
              );
            },
          ),
        ));
  }
}
