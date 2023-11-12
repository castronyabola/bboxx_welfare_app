import 'package:bboxx_welfare_app/pdf_manager/model/customer.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  final List<InvoiceInfo> loanDetails;

  const Invoice({
     this.info,
     this.supplier,
     this.customer,
     this.items,
    this.loanDetails
  });
}

class InvoiceInfo {
  final String myName;
  final String employmentNumber;
  final String membershipNumber;
  final String IDNumber;
  final String designation;
  final String location;
  final String phoneNumber;
  final String applicantDetails;
  final String description;
  final String number;
  final String date;
  final String dueDate;
  final String paymentPeriod;
  final String totalGuarantorAmount;
  final String loanAmount;
  final String loanInstallments;
  final String mySavings;
  final String reasonForLoan;
  final String loanDisbursementMethod;


  const InvoiceInfo({
     this.description,
     this.number,
     this.date,
     this.dueDate,
    this.paymentPeriod,
    this.totalGuarantorAmount,
    this.applicantDetails,
    this.phoneNumber,
    this.location,
    this.designation,
    this.IDNumber,
    this.membershipNumber,
    this.employmentNumber,
    this.myName,
    this.loanInstallments,
    this.loanAmount,
    this.mySavings,
    this.reasonForLoan,
    this.loanDisbursementMethod
  });
}

class InvoiceItem {
  final String name;
  final String guarantorAmount;
  final String guarantorRequestStatus;
  final String date;


  const InvoiceItem({
     this.name,
     this.date,
     this.guarantorAmount,
     this.guarantorRequestStatus,
  });
}
