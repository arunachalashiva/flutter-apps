import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const S2TApp());
}

class S2TApp extends StatelessWidget {
  const S2TApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech2Text',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const S2THomePage(title: 'S2T'),
    );
  }
}

class S2THomePage extends StatefulWidget {
  const S2THomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<S2THomePage> createState() => _S2THomePageState();
}

class _S2THomePageState extends State<S2THomePage> {
  String _s2t = "Press mic to speek";
  bool _speaking = false;
  bool _inited = false;
  double _currentFont = 26.0;
  SpeechToText _speech = SpeechToText();
  List<LocaleName> _localNames = [];
  String _currentLocaleId = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _inited = await _speech.initialize(onStatus: statusListener, onError: errorListener);
    _localNames = await _speech.locales();
    for (var localName in _localNames) {
      print("${localName.name}");
    }
    setState(() {
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _s2t = result.recognizedWords;
    });
  }

  void statusListener(String status) {
    setState(() {
      //_s2t = "Listening";
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      _s2t = "Error in listener. Try Again.";
    });
  }

  void startListening() async {
    await _speech.listen(onResult: resultListener, localeId: _currentLocaleId);
    setState(() {});
  }

  void stopListening() async {
    await _speech.stop();
    setState(() {});
  }

  void onLocaleSet(BuildContext context, LocaleName localeName) {
    setState(() {
          _currentLocaleId = localeName.localeId;
     });
     Navigator.pop(context);
  }

  List<Widget> getLocaleList(BuildContext context) {
    List<ListTile> children = [];
    for (var localeName in _localNames) {
      children.add(ListTile(
        title: Text(localeName.name),
        onTap: () => onLocaleSet(context, localeName),
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title + " - [" + _currentLocaleId + "]" ),
      ),
      drawer: Drawer(
        child: ListView.builder(
              itemCount: _localNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_localNames[index].name),
                  onTap: () => onLocaleSet(context, _localNames[index]),
                );
              },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _currentFont = _currentFont * details.scale;
                    _currentFont = _currentFont < 26.0 ? 26.0 : (_currentFont > 44.0 ? 44.0 : _currentFont);
                  });
                },
                child: Text(
                  _s2t,
                  style: TextStyle(
                    fontSize: _currentFont,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speech.isNotListening ? startListening : stopListening,
        tooltip: 'Listen',
        child: Icon(_speech.isNotListening ? Icons.mic_off : Icons.mic),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
