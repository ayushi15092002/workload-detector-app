import 'package:flutter/material.dart';
import '../../model/file_data_model.dart';
import '../../widgets/drop_zone_widget.dart';
import '../../widgets/dropped_file_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState  extends State<MyHomePage> {

  File_Data_Model? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white, size: 19.0),
        leadingWidth: 72.0,
        title: const Text(
          "The Burger Club",
          // style: Fonts.appBarTitle.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: DropZoneWidget(
                      onDroppedFile: (file) => setState(()=> this.file = file) ,
                    ),
                  ),
                  SizedBox(height: 20,),
                  DroppedFileWidget(file:file ),

                ],
              ))
        ],
      ),
    );
  }

}

