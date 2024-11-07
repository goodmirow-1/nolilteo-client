import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/my_page/controller/my_post_controller.dart';

import '../community/community_detail_page.dart';
import '../community/componets/post_card.dart';
import '../community/models/post.dart';
import '../config/constants.dart';
import '../config/global_function.dart';
import '../config/global_widgets/animated_tap_bar.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/custom_navigation_bar.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/global_widgets/responsive.dart';
import '../repository/post_repository.dart';

class MyPostPage extends StatefulWidget {
  final bool isLike;
  final int userID;

  const MyPostPage({Key? key, required this.isLike, required this.userID}) : super(key: key);

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  final MyPostController controller = Get.put(MyPostController(tag: GlobalData.myPostPageCount.toString()), tag: GlobalData.myPostPageCount.toString());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() => controller.maxScrollEvent(scrollController));
    controller.isLike = widget.isLike;
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
      child: GetBuilder<MyPostController>(
          id: 'fetchData',
          tag: controller.tag,
          initState: (_) => controller.fetchData(widget.userID),
          builder: (_) {
            if (controller.fetchLoading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

            return Scaffold(
              appBar: customAppBar(context, 
                title: controller.isLike
                    ? '좋아요한 글'
                    : widget.userID == GlobalData.loginUser.id
                        ? '내 게시글'
                        : '게시글 보기',
                centerTitle: false,
              ),
              body: GetBuilder<MyPostController>(
                  tag: controller.tag,
                  builder: (_) {
                    return Column(
                      children: [
                        AnimatedTapBar(
                          barIndex: controller.showIndex,
                          listTabItemTitle: controller.titleList,
                          listTabItemWidth: controller.titleWidthList,
                          onPageChanged: (index) {
                            if (controller.pageController.hasClients) controller.pageController.animateToPage(index, duration: AnimatedTapBar.duration, curve: AnimatedTapBar.curve);
                            if (scrollController.hasClients && scrollController.offset > 0.1) scrollController.jumpTo(0.1);
                          },
                        ),
                        buildLine(),
                        SizedBox(height: 16 * sizeUnit),
                        Expanded(child: buildPageView()),
                      ],
                    );
                  }),
            );
          }),
    );
  }

  PageView buildPageView() {
    return PageView.builder(
        controller: controller.pageController,
        itemCount: controller.titleList.length,
        onPageChanged: (index) => controller.pageChange(index),
        itemBuilder: (context, index) {
          return customRefreshIndicator(
              onRefresh: controller.onRefresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.postList.length,
                itemBuilder: (context, index) {
                  Post post = controller.postList[index];

                  return PostCard(
                    post: post,
                    onTap: () {
                      exitFunc() async {
                        bool? result = await PostRepository.postLike(post.id, post.type);
                        if (result != null && result) {
                          controller.remove(index);
                          Get.back();
                        }
                      }

                      if (controller.isLike == false) {
                        Get.toNamed('${CommunityDetailPage.route}/${post.id}')!.then((value) => GlobalFunction.syncPost());
                      } else {
                        if (post.deleteType == 1) {
                          showCustomDialog(
                            title: '삭제된 게시글입니다.',
                            description: '좋아요를 취소하시겠어요?',
                            okFunc: exitFunc,
                            isCancelButton: true,
                            okText: '네',
                            cancelText: '아니오',
                          );
                        } else if (post.deleteType == 2) {
                          showCustomDialog(
                            title: '신고누적으로 삭제된 게시글입니다.',
                            description: '좋아요를 취소하시겠어요?',
                            okFunc: exitFunc,
                            isCancelButton: true,
                            okText: '네',
                            cancelText: '아니오',
                          );
                        } else if (post.deleteType == 3) {
                          showCustomDialog(
                            title: '관리자에 의해 삭제된 게시글입니다.',
                            description: '좋아요를 취소하시겠어요?',
                            okFunc: exitFunc,
                            isCancelButton: true,
                            okText: '네',
                            cancelText: '아니오',
                          );
                        } else {
                          Get.toNamed('${CommunityDetailPage.route}/${post.id}')!.then((value) => GlobalFunction.syncPost());
                        }
                      }
                    }, // 게시글 동기화
                  );
                },
              ));
        });
  }
}
