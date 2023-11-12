import 'dart:io';
import 'package:bboxx_welfare_app/pdf_manager/api/pdf_api.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/customer.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/invoice.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/supplier.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:intl/intl.dart';


var currencyFormat = new NumberFormat.currency(locale: "en_US",
    symbol: "KES ", decimalDigits: 0);

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 0.2 * PdfPageFormat.cm),
        buildTitlePage1(invoice),
        SizedBox(height: 1 * PdfPageFormat.cm),
        buildFooter(invoice),

        //buildHeader(invoice),
        //SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildFooter(invoice),
      ],
      //footer: (context) => buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'welfare loan.pdf', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 0.1 * PdfPageFormat.cm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data:
                      'Loan Applicant: ${invoice.info.myName}\n'
                      'Loan ID: ${invoice.info.number}\n'
                      'Loan Amount: ${invoice.info.loanAmount}\n'
                      'Payment Period: ${invoice.info.paymentPeriod}\n'
                      'Loan Installments: ${invoice.info.loanInstallments}\n'
                      'Loan Date: ${invoice.info.date}',
                ),
              ),
              SizedBox(height: 0.1 * PdfPageFormat.cm),
              Text('APPROVED', style: pw.TextStyle(fontSize:6,fontWeight:pw.FontWeight.bold,color:PdfColors.greenAccent)),
              SizedBox(height: 1 * PdfPageFormat.cm),
              buildSupplierAddress(invoice.supplier),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //buildCustomerAddress(invoice.customer),
              //buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(customer.address, style: TextStyle(fontSize: 8)),
        ],
      );

  static Widget buildLoanDetails(InvoiceInfo info) {
    final titles = <String>[
      'Loan ID:',
      'Loan Amount:',
      'Loan Start Date:',
      'Payment Period:',
      'Loan Installments:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      currencyFormat.format(int.parse(info.loanAmount)),
      info.date,
      info.paymentPeriod,
      info.loanInstallments,
      info.dueDate,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 500);
      }),
    );
  }
  static Widget buildApplicantDetails(InvoiceInfo info) {
    final titles = <String>[
      'Name:',
      'Employment Number:',
      'Membership Number:',
      'ID Number:',
      'Designation:',
      'Location:',
      'Official Mpesa Number:',
      'Reason for the Loan:',
      'Loan Disbursement Method:',
    ];
    final data = <String>[
      info.myName,
      info.employmentNumber,
      info.membershipNumber,
      info.IDNumber,
      info.designation,
      info.location,
      info.phoneNumber,
      info.reasonForLoan,
      info.loanDisbursementMethod
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 500);
      }),
    );
  }
  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address, style: TextStyle(fontSize: 8),textAlign: pw.TextAlign.center),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          Text('CONFIDENTIAL',textAlign: pw.TextAlign.center,
              style: TextStyle(fontSize:8,fontWeight:FontWeight.bold,color:PdfColors.red)),
          Text('LOAN APPLICATION & AGREEMENT FORM',
              textAlign: pw.TextAlign.center,
              style: TextStyle(fontSize:10,decoration: TextDecoration.underline, fontWeight: FontWeight.bold))
        ],
      );
  static Widget buildTitlePage1(Invoice invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'SECTION A: DETAILS OF THE APPLICANT',
        style: TextStyle(decoration: TextDecoration.underline,fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
      buildApplicantDetails(invoice.info),
      SizedBox(height: 1 * PdfPageFormat.cm),
      Text(
        'SECTION B: DETAILS OF THE LOAN',
        style: TextStyle(decoration: TextDecoration.underline,fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
      buildLoanDetails(invoice.info),
      SizedBox(height: 1 * PdfPageFormat.cm),
      Text(
        'SECTION C: LOAN REPAYMENT TERMS',
        style: TextStyle(decoration: TextDecoration.underline,fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
      Text('The loan will be repaid to NIC bank account number 1003911787 or via M-pesa pay bill number 488488 to account number 1003911787. Proof of payment should reach the treasurer by latest 5th of every month.'
          ,style: TextStyle(fontSize: 10),textAlign: pw.TextAlign.left),
      SizedBox(height: 1 * PdfPageFormat.cm),
      Text(
        'SECTION D: CONSENT',
        style: TextStyle(decoration: TextDecoration.underline,fontSize: 10, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
      Text('I agree to abide by the repayment terms in section C above failure to which I consent for the payroll to proceed and deduct automatically ${invoice.info.loanAmount} from my salary in installments of ${invoice.info.loanInstallments} for ${invoice.info.paymentPeriod} commencing on ${invoice.info.date} to NIC account number 1003911787. This agreement is irrevocable till the loan is paid in full.\n\n'
          'NOTE: Any member willing to pay any extra amount to clear the loan is allowed to make payment to NIC bank account number 1003911787 or via M-pesa pay bill number 488488.\n'
          'The Welfare will not cater for the transaction charges'
          ,style: TextStyle(fontSize: 10),textAlign: pw.TextAlign.left)
    ],
  );
  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          Text(
            'SECTION E: GUARANTORS',
            style: TextStyle(decoration: TextDecoration.underline,fontSize: 10, fontWeight: FontWeight.bold),
          ):SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          SizedBox(height: 0.5 * PdfPageFormat.cm): SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          Text(invoice.info.description,
              style: TextStyle(fontSize: 10)):SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          SizedBox(height: 0.5 * PdfPageFormat.cm):SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          buildGuarantorTable(invoice):SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          Divider():SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          buildTotal(invoice):SizedBox(),
          int.parse(invoice.info.loanAmount) > int.parse(invoice.info.mySavings)?
          SizedBox(height: 2 * PdfPageFormat.cm):SizedBox(),
          Text('SECTION F: DECLARATION',textAlign: pw.TextAlign.center,
              style: TextStyle(fontSize:10,decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          Text('I ${invoice.info.myName} hereby declare that the foregoing particulars are true to the best of my knowledge and belief and agree to the terms of the loan and undertake to repay the loan approved. This agreement is irrevocable till the loan is fully recovered.',
              style:TextStyle(fontSize: 10)),
          SizedBox(height: 2 * PdfPageFormat.cm),
          Text('SECTION G: For Official use only',textAlign: pw.TextAlign.center,
          style: TextStyle(fontSize:10,decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          Text('Financial Summary of the Client', style:TextStyle(fontSize: 10)),
          buildFinancialSummaryTable(invoice),
          SizedBox(height: 1.5 * PdfPageFormat.cm),
        ],
      );

  static Widget buildGuarantorTable(Invoice invoice) {
    final headers = [
      'Name',
      'Guarantor Amount',
      'Guarantor Request Status',
      'Date',
    ];
    final data = invoice.items.map((item) {

      return [
        item.name,
        item.guarantorAmount,
        item.guarantorRequestStatus,
        item.date
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      cellStyle: pw.TextStyle(fontSize:8),
      oddRowDecoration: pw.BoxDecoration(color:PdfColors.blueGrey100),
      headerStyle: TextStyle(fontSize:8,fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 15,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerLeft,
        3: Alignment.centerLeft,
      },
    );
  }
  static Widget buildFinancialSummaryTable(Invoice invoice) {
    final headers = [
      'Item',
      'Value',
    ];
    final data = invoice.loanDetails.map((item) {

      return [
        item.applicantDetails,
        item.date,
      ];
    }).toList();

    return Table.fromTextArray(
      data: data,
      headers: headers,
      border: null,
      cellStyle: pw.TextStyle(fontSize:8),
      //oddCellStyle: pw.TextStyle(color:PdfColors.grey300) ,
      oddRowDecoration: pw.BoxDecoration(color:PdfColors.blueGrey100),
      headerStyle: TextStyle(fontSize:8,fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 15,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 5),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                buildText(
                  title: 'Total Guarantor Amount',
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  value: invoice.info.totalGuarantorAmount,
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          Text('bboxx.co.ke', style: TextStyle(fontSize:8)),
          SizedBox(height: 1 * PdfPageFormat.cm),
        ],
      );

  static buildSimpleText({
     String title,
     String value,
  }) {
    final style = TextStyle(fontSize:10,fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value, style: TextStyle(fontSize:8)),
      ],
    );
  }

  static buildText({
     String title,
     String value,
    double width = double.infinity,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontSize:10,fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: TextStyle(fontSize:8)),
        ],
      ),
    );
  }
}
