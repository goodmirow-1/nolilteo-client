
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nolilteo/config/constants.dart';
import '../community/controllers/community_controller.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import '../wbti/model/wbti_type.dart';
import 'controller/notification_controller.dart';
import 'model/notification.dart';

class TotalNotificationPage extends StatefulWidget {
  const TotalNotificationPage({Key? key}) : super(key: key);

  @override
  _TotalNotificationPageState createState() => _TotalNotificationPageState();
}

class _TotalNotificationPageState extends State<TotalNotificationPage> {
  final GlobalData globalData = Get.put(GlobalData());
  final NotificationController notificationController = Get.put(NotificationController());
  final CommunityController communityController = Get.put(CommunityController());

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  List<NotificationModel> unreadList = [];
  List<NotificationModel> todayList = [];
  List<NotificationModel> weekList = [];
  List<NotificationModel> prevList = [];

  @override
  void initState() {
    unreadList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.NEW);
    todayList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.TODAY);
    weekList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.WEEK);
    prevList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.PREV);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      notificationController.readNoti();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
          appBar: customAppBar(context,
            title: '알림',
            centerTitle: false,
            controller: notificationController.scrollController
          ),
          body:  unreadList.isEmpty && todayList.isEmpty && weekList.isEmpty && prevList.isEmpty ? Center(child: noSearchResultWidget('알림이 없어요')) :

          SingleChildScrollView(

            child: RefreshIndicator(
              key: refreshKey,
              onRefresh: () async {
                unreadList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.NEW);
                todayList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.TODAY);
                weekList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.WEEK);
                prevList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.PREV);

                setState(() {

                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLine(),
                  buildNotificationList(unreadList, '읽지 않음'),
                  if(unreadList.isNotEmpty) buildLine(),
                  buildNotificationList(todayList, '오늘'),
                  if(todayList.isNotEmpty) buildLine(),
                  buildNotificationList(weekList, '이번 주'),
                  if(weekList.isNotEmpty) buildLine(),
                  buildNotificationList(prevList, '이전 알림'),
                  if(prevList.isNotEmpty) buildLine(),
                ],
              ),
            ),
          )
      ),
    );
  }

  Widget buildNotificationList(List<NotificationModel> notiList, String text){
    if(notiList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 0, 0),
          child: Text(text,
            style: TextStyle(
          fontSize: 16 * sizeUnit,
          fontWeight: FontWeight.w800,
          height: 1,
          color: nolColorOrange,
          ),),
        ),
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: notiList.length,
            itemBuilder: (BuildContext context, int index) {
              return Slidable(
                key: Key(notiList[index].id.toString()),
                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  extentRatio: 48 / 360,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        setState(() {
                          notificationController.removeNotification(notiList[index]);
                          notiList.remove(notiList[index]);
                        });
                      },
                      backgroundColor: const Color.fromRGBO(255, 139, 119, 1),
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_outlined,
                    ),
                  ],
                ),
                child: notificationItem(notiList[index]),
              );
            }, separatorBuilder: (BuildContext context, int index) => const Divider(height: 1,thickness: 0.5)
        ),
      ],
    );
  }

  void doNothing(BuildContext context) {}

  Widget notificationItem(NotificationModel model){

    return SizedBox(
      width: 360 * sizeUnit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24 * sizeUnit, 20 * sizeUnit, 0,  12 * sizeUnit),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    await notificationController.notiClickEvent(model).then((value) => {
                      setState(() {
                      })
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 24 * sizeUnit),
                    child: SizedBox(
                      width: 312 * sizeUnit,
                      child: Align(alignment: Alignment.topLeft, child: getNotiInfoText(model)),
                    ),
                  ),
                ),
                buildLine()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getNotiInfoText(NotificationModel model) {
    return RichText(
        text: TextSpan(children: [
          customTextSpan(model, 0),
          customTextSpan(model, 1),
          customTextSpan(model, 2),
          customTextSpan(model, 3),
          customTextSpan(model, 4),
          if(model.type != NOTI_EVENT_NEW_USER_WELCOME) ... [
            TextSpan(text: " ${GlobalFunction.timeCheck(GlobalFunction.replaceDate(model.createdAt))}", style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),)
          ]
        ]));
  }

  String getTypeStr(int type){
    return type == 0 ? '놀터' : type == 1 ? '일터' : '모여라';
  }

  TextSpan customTextSpan(NotificationModel model, int index) {
    String info = '';
    TextStyle style = STextStyle.body3();

    switch(model.type){

      case NOTI_EVENT_TEMP:
        {
          switch(index){
            case 0:
              {
                info = '모여라\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = "신입 디자이너의 애환..\n";
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '하잉 | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = "사교적인 디자이너";
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 회원님의 게시글을 좋아해요. ';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_LIKE:
        {
          switch(index){
            case 0:
              {
                info = '${getTypeStr(model.cType)}\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${model.nickName.split('/')[0]} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(model.nickName.split('/')[1]).title} ${model.nickName.split('/')[2]}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 회원님의 게시물을 좋아해요.';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY:
        {
          switch(index){
            case 0:
              {
                info = '${getTypeStr(model.cType)}\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${model.nickName.split('/')[0]} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(model.nickName.split('/')[1]).title} ${model.nickName.split('/')[2]}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 댓글을 남겼어요.';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY_LIKE:
        {
          switch(index){
            case 0:
              {
                info = '${getTypeStr(model.cType)}\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${model.nickName.split('/')[0]} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(model.nickName.split('/')[1]).title} ${model.nickName.split('/')[2]}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 회원님의 댓글을 좋아해요.';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY_REPLY:
        {
          switch(index){
            case 0:
              {
                info = '${getTypeStr(model.cType)}\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${model.nickName.split('/')[0]} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(model.nickName.split('/')[1]).title} ${model.nickName.split('/')[2]}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 회원님의 댓글에 답글을 남겼어요.';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_GATHERING_JOIN:
        {
          switch(index){
            case 0:
              {
                info = '${getTypeStr(model.cType)}\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${model.nickName.split('/')[0]} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(model.nickName.split('/')[1]).title} ${model.nickName.split('/')[2]}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님이 회원님의 모임에 참여했어요.';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_DAILY_POPULAR:
        {
          switch(index){
            case 0:
              {
                info = '띵동~!🔔 지금은 당 충전할 시간이예요.\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
              }
              break;
            case 3:
              {
              }
              break;
            case 4:
              {
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_WEEKLY_BEST:
        {
          switch(index){
            case 0:
              {
                info = '두둥~!💌 주간 베스트 게시글이 도착했어요.';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '${model.title}\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
              }
              break;
            case 3:
              {
              }
              break;
            case 4:
              {
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_NEW_USER_WELCOME:
        {
          switch(index){
            case 0:
              {
                info = '안내\n';
                style = STextStyle.subTitle3().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 1:
              {
                info = '가입인사\n';
                style = STextStyle.subTitle1().copyWith(height: 1.8);
              }
              break;
            case 2:
              {
                info = '${GlobalData.loginUser.nickName} | ';
                style = STextStyle.subTitle2().copyWith(height: 2.0);
              }
              break;
            case 3:
              {
                info = '${WbtiType.getType(GlobalData.loginUser.wbti).title} ${GlobalData.loginUser.job}';
                style = STextStyle.subTitle2().copyWith(color: const Color.fromRGBO(255, 139, 119, 1));
              }
              break;
            case 4:
              {
                info = '님! WBTI의 회원이 되신걸 진심으로 환영해요. 자유로운 당 충전시간을 가져봐요';
                style = STextStyle.body3();
              }
              break;
          }
        }
        break;
      default: break;
    }

    return TextSpan(text: info, style: style);
  }
}
