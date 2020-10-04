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
  SpeechToText _speech = null;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
	reverse:true,
        child: Container(
	  padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
	  child: Text(
	    '$_speech2Txt',
	    style: TextStyle(
              fontSize: 28.0,
	      fontWeight: FontWeight.bold,
	      letterSpacing: 2.0,
	    ), // style
          ), // child
        ), // Container
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
      bool hasSpeech = await _speech.initialize(onStatus: statusListener, onError: errorListener);
      if (hasSpeech) {
        setState(() {
	  _speaking = true;
          _speech2Txt = "Listening";
	});
	_speech.listen(
	  onResult: resultListener,
	  cancelOnError: true,
	);
      }
    } else {
      setState(() {
        _speaking = false;
        _speech2Txt = "Press mic to speak";
      });
      _speech.stop();
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
}
