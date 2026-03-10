import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'model.dart';

class EditUser extends StatefulWidget {

  final User user;

  EditUser({required this.user});

  @override
  _EditUserState createState() => _EditUserState();

}

class _EditUserState extends State<EditUser> {

  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController age;

  File? _image;

  final picker = ImagePicker();

  @override
  void initState() {

    super.initState();

    name = TextEditingController(text: widget.user.name);
    email = TextEditingController(text: widget.user.email);
    age = TextEditingController(text: widget.user.age);

    _image = File(widget.user.image);

  }

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

  updateUser() async {

    User user = User(
      id: widget.user.id,
      name: name.text,
      email: email.text,
      age: age.text,
      image: _image!.path,
    );

    await DatabaseHelper.instance.updateUser(user);

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Edit User")),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            GestureDetector(

              onTap: pickImage,

              child: CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(_image!),
              ),

            ),

            SizedBox(height:20),

            TextField(controller: name),
            TextField(controller: email),
            TextField(controller: age),

            SizedBox(height:20),

            ElevatedButton(
              onPressed: updateUser,
              child: Text("Update"),
            )

          ],

        ),

      ),

    );

  }

}