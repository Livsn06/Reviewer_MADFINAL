import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MysqlScreen extends StatefulWidget {
  const MysqlScreen({super.key});

  @override
  State<MysqlScreen> createState() => _MysqlScreenState();
}

class _MysqlScreenState extends State<MysqlScreen> {
  Future<List> fetchStudents() async {
    String uri = 'http://192.168.1.21/mad/students.php';

    var res = await http.get(Uri.parse(uri));
    print("isedit: $isedit");
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      return data;
    }

    return [];
  }

  void insertStudent() async {
    String uri = 'http://192.168.1.21/mad/students.php';

    if (IDTC.text.isEmpty | NAMETC.text.isEmpty | COURSETC.text.isEmpty) {
      print('THERE IS NULL INSERT');
      return;
    }

    var inputs = {
      'id': IDTC.text,
      'name': NAMETC.text,
      'course': COURSETC.text
    };

    var res = await http.post(Uri.parse(uri), body: inputs);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('new student added'),
      ));
    }
  }

  void deleteStudent(String id) async {
    String uri = 'http://192.168.1.21/mad/students.php';

    var res = await http.delete(Uri.parse(uri), body: {'id': id});

    if (res.statusCode == 200) {
      print('success');
    }
  }

  void updateStudent() async {
    String uri = 'http://192.168.1.21/mad/students.php';

    var inputs = {
      'id': IDTC.text,
      'name': NAMETC.text,
      'course': COURSETC.text
    };

    var res = await http.put(Uri.parse(uri), body: inputs);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('record updated'),
      ));
    }
  }

  var IDTC = TextEditingController();
  var NAMETC = TextEditingController();
  var COURSETC = TextEditingController();
  bool isedit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MYSQL_API'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //
          // INPUT FIELDS
          InputField(
            label: 'enter id',
            controller: IDTC,
            isDisable: isedit ? true : false,
          ),
          const Gap(10),

          InputField(label: 'enter name', controller: NAMETC),
          const Gap(10),

          InputField(label: 'enter course', controller: COURSETC),
          const Gap(15),

          // BUTTON
          MaterialButton(
            onPressed: () {
              if (isedit) {
                updateStudent();
                isedit = false;
              } else {
                insertStudent();
              }
              setState(() {
                IDTC.clear();
                NAMETC.clear();
                COURSETC.clear();
              });
            },
            color: Colors.blue,
            child: Text(isedit ? 'Edit' : 'Add'),
          ),
          const Gap(15),

          // LISTVIEW BUILDER
          FutureBuilder(
            future: fetchStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Empty data'),
                );
              }

              var data = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        alignment: Alignment.centerLeft,
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      key: Key(data[index]['studno']),

                      // delete onconfirm
                      confirmDismiss: (direction) async {
                        bool isdelete = false;
                        await QuickAlert.show(
                          context: context,
                          title: "Delete this student?",
                          type: QuickAlertType.confirm,
                          onConfirmBtnTap: () {
                            isdelete = true;
                            Navigator.of(context).pop();
                          },
                        );
                        return isdelete;
                      },

                      // delete confirmed
                      onDismissed: (direction) {
                        deleteStudent(data[index]['studno']);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('student deleted'),
                        ));
                      },

                      // cards
                      child: Card(
                        child: ListTile(
                          onTap: () async {
                            await QuickAlert.show(
                              context: context,
                              title: "Edit this student?",
                              type: QuickAlertType.confirm,
                              onConfirmBtnTap: () {
                                isedit = true;
                                setState(() {
                                  IDTC.text = data[index]['studno'];
                                  NAMETC.text = data[index]['name'];
                                  COURSETC.text = data[index]['course'];
                                  Navigator.of(context).pop();
                                });
                              },
                            );
                          },
                          title: Text(data[index]['name']),
                          subtitle: Text(data[index]['studno']),
                          trailing: Text(data[index]['course']),
                        ),
                      ),
                    );
                  },
                  itemCount: data.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  InputField({
    super.key,
    required this.label,
    required this.controller,
    this.isDisable = false,
  });
  final String label;
  final TextEditingController controller;
  bool isDisable = false;
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: isDisable,
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: label,
      ),
    );
  }
}
