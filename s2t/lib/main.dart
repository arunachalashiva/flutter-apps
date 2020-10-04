import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(S2TApp());
}

class S2TApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech2Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: S2THomePage(title: 'S2T'),
    );
  }
}

class S2THomePage extends StatefulWidget {
  S2THomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _S2TPageState createState() => _S2TPageState();
}

class _S2TPageState extends State<S2THomePage> {
  String _speech2Txt = "Press mic to speak";
  bool _speaking = false;
  bool _inited = false;
  SpeechToText _speech = null;
  List<LocaleName> _localeNames = [];
  String _currentLocaleId = "";

  @override
  void initState() {
    super.initState();
    initSpeechState().then((result) {
      setState(() {
        _speaking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      DropdownButton(
                        onChanged: (selectedVal) => switchLang(selectedVal),
                        value: _currentLocaleId,
                        items: _localeNames
                            .map(
                              (localeName) => DropdownMenuItem(
                                value: localeName.localeId,
                                child: Text(localeName.name),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ), // Row
                ],
              ),
            ), // Conainer drop down
            Container(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
              child: Text(
                '$_speech2Txt',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ), // style
              ), // child
            ), // Container text
          ],
        ),
      ), // body
      floatingActionButton: FloatingActionButton(
        onPressed: _getSpeech2Txt,
        tooltip: 'Speak',
        child: Icon(_speaking ? Icons.mic_rounded : Icons.mic_none_rounded),
      ),
    );
  }

  void _getSpeech2Txt() async {
    if (!_speaking) {
      setState(() {
        _speaking = true;
        _speech2Txt = "Listening";
      });
      _speech.listen(
        onResult: resultListener,
        localeId: _currentLocaleId,
        cancelOnError: true,
      );
    } else {
      setState(() {
        _speaking = false;
        _speech2Txt = "Press mic to speak";
      });
      _speech.stop();
    }
  }

  Future<void> initSpeechState() async {
    _speech = SpeechToText();
    bool hasSpeech = await _speech.initialize(
        onStatus: statusListener, onError: errorListener);
    if (hasSpeech) {
      _localeNames = await _speech.locales();
      var systemLocale = await _speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _speech2Txt = result.recognizedWords;
    });
  }

  void statusListener(String status) {
    setState(() {
      _speech2Txt = "Listening";
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      _speech2Txt = "Error in Listener. Try again";
    });
  }

  void switchLang(String selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
  }
}
