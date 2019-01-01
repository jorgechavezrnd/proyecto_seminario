import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:proyecto_seminario/models/student_model.dart';

const apiUrl = 'http://192.168.133.129:8080/compare';
const pictureUrl = 'assets/img/nobody.jpg';

class StudentDetails extends StatefulWidget {

  File image;

  StudentDetails({ this.image });

  @override
  _StudentDetailsState createState() {
    return _StudentDetailsState();
  }

}

class _StudentDetailsState extends State<StudentDetails> {

  dynamic response;
  List<StudentModel> students;

  @override
  void initState() {
    super.initState();
    this.sendImage();
  }

  void sendImage() {
    print('Send Image');

    Dio dio = new Dio();
    FormData formData = new FormData();
    formData.add('file', new UploadFileInfo(widget.image, basename(widget.image.path)));

    dio.post(apiUrl, data: formData, options: Options(
      method: 'POST',
      responseType: ResponseType.JSON
    )).then((response) => setState(() {
      this.response = response;
      this.students = new List();

      int tam = this.response.data['students'].length;

      for (int i = 0; i < tam; ++i) {
        String name = this.response.data['students'][i];
        print('Student $i : $name');
        this.students.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }

    })).catchError((error) => print(error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Estudiantes presentes'),
        ),
      ),
      //body: response == null ? Center(child: CircularProgressIndicator()) : Text(this.response.data['students'].toString())
      body: response == null ? Center(child: CircularProgressIndicator(),) : ListView.builder(
        itemCount: this.students.length,
        itemBuilder: (context, i) => Column(
          children: <Widget>[
            Divider(
              height: 10.0,
            ),
            ListTile(
              leading: CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(this.students[i].pictureUrl),
              ),
              title: Text(
                this.students[i].name,
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            )
          ],
        ),
      )
    );
  }

}