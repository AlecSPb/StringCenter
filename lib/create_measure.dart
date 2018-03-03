import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';

import 'tab.dart';
import 'home.dart';

class CreateMeasure extends StatefulWidget {
  String _title;
  String _info;
  String _tuning;

  CreateMeasure(String title, String info, String tuning) {
    _title = title;
    _info = info;
    _tuning = tuning;
  }

  _CreateMeasureState createState() =>
      new _CreateMeasureState(_title, _info, _tuning);
}

class _CreateMeasureState extends State<CreateMeasure> {
  Tabb _t;
  Measure _m;
  int _noteCount;
  TextEditingController _noteController = new TextEditingController();
  TextEditingController _symbolController = new TextEditingController();
  FocusNode _noteFocus = new FocusNode();
  FocusNode _symbolFocus = new FocusNode();


  _CreateMeasureState(String title, String info, String tuning) {
    _t = new Tabb(title, info, tuning);
    _m = new Measure('stuff', _t.tuning.length, 0, _t.tuning);
    _noteCount = 0;
  }

  void _newMeasure() {
    setState(() {
        _noteCount = int.parse(_noteController.text);
        _m = new Measure(_t.info, _t.tuning.length, _noteCount, _t.tuning);

    });
  }


  void _changeNote(int i, int j) {
    if (!(_symbolFocus.hasFocus) && !(_noteFocus.hasFocus)) {
      setState(() {
        if (j != null && i != null) {
          _m.strings[(1 + _t.tuning.length) - j].notes[i] =
              _symbolController.text;
        }
      });
  }
  }

  void _nextMeasure() {
    setState(() {
      _t.addMeasure(_m);
      _m = new Measure(_t.info, _t.tuning.length, _noteCount, _t.tuning);
    });
  }

  _pushTab() async {
    var url ="http://proj-309-ss-5.cs.iastate.edu:3000/api/tab/createTab";
    var httpClient = new HttpClient();
    String result;
    var json = JSON.encode(_t);
    print (json);
    try {
      var request = await httpClient.postUrl(Uri.parse(url));
      print(Uri.parse(url));
      request.headers.contentType = new ContentType("application", "json");
      request.write(json);
      var response = await request.close();
      var responseBody = await response.transform(UTF8.decoder).join();
      print('BODY: $responseBody');
      Map b = new Map();
      b = JSON.decode(responseBody);
      Tabb t = new Tabb.fromJson(b);
      print(t); // fields are the same, just no quotes
      //TODO (if success result = success)
      result = 'success';
      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(
          builder: (BuildContext context) => new Home()),
              (Route<dynamic> route) => false
      );
    } catch (exception) {
      result = 'fail';
      print(exception);
    }
  }

  //returns a list of widgets that is used as children in this screen's
  List<Widget> generateWidgets() {
    List<Widget> wlist = [];

    //adds text field for entering the desired number of notes in the measure
    wlist.add(
      new TextField(
        controller: _noteController,
        focusNode: _noteFocus,
        maxLength: 2,
        maxLengthEnforced: true,
        onChanged: (_) {
          _newMeasure();
        },
        decoration: new InputDecoration(
          hintText: '# of notes',
        ),
      ),
    );

    //adds tuning labels on the left hand side
    wlist.add(new Text(''));
    for (int i = _t.tuning.length - 1; i >= 0; i--) {
      wlist.add(
        new Text(
          _t.tuning[i],
          textAlign: TextAlign.center,
        ),
      );
    }
    //blank space to skip the top row in column 2
    wlist.add(new Text(''));
    for (int i = 0; i < _noteCount; i++) {
      for (int j = 0; j < _t.tuning.length + 2; j++) {
        if (i == 1 && j == 0) {
          wlist.add(
            new TextField(
              controller: _symbolController,
              focusNode: _symbolFocus,
              maxLength: 2,
              maxLengthEnforced: true,
              onChanged: (_) {},
              decoration: new InputDecoration(
                hintText: 'symbol',
              ),
            ),
          );
          //skips top row
        } else if (j == 0 && i != 0) {
          wlist.add(new Text(''));
          //adds column labels
        } else if (j == 1) {
          wlist.add(new Text(
            i.toString(),
            textAlign: TextAlign.center,
          ));
          //adds note buttons
        } else if(!(i == 0 && j == 0)){
          wlist.add(new MaterialButton(
              child: new Text(
                _m.strings[(1+_t.tuning.length)-j].notes[i],
              ),
              onPressed: () {
                _changeNote(i, j);
              }));
        }
      }
    }
    return wlist;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Create Measure',
          textAlign: TextAlign.center,
        ),
        actions: [
          new IconButton(icon: new Icon(Icons.add), onPressed: _nextMeasure),
          new IconButton(icon: new Icon(Icons.file_upload), onPressed: _pushTab),
        ],
      ),
      body: new Container(
          alignment: Alignment.center,
          child: new GridView.count(
            primary: false,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20.0),
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 1.0,
            crossAxisCount: 2 + _t.tuning.length,
            children: generateWidgets(),
          )),
    );
  }
}
