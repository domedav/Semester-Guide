import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semester_guide/add_semester.dart';
import 'package:semester_guide/semester.dart';
import 'package:semester_guide/semester_widget.dart';
import 'package:semester_guide/storage.dart';

class AppHome extends StatefulWidget{
  const AppHome({super.key});

  @override
  State<StatefulWidget> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome>{

  List<Semester> semesterList = [];
  List<Widget> widgets = [];

  bool hadSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // navigation bar color
      statusBarColor: Color.fromRGBO(0x22, 0x22, 0x22, 1.0), // status bar color
    ));

    Future.delayed(Duration.zero, ()async{
      await AppStore.loadData();
    }).whenComplete((){
      setState(() {
        semesterList = AppStore.getList();
        fillWidgetsList(semesterList);
      });
    });

    _searchController.addListener(() {
      if(_searchController.text.isEmpty && hadSearch){
        setState(() {
          fillWidgetsList(semesterList);
        });
      }
    });
  }

  void jumpToAddScreen(){
    _searchController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSemester(onExit: onAddScreenBack,),
        barrierDismissible: true,
        allowSnapshotting: true,
        maintainState: true,
        fullscreenDialog: false
      ),
    );
  }

  void onAddScreenBack(){
    setState(() {
      semesterList = AppStore.getList();
      fillWidgetsList(semesterList);
    });
  }

  void fillWidgetsList(List<Semester> semList){
    widgets.clear();
    widgets.add(const SizedBox(height: 18));
    int prevSemesterLine = -1;
    bool hasAny = false;
    for(var item in semList){
      if(item.semester <= 0){
        hasAny = true;
        continue;
      }
      if(prevSemesterLine != item.semester){
        widgets.add(getSeparatorLine('${item.semester}. semester'));
        prevSemesterLine = item.semester;
      }
      widgets.add(SemesterWidget(name: item.name, code: item.code, type: item.type, credit: item.credit, dependsDisplay: item.neededsCode, semester: item, onDismiss: semesterDismiss, onConfirmDismiss: confirmDismiss,));
    }
    if(!hasAny){
      return;
    }
    widgets.add(getSeparatorLine('Any semester'));
    for(var item in semList){
      if(item.semester > 0){
        continue;
      }
      widgets.add(SemesterWidget(name: item.name, code: item.code, type: item.type, credit: item.credit, dependsDisplay: item.neededsCode, semester: item, onDismiss: semesterDismiss, onConfirmDismiss: confirmDismiss,));
    }
  }

  void semesterDismiss(Semester semester){
    AppStore.removeData(semester);
    AppStore.saveData();
  }

  SemesterWidget? prevWidget;
  Timer timer = Timer(Duration.zero, () {});

  bool confirmDismiss(SemesterWidget widget){
    if(prevWidget == widget){
      AppStore.removeData(widget.semester);
      AppStore.saveData();
      setState(() {
        fillWidgetsList(semesterList);
      });
      return true;
    }
    prevWidget = widget;
    timer.cancel();
    timer = Timer(const Duration(seconds: 3), (){
      prevWidget = null;
    });
    return false;
  }

  bool hasInList(List<String> list, String search){
    for(var item in list) {
      final name = AppStore.getNameOfSemesterByCode(item);
      if (item.toLowerCase().contains(search) || name.trim().toLowerCase().contains(search)) {
        return true;
      }
    }
    return false;
  }

  void filterDisplayResults(){
    hadSearch = true;
    setState(() {
      final searchStr = _searchController.text.trim().toLowerCase();
      final List<Semester> collect = [];
      for(int i = 0; i < widgets.length; i++){
        final item = widgets[i];
        if(item is! SemesterWidget){
          continue;
        }
        if(item.name.toLowerCase().contains(searchStr) || item.code.toLowerCase().contains(searchStr) || (item.semester.semester <= 0 ? 'any' : '${item.semester.semester}.').toLowerCase().contains(searchStr) || item.credit.toLowerCase().contains(searchStr) || item.type.toLowerCase().contains(searchStr) || hasInList(item.dependsDisplay, searchStr)){
          collect.add(item.semester);
        }
      }
      fillWidgetsList(collect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1),
      body: Container(
        padding: MediaQuery.of(context).padding,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(.3),
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                          labelText: 'Search',
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
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                        onPressed: filterDisplayResults,
                        icon: const Icon(
                          Icons.search,
                          size: 30,
                        )
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widgets,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: jumpToAddScreen,
        backgroundColor: const Color.fromRGBO(0x20, 0x18, 0x28, 1),
        foregroundColor: const Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget getSeparatorLine(String text){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: Container(height: 2, color: Colors.white.withOpacity(.2),)),
        Expanded(flex: 2, child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.2),
            fontWeight: FontWeight.w700,
            fontSize: 12
          ),
        )),
        Expanded(flex: 3, child: Container(height: 2, color: Colors.white.withOpacity(.2),)),
      ],
    );
  }
}