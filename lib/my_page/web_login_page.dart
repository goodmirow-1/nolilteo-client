import 'package:flutter/material.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:nolilteo/repository/user_repository.dart';
import '../config/constants.dart';
import 'package:get/get.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';

class WebLoginPage extends StatefulWidget {
  const WebLoginPage({Key? key}) : super(key: key);

  @override
  State<WebLoginPage> createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage> {

  bool isOk = false;

  List<TextEditingController> textControllerList = List.generate(8, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for(var i = 0 ; i < textControllerList.length ; ++i){
      textControllerList[i].dispose();
    }

    super.dispose();
  }

  Widget otpTextfield(int index){
    return SizedBox(
      width: 20 * sizeUnit,
      child: TextField(
        controller: textControllerList[index],
          autofocus: index == 0 ? true : false,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
              counterText: "",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.black)
              ),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey)
            )
          ),
          onTap: () {
            if(index == 0){
              for (var element in textControllerList) {
                element.clear();
              }
            }else{
              textControllerList[index].clear();
            }

            setState(() {
              isOk = false;
            });
          },
          onChanged : (value) {
            if(value.isNotEmpty){
              FocusScope.of(context).nextFocus();
            }

            setState(() {

              int i = 0;
              for(i = 0 ; i < textControllerList.length ; ++i){
                bool needBreak = false;
                if(textControllerList[i].text.isEmpty || textControllerList[i].text == '' || textControllerList[i].text == ' '){
                  setState(() {
                    isOk = false;
                    needBreak = true;
                  });
                  if(needBreak == true){
                    break;
                  }
                }
              }

              if(i == 8){
                setState(() {
                  isOk = true;
                });
              }
            });
          }
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: 'WBTI 웹 로그인', centerTitle: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24 * sizeUnit, 16 * sizeUnit, 0, 0),
              child: Text('인증코드 입력', style: STextStyle.body2(),),
            ),
            SizedBox(height: 8 * sizeUnit,),
            Padding(
              padding: EdgeInsets.fromLTRB(44 * sizeUnit,0, 44 * sizeUnit, 0),
              child: Row(
                children: [
                  otpTextfield(0),
                  SizedBox(width: 14 * sizeUnit,),
                  Text('-', style: STextStyle.body3() ,),
                  SizedBox(width: 14 * sizeUnit,),
                  otpTextfield(1),
                  SizedBox(width: 8 * sizeUnit,),
                  otpTextfield(2),
                  SizedBox(width: 8 * sizeUnit,),
                  otpTextfield(3),
                  SizedBox(width: 14 * sizeUnit,),
                  Text('-', style: STextStyle.body3() ,),
                  SizedBox(width: 14 * sizeUnit,),
                  otpTextfield(4),
                  SizedBox(width: 8 * sizeUnit,),
                  otpTextfield(5),
                  SizedBox(width: 8 * sizeUnit,),
                  otpTextfield(6),
                  SizedBox(width: 8 * sizeUnit,),
                  otpTextfield(7),
                ],
              ),
            ),
            SizedBox(height: 40 * sizeUnit,),
            Padding(
              padding: EdgeInsets.only(left: 32 * sizeUnit, right: 32 * sizeUnit, bottom: 24 * sizeUnit),
              child: InkWell(
                borderRadius: BorderRadius.circular(24 * sizeUnit),
                onTap: () async {
                  if(false == isOk){
                    GlobalFunction.showToast(msg: '인증코드를 입력해 주세요.');
                  }else{
                    String otp = '';

                    for (var element in textControllerList) {
                      otp += element.text;
                    }

                    var res = await UserRepository.otpCheck(otp: otp);

                    showCustomDialog(
                      title: res == false ? '인증코드가 올바르지 않습니다.\n확인 후 다시 입력해 주세요.' : '웹으로 돌아가서 완료를 눌러주세요.',
                      okFunc: () {
                        Get.back();
                        Get.back();
                      },
                      okText: '네',
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48 * sizeUnit,
                  decoration: BoxDecoration(
                    color: isOk ? nolColorOrange : nolColorGrey,
                    borderRadius: BorderRadius.circular(24 * sizeUnit),
                  ),
                  child: Center(
                      child: Text('확인', style: STextStyle.button()),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
