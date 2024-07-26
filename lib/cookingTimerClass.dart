import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CookingTimerClass extends StatefulWidget {
  const CookingTimerClass({Key? key}) : super(key: key);

  @override
  State<CookingTimerClass> createState() => _CookingTimerClassState();
}

class _CookingTimerClassState extends State<CookingTimerClass> with SingleTickerProviderStateMixin {

  final AudioPlayer audioPlayer = AudioPlayer();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int sec = 0;
  int min = 0;
  int hour = 0;
  late String displaySec;
  late String displayMin;
  late String displayHour;
  bool isRunning = false;
  bool isAlarmPlaying = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _updateDisplayStrings();
    _loadAudio();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _shakeController.forward();
      }
    });
  }

  void _playAlarm() async {
    if (!isAlarmPlaying) {
      isAlarmPlaying = true;
      await audioPlayer.resume();

      bool hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
      }

      _shakeController.forward(); // 알람이 울릴 때 애니메이션 시작
    }
  }

  void _stopAlarm() {
    if (isAlarmPlaying) {
      audioPlayer.pause();
      Vibration.cancel();
      isAlarmPlaying = false;
      _shakeController.stop(); // 알람이 멈출 때 애니메이션 정지
    }
  }
  Future<void> _loadAudio() async {
    await audioPlayer.setSource(AssetSource('alarm.mp3'));
    await audioPlayer.setReleaseMode(ReleaseMode.loop); // 루프 모드 설정
  }


  void _updateDisplayStrings() {
    displaySec = sec.toString().padLeft(2, '0');
    displayMin = min.toString().padLeft(2, '0');
    displayHour = hour.toString().padLeft(2, '0');
  }

  void _startTimer() {
    if (!isRunning) {
      isRunning = true;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (sec > 0) {
            sec--;
          } else if (min > 0) {
            min--;
            sec = 59;
          } else if (hour > 0) {
            hour--;
            min = 59;
            sec = 59;
          } else {
            timer.cancel();
            isRunning = false;
            _playAlarm();
          }
          _updateDisplayStrings();
        });
      });
    }
  }

  void _stopTimer() {
    if (isRunning) {
      timer.cancel();
      isRunning = false;
    }
    _stopAlarm(); // 타이머 중지 시 알람도 중지
  }

  void _countSecUp() {
    setState(() {
      sec++;
      if (sec >= 60) {
        sec = 0;
      }
      _updateDisplayStrings();
    });
  }

  void _countMinUp() {
    setState(() {
      min++;
      if (min >= 60) {
        min = 0;
      }
      _updateDisplayStrings();
    });
  }

  void _countHourUp() {
    setState(() {
      hour++;
      if (hour >= 60) {
        hour = 0;
      }
      _updateDisplayStrings();
    });
  }

  void _countSecDown() {
    setState(() {
      if (sec == 0) {
        sec = 60;
      } else {
        sec--;
      }
      _updateDisplayStrings();
    });
  }

  void _countMinDown() {
    setState(() {
      if (min == 0) {
        min = 60;
      } else {
        min--;
      }
      _updateDisplayStrings();
    });
  }

  void _countHourDown() {
    setState(() {
      if (hour == 0) {
        hour = 60;
      } else {
        hour--;
      }
      _updateDisplayStrings();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    audioPlayer.dispose();
    if (isRunning) {
      timer.cancel();
    }
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        const SizedBox(
          height: 25,
        ),
        Container(
          width: width,
          height: 52,
          child: Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    _countHourUp();
                  },
                  child: const Icon(Icons.arrow_drop_up,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    _countMinUp();
                  },
                  child: const Icon(Icons.arrow_drop_up,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    _countSecUp();
                  },
                  child: const Icon(Icons.arrow_drop_up,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Container(
          width: width,
          height: 75,
          child: Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(displayHour,
                  style: const TextStyle(
                      fontFamily: 'AppleSDGothicNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.grey
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.1,
                child: const Text(':',
                  style: TextStyle(
                      fontFamily: 'AppleSDGothicNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.grey
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(displayMin,
                  style: const TextStyle(
                      fontFamily: 'AppleSDGothicNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.grey
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.1,
                child: const Text(':',
                  style: TextStyle(
                      fontFamily: 'AppleSDGothicNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.grey
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(displaySec,
                  style: const TextStyle(
                      fontFamily: 'AppleSDGothicNeo',
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.grey
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Container(
          width: width,
          height: 52,
          child: Row(
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _countHourDown();
                    });
                  },
                  child: const Icon(Icons.arrow_drop_down,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _countMinDown();
                    });
                  },
                  child: const Icon(Icons.arrow_drop_down,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _countSecDown();
                    });
                  },
                  child: const Icon(Icons.arrow_drop_down,
                    size: 52,
                    color: Colors.amber,),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          width: width,
          height: 35,
          child: Row(
            children: [
              GestureDetector(
                onTap: (){
                  _startTimer();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: width * 0.5,
                  color: Colors.green,
                  child: const Text('시작',
                    style: TextStyle(
                        fontFamily: 'AppleSDGothicNeo',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.7,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  _stopTimer();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: width * 0.5,
                  color: Colors.deepOrange,
                  child: const Text('중지',
                    style: TextStyle(
                        fontFamily: 'AppleSDGothicNeo',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.7,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
            alignment: Alignment.center,
            width: width,
            height: 55,
            child:
            Row(
              children: [
                Container(
                  width: width * 0.4,
                  padding: EdgeInsets.only(right: 0),
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _shakeAnimation.value,
                        child: child,
                      );
                    },
                    child: Image.asset('assets/CookingAlarm.png', fit: BoxFit.contain),
                  ),
                ),
                Container(
                  width: width * 0.6,
                  padding: EdgeInsets.only(left: 5),
                  child: const Text('알람이 울리면 중지버튼을 클릭해 주세요.',
                    style: TextStyle(
                        fontFamily: 'AppleSDGothicNeo',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey
                    ),
                  ),
                )
              ],
            )
        ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}
