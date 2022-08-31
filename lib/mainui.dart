import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  @override
  State<UI> createState() => _UIState();
}

String selectedFile = "";

Future<dynamic> selectAndConvertFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["xls"],
      dialogTitle: "Chọn tệp Excel danh sách học sinh mẫu 1 của VNEdu");
  if (result != null) {
    var process = Process.runSync(
        "contacts_filter\\contacts_filter.exe", ["--path", result.paths[0]!]);
    if (process.stdout == "wrong_file_type") {
      return [result.paths[0]!, false];
    }
    return result.paths[0]!;
  } else {
    if (selectedFile != "") {
      return selectedFile;
    } else {
      return ["", false];
    }
  }
}

class _UIState extends State<UI> {
  int _selectedIndex = 0;
  String selectedProvider = "VNEdu";
  String selectedNameSetting = "Tên đệm + tên học sinh";
  String selectedNamePut = "Tên phụ đứng trước";
  bool isDone = false;
  late TextEditingController extraText;
  late Widget selectFileIcon =
      Icon(Icons.add, size: MediaQuery.of(context).size.height / 40);
  List<dynamic> selectColor = [null, null];

  @override
  void initState() {
    super.initState();
    extraText = TextEditingController();
    extraText.text = "Phụ huynh";
  }

  @override
  void dispose() {
    extraText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [
      Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height / 100),
              child: Text(selectedFile)),
          SizedBox(
              width: MediaQuery.of(context).size.width / 8,
              height: MediaQuery.of(context).size.height / 20,
              child: ElevatedButton.icon(
                  icon: selectFileIcon,
                  style: ElevatedButton.styleFrom(
                      primary: selectColor[0], onPrimary: selectColor[1]),
                  onPressed: () {
                    selectAndConvertFile().then((handle) {
                      setState(() {
                        if (handle[1] == false) {
                          selectFileIcon = Icon(Icons.close,
                              size: MediaQuery.of(context).size.height / 40);
                          selectColor = [
                            Theme.of(context).colorScheme.error,
                            Theme.of(context).colorScheme.onError
                          ];
                          isDone = false;
                          selectedFile = handle;
                        } else {
                          selectFileIcon = Icon(Icons.check,
                              size: MediaQuery.of(context).size.height / 40);
                          selectColor = [null, null];
                          isDone = true;
                          selectedFile = handle;
                        }
                      });
                    });
                  },
                  label: Text("Chọn tệp",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 60)))),
          Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 50),
              child: Text("Đặt tên danh bạ",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 50))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DropdownButton<String>(
              value: selectedNamePut,
              icon: const Icon(Icons.expand_more),
              elevation: 16,
              onChanged: (String? newValue) {
                setState(() {
                  selectedNamePut = newValue!;
                });
              },
              items: <String>["Tên phụ đứng trước", "Tên phụ đứng sau"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(width: 15),
            DropdownButton<String>(
              value: selectedNameSetting,
              icon: const Icon(Icons.expand_more),
              elevation: 16,
              onChanged: (String? newValue) {
                setState(() {
                  selectedNameSetting = newValue!;
                });
              },
              items: <String>[
                "Họ và tên học sinh",
                "Tên đệm + tên học sinh",
                "Chỉ tên học sinh"
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ]),
          Container(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 5,
                right: MediaQuery.of(context).size.width / 5,
                top: MediaQuery.of(context).size.height / 50),
            child: TextField(
                controller: extraText,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Tên phụ",
                    helperText: selectedNamePut == "Tên phụ đứng trước"
                        ? "Ví dụ: ${extraText.text} <$selectedNameSetting>"
                        : "Ví dụ: <$selectedNameSetting> ${extraText.text}")),
          ),
          Container(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 5,
                  right: MediaQuery.of(context).size.width / 5,
                  top: MediaQuery.of(context).size.height / 50),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.height / 20,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow,
                        size: MediaQuery.of(context).size.height / 40),
                    label: Text("Chuyển đổi",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60)),
                    onPressed: isDone
                        ? () {
                            FilePicker.platform.saveFile(
                                dialogTitle: "Lưu danh bạ",
                                type: FileType.custom,
                                allowedExtensions: ["vcf"]).then((result) {
                              if (result != null) {
                                var proc = Process.runSync(
                                    "contacts_filter\\contacts_filter.exe", [
                                  "--convert",
                                  selectedFile,
                                  "--saveat",
                                  result,
                                  "--extratext",
                                  extraText.text,
                                  "--namesetting",
                                  selectedNameSetting,
                                  "--sort",
                                  selectedNamePut
                                ]);
                                if (proc.stdout.startsWith("success")) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Chuyển đổi và lưu danh bạ thành công. Đã chuyển được ${proc.stdout.replaceAll(RegExp(r'success '), '')} danh bạ!"),
                                  ));
                                }
                              }
                            });
                          }
                        : null,
                  )))
        ],
      )),
      const Center(child: Text("Đang phát triển..."))
    ];

    return Scaffold(
        appBar: AppBar(
            title: Text("Xuất danh bạ danh sách học sinh $selectedProvider"),
            toolbarHeight: 50),
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                  selectedProvider = index == 0 ? "VNEdu" : "ViettelEdu";
                });
              },
              groupAlignment: 0,
              extended: true,
              elevation: 1,
              minExtendedWidth: MediaQuery.of(context).size.width / 10,
              trailing: Column(children: [
                SizedBox(height: MediaQuery.of(context).size.height / 10),
                TextButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text("Thông tin bản quyền"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Thông tin bản quyền"),
                              content: const Text(
                                  "Phần mềm nầy là một phần mềm mã nguồn mở được viết bằng Dart (Flutter) và Python, dựa theo giấy phép MIT.\nPhần mềm đang sử dụng các dự án mã nguồn mở khác:\n- file_picker (Flutter)\n- xlrd (Python)"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    })
              ]),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: Text('VNEdu'),
                    padding: EdgeInsets.only(top: 10, bottom: 10)),
                NavigationRailDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: Text('SMAS'),
                    padding: EdgeInsets.only(top: 10, bottom: 10)),
              ],
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.topLeft, child: body[_selectedIndex]))
          ],
        ));
  }
}
