import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reminder/model/user.dart';


class addNewTask extends StatefulWidget{
  final String userid;
  addNewTask({this.userid});
  @override
  _addNewTaskState createState() => _addNewTaskState();
}

class _addNewTaskState extends State<addNewTask> {
TextEditingController _addTask = new TextEditingController();
DateTime _currentdate = DateTime.now();
  String newTaskTitle;

Future _selectDate(context) async {
  final DateTime _seldate = await showDatePicker(
      context: context,
      initialDate: _currentdate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context,child){
        return SingleChildScrollView(
          child: child,
        );
      }
  );
  if(_seldate!=null){
    setState(() {
      _currentdate = _seldate;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    String _formatdate = new DateFormat.yMMMd().format(_currentdate);
    return Container(
      color: Color(0xff757575),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(
                "Add Task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0,right: 8,bottom: 10,top: 10),
              child: Container(
                alignment: Alignment.topLeft,
                  child: TextField(
                    controller: _addTask,
                    decoration: InputDecoration(
                      hintText: 'You can add anew reminder',
                      suffixIcon: IconButton(icon: Icon(Icons.today), onPressed:() => _selectDate(context))
                    ),
                    onChanged: (newText){
                      newTaskTitle = newText;
                    },
                    textAlign: TextAlign.center,
                    autofocus: true,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
                  Firestore.instance.collection("tasks").document(widget.userid).collection('userId').document()
                      .setData({'name' : _addTask.text,'time':_formatdate});
                  Navigator.pop(context);
                },
                child: Text("Add",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),

    );
  }
}