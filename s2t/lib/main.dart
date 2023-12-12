import 'package:adaptive_theme/adaptive_theme.dart';
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
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.dark,
      debugShowFloatingThemeButton: true,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Speech2Text',
        theme: theme,
        darkTheme: darkTheme,
        home: const S2THomePage(title: 'S2T'),
      ),
    );
  }
}

class S2THomePage extends StatefulWidget {
  const S2THomePage({super.key, required this.title});

  final String title;

  @override
  State<S2THomePage> createState() => _S2THomePageState();
}

class _S2THomePageState extends State<S2THomePage> {
  String _s2t = "Press mic to speak";
  double _currentFont = 26.0;
  final SpeechToText _speech = SpeechToText();
  List<LocaleName> _localNames = [];
  String _currentLocaleId = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await _speech.initialize(onStatus: statusListener, onError: errorListener);
    _localNames = await _speech.locales();
    var systemLocale = await _speech.systemLocale();
    _currentLocaleId = systemLocale?.localeId ?? '';
    setState(() {
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _s2t = result.recognizedWords;
    });
  }

  void statusListener(String status) {
    setState(() {});
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
        title: Text("${widget.title} - [$_currentLocaleId]" ),
        actions: [
          IconButton(onPressed: () => AdaptiveTheme.of(context).toggleThemeMode(), icon: const Icon(Icons.lightbulb)),
        ],
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
