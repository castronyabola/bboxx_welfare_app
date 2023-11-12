
class Account {
  //Personal Details
  String myName;
  String employmentNumber;
  String membershipNumber;
  String IDNumber;
  String designation;
  String location;
  String phoneNumber;
  String role;
  String postalAddress;
  String postalCode;
  String myPin;
  String resetPin;
  String email;
  String uid;
  String guarantorUid;
  String guaranteeUid;

  //Next of Kin
  String nextOfKinName;
  String nextOfKinIDNumber;
  String nextOfKinPhoneNumber;
  String nextOfKinRelationship;

  //BENEFICIARIES
  //Parent/Guardian1
  String parent1Name;
  String parent1IDNumber;
  String parent1PhoneNumber;
  String parent1Relationship;

  //Parent/Guardian2
  String parent2Name;
  String parent2IDNumber;
  String parent2PhoneNumber;
  String parent2Relationship;

  //Spouse
  String spouseName;
  String spouseIDNumber;
  String spousePhoneNumber;
  String spouseRelationship;

  //child1
  String child1Name;
  String child1DateOfBirth;

  //child2
  String child2Name;
  String child2DateOfBirth;

  //child3
  String child3Name;
  String child3DateOfBirth;

  //child4
  String child4Name;
  String child4DateOfBirth;

  //child5
  String child5Name;
  String child5DateOfBirth;

  //loanDetails
  String reasonForLoan;
  String loanDisbursementMethod;

  bool welfareCreateCheck;

  String myAccountID;
  String guarantee;
  String guarantor;
  String guaranteeStatus;
  int guarantorBalance;
  int myLoan;
  int mySavings;
  String savingsStartDate;
  double loanInterest;
  int loanPaid;
  int loanDue;
  int loanPeriod;
  int loanRequested;
  int loanGranted;
  double loanInstallments;
  var loanDueDate;
  int monthlySavings;
  int selectedGuarantorCounter;
  int acceptedGuarantorCounter;
  String guarantorToken;
  String guaranteeToken;
  String dateApproved;
  bool notificationRead;

  Account(
      {
        this.myAccountID,
        this.myLoan,
        this.myName,
        this.mySavings,
        this.savingsStartDate,
        this.loanInterest,
        this.loanPaid,
        this.monthlySavings,
        this.loanDue,
        this.loanDueDate,
        this.guarantee,
        this.guaranteeStatus,
        this.guarantor,
        this.selectedGuarantorCounter,
        this.acceptedGuarantorCounter,
        this.loanRequested,
        this.loanPeriod,
        this.guarantorBalance,
        this.guarantorToken,
        this.guaranteeToken,
        this.dateApproved,
        this.notificationRead,
        this.loanInstallments,
        this.loanGranted,
        this.phoneNumber,
        this.location,
        this.designation,
        this.employmentNumber,
        this.IDNumber,
        this.membershipNumber,
        this.loanDisbursementMethod,
        this.reasonForLoan,
        this.myPin,
        this.resetPin,
        this.email,
        this.postalCode,
        this.postalAddress,
        this.role,
        this.child1DateOfBirth,
        this.child1Name,
        this.child2DateOfBirth,
        this.child2Name,
        this.parent1IDNumber,
        this.child3DateOfBirth,
        this.child3Name,
        this.child4DateOfBirth,
        this.child4Name,
        this.child5DateOfBirth,
        this.child5Name,
        this.nextOfKinIDNumber,
        this.nextOfKinName,
        this.nextOfKinPhoneNumber,
        this.nextOfKinRelationship,
        this.parent1Name,
        this.parent1PhoneNumber,
        this.parent1Relationship,
        this.parent2IDNumber,
        this.parent2Name,
        this.parent2PhoneNumber,
        this.parent2Relationship,
        this.spouseIDNumber,
        this.spouseName,
        this.spousePhoneNumber,
        this.spouseRelationship,
        this.uid,
        this.guaranteeUid,
        this.guarantorUid,
        this.welfareCreateCheck
      }
      );

  factory Account.fromJson(Map<String, dynamic> json) {

    return Account(
      myAccountID: json['myAccountID'],
      myLoan: json['myLoan'],
      myName: json['myName'],
      mySavings: json['mySavings'],
      savingsStartDate: json['savingsStartDate'],
      loanInterest: json['loanInterest'],
      loanPaid: json['loanPaid'],
      monthlySavings: json['monthlySavings'],
      loanDue: json['loanDue'],
      loanDueDate: json['loanDueDate'],
      guarantee: json['guarantee'],
      guarantor: json['guarantor'],
      guaranteeStatus: json['guaranteeStatus'],
      selectedGuarantorCounter: json['selectedGuarantorCounter'],
      acceptedGuarantorCounter: json['acceptedGuarantorCounter'],
        loanRequested: json['loanRequested'],
      loanPeriod: json['loanPeriod'],
      guarantorBalance: json['guarantorBalance'],
      guarantorToken:json['guarantorToken'],
      guaranteeToken:json['guaranteeToken'],
      dateApproved:json['dateApproved'],
      notificationRead:json['notificationRead'],
      loanInstallments:json['loanInstallments'],
      loanGranted:json['loanGranted'],
      phoneNumber:json['phoneNumber'],
      location:json['location'],
      designation:json['designation'],
      employmentNumber:json['employmentNumber'],
      IDNumber:json['IDNumber'],
      membershipNumber:json['membershipNumber'],
      loanDisbursementMethod:json['loanDisbursementMethod'],
      reasonForLoan:json['reasonForLoan'],
      myPin:json['myPin'],
        resetPin:json['resetPin'],
      email:json['email'],
        postalAddress:json['postalAddress'],
        postalCode:json['postalCode'],
        role:json['role'],
        child1Name:json['child1Name'],
      child2Name:json['child2Name'],
      child3Name:json['child3Name'],
      child4Name:json['child4Name'],
      child5Name:json['child5Name'],
      child1DateOfBirth:json['child1DateOfBirth'],
      child2DateOfBirth:json['child2DateOfBirth'],
      child3DateOfBirth:json['child3DateOfBirth'],
      child4DateOfBirth:json['child4DateOfBirth'],
      child5DateOfBirth:json['child5DateOfBirth'],
      spouseName:json['spouseName'],
      spouseIDNumber:json['spouseIDNumber'],
      spousePhoneNumber:json['spousePhoneNumber'],
      spouseRelationship:json['spouseRelationship'],
      parent1Name:json['parent1Name'],
      parent2Name:json['parent2Name'],
      parent1IDNumber:json['parent1IDNumber'],
      parent2IDNumber:json['parent2IDNumber'],
      parent1PhoneNumber:json['parent1PhoneNumber'],
      parent2PhoneNumber:json['parent2PhoneNumber'],
      parent1Relationship:json['parent1Relationship'],
      parent2Relationship:json['parent2Relationship'],
      nextOfKinName:json['nextOfKinName'],
      nextOfKinIDNumber:json['nextOfKinIDNumber'],
      nextOfKinRelationship:json['nextOfKinRelationship'],
      nextOfKinPhoneNumber:json['nextOfKinPhoneNumber'],
      uid:json['uid'],
      guaranteeUid: json['guaranteeUid'],
      guarantorUid: json['guarantorUid'],
      welfareCreateCheck: json['welfareCreateCheck']

    );
  }
}