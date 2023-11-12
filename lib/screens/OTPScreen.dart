import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../google_signin_provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key key, this.phoneNumber, this.countryCode, this.emailAddress}) : super(key: key);
  final String phoneNumber;
  final String countryCode;
  final String emailAddress;
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  String verifiedPhoneNumber = '';
  //String SMSCode = '';

  verifyPhone() async{
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async{
          //SMSCode = credential.smsCode;
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async{
            if(value.user != null){
              await FirebaseFirestore.instance
                  .collection("phoneNumbers")
                  .doc(user.email)
                  .set({
                'phoneNumber': FirebaseAuth.instance.currentUser.phoneNumber.replaceAll(widget.countryCode, ''),
              });

              final provider =
              Provider.of<GoogleSignInProvider>(context, listen:false);
              provider.logout();
              //AuthMethods().signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PageHandler()),
                      (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e){
          print(e.message);
        },
        codeSent: (String verificationID, int resendToken){
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID){
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 60)
    );
  }
  Future invalidCodeDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),topRight:Radius.circular(20))
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Invalid Code',style: TextStyle(color:Colors.red,fontSize: 12),),
            ],
          ),
          content: Text(
            'You have Entered an Invalid Code. Please try again',
            textAlign: TextAlign.center,style: TextStyle(fontSize: 11),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Okay',style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future phoneAdditionNotificationDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),topRight:Radius.circular(20))
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Phone Number Addition',style: TextStyle(color:Colors.green,fontSize: 12),),
            ],
          ),
          content: Text(
            '''You have Successfully Added your Official Phone Number. You will be redirected to the login page after pressing the Okay Button.''',
            textAlign: TextAlign.center,style: TextStyle(fontSize: 11),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Okay',style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                    final provider =
                    Provider.of<GoogleSignInProvider>(context, listen:false);
                    provider.logout();
                    //AuthMethods().signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => PageHandler()),
                            (route) => false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    verifyPhone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: GoogleFonts.poppins(
          fontSize: 12, color: Colors.lightBlue),//Color.fromRGBO(70, 69, 66, 1)),
      decoration: BoxDecoration(
        color: Color.fromRGBO(240, 240, 250, 0.37),
        borderRadius: BorderRadius.circular(24),
      ),
    );
    final cursor = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(200),
            //bottomLeft: Radius.circular(200)
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        title: Column(
          children: [
            Center(
              child: Container(
                  height: 50,
                  width: 50,
                  child: Image.asset('android/assets/images/Bboxx_icon.png')),
            ),
            SizedBox(height: 10),
            Text("Phone Number Verification", style:TextStyle(fontWeight:FontWeight.w600,color: Colors.lightBlue, fontSize: 16)),
            SizedBox(height: 40),
          ],
        ),
        toolbarHeight: 150,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 0,
                  blurRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20.0),
                      child: Text('Please Enter the code sent to the number below',style:TextStyle(fontSize: 12)),
                    )
                ),
                Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top:25.0),
                      child: Text('(${widget.countryCode}) ${widget.phoneNumber.replaceAll(widget.countryCode, '')}', style:TextStyle(color:Colors.blue,fontSize: 12, fontWeight: FontWeight.w800)),
                    )
                ),
                SizedBox(height: size.height*0.2),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Pinput(
                    listenForMultipleSmsOnAndroid: true,
                    //androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                    length: 6,
                    controller: _pinPutController,
                    focusNode: _pinPutFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    //separator: SizedBox(width: 16),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05999999865889549),
                            offset: Offset(0, 3),
                            blurRadius: 16,
                          )
                        ],
                      ),
                    ),
                    showCursor: true,
                    cursor: cursor,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    onCompleted: (pin) async{
                     try{
                       await FirebaseAuth.instance.signInWithCredential(
                           PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin))
                           .then((value) async{
                         if(value.user != null){
                           //verifiedPhoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
                           //createAccount();
                           await FirebaseFirestore.instance
                               .collection("phoneNumbers")
                               .doc(user.email)
                               .set({
                             'phoneNumber': FirebaseAuth.instance.currentUser.phoneNumber.replaceAll('${widget.countryCode}', ''),
                           });
                           phoneAdditionNotificationDialog();
                         }
                           });
                     }catch (e){
                       FocusScope.of(context).unfocus();
                        invalidCodeDialog();
                       //_scaffoldkey.currentState.showSnackBar(SnackBar(content: Text('Invalid OTP')));
                      }
                    },
                  ),
                ),
                SizedBox(height: size.height*0.2),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(10),
                          //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                          fixedSize: MaterialStateProperty.all(Size(size.width*0.3, size.height*0.05)),
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )
                          )
                      ),
                      child: Text("Back", style: TextStyle(fontSize:12,color: Colors.lightBlue)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
