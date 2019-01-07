import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_seminario/student_details.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class TakePicture extends StatefulWidget {
  @override
  _TakePictureState createState() {
    return _TakePictureState();
  }
}

class _TakePictureState extends State<TakePicture> {
  File image;
  SocketIO socketIO;

  void takePicture(String source) async {
    ImageSource imageSource;

    if (source == 'camera') {
      print('Camera');
      imageSource = ImageSource.camera;
    } else {
      print('Gallery');
      imageSource = ImageSource.gallery;
    }

    File img = await ImagePicker.pickImage(source: imageSource);

    if (img != null) {
      setState(() {
        this.image = img;
        this.image.length().then((len) {
          print('Tamanio: $len');
        });
      });
    }

    socketIO = SocketIOManager().createSocketIO("http://10.0.0.17:3000", "/");

    socketIO.init();

    socketIO.subscribe("message", (data){ print('FUNCIONA!!!!!!!'); print(data); });

    socketIO.connect();
  }

  void pushStudentsDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetails(image: this.image)
      )
    );
  }

  void sendImage() {
    List<int> imageBytes = this.image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    socketIO.sendMessage('upload', '{"image": "$base64Image"}', (){});

    socketIO.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Escoger Imagen'),
        ),
      ),
      body: Container(
        child: Center(
            child: this.image == null
                ? Text('Imagen no seleccionada')
                : Image.file(this.image)),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
                heroTag: 1,
                // onPressed: () => takePicture('camera'),
                onPressed: () => this.sendImage(),
                child: Icon(Icons.camera_alt)),
            FloatingActionButton(
                heroTag: 2,
                onPressed: () =>
                    image == null ? null : pushStudentsDetails(context),
                child: Icon(Icons.send),
                backgroundColor: this.image == null ? Colors.grey : null),
            FloatingActionButton(
                heroTag: 3,
                onPressed: () => takePicture('gallery'),
                child: Icon(Icons.image))
          ],
        ),
      ),
    );
  }
}
