import 'package:cloud_firestore/cloud_firestore.dart';

class FcmServices {
  Future updateFCMData(bool isSuccess, data) async {
    try {
      DateTime now = DateTime.now();
      if (isSuccess) {
        await FirebaseFirestore.instance.collection('fcm').doc('$data').set({
          'time': '${now.year}.${now.month}.${now.day} ${now.hour}:${now.minute}',
          'isSuccess': isSuccess,
          'data': data,
        });
      } else {
        await FirebaseFirestore.instance.collection('fcm').add({
          'time': '${now.year}.${now.month}.${now.day} ${now.hour}:${now.minute}',
          'isSuccess': isSuccess,
          'data': data,
        });
      }
    } catch(e) {
      print("error updateFCMData $e");
    }
  }
}