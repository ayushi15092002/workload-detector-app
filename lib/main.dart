// import 'package:flutter/material.dart';
// import 'package:workload_detector_app/screens/home/home.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }


import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
          child: Wrap(
            direction: Axis.horizontal,
            runSpacing: 8,
            spacing: 8,
            children: const [
              ExampleDragTarget(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String res = await sendFiles();
            print("res = $res");
          },
        ),
      ),
    );
  }

  Future<String> sendFiles() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/predict'));

    // add vhdr file
    var vhdrFile = await http.MultipartFile.fromPath('vhdr', 'F:/drdo/data/nback1.vhdr');
    request.files.add(vhdrFile);

    // add vmrk file
    var vmrkFile = await http.MultipartFile.fromPath('vmrk', 'F:/drdo/data/nback1.vmrk');
    request.files.add(vmrkFile);

    // add eeg file
    var eegFile = await http.MultipartFile.fromPath('eeg', 'F:/drdo/data/nback1.eeg');
    request.files.add(eegFile);

    var response = await request.send();
    var responseText = await response.stream.bytesToString();
    return responseText;
  }
}

class ExampleDragTarget extends StatefulWidget {
  const ExampleDragTarget({Key? key}) : super(key: key);

  @override
  _ExampleDragTargetState createState() => _ExampleDragTargetState();
}

class _ExampleDragTargetState extends State<ExampleDragTarget> {
  final List<XFile> _list = [];

  bool _dragging = false;

  Offset? offset;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          _list.addAll(detail.files);
        });

        debugPrint('onDragDone:');
        for (final file in detail.files){
          debugPrint('  ${file.path} ${file.name}'
              '  ${await file.lastModified()}'
              '  ${await file.length()}'
              '  ${file.mimeType}');
        }
      },
      onDragUpdated: (details) {
        setState(() {
          offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
          offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
          offset = null;
        });
      },
      child: Container(
        height: 200,
        width: 600,
        // color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        child: buildDecoration(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    if (_list.isEmpty)
                      const Center(child: Text("Drop here"))
                    else
                      Text(_list.map((e) => e.path).join("\n")),
                    if (offset != null)
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          '$offset',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // final events = await controller.pickFiles();
                        // if(events.isEmpty) return;
                        // UploadedFile(events.first);
                      },
                      icon: Icon(Icons.search),
                      label: Text(
                        'Choose File',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20
                          ),
                          primary: Colors.green.shade300,
                          shape: RoundedRectangleBorder()
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildDecoration({required Widget child}){
  final colorBackground =  Colors.green;
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(10),
      color: colorBackground,
      child: DottedBorder(
          borderType: BorderType.RRect,
          color: Colors.white,
          strokeWidth: 3,
          dashPattern: const [8,4],
          radius: const Radius.circular(10),
          padding: EdgeInsets.zero,
          child: child
      ),
    ),
  );
}
