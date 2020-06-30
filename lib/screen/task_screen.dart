import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder/widgets/drawer_app.dart';
import 'package:reminder/widgets/get_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_new_task.dart';
class TaskScreen extends StatefulWidget {
  final String userid;
  TaskScreen({this.userid});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  String email;
  String name;
  String mediaUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }
  getPref() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences.getString("email");
    name = sharedPreferences.getString("displayName");
    mediaUrl = sharedPreferences.getString("photoUrl");
    print("email $email");
    print(name);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerApp(),
      backgroundColor: Colors.deepPurple,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: (context) => addNewTask(userid: widget.userid,
          ));
        },
        child: Icon(Icons.add),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding:
            const EdgeInsets.only(top: 60, left: 20, right: 30, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     InkWell(
                       onTap: (){
                         _scaffoldKey.currentState.openDrawer();
                       },
                       child: CircleAvatar(
                         child: Icon(Icons.menu),
                         backgroundColor: Colors.white,
                         radius: 30,
                       ),
                     ),
                     SizedBox(
                       width: 10,
                     ),
                Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    "Reminder",
                    style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                   ],
                 )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: GetDate(userId: widget.userid,),
            ),
          ),
        ],
      ),
    );
  }
}