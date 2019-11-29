import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_companion_app/data/db.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {

  var lastamount;
     getlast() async{
     lastamount = await getLastAmount();
     if(lastamount == null)lastamount=0;
   }
  var selectedPageIndex = 0;
  var amount = 0;
  var name = "No Data";
  final FocusNode _nameFocusNode = new FocusNode();
  final FocusNode _amountFocusNode = new FocusNode();
  @override
  void initState() {
    getlast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              title: Text("Add"),
              icon: Icon(
                FontAwesomeIcons.wallet,
                color: selectedPageIndex == 0 ? Colors.blue : Colors.grey,
              )),
          BottomNavigationBarItem(
            title: Text("Used"),
            icon: Icon(FontAwesomeIcons.handHoldingUsd,
                color: selectedPageIndex == 1 ? Colors.blue : Colors.grey),
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedPageIndex = index;
            if (selectedPageIndex == 0) {
              _settingBottomSheet(context);
            } else if (selectedPageIndex == 1) {
              readAll();
            }
          });
        },
        currentIndex: selectedPageIndex,
      ),
      body: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: 150.0,
              decoration: BoxDecoration(color: Colors.blueGrey),
              alignment: Alignment(0.0, 0.0),
              child: Text(
                "$lastamount MMK",
                style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  void _settingBottomSheet(context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                child: Wrap(
              children: <Widget>[
                new TextField(
                  decoration:
                      new InputDecoration(labelText: "Enter your Income Path"),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(30),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                  ],
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  focusNode: _nameFocusNode,
                  onChanged: (text) {
                    name = text;
                    print(name);
                  },
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_amountFocusNode),
                ),
                new TextField(
                    decoration:
                        new InputDecoration(labelText: "Enter your amount"),
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(12),
                      WhitelistingTextInputFormatter.digitsOnly,
                      BlacklistingTextInputFormatter.singleLineFormatter,
                    ],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    focusNode: _amountFocusNode,
                    onSubmitted: (value) {
                      amount = int.parse(value);
                      print(amount);
                      if (name != "No Data" && amount != 0) {
                        save(name, amount);
                        Navigator.pop(context);
                      } else if (name == "No Data") {
                        FocusScope.of(context).requestFocus(_nameFocusNode);
                      } else if (amount == 0) {
                        FocusScope.of(context).requestFocus(_amountFocusNode);
                      }
                    }),
              ],
            )));
      },
    );
  }
}
