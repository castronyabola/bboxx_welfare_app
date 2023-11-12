import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/screens/loginpage.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();

  final _formKey = GlobalKey<FormState>();

  final emailHolder = TextEditingController();
  final passwordHolder = TextEditingController();
  final confirmPasswordHolder = TextEditingController();


  String password;
  String confirmPassword;
  String email;

  bool passwordView = true;
  bool confirmPasswordView = true;

  @override
  void initState() {
    super.initState();
  }

  Future signUp() async{
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailHolder.text.trim(),
          password: passwordHolder.text.trim()
      );
        Navigator.of(context).pop();
       return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHandler()));

    } on FirebaseAuthException catch(e){
      Navigator.of(context).pop();
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          //backgroundColor:Colors.yellowAccent,
          title: Center(child: new Text('Alert!',style: TextStyle(fontSize: 14))),
          content: Text(e.message,
              textAlign: TextAlign.center,style: TextStyle(color:Colors.red,fontSize: 12)),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                  return Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageHandler()));

                },
              ),
            ),

          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()));
             },
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(200),
                //bottomRight: Radius.circular(200)
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: ()
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage())
                );
              },
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.lightBlue),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 8,
            title: Column(
              children: [
                Text("Registration", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)),
              ],
            ),
            toolbarHeight: 50,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        SizedBox(height:size.height*0.01),
                        Column(
                          children: [
                            Text("LOG IN DETAILS", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                            Form(
                              key: _formKey,
                              child:
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(12),
                                          child:
                                          TextFormField(
                                            textAlignVertical: TextAlignVertical.top,
                                            focusNode: f1,
                                            keyboardType: TextInputType.emailAddress,
                                            controller: emailHolder,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.email),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.lightBlueAccent.shade100,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              labelText: "Email address",
                                              //helperText: 'Edit Your Employment Number',
                                            ),
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onChanged: (value) {
                                              //email = value;
                                            },
                                            validator: (value) {
                                              if (value != null && !EmailValidator.validate(value)){
                                                return "Please Enter a Valid Email";
                                              }
                                              return null;
                                            },
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(12),
                                          child:
                                          TextFormField(
                                            textAlignVertical: TextAlignVertical.top,
                                            obscureText: passwordView,
                                            obscuringCharacter: '*',
                                            focusNode: f2,
                                            keyboardType: TextInputType.visiblePassword,
                                            controller: passwordHolder,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.lock),
                                              suffix: IconButton(
                                                  padding: EdgeInsets.only(bottom: 5,top: 0),
                                                  onPressed: (){
                                                    setState(() {
                                                      return passwordView = !passwordView;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    passwordView ? Icons.visibility: Icons.visibility_off,
                                                    color: Colors.lightBlue,
                                                  )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.lightBlueAccent.shade100,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              labelText: "Password",
                                            ),
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onChanged: (value) {
                                              password = value;
                                            },
                                            validator: (password) {
                                              if (password != null && password.length < 8){
                                                return "Please enter a valid password";
                                              }
                                              return null;
                                            },
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(12),
                                          child:
                                          TextFormField(
                                            textAlignVertical: TextAlignVertical.top,
                                            obscureText: confirmPasswordView,
                                            obscuringCharacter: '*',
                                            focusNode: f3,
                                            keyboardType: TextInputType.visiblePassword,
                                            controller: confirmPasswordHolder,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.lock),
                                              suffix: IconButton(
                                                  padding: EdgeInsets.only(bottom: 5,top: 0),
                                                  onPressed: (){
                                                    setState(() {
                                                      return confirmPasswordView = !confirmPasswordView;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    confirmPasswordView ? Icons.visibility: Icons.visibility_off,
                                                    color: Colors.lightBlue,
                                                  )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.lightBlueAccent.shade100,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              labelText: "Confirm Password",
                                            ),
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onChanged: (value) {
                                              confirmPassword = value;
                                            },
                                            validator: (password) {
                                              if (password != passwordHolder.text.trim()){
                                                return 'The passwords do not match';
                                              }
                                              return null;
                                            },
                                          )
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(10),
                                  //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                                  fixedSize: MaterialStateProperty.all(Size(size.width*0.75, size.height*0.05)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      )
                                  )
                              ),
                              child: Text("Register", style: TextStyle(color: Colors.lightBlue)),
                              onPressed: () {
                                if(_formKey.currentState.validate()) {
                                  signUp();
                                  //submitData();
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(child: CircularProgressIndicator());
                                    });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Already have an Account ? ',style: TextStyle(color: Colors.lightBlue)),
                                  Text('Sign In', style: TextStyle(color:Colors.lightBlue,fontWeight: FontWeight.bold)),
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}
