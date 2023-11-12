import 'package:bboxx_welfare_app/screens/home.dart';
import 'package:bboxx_welfare_app/screens/info.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/screens/settings_page.dart';
import 'package:bboxx_welfare_app/utils/user_simple_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:bboxx_welfare_app/utils.dart';
import 'package:bboxx_welfare_app/icon_widget.dart';
import 'package:smart_select/smart_select.dart';

class AccountPage extends StatefulWidget {
  final String idUser;

  const AccountPage({
    Key key,
    this.idUser,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String shop = "Bboxx";
  String language = "English";

  @override
  void initState() {
    super.initState();
    shop = UserSimplePreferences.getShop() ?? '';
    language = UserSimplePreferences.getLanguage() ?? '';
  }

  final user = FirebaseAuth.instance.currentUser;

  // getData()  async {
  //    await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(myName)
  //       .snapshots()
  //       .listen((value){
  //     shop = value.data()['shop'];
  //     language = value.data()['language'];
  //   });
  //  setState(() {});
  // }
  Future showMyDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return language == "English" ? AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Confirmation'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children:  <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your settings have been updated'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Ok'),
                  onPressed: () async{
                    await UserSimplePreferences.setLanguage(language);
                    await UserSimplePreferences.setShop(shop);
                    await Navigator.pop(context);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageHandler())
                    );
                  },
                ),
              ],
            ),

          ],
        )
            :AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Uthibitisho'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children:  <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Mipangilio yako imesasishwa'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Sawa'),
                  onPressed: () async{
                    await UserSimplePreferences.setLanguage(language);
                    await UserSimplePreferences.setShop(shop);
                    await Navigator.pop(context);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageHandler())
                    );
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
  Widget build(BuildContext context) {
    //getData();
    return SimpleSettingsTile(
      title: language == "English" ? 'Account Settings' : 'Mipangilio ya Akaunti',
      subtitle: language == "English" ? 'Shop, Language, Info':'Duka, Lugha, Habari' ,
      leading: IconWidget(icon: Icons.person),
      child: SettingsScreen(
        title: language == "English" ? 'Account Settings' : 'Mipangilio ya Akaunti',
        children: <Widget>[//getData(),
          SizedBox(height: 25),
          Padding(
            padding: EdgeInsets.all(15),
            child: buildLanguage(context),
          ),
          SizedBox(height: 25),
          Padding(
            padding: EdgeInsets.all(15),
            child: buildShop(context),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget buildShop(BuildContext context) {
    //String value = "";
    List<S2Choice<String>> options = [
      S2Choice<String>(value: 'Bomet', title: 'Bomet'),
      S2Choice<String>(value: 'Bondo', title: 'Bondo'),
      S2Choice<String>(value: 'Bumala', title: 'Bumala'),
      S2Choice<String>(value: 'Bungoma', title: 'Bungoma'),
      S2Choice<String>(value: 'Busia', title: 'Busia'),
      S2Choice<String>(value: 'Butere', title: 'Butere'),
      S2Choice<String>(value: 'Chepseon', title: 'Chepseon'),
      S2Choice<String>(value: 'Homabay', title: 'Homabay'),
      S2Choice<String>(value: 'Hola', title: 'Hola'),
      S2Choice<String>(value: 'Kabarnet', title: 'Kabarnet'),
      S2Choice<String>(value: 'Kajiado', title: 'Kajiado'),
      S2Choice<String>(value: 'Kakamega', title: 'Kakamega'),
      S2Choice<String>(value: 'Kakuma', title: 'Kakuma'),
      S2Choice<String>(value: 'Kapenguria', title: 'Kapenguria'),
      S2Choice<String>(value: 'Kapsabet', title: 'Kapsabet'),
      S2Choice<String>(value: 'Katito', title: 'Katito'),
      S2Choice<String>(value: 'Kapsowar', title: 'Kapsowar'),
      S2Choice<String>(value: 'Kendu Bay', title: 'Kendu Bay'),
      S2Choice<String>(value: 'Kibwezi', title: 'Kibwezi'),
      S2Choice<String>(value: 'Kilifi', title: 'Kilifi'),
      S2Choice<String>(value: 'Kinango', title: 'Kinango'),
      S2Choice<String>(value: 'Kipkaren', title: 'Kipkaren'),
      S2Choice<String>(value: 'Kipsitet', title: 'Kipsitet'),
      S2Choice<String>(value: 'Kisumu', title: 'Kisumu'),
      S2Choice<String>(value: 'Kitale', title: 'Kitale'),
      S2Choice<String>(value: 'Kitui', title: 'Kitui'),
      S2Choice<String>(value: 'Kwale', title: 'Kwale'),
      S2Choice<String>(value: 'Litein', title: 'Litein'),
      S2Choice<String>(value: 'Lodwar', title: 'Lodwar'),
      S2Choice<String>(value: 'Luanda', title: 'Luanda'),
      S2Choice<String>(value: 'Machakos', title: 'Machakos'),
      S2Choice<String>(value: 'Magunga', title: 'Magunga'),
      S2Choice<String>(value: 'Malindi', title: 'Malindi'),
      S2Choice<String>(value: 'Maralal', title: 'Maralal'),
      S2Choice<String>(value: 'Masara', title: 'Masara'),
      S2Choice<String>(value: 'Matuu', title: 'Matuu'),
      S2Choice<String>(value: 'Mbita', title: 'Mbita'),
      S2Choice<String>(value: 'Muranga', title: 'Muranga'),
      S2Choice<String>(value: 'Nakuru', title: 'Nakuru'),
      S2Choice<String>(value: 'Narok', title: 'Narok'),
      S2Choice<String>(value: 'Ndhiwa', title: 'Ndhiwa'),
      S2Choice<String>(value: 'Nyahururu', title: 'Nyahururu'),
      S2Choice<String>(value: 'Nyamira', title: 'Nyamira'),
      S2Choice<String>(value: 'Nyangusu', title: 'Nyangusu'),
      S2Choice<String>(value: 'Oloitoktok', title: 'Oloitoktok'),
      S2Choice<String>(value: 'Oyugis', title: 'Oyugis'),
      S2Choice<String>(value: 'Rongo', title: 'Rongo'),
      S2Choice<String>(value: 'Serem', title: 'Serem'),
      S2Choice<String>(value: 'Siaya', title: 'Siaya'),
      S2Choice<String>(value: 'Taveta', title: 'Taveta'),
      S2Choice<String>(value: 'Tharaka Nithi', title: 'Tharaka Nithi'),
      S2Choice<String>(value: 'Voi', title: 'Voi'),
      S2Choice<String>(value: 'Wote', title: 'Wote'),
      S2Choice<String>(value: 'Bboxx', title: 'Bboxx'),
      S2Choice<String>(value: 'Other', title: 'Other'),

    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor,
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
      child: SmartSelect<String>.single(
          tileBuilder: (context, state) {
            return S2Tile(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: state.titleWidget,
              value: state.valueDisplay,
              onTap: state.showModal,
              leading: Icon(Icons.location_city, color: Colors.lightBlue),
              isTwoLine: true,
            );
          },
          choiceStyle: S2ChoiceStyle(
            activeColor: Colors.lightBlue,
            color: Colors.black,
            runSpacing: 4,
            spacing: 12,
            showCheckmark: true,
          ),
          choiceType: S2ChoiceType.switches,
          modalHeaderStyle: S2ModalHeaderStyle(
            backgroundColor: Theme
                .of(context)
                .backgroundColor,
            textStyle: TextStyle(fontSize: 18, color: Colors.lightBlue),
          ),
          modalConfig: S2ModalConfig(
              filterAuto: true,
              barrierDismissible: false,
              useConfirm: true,
              useFilter: true,
              useHeader: true,
              confirmIcon: Icon(
                  Icons.check_circle_outline),
              confirmColor: Colors.lightBlue
          ),
          modalStyle: S2ModalStyle(
            elevation: 20,
            backgroundColor: Colors.white12.withOpacity(0.8),
          ),
          modalType: S2ModalType.popupDialog,
          choiceDirection: Axis.vertical,
          placeholder: language == "English" ? "Please Select your shop" : "Tafadhali Chagua duka lako",
          title: language == "English" ? "My Shop" : "Duka Langu",
          value: shop,
          choiceItems: options,
          onChange: (state) {
            setState(() {
              return this.shop = state.value;
            });
               // FirebaseFirestore.instance.collection("users").doc(
               //    myName).update(
               //    {
               //      'shop': state.value
               //    }
               // );
               showMyDialog();
               // Navigator.push(
               //     context,
               //     MaterialPageRoute(builder: (context) => SettingsPage())
               // );
          }
      ),
    );
  }

  Widget buildLanguage(BuildContext context) {
    //String language = "mm";
    List<S2Choice<String>> options = [
      S2Choice<String>(value: 'English', title: 'English'),
      S2Choice<String>(value: 'Swahili', title: 'Swahili'),

    ];

    List<S2Choice<String>> chaguo = [
      S2Choice<String>(value: 'English', title: 'kiingereza'),
      S2Choice<String>(value: 'Swahili', title: 'kiswahili'),

    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor,
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
      child: SmartSelect<String>.single(
          tileBuilder: (context, state) {
            return S2Tile(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: state.titleWidget,
              value: state.valueDisplay,
              onTap: state.showModal,
              leading: Icon(Icons.language, color: Colors.lightBlue),
              isTwoLine: true,
            );
          },
          choiceStyle: S2ChoiceStyle(
            activeColor: Colors.lightBlue,
            color: Colors.black,
            runSpacing: 4,
            spacing: 12,
            showCheckmark: true,
          ),
          choiceType: S2ChoiceType.switches,
          modalHeaderStyle: S2ModalHeaderStyle(
            backgroundColor: Theme
                .of(context)
                .backgroundColor,
            textStyle: TextStyle(fontSize: 18, color: Colors.lightBlue),
          ),
          modalConfig: S2ModalConfig(
              filterAuto: true,
              barrierDismissible: false,
              useConfirm: true,
              useFilter: true,
              useHeader: true,
              confirmIcon: Icon(
                  Icons.check_circle_outline),
              confirmColor: Colors.lightBlue
          ),
          modalStyle: S2ModalStyle(
            elevation: 20,
            backgroundColor: Colors.white12.withOpacity(0.8),
          ),
          modalType: S2ModalType.popupDialog,
          choiceDirection: Axis.vertical,
          placeholder: language == "English" ? "Please Select your preferred language" : "Tafadhali chagua lugha unayopendelea",
          title: language == "English" ? "Language" : "Lugha",
          value: language,
          choiceItems: language == "English" ? options: chaguo,
          onChange: (state) {
            setState(() => this.language = state.value);
              //  FirebaseFirestore.instance.collection("users")
              //     .doc(myName)
              //     .update(
              //     {
              //       'language': state.value
              //     }
              // );
             showMyDialog();
          }
      ),
    );
  }
}

