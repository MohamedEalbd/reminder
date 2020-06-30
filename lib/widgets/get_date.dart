import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder/widgets/notification.dart';

final task = Firestore.instance.collection('tasks');

class GetDate extends StatefulWidget {
  final String userId;
  GetDate({this.userId});
  @override
  _GetDateState createState() => _GetDateState();
}

class _GetDateState extends State<GetDate> {
  DateTime _currentdate = DateTime.now();

  TextEditingController _updateName = new TextEditingController();

  update(selectDoc, newValues) {
    task.document(widget.userId).collection("userId").document(selectDoc).updateData(newValues).catchError((e) {
      print(e);
    });
  }

  deleteData(docId) {
    task.document(widget.userId).collection("userId").document(docId).delete().catchError((e) {
      print(e);
    });
  }

  Future _selectDate(context) async {
    final DateTime _seldate = await showDatePicker(
        context: context,
        initialDate: _currentdate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return SingleChildScrollView(
            child: child,
          );
        });
    if (_seldate != null) {
      setState(() {
        _currentdate = _seldate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String _formatdate = new DateFormat.yMMMd().format(_currentdate);
    void _showDialog(docId) {
      // flutter defined function
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("UpdateDate"),
            content: new TextField(
              controller: _updateName,
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Save"),
                onPressed: () {
                  update(docId, {'name': _updateName.text});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return StreamBuilder(
        stream: task.document(widget.userId).collection("userId").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.pinkAccent,));
          } else {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot taske = snapshot.data.documents[index];
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              LocalNotifications(title: "Hello${taske['name']}",body: "You have a reminder${{taske['time']}}",);
                              print("tapped");
                            },
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          taske['name'],textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8),
                                          child: Text(
                                            "${taske['time']}",textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),

                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.update,color: Colors.grey,),
                                  onPressed: () {
                                    _showDialog(taske.documentID);
                                  }),
                              IconButton(
                                  icon: Icon(Icons.delete_outline,color: Colors.grey,),
                                  onPressed: () {
                                    deleteData(taske.documentID);
                                  }),
                            ],
                          )
                        ],
                      ),
                      Divider(),
                    ],
                  );
                });
          }
        });
  }
}
