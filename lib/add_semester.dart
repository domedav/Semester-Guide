import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semester_guide/semester.dart';
import 'package:semester_guide/storage.dart';

class AddSemester extends StatefulWidget{
  const AddSemester({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  State<StatefulWidget> createState() => _AddSemesterState();

}
class _AddSemesterState extends State<AddSemester>{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  static int _selectedSemester = 1;

  final List<TextEditingController> _dependencyList = [];
  final List<Widget> _dependencyWidgets = [];
  bool hasHint = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
    ));

    _dependencyWidgets.add(Text(
      'Dependency Codes',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: Colors.white.withOpacity(.3)
      ),
    ));
  }

  void jumpToHomeScreen(){
    Navigator.pop(context);
    widget.onExit();
  }

  void addSemesterAndJump(){
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final type = _typeController.text.trim();
    final credit = _creditController.text.trim();

    final List<String> list = [];
    for(var item in _dependencyList){
      if(item.text.trim().isEmpty){
        continue;
      }
      list.add(item.text.trim());
    }

    AppStore.addData(Semester(_selectedSemester, name.isEmpty ? '-' : name, code.isEmpty ? '-' : code, type.isEmpty ? '-' : type, list, credit.isEmpty ? '-' : credit));
    AppStore.saveData();

    jumpToHomeScreen();
  }

  void decreaseSemester(){
    if(_selectedSemester <= 0){
      return;
    }
    setState(() {
      _selectedSemester--;
    });
  }
  void increaseSemester(){
    if(_selectedSemester >= 99){
      return;
    }
    setState(() {
      _selectedSemester++;
    });
  }


  void addDependencyWidget(){
    setState(() {
      if(hasHint){
        _dependencyWidgets.clear();
        hasHint = false;
      }
      _dependencyList.add(TextEditingController());
      _dependencyWidgets.add(
        Container(
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: _dependencyList[_dependencyList.length - 1],
            decoration: InputDecoration(
              labelStyle: TextStyle(
                  color: Colors.white.withOpacity(.3),
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
              labelText: 'Dependency code',
              hintMaxLines: 1,
              border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(.3)
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(.3)
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(.3)
                  )
              ),
            ),
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
            ),
            maxLines: 1,
          ),
        )
      );
    });
  }

  void removeDependencyWidget(){
    final idx = _dependencyWidgets.length - 1;
    if(idx <= -1){
      return;
    }
    setState(() {
      _dependencyWidgets.removeAt(idx);
      _dependencyList.removeAt(idx);
      if(_dependencyWidgets.isEmpty){
        hasHint = true;
        _dependencyWidgets.add(Text(
          'Dependency Codes',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white.withOpacity(.3)
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1),
      body: Container(
        padding: MediaQuery.of(context).padding,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //const SizedBox(height: 12),
              //ElevatedButton(
              //  onPressed: (){jumpToHomeScreen();},
              //  child: Container(
              //    padding: const EdgeInsets.all(18),
              //    child: const Row(
              //      mainAxisAlignment: MainAxisAlignment.center,
              //      children: [
              //        Icon(
              //          Icons.undo_rounded,
              //          size: 30,
              //        ),
              //        Text(
              //          'Back',
              //          textAlign: TextAlign.center,
              //          style: TextStyle(
              //              fontSize: 22,
              //              fontWeight: FontWeight.w800
              //          ),
              //        ),
              //      ],
              //    ),
              //  )
              //),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Colors.white.withOpacity(.03)
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Colors.white.withOpacity(.3))
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(child: Text(
                            'Semester: ${_selectedSemester <= 0 ? 'Any' : '$_selectedSemester'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600
                            ),
                          )),
                          Column(
                            children: [
                              IconButton(onPressed: increaseSemester, icon: Icon(
                                Icons.add,
                                color: Colors.green.shade200,
                              )),
                              IconButton(onPressed: decreaseSemester, icon: Icon(
                                Icons.remove,
                                color: Colors.redAccent.shade100,
                              )),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.white.withOpacity(.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        labelText: 'Name',
                        hintMaxLines: 1,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.white.withOpacity(.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        labelText: 'Code',
                        hintMaxLines: 1,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.white.withOpacity(.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        labelText: 'Type',
                        hintMaxLines: 1,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _creditController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.white.withOpacity(.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        labelText: 'Credit',
                        hintMaxLines: 1,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(.3)
                            )
                        ),
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Colors.white.withOpacity(.04)),
                        color: Colors.white.withOpacity(.01)
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: _dependencyWidgets
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(onPressed: addDependencyWidget, icon: Icon(
                                Icons.add,
                                color: Colors.green.shade200,
                              )),
                              IconButton(onPressed: removeDependencyWidget, icon: Icon(
                                Icons.remove,
                                color: Colors.redAccent.shade100,
                              )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 12),
              //ElevatedButton(
              //    onPressed: (){addSemesterAndJump();},
              //    child: Container(
              //      padding: const EdgeInsets.all(18),
              //      child: const Row(
              //        mainAxisAlignment: MainAxisAlignment.center,
              //        children: [
              //          Icon(
              //            Icons.check_rounded,
              //            size: 30,
              //          ),
              //          Text(
              //            'Add',
              //            textAlign: TextAlign.center,
              //            style: TextStyle(
              //                fontSize: 22,
              //                fontWeight: FontWeight.w800
              //            ),
              //          ),
              //        ],
              //      ),
              //    )
              //),
            ],
          )
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: addSemesterAndJump,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(0x20, 0x18, 0x28, 1)),
            padding: MaterialStateProperty.all(const EdgeInsets.all(14))
        ),
        icon: const Icon(
          Icons.check_rounded,
          color: Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: addSemesterAndJump,
        backgroundColor: const Color.fromRGBO(0x20, 0x18, 0x28, 1),
        foregroundColor: const Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
        child: const Icon(Icons.check_rounded),
      ),*/
    );
  }
}