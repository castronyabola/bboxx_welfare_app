import 'dart:async';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

import '../models/navigation.dart';

class TransactionHistory extends StatefulWidget {

  TransactionHistory({Key key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();

}

class _TransactionHistoryState extends State<TransactionHistory> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  final controller = TextEditingController();
  List<dynamic> logs = [];
  List<dynamic> sortedData = [];

  bool searchChecker = false;
  bool dataLoaded = false;

  DateTime startDateTime;
  DateTime endDateTime;

  String phoneNumber;

  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd/MMMM/yyyy hh:mm a');

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    fetchData('transaction_history');
    // Initialize with the current date and time
    startDateTime = DateTime(2023, 10, 01, 0, 0);
    endDateTime = DateTime.now(); // End of the day
    _initPackageInfo();
    sendLog('logs', 'Transaction History Screen Launched');
  }

  // Future createExcelFile() async {
  //   final excel = Excel.createExcel();
  //   final sheet = excel['Sheet1'];
  //
  //   // Add data to the Excel sheet
  //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'User';
  //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'TimeStamp';
  //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'IP Address';
  //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'User Action';
  //
  //   int rowCount = 1;
  //   sortedData.forEach((element) {
  //     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowCount)).value = element[3];
  //     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowCount)).value = element[0];
  //     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowCount)).value = element[1];
  //     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowCount)).value = element[2];
  //     rowCount++;
  //   });
  //
  //   // Save the Excel file
  //   final excelFile = await excel.encode();
  //
  //   return excelFile;
  //
  // }
  // Future<void> downloadExcelFile(Uint8List excelFile, String fileName) async {
  //   final blob = html.Blob([excelFile]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   final anchor = html.AnchorElement(href: url)
  //     ..target = 'blob'
  //     ..download = fileName;
  //
  //   // Programmatically click the anchor element to trigger the download.
  //   anchor.click();
  //
  //   // Clean up resources.
  //   html.Url.revokeObjectUrl(url);
  // }
  void sortData() {
    setState(() {
      // Sort the data by the timestamp (date and time)
      logs.sort((a, b) {
        DateTime timestampA = DateTime.parse(a[2]);
        DateTime timestampB = DateTime.parse(b[2]);
        return timestampB.compareTo(timestampA); // Descending order (latest first)
      });

      sortedData = List.from(logs); // Make a copy of the sorted data
    });
  }
  Future<void> fetchData(table) async {
    final encryptedEmail = encryptString(user.email, secretKey);
    final encryptedTableName = encryptString(table, secretKey);
    final encryptedAuthToken = encryptString(authToken, secretKey);

    // Define the query parameters (if any)
    final Map<String, String> queryParams = {
      'email': encryptedEmail,
      'table': encryptedTableName
    };

    // Construct the full URL with query parameters
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      // Make the HTTP GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $encryptedAuthToken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> record = data['data'];
        logs = record;
        sortData();
        dataLoaded = true;
      } else {
        // Handle errors
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
    }
  }
  encrypt.Key generateAESKey(String secretKey) {
    // Ensure the secretKey is either 128, 192, or 256 bits long.
    final validKeyLengths = [16, 24, 32]; // In bytes (128, 192, 256 bits)
    final keyBytes = utf8.encode(secretKey);
    final keyLength = keyBytes.length;

    if (!validKeyLengths.contains(keyLength)) {
      throw ArgumentError('Invalid key length. Key must be 128, 192, or 256 bits long.');
    }

    return encrypt.Key(keyBytes);
  }
  String encryptString(String input, String secKey) {
    final key = generateAESKey(secretKey);
    final iv = encrypt.IV.fromLength(16); // 16 bytes for AES encryption

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(input, iv: iv);

    return encrypted.base64;
  }
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  Future<void> sendLog(table, action) async {
    //get IP address
    final result = await http.get(Uri.parse('https://api.ipify.org?format=json'));

    if (result.statusCode == 200) {
      final data = await json.decode(result.body);
      setState(() {
        //print('IP Data: $data');
        ipAddress = data['ip'];
      });
    } else {
      setState(() {
        ipAddress = 'Error';
      });
    }

    // Get the current date and time
    DateTime now = DateTime.now();
    String createdTime = now.toString();

    final encryptedEmail = encryptString(user.email, secretKey);
    final encryptedTableName = encryptString(table, secretKey);
    final encryptedAction = encryptString(action + ' mav: ${_packageInfo.version}', secretKey);
    final encryptedTimeCreated = encryptString(createdTime, secretKey);
    final encryptedIPAddress = encryptString(ipAddress, secretKey);
    final encryptedAuthToken = encryptString(authToken, secretKey);

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $encryptedAuthToken'
    };
    var request = http.Request('POST', Uri.parse('$baseUrl'));
    request.body = json.encode({
      "headers": headers,
      "body": "{\"table\": \"$encryptedTableName\", \"email\": \"$encryptedEmail\", \"ipaddress\": \"$encryptedIPAddress\", \"action\": \"$encryptedAction\", \"created_at\": \"$encryptedTimeCreated\"}"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Log recorded');
    }
    else {
      print(response.reasonPhrase);
    }

  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: () async {
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigation())
      );
      },
      child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            iconTheme: IconThemeData(color: Colors.lightBlue),
            backgroundColor: Theme.of(context).cardColor,
            toolbarHeight: size.height * 0.08,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: ()
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => navigation())
                );
                // Navigator.of(context).pop();
              },
            ),
            title:  Center(
                child: Text('Transaction History',style: TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16))),
            elevation: 3,
          ),
          body: Container(
            //color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: size.height * 0.05,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: size.width * 0.05),
                          Container(
                              width:size.width * 0.25,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.normal,
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                               child: Center(child: Text('Date Completed', style: TextStyle(fontWeight:FontWeight.bold,fontSize:12))),
                          )),
                          SizedBox(width: size.width * 0.13),
                          Container(
                              width:size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.normal,
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                               child: Center(child: Text('Transaction Details', style: TextStyle(fontWeight:FontWeight.bold,fontSize:12))),
                          )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  sortedData.isNotEmpty && dataLoaded?
                  Container(
                    height: size.height * 0.7,
                    width: size.width,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: sortedData.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              hoverColor: Colors.lightBlue.shade50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              tileColor: Theme
                                .of(context)
                                .cardColor,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: 0,
                              dense:true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: Theme
                                            .of(context)
                                            .cardColor,
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            blurStyle: BlurStyle.normal,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text('${sortedData[index][2]}',
                                            textAlign: TextAlign.center,style: TextStyle(fontSize: 10)),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.06),
                                    Container(
                                        width: size.width * 0.5,
                                        decoration: BoxDecoration(
                                          color: Theme
                                              .of(context)
                                              .cardColor,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              blurStyle: BlurStyle.normal,
                                              offset: Offset(5, 5),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Type: '
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
                                                  Text('${sortedData[index][3]}'
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontSize: 10)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Status: '
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
                                                  Text('${sortedData[index][4]}'
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontSize: 10)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Amount: '
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
                                                  Text('${currencyFormat.format(double.parse(sortedData[index][6]))}'
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontSize: 10)),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Guarantors: '
                                                      ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
                                                  Flexible(
                                                    child: Text('${sortedData[index][5]}'
                                                        ,textAlign: TextAlign.center,style: TextStyle(fontSize: 10)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              //subtitle:Text('${sortedData[index]['membershipNumber']}'),
                              onTap:  () {
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ):
                  sortedData.isEmpty && dataLoaded?
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.13),
                    child: Container(
                      //width:size.width * 0.1,
                      //height: size.height * 0.1,
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 10,
                            blurStyle: BlurStyle.normal,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('No Transaction History Found'
                                ,textAlign: TextAlign.center,
                                style: TextStyle(fontWeight:FontWeight.w800,fontSize: 12)),
                          ),
                      ),
                    ),
                  ):
                  Container(
                    height: size.height * 0.7,
                    width: size.width,
                    child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                          strokeWidth: 2,)
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