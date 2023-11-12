import 'dart:async';
import 'dart:io';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/models/notifications.dart';
import 'package:bboxx_welfare_app/pdf_manager/api/pdf_api.dart';
import 'package:bboxx_welfare_app/pdf_manager/api/pdf_invoice_api.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/customer.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/invoice.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/supplier.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:smart_select/smart_select.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  var now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MMM/yyyy');
  final DateFormat dateFormatter = DateFormat('ddMMyy');
  var time = const Duration(seconds: 5);

  final user = FirebaseAuth.instance.currentUser;
  bool controller = false;
  int acceptedGuarantorCounterStore = 0;
  String myAccountID = '';
  int myLoan = 0;
  String myName = '';
  int mySavings = 0;
  String savingsStartDate = '';
  double loanInterest = 0.0;
  //int loanPaid = 0;
  int loanDue = 0;
  int loanRequested = 0;
  int monthlySavings = 0;
  //String loanDueDate = '';
  String guarantee = '';
  String guarantor = '';
  String guaranteeStatus = '';
  int acceptedGuarantorCounter = 0;
  int guarantorBalance = 0;
  int loanPeriod = 0;
  double loanInstallments = 0.0;
  int loanGranted = 0;
  String pdfDownloadURL = '';
  String employmentNumber;
  String membershipNumber;
  String IDNumber;
  String designation;
  String location;
  String reasonForLoan = '';
  String loanDisbursementMethod = '';


  List<Account> _accountDetails = [];
  List<Account> filteredAccountDetails = <Account>[];

  List<Account> getAccount() {
    return _accountDetails;
  }

  final _formKey = GlobalKey<FormState>();

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();
  FocusNode f6 = FocusNode();
  FocusNode f7 = FocusNode();

  final phoneNumberHolder = TextEditingController();
  final savingsHolder = TextEditingController();
  final monthlyDeductionsHolder = TextEditingController();
  final loanHolder = TextEditingController();
  final loanRepaymentPeriodHolder = TextEditingController();
  final loanBalanceHolder = TextEditingController();
  final loanPaidHolder = TextEditingController();
  final loanDueDateHolder = TextEditingController();

  String phoneNumber = '';
  int savings = 0;
  int monthlyDeductions = 0;
  int loan = 0;
  int loanRepaymentPeriod = 0;
  int loanBalance = 0;
  int loanPaid = 0;
  String loanDueDate = '';

  @override
  void initState() {
    super.initState();
    getData();
    Notifications.init();
  }

  void listenNotifications(){
    Notifications.onNotifications.stream.listen(onClickedNotification);
  }

  void onClickedNotification(String payload){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Guarantors())
    );
  }


  Future <void> submitUserDetails() async{
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc('Accounts')
        .update({
      '${phoneNumber}.${'mySavings'}': savings,
      '${phoneNumber}.${'monthlySavings'}': monthlyDeductions,
      '${phoneNumber}.${'myLoan'}': loan,
      '${phoneNumber}.${'loanPeriod'}': loanRepaymentPeriod,
      '${phoneNumber}.${'loanDue'}': loanBalance,
      '${phoneNumber}.${'loanPaid'}': loan - loanBalance,
      '${phoneNumber}.${'loanDueDate'}': loanDueDate,
    });
  }
  Future submitDetailsConfirmDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Update User Details',style: TextStyle(fontSize: 15, color:Colors.white),),
            ],
          ),
          content: Container(
            //height: 100,
            child:
            Text('',
                 style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.start,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Agree',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                    submitUserDetails();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future <void> getData() async {
    controller = true;
    await FirebaseFirestore.instance.collection("welfareUsers").doc('Accounts').get().then((value){
      if (!mounted || controller == false) return;
      setState(() {
        _accountDetails.clear();
        List.from(value.data().values).forEach((element){
          Account data = Account.fromJson(element);
          _accountDetails.add(data);
          if(data.uid == user.uid) {
            mySavings = data.mySavings;
            myLoan = data.myLoan;
            loanDue = data.loanDue;
            loanPaid = 0;//data.loanPaid;
            loanInterest = data.loanInterest;
            loanDueDate = data.loanDueDate;
            savingsStartDate = data.savingsStartDate;
            monthlySavings = data.monthlySavings;
            myName = data.myName;
            loanRequested = data.loanRequested;
            loanPeriod = data.loanPeriod;
            loanInstallments = data.loanInstallments;
            loanGranted = data.loanGranted;
            employmentNumber = data.employmentNumber;
            membershipNumber = data.membershipNumber;
            IDNumber = data.IDNumber;
            designation = data.designation;
            location = data.location;
            phoneNumber = data.phoneNumber;
            reasonForLoan = data.reasonForLoan;
            loanDisbursementMethod = data.loanDisbursementMethod;
          }

          acceptedGuarantorCounter = _accountDetails
              .where((element) =>
          element.guaranteeStatus == 'accepted' &&
              element.guarantee == myName)
              .length;

          filteredAccountDetails = _accountDetails.where((element) =>
          element.guarantee == myName &&
          element.guaranteeStatus == 'accepted').toList();

        });
      });
    });
    acceptedGuarantorCounterStore = acceptedGuarantorCounter;
    controller = false;
  }

  generatePDF() async{
    var baseFormatter = dateFormatter.format(now);
    var newFormatter = formatter.format(now);

    String guarantorAmount = '${currencyFormat.format(loanRequested~/3)}';

     String name0;
     String date0;

    String name1;
    String date1;

    String name2;
    String date2;

    filteredAccountDetails.asMap().forEach((key, value) async{
      name0 = filteredAccountDetails[0].guarantor;
      date0 = filteredAccountDetails[0].dateApproved;

      name1 = filteredAccountDetails[1].guarantor;
      date1 = filteredAccountDetails[1].dateApproved;

      name2 = filteredAccountDetails[2].guarantor;
      date2 = filteredAccountDetails[2].dateApproved;
    });

    final invoice = Invoice(
      supplier: Supplier(
        name: 'BBOXX STAFF WELFARE SELF HELP GROUP',
        address:
        'P.O. BOX 1886-40100\n'
        'KISUMU-KENYA\n'
        'Tel:0700110790/0722537356\n'
        'Email: bboxxwelfare@gmail.com',
      ),
      customer: Customer(
        name: myName,
        address: 'Loan: ${currencyFormat.format(loanRequested)}',
      ),
      info: InvoiceInfo(
        mySavings: mySavings.toString(),
        loanAmount: loanRequested.toString(),
        reasonForLoan: reasonForLoan,
        loanDisbursementMethod: loanDisbursementMethod,
        loanInstallments: currencyFormat.format(loanInstallments),
        myName: myName,
        employmentNumber: employmentNumber,
        membershipNumber: membershipNumber,
        IDNumber: IDNumber.toString(),
        designation: designation,
        location: location,
        phoneNumber: phoneNumber,
        date: newFormatter,
        dueDate: loanDueDate,
        paymentPeriod: '${loanPeriod} Months',
        description: 'The undersigned, hereby accept jointly and severally liable for the repayment of the loan in the event of the borrower\u0027s default. The amount in default may be recovered by an offset against their savings in the Welfare, salaries or dividends till the defaulted amount has been cleared in full. This undertaking should be honored accordingly till the loan in default is fully recovered.',
        number: 'BXCK0013${baseFormatter}',
        totalGuarantorAmount: '${currencyFormat.format(loanRequested)}'
      ),
      items: [
        InvoiceItem(
          name: name0,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date0,
        ),
        InvoiceItem(
          name: name1,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date1,
        ),
        InvoiceItem(
          name: name2,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date2,
        ),
      ],
      loanDetails:
        [
          InvoiceInfo(
            applicantDetails: 'Current Savings',
            date: '${currencyFormat.format(mySavings)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan limit',
            date: '${currencyFormat.format((mySavings*3) - loanDue)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Monthly savings',
            date: '${currencyFormat.format(monthlySavings)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan requested',
            date: '${currencyFormat.format(loanGranted)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan balance',
            date: '${currencyFormat.format(loanDue)}',
          ),
          InvoiceInfo(
            applicantDetails: '50% qualification amount',
            date: '${currencyFormat.format(loanGranted)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Repayment period (Months)',
            date: '${loanPeriod} Months',
          ),
          InvoiceInfo(
            applicantDetails: 'Instalments',
            date: '${currencyFormat.format(loanInstallments)}',
          ),
        ]
    );

    final pdfFile = await PdfInvoiceApi.generate(invoice);

    PdfApi.openFile(pdfFile)
        .then((value) => uploadPDF())
        .then((value) => sendEmail());

  }
 uploadPDF() async{
   var formatted = formatter.format(now);

    FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child("${myName} Loan on: " + formatted.toString() +'.pdf');
  UploadTask uploadTask = ref.putFile(File(PdfApi.url));
    var downloadUrl = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    String url = downloadUrl.toString();
    print('URL is: $url');
    pdfDownloadURL = url;
    return url;

}

sendEmail() async
  {
    var formatted = formatter.format(now);

    await FirebaseFirestore.instance
        .collection('mail')
        .add(
      {
        'to': user.email,
        'cc':'info@globsoko.com',
        'message': {
          'subject': 'Bboxx Welfare Loan Form ${formatted.toString()}',
          'text': 'Dear ${myName},\n'
              '\n'
              'Your loan request of Kes. ${currencyFormat.format(loanRequested)} has been approved.\n'
              'Please find attached the approved loan form.\n'
              '\n'
              'Regards,\n'
              'Bboxx Welfare',
          'attachments': [{
            'contentType':'pdf',
            'filename':'${myName} Welfare Loan.pdf',
            'href': pdfDownloadURL
          }]
        },
      }
    );
  }

  @override
  Widget build (BuildContext context) {

    final Size size = MediaQuery
        .of(context)
        .size;
    double var12 = size.height * 0.0185;

    return WillPopScope(
      onWillPop: () async => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigation())
      ),
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(100),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()
            {
              controller = false;
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => navigation())
              );
            },
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 3,
          title: Text("Welfare Admin", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)),
          toolbarHeight: 50,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('WELFARE USER DETAILS',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.lightBlue)),
            ),
            Divider(
              indent: 12,
              endIndent: 12,
              thickness: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                 child: Column(
              children: [
                SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
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
                    child: Column(
                      children: [
                        Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget> [
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f1,
                                      keyboardType: TextInputType.phone,
                                      controller: phoneNumberHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "User Registered Phone Number",
                                        labelText: "Phone Number",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      maxLength: 10,
                                      onChanged: (value) {
                                        //controller = false;
                                        phoneNumber = value.replaceFirst('0', '');
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter phone Number";
                                        }
                                        else if (value.length != 10){
                                          return 'Phone number must be 10 digits';
                                        }
                                        return null;
                                      },
                                    )
                                ),
                                Padding(
                                  padding: EdgeInsets.all(var12),
                                  child:
                                  TextFormField(
                                    focusNode: f2,
                                    keyboardType: TextInputType.number,
                                    controller: savingsHolder,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                      hintText: "User Savings",
                                      labelText: "Savings",
                                      //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                    ),
                                    onChanged: (value) {
                                      //controller = false;
                                      savings = int.parse(value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty){
                                        return "Please enter loan amount";
                                      }
                                      // else if (int.parse(amount) > maxLoanAmount){
                                      //   return 'You do not qualify for this amount';
                                      // }
                                      return null;
                                    },
                                  )
                                ),
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f3,
                                      keyboardType: TextInputType.number,
                                      controller: monthlyDeductionsHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "Monthly Deductions",
                                        labelText: "Deductions",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      onChanged: (value) {
                                        //controller = false;
                                        monthlyDeductions = int.parse(value);;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter deductions amount";
                                        }
                                        // else if (int.parse(amount) > maxLoanAmount){
                                        //   return 'You do not qualify for this amount';
                                        // }
                                        return null;
                                      },
                                    )
                                ),
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f4,
                                      keyboardType: TextInputType.number,
                                      controller: loanHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "Current Loan Amount",
                                        labelText: "Loan Amount",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      onChanged: (value) {
                                        //controller = false;
                                        loan = int.parse(value);;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter loan amount";
                                        }
                                        // else if (int.parse(amount) > maxLoanAmount){
                                        //   return 'You do not qualify for this amount';
                                        // }
                                        return null;
                                      },
                                    )
                                ),
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f5,
                                      keyboardType: TextInputType.number,
                                      controller: loanRepaymentPeriodHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "Loan repayment Period",
                                        labelText: "Repayment Period",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      onChanged: (value) {
                                        //controller = false;
                                        loanRepaymentPeriod = int.parse(value);;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter loan repayment period";
                                        }
                                        // else if (int.parse(amount) > maxLoanAmount){
                                        //   return 'You do not qualify for this amount';
                                        // }
                                        return null;
                                      },
                                    )
                                ),
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f6,
                                      keyboardType: TextInputType.number,
                                      controller: loanBalanceHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "Loan Balance",
                                        labelText: "Loan Balance",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      onChanged: (value) {
                                        //controller = false;
                                        loanBalance = int.parse(value);;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter loan amount";
                                        }
                                        // else if (int.parse(amount) > maxLoanAmount){
                                        //   return 'You do not qualify for this amount';
                                        // }
                                        return null;
                                      },
                                    )
                                ),
                                // Padding(
                                //     padding: EdgeInsets.all(var12),
                                //     child:
                                //     TextFormField(
                                //       focusNode: f6,
                                //       keyboardType: TextInputType.number,
                                //       controller: loanPaidHolder,
                                //       decoration: InputDecoration(
                                //         border: OutlineInputBorder(
                                //             borderRadius: BorderRadius.all(Radius.circular(5))
                                //         ),
                                //         //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                //         hintText: "Loan paid",
                                //         labelText: "Loan Paid",
                                //         //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                //       ),
                                //       onChanged: (value) {
                                //         //controller = false;
                                //         loanPaid = double.parse(value);
                                //       },
                                //       validator: (value) {
                                //         if (value == null || value.isEmpty){
                                //           return "Please enter loan amount";
                                //         }
                                //         // else if (int.parse(amount) > maxLoanAmount){
                                //         //   return 'You do not qualify for this amount';
                                //         // }
                                //         return null;
                                //       },
                                //     )
                                // ),
                                Padding(
                                    padding: EdgeInsets.all(var12),
                                    child:
                                    TextFormField(
                                      focusNode: f7,
                                      keyboardType: TextInputType.datetime,
                                      controller: loanDueDateHolder,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                        hintText: "Loan Due Date",
                                        labelText: "Loan Due Date",
                                        //helperText: 'Maximum amount ${currencyFormat.format(maxLoanAmount)}',
                                      ),
                                      onChanged: (value) {
                                        //controller = false;
                                        loanDueDate = value;;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter loan amount";
                                        }
                                        // else if (int.parse(amount) > maxLoanAmount){
                                        //   return 'You do not qualify for this amount';
                                        // }
                                        return null;
                                      },
                                    )
                                ),
                                SizedBox(height: 30,),
                                 ],
                                ),
                             ),
                      ],
                    ),

                  ),
                ),
                 ]
               )
              ),
            ),
            Divider(
              indent: 12,
              endIndent: 12,
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: var12),
              child: Center(
                child:ElevatedButton (
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                             Colors.lightBlue
                        ),
                        fixedSize: MaterialStateProperty.all<Size>(
                            Size(size.width*0.65, size.height*0.025)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              //side: BorderSide(color: Colors.lightBlue)
                            )
                        )
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        submitDetailsConfirmDialog();
                          //loanDialog();
                      }
                    },
                    child:
                    Text("Continue", style: TextStyle(color: Colors.white),)
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}

