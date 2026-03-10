import 'dart:io';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'model.dart';
import 'add_user.dart';
import 'edit_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SQLite CRUD",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(),
    );

  }

}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  List<User> users = [];

  loadUsers() async {

    users = await DatabaseHelper.instance.getUsers();
    setState(() {});

  }

  @override
  void initState() {

    super.initState();
    loadUsers();

  }

  deleteUser(int id) async {

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete"),
        content: Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context,false),
          ),
          TextButton(
            child: Text("Yes"),
            onPressed: () => Navigator.pop(context,true),
          )
        ],
      ),
    );

    if(confirm){

      await DatabaseHelper.instance.deleteUser(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User Deleted"))
      );

      loadUsers();

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("User Manager"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddUser()),
          );

          loadUsers();

        },
      ),

      body: users.isEmpty
          ? Center(child: Text("No Users Added"))
          : ListView.builder(

        itemCount: users.length,

        itemBuilder: (context,index){

          final user = users[index];

          return Card(

            elevation: 5,
            margin: EdgeInsets.all(10),

            child: ListTile(

              leading: CircleAvatar(
                radius: 30,
                backgroundImage: FileImage(File(user.image)),
              ),

              title: Text(user.name),
              subtitle: Text("${user.email}\nAge: ${user.age}"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: Icon(Icons.edit,color: Colors.green),
                    onPressed: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUser(user: user),
                        ),
                      );

                      loadUsers();

                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.delete,color: Colors.red),
                    onPressed: () {
                      deleteUser(user.id!);
                    },
                  ),

                ],
              ),

            ),

          );

        },

      ),

    );

  }

}