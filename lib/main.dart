import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
      theme: ThemeData(
          primaryColor: Colors.brown,
          buttonColor: Colors.brown,
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: Colors.brown)),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() {
    return _StartScreenState();
  }
}

enum Gamestate { running, paused, before, over, settings }

const millisecondsstep = 25;

class _StartScreenState extends State {
  final audioplayer = AudioPlayer();

  void playAudio() async {
    await audioplayer.setAsset('assets/bum.mp3');
    audioplayer.play();
  }

  num _timespeedup = 1;

  Duration timePlayer1; // in seconds // white
  num delayPlayer1;
  Duration timePlayer2; // in seconds // black
  num delayPlayer2;
  num playerToMove = 0; // later 1, 2

  num player1Moves = 0;
  num player2Moves = 0;

  num settingsDelay = 0; // in seconds
  Duration settingsTimeEachPlayer = Duration(minutes: 3);
  num settingsIncrement = 0;

  Timer _timer;

  Gamestate gamestate;

  bool timeIndicatorsVisible = true;
  bool moveCounterVisible = true;

  // var _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //   setState(() {
  //     print("1");
  //   });
  // });

  void initialization() {
    timePlayer1 = Duration(microseconds: settingsTimeEachPlayer.inMicroseconds);
    timePlayer2 = Duration(microseconds: settingsTimeEachPlayer.inMicroseconds);
    delayPlayer1 = delayPlayer2 = 0;
    gamestate = Gamestate.before;
    player1Moves = 0;
    player2Moves = 0;
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void restartButtonPressed(BuildContext context) {
    if (gamestate == Gamestate.paused) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("Reset Clock"),
                content:
                    Text("Are you sure you want to reset the chess clock?"),
                actions: [
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.grey,
                  ),
                  FlatButton(
                    child: Text("Reset"),
                    onPressed: () {
                      setState(() {
                        initialization();
                      });
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.red,
                  ),
                ],
              ),
          barrierDismissible: true);
    }
    // restart:
    else if (gamestate == Gamestate.over) {
      setState(() {
        initialization();
      });
    }
  }

  void enterSettings(BuildContext context) {
    Map<int, String> timesDictionary = {
      1: "1 Minute",
      2: "2 Minutes",
      3: "3 Minutes",
      5: "5 Minutes",
      10: "10 Minutes",
      30: "30 Minutes",
      60: "1 Hour",
      120: "2 Hours"
    };

    Map<int, String> incrementsDictionary = {
      0: "No Increment",
      1: "1 Second",
      2: "2 Seconds",
      3: "3 Seconds",
      5: "5 Seconds",
      10: "10 Seconds",
      15: "15 Seconds",
      30: "30 Seconds",
      60: "1 Minute"
    };

    Map<int, String> delaysDictionary = {
      0: "No Delay",
      1: "1 Second",
      2: "2 Seconds",
      3: "3 Seconds",
      5: "5 Seconds",
      10: "10 Seconds",
      15: "15 Seconds",
      30: "30 Seconds",
      60: "1 Minute"
    };

    Map<bool, String> showBarsDictionary = {
      true: "Visible",
      false: "Hidden",
    };

    Map<bool, String> showMovesDictionary = {
      true: "Visible",
      false: "Hidden",
    };

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (BuildContext c) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text("Time", style: TextStyle(fontSize: 20, color: Colors.brown)),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    "The time each player is given for the entire game. When a players time reaches zero the game is lost.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
              ),
              DropdownButtonFormField<int>(
                value: settingsTimeEachPlayer.inMinutes,
                onChanged: (int newval) {
                  print(newval);
                  setState(() {
                    settingsTimeEachPlayer = Duration(minutes: newval);
                    initialization();
                  });
                },
                items: timesDictionary.keys
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          timesDictionary[e],
                          style: TextStyle(fontSize: 20),
                        )))
                    .toList(),
                elevation: 16,
                style: TextStyle(color: Colors.brown),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                //height: 2,
                // color: Colors.brown,
              ),
              Text("Increment",
                  style: TextStyle(fontSize: 20, color: Colors.brown)),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    "The amount of time each player gets added to their clock every time they pass the move to the other player.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
              ),
              DropdownButtonFormField<int>(
                value: settingsIncrement,
                onChanged: (int newval) {
                  print(newval);
                  setState(() {
                    settingsIncrement = newval;
                  });
                },
                items: incrementsDictionary.keys
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          incrementsDictionary[e],
                          style: TextStyle(fontSize: 20),
                        )))
                    .toList(),
                elevation: 16,
                style: TextStyle(color: Colors.brown),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                //height: 2,
                // color: Colors.brown,
              ),
              Text("Delay",
                  style: TextStyle(fontSize: 20, color: Colors.brown)),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    "On every move there is a certain delay (free time) that passes before the clock starts counting down.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
              ),
              DropdownButtonFormField<int>(
                value: settingsDelay,
                onChanged: (int newval) {
                  print(newval);
                  setState(() {
                    settingsDelay = newval;
                  });
                },
                items: delaysDictionary.keys
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          delaysDictionary[e],
                          style: TextStyle(fontSize: 20),
                        )))
                    .toList(),
                elevation: 16,
                style: TextStyle(color: Colors.brown),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                //height: 2,
                // color: Colors.brown,
              ),
              Text("Time Bar",
                  style: TextStyle(fontSize: 20, color: Colors.brown)),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    "Visibility of time bar at the bottom/top of the screen. You can disable it if it annoys you.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
              ),
              DropdownButtonFormField<bool>(
                value: timeIndicatorsVisible,
                onChanged: (bool newval) {
                  print(newval);
                  setState(() {
                    timeIndicatorsVisible = newval;
                  });
                },
                items: showBarsDictionary.keys
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          showBarsDictionary[e],
                          style: TextStyle(fontSize: 20),
                        )))
                    .toList(),
                elevation: 16,
                style: TextStyle(color: Colors.brown),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                //height: 2,
                // color: Colors.brown,
              ),
              Text("Move Counter",
                  style: TextStyle(fontSize: 20, color: Colors.brown)),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    "Visibility of the move counter in the bottem left corner. You can disable it if it annoys you.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
              ),
              DropdownButtonFormField<bool>(
                value: moveCounterVisible,
                onChanged: (bool newval) {
                  print(newval);
                  setState(() {
                    moveCounterVisible = newval;
                  });
                },
                items: showMovesDictionary.keys
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          showMovesDictionary[e],
                          style: TextStyle(fontSize: 20),
                        )))
                    .toList(),
                elevation: 16,
                style: TextStyle(color: Colors.brown),
              ),
            ],
          ));
    }));
  }

  void exitSettings(BuildContext context) {}

  void settingsButtonPressed(BuildContext context) {
    print("settings");
    enterSettings(context);
  }

  void pauseButtonPressed() {
    if (gamestate == Gamestate.running) {
      // pause it:
      print("pause");
      setState(() {
        gamestate = Gamestate.paused;
        this._timer.cancel();
      });
    } else if (gamestate == Gamestate.paused) {
      // pause it:
      print("resume");
      setState(() {
        gamestate = Gamestate.running;
        // create new timer that runs:
        this._timer = Timer.periodic(
            Duration(milliseconds: millisecondsstep), timerTickHandler);
      });
    }
  }

  ////////////////////////////////////////////////////

  void timerTickHandler(Timer timer) //  is called every 50 milliseconds;
  {
    //print("tick");
    if (gamestate == Gamestate.running) {
      // decrement time of a player:

      setState(() {
        if (playerToMove == 1) {
          if (delayPlayer1 > 0) {
            delayPlayer1 -= millisecondsstep * 0.001;
          } else {
            timePlayer1 -= Duration(
                    milliseconds: (millisecondsstep - delayPlayer1).toInt()) *
                _timespeedup;

            if (timePlayer1.inMilliseconds <= 0) {
              // spieler 1 hat on time verloren:
              gamestate = Gamestate.over;
              playAudio();
            }
          }
        } else if (playerToMove == 2) {
          if (delayPlayer2 > 0) {
            delayPlayer2 -= millisecondsstep * 0.001;
          } else {
            timePlayer2 -= Duration(
                    milliseconds: (millisecondsstep - delayPlayer2).toInt()) *
                _timespeedup;
            if (timePlayer2.inMilliseconds <= 0) {
              // spieler 1 hat on time verloren:
              gamestate = Gamestate.over;
              playAudio();
            }
          }
        }
      });
    } else
      timer.cancel();
  }

  // ACTIONS:

  void whiteStartsGameWithFirstTap() {
    if (gamestate != Gamestate.before) return;
    setState(() {
      print("white taps and starts the game");
      gamestate = Gamestate.running;
      player1Moves++;
      playerToMove = 2; // black;
      delayPlayer2 = settingsDelay;
      delayPlayer1 = 0;
      this._timer = Timer.periodic(
          Duration(milliseconds: millisecondsstep), timerTickHandler);
    });
  }

  void playerTapsField(int player) {
    print("tap by $player"); // 1 = white, 2 = black

    if (this.gamestate == Gamestate.before && player == 1) {
      whiteStartsGameWithFirstTap();
    }
    if (this.gamestate == Gamestate.running) {
      // only do somethign if it is the players turn who tapped:
      if (player == playerToMove) {
        setState(() {
          if (playerToMove == 1) {
            player1Moves++;
            playerToMove = 2;
            delayPlayer2 = settingsDelay;
            delayPlayer1 = 0;
            timePlayer1 += Duration(seconds: settingsIncrement);
          } else if (playerToMove == 2) {
            player2Moves++;
            playerToMove = 1;
            delayPlayer1 = settingsDelay;
            delayPlayer2 = 0;
            timePlayer2 += Duration(seconds: settingsIncrement);
          }
        });
      }
    }
  }

  ////////////////////////////////////////////////////

  String durationToString(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    num hours = d.inHours.remainder(60);
    num minutes = d.inMinutes.remainder(60);
    num seconds = d.inSeconds.remainder(60);
    return (hours != 0
            ? hours.toString() + ":" + twoDigits(minutes)
            : "" + minutes.toString()) +
        ":" +
        twoDigits(seconds);
  }

  @override
  build(BuildContext context) {
    String displayedTimePlayer1 = durationToString(timePlayer1);
    String displayedTimePlayer2 = durationToString(timePlayer2);

    num player1Progress =
        (timePlayer1.inMilliseconds / settingsTimeEachPlayer.inMilliseconds)
            .clamp(0, 1);
    num player2Progress =
        (timePlayer2.inMilliseconds / settingsTimeEachPlayer.inMilliseconds)
            .clamp(0, 1);

    num player1DelayProgress =
        settingsDelay != 0 ? (delayPlayer1 / settingsDelay).clamp(0, 1) : 0;
    num player2DelayProgress =
        settingsDelay != 0 ? (delayPlayer2 / settingsDelay).clamp(0, 1) : 0;

    List<Widget> middleButtons = [];

    // RESTART BUTTON
    if (gamestate == Gamestate.over || gamestate == Gamestate.paused) {
      middleButtons.add(
        FloatingActionButton(
          heroTag: null,
          onPressed: () => restartButtonPressed(context),
          child: Icon(Icons.replay),
        ),
      );
    }
    // PAUSE BUTTON
    if (gamestate == Gamestate.running)
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: pauseButtonPressed,
        child: Icon(Icons.pause),
      ));
    if (gamestate == Gamestate.paused)
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: pauseButtonPressed,
        child: Icon(Icons.play_arrow),
      ));
    // SETTINGS BUTTON
    if (gamestate == Gamestate.before ||
        gamestate == Gamestate.over ||
        gamestate == Gamestate.paused) {
      middleButtons.add(FloatingActionButton(
        heroTag: null,
        onPressed: () => settingsButtonPressed(context),
        child: Icon(Icons.settings),
      ));
    }

    Color playermessagecolor = Colors.grey[400];
    List<String> playermessages = ["", ""];
    if (gamestate == Gamestate.before)
      playermessages = ["(Tap after your first move.)", ""];
    else if (gamestate == Gamestate.over) {
      playermessagecolor = Colors.red;
      if (timePlayer1.inSeconds <= 0) {
        playermessages = ["You lost on Time!", ""];
      } else if (timePlayer2.inSeconds <= 0) {
        playermessages = ["", "You lost on time!"];
      }
    } else if (gamestate == Gamestate.paused) {
      playermessages = playerToMove == 1
          ? ["(It's your move.)", ""]
          : ["", "(It's your move.)"];
    }

    return Scaffold(
        body: Container(
            margin: EdgeInsets.only(top: 24),
            child: Stack(children: [
              Column(
                children: [
                  Expanded(
                      flex: 3,
                      child: Transform.rotate(
                        angle: 3.14,
                        child: Stack(
                          children: [
                            Material(
                                color: Colors.grey[900],
                                child: InkWell(
                                    highlightColor: Colors.grey[800],
                                    splashColor: Colors.grey[800],
                                    onTap: () {
                                      playerTapsField(2);
                                    },
                                    child: Stack(children: [
                                      Center(
                                        child: Text(
                                          displayedTimePlayer2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 90,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      moveCounterVisible
                                          ? Align(
                                              alignment: Alignment(-0.8, 0.75),
                                              child: Text(
                                                  player2Moves.toString(),
                                                  style: TextStyle(
                                                      color: playermessagecolor,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                          : SizedBox.shrink(),
                                    ]))),
                            timeIndicatorsVisible
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: TimeBar(
                                      progress: player2Progress.toDouble(),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            DelayIndicator(player2DelayProgress.toDouble(), 2),
                            playermessages[1] != ""
                                ? IgnorePointer(
                                    child: Align(
                                    alignment: Alignment(0, -0.6),
                                    child: Text(
                                      playermessages[1],
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: playermessagecolor),
                                    ),
                                  ))
                                : SizedBox.shrink(),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Material(
                            color: Colors.white,
                            child: InkWell(
                                highlightColor: Colors.grey[500],
                                splashColor: Colors.grey[300],
                                onTap: () {
                                  playerTapsField(1);
                                },
                                child: Stack(children: [
                                  Center(
                                    child: Text(
                                      displayedTimePlayer1,
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontSize: 90,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  moveCounterVisible
                                      ? Align(
                                          alignment: Alignment(-0.8, 0.75),
                                          child: Text(player1Moves.toString(),
                                              style: TextStyle(
                                                  color: playermessagecolor,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold)))
                                      : SizedBox.shrink(),
                                ]))),
                        timeIndicatorsVisible
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: TimeBar(
                                  progress: player1Progress.toDouble(),
                                ),
                              )
                            : SizedBox.shrink(),
                        DelayIndicator(player1DelayProgress.toDouble(), 1),
                        playermessages[0] != ""
                            ? IgnorePointer(
                                child: Align(
                                    alignment: Alignment(0, -0.6),
                                    child: Text(
                                      playermessages[0],
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: playermessagecolor,
                                      ),
                                    )))
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: middleButtons,
                    ),
                  ),
                )
              ])
            ])));
  }
}

class DelayIndicator extends StatelessWidget {
  final double progress;
  int player;
  DelayIndicator(this.progress, this.player);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        child: Align(
            alignment: Alignment.center,
            child: Container(
              child: CircularProgressIndicator(
                value: progress == 0 ? 0 : 1 - progress,
                strokeWidth: 16,
                // backgroundColor:
                //     this.player == 2 ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                    this.player == 2 ? Colors.white10 : Colors.black12),
              ),
              height: 280,
              width: 280,
            )));
  }
}

class TimeBar extends StatelessWidget {
  final double progress;
  final Alignment alignment;

  TimeBar({this.progress = 0, this.alignment = Alignment.centerLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      height: 8,
      color: Colors.grey[309],
      child: Container(
        color: progressToColor(progress),
        height: 30,
        width: MediaQuery.of(context).size.width * progress,
      ),
    );
  }
}

Color progressToColor(double progress) {
  double clamped = progress.clamp(0, 1);

  clamped = (clamped * clamped + (clamped * 2)) / 3; // shifts a bit towards red

  return HSVColor.fromAHSV(1.0, clamped * 110, 1, 0.8).toColor();
}
