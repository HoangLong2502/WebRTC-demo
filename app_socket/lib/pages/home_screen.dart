import 'dart:convert';

import 'package:app_socket/apis/meeting_api.dart';
import 'package:app_socket/models/meeting_detail.dart';
import 'package:app_socket/pages/join_screen.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final globalKey = GlobalKey<FormState>();
  String meetingId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting App', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: globalKey,
        child: formUI(),
      ),
    );
  }

  Widget formUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to WebRTC Meeting App'),
            const SizedBox(height: 20),
            FormHelper.inputFieldWidget(
              context,
              "meetingId",
              "enter your meetingId",
              (String value) {
                if (value.isEmpty) {
                  return "Meeting id can't be empty";
                }
                return null;
              },
              (onSave) {
                meetingId = onSave;
              },
              borderRadius: 10,
              borderFocusColor: Colors.redAccent,
              borderColor: Colors.redAccent,
              hintColor: Colors.grey,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FormHelper.submitButton(
                    'join meeting',
                    () {
                      if (validateAndSave()) {
                        validateMeeting(meetingId);
                      }
                    },
                  ),
                ),
                Flexible(
                  child: FormHelper.submitButton(
                    'Start meeting',
                    () async {
                      var response = await startMeeting();
                      final body = json.decode(response!.body);
                      final meetId = body['data'];
                      validateMeeting(meetId);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void validateMeeting(String meetingId) async {
    try {
      final response = await joinMeeting(meetingId);
      var data = json.decode(response!.body);
      final meetingDetails = MeetingDetail.fromJson(data['data']);
      //go To Join Screen
      goToJoinScreen(meetingDetails);
    } catch (e) {
      FormHelper.showSimpleAlertDialog(context, "Meeting App", "Invalid Meeting Id", "OK", () {
        Navigator.of(context).pop();
      },);
    }
  }

  void goToJoinScreen(MeetingDetail meetingDetail) {
    Navigator.push(context, MaterialPageRoute(builder:(context) => JoinScreen(meetingDetail: meetingDetail,),),);
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
