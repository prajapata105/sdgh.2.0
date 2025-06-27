import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ssda/utils/constent.dart';
import '../../weight/snapkbar.dart';
import 'login-otp.dart';

class MobileNumber extends StatefulWidget {
  const MobileNumber({Key? key}) : super(key: key);
  static String phonenumber = '';
  @override
  State<MobileNumber> createState() => _MobileNumberState();
}
class _MobileNumberState extends State<MobileNumber> {
  final TextEditingController _mobilenumber = TextEditingController();
  final auth = FirebaseAuth.instance;
  final formGlobalKey = GlobalKey<FormState>();
  Snakbar snakbar = Snakbar();
  bool loding = false;
  var size,w,h;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: h*0.02,horizontal: w*0.04),
            child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('loginscreen').snapshots(), builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context,int index){
                              Map<String, dynamic> bannners = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return SizedBox(
                                height:h*0.2,
                                width: w*1,
                                child:SvgPicture.network(bannners['image'].toString(),fit: BoxFit.contain),
                              );
                            });

                      } else {
                        return const Text('data not found');
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
                  SizedBox(height: h*0.04,),
                  Text(
                    'Phone Verification',
                    style: Maintital,
                  ),
                  SizedBox(height: h*0.05,),
                  Text('We need to register your phone number before getting started !',style: Subtital,),
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.05,bottom: h*0.01),
                    child:      Container(
                      height: h * 0.06,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: ksubprime),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child:

                            CountryCodePicker(
                              initialSelection: 'IN',
                              closeIcon: const Icon(Icons.close),
                              enabled: false,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const Text(
                            "|",
                            style: TextStyle(fontSize: 33, color: ksubprime),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              flex: 2,
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller: _mobilenumber,
                                validator: (val) {
                                  if (val!.length !=10) {
                                    return snakbar.snakbarsms('कृपया सही मोबाइल नंबर डाले');
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  MobileNumber.phonenumber = value;
                                },
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Phone Number",
                                ),

                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  InkWell(
                    splashColor: Colors.greenAccent,
                    focusColor: Colors.cyanAccent,
                    hoverColor: Colors.red,
                    onTap: () {
                      if(formGlobalKey.currentState!.validate()){
                        setState(() {
                          loding = true;
                        });
                      }
                      auth.verifyPhoneNumber(
                          verificationCompleted: (_) {
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            snakbar.snakbarsms(e.toString());
                            setState(() {
                              loding = false;
                            });
                            if(e.code == 'invalid-phone-number'){
                              setState(() {
                                loding = false;
                              });
                              snakbar.snakbarsms('कृपया सही मोबाइल नंबर डाले ');
                            }
                          },
                          codeSent: (String verification, int? token) {
                            setState(() {
                              loding = false;
                            });
                            snakbar.snakbarsms('ओटीपी भेज दिया गया है');
                            Get.off(OtpScreen(
                              verfyid: verification,
                            ));
                          },
                          codeAutoRetrievalTimeout: (_) {
                            setState(() {
                              loding = false;
                            });
                            snakbar.snakbarsms('समय सीमा समाप्त हो गई है');
                          },
                          phoneNumber: "+91${_mobilenumber.text}"
                      ).then((value){
                        setState(() {
                        });
                      });
                    },
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: h * 0.06,
                        width: w * 1,
                        decoration: BoxDecoration(
                          boxShadow: const [BoxShadow(color: kPrimaryColor, blurRadius: 4)],
                          color: ksubprime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                        loding ? const CircularProgressIndicator(
                          color: kPrimaryColor,
                        ) :
                        const Text(
                          'Send OTP',
                          style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
