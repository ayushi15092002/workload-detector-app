import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ExampleDragTarget extends StatefulWidget {
  final Function(List<XFile>) onDataReceived;
  const ExampleDragTarget({Key? key, required this.onDataReceived}) : super(key: key);

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
          if(_list.length<4) {
            _list.addAll(detail.files);
          }
        });
        widget.onDataReceived(_list);

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