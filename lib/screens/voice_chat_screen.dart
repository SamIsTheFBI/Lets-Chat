import 'package:flutter/material.dart';
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  bool isVoiceChatActive = false; // Tracks whether the voice chat screen is active
  bool isMuted = false;
  final _textController = TextEditingController();
  bool _showEmoji =false;// Tracks whether the mic is muted
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap:() =>FocusScope.of(context).unfocus(),
    child: WillPopScope(
    //If emojis are shown & back button is pressed then hide emoji
    //or else simply close current screen on back button click
    onWillPop: (){
    if(_showEmoji)
    {
    setState(() {
    _showEmoji=!_showEmoji;

    });
    return Future.value(false); //The current screen is not removed
    }
    else
    {
    return Future.value(true); //Current screen is removed
    }

    },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Voice Chat',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          body:voiceChatScreen(),

        ),
      ),
    ));
  }

  // Voice Chat Screen widget
  Widget voiceChatScreen() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isMuted ? Icons.mic_off : Icons.mic,
                size: 100,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              Text(
                isMuted ? 'You are muted. Nobody can hear you.' : "You are in a voice chat. The Spotlight is yours.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Mute/Unmute button
                IconButton(
                  icon: Icon(
                    isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? Colors.redAccent : Colors.green,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      isMuted = !isMuted; // Toggle mute/unmute
                    });
                  },
                ),
                // Server Chat screen button (pop once)
                IconButton(
                  icon: Icon(Icons.chat, color: Colors.blueAccent, size: 30),
                  onPressed: () {
                    // Pop the screen once, if applicable (in real app)
                    Navigator.pop(context);
                  },
                ),
                // Emoji Reaction button
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: Colors.amber, size: 30),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: (BuildContext context){
                      return SizedBox(
                        height: 100,
                          width: 400,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(onPressed: (){}, child: Text("😀")),
                                ElevatedButton(onPressed: (){}, child: Text("😂")),
                                ElevatedButton(onPressed: (){}, child: Text("😎")),
                                ElevatedButton(onPressed: (){}, child: Text("😥")),
                              ],
                            )
                          ),
                      );

                    },
                    );
                  }
                ),

                // Disconnect button (pop twice)
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red, size: 30),
                  onPressed: () {
                    // Pop the screen twice (go back two screens, if applicable)
                    Navigator.pop(context); // First pop
                    Navigator.pop(context); // Second pop
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}