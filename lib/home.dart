import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'drag_target.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<XFile> _list = [];
  String result = " ";
  bool isLoading = false;
  void onDataReceived(List<XFile>? data) {
    setState(() {
      _list = data!;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // automaticallyImplyLeading: true,
        backgroundColor: Colors.black54,
        iconTheme: const IconThemeData(color: Colors.white, size: 19.0),
        leadingWidth: 72.0,
        title: const Text(
          "Mental Workload Detector",
          // style: Fonts.appBarTitle.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              direction: Axis.horizontal,
              runSpacing: 8,
              spacing: 8,
              children:  [
                DragTargetWidget(onDataReceived: onDataReceived),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 60,
              width: 150,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Color(0xffE1B310)),
                      textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black, fontFamily: "Rye")),
                      elevation: MaterialStateProperty.all(20.0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          )
                      )),
                  child: Text(
                    "Check",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {

                    print("pressed");
                    if (_list.length == 3) {
                      setState(() {
                        isLoading = true;
                        result = "";
                      });
                      String res = await sendFiles();
                      print("res $res");
                      if(res != null && res.isNotEmpty){
                        print("setting state");
                        isLoading = false;
                        result = res;
                        setState(() {});
                      }

                    }
                  }

              ),
            ),
            Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  resWidget()
                ],
            )

          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     print("pressed");
      //     if(_list.length == 3) {
      //       print(">>>>");
      //       String res = await sendFiles();
      //       print("res = $res");
      //       if(res != null && res.isNotEmpty){
      //         setState(() {
      //           isLoading = false;
      //           result = res;
      //         });
      //       }
      //     }
      //   },
      // ),
    );
  }
  Widget resWidget(){
    if(isLoading == true){
      return CupertinoActivityIndicator();
    }
    print(!isLoading && result.isNotEmpty);
    if(!isLoading && result.isNotEmpty){
      print("under if");
      return Text(
          resultString(result),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      );

    }
    return SizedBox();
  }
  String resultString(String res){
    if(res == "0"){
      return "LOW";
    }
    else if(res == "2"){
      return "MEDIUM";
    }
    else if(res == "3"){
      return "HIGH";
    }
    return "";
  }
  Future<String> sendFiles() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/predict'));

    for(int i= 0 ; i<_list.length ; i++){
      if(_list[i].name.contains("vhdr")){
        // add vhdr file
        var vhdrFile = await http.MultipartFile.fromPath('vhdr', _list[i].path.toString());
        request.files.add(vhdrFile);
      }else if(_list[i].name.contains("vmrk")){
        // add vmrk file
        var vmrkFile = await http.MultipartFile.fromPath('vmrk', _list[i].path.toString());
        request.files.add(vmrkFile);
      }else if(_list[i].name.contains("eeg")){
        // add eeg file
        var eegFile = await http.MultipartFile.fromPath('eeg', _list[i].path.toString());
        request.files.add(eegFile);
      }
    }
    var response = await request.send();
    var responseText = await response.stream.bytesToString();
    return responseText;
  }
}
