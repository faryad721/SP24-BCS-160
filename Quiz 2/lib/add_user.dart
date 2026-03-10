import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'model.dart';

class AddUser extends StatefulWidget {

  @override
  _AddUserState createState() => _AddUserState();

}

class _AddUserState extends State<AddUser> {

  final name = TextEditingController();
  final email = TextEditingController();
  final age = TextEditingController();

  File? _image;

  final picker = ImagePicker();

  Future pickImage() async {

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if(picked!=null){

      setState(() {
        _image = File(picked.path);
      });

    }

  }

  saveUser() async {

    if(_image==null) return;

    User user = User(
      name: name.text,
      email: email.text,
      age: age.text,
      image: _image!.path,
    );

    await DatabaseHelper.instance.insertUser(user);

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Add User")),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(

            children: [

              GestureDetector(

                onTap: pickImage,

                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  _image!=null ? FileImage(_image!) : null,
                  child: _image==null
                      ? Icon(Icons.camera_alt,size:40)
                      : null,
                ),

              ),

              SizedBox(height:20),

              TextField(
                controller: name,
                decoration: InputDecoration(labelText: "Name"),
              ),

              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: age,
                decoration: InputDecoration(labelText: "Age"),
              ),

              SizedBox(height:20),

              ElevatedButton(
                onPressed: saveUser,
                child: Text("Add User"),
              )

            ],

          ),

        ),

      ),

    );

  }

}