import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:semester_guide/add_semester.dart';
import 'package:semester_guide/semester.dart';
import 'package:semester_guide/semester_widget.dart';
import 'package:semester_guide/storage.dart';

class AppHome extends StatefulWidget{
  const AppHome({super.key});

  @override
  State<StatefulWidget> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with TickerProviderStateMixin{

  List<Semester> semesterList = [];
  List<Widget> widgets = [];

  bool hadSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _animationDouble;

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
      closeMenu();
      if(_searchController.text.isEmpty && hadSearch){
        setState(() {
          fillWidgetsList(semesterList);
        });
      }
    });
    _scrollController.addListener(() {
      closeMenu();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animationDouble = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
  }

  void jumpToAddScreen(){
    toggleMenu();
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
    closeMenu();
    if(prevWidget == widget){
      AppStore.removeData(widget.semester);
      AppStore.saveData();
      setState(() {
        fillWidgetsList(semesterList);
      });
      return true;
    }
    if(Platform.isAndroid){
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: 'Swipe again to delete!',
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 14,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
        textColor: Colors.white,
      );
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

  bool _menuToggleState = false;
  void toggleMenu(){
    if(_menuToggleState){
      _animationController.reverse();
      _menuToggleState = false;
      return;
    }
    _menuToggleState = true;
    _animationController.forward();
  }

  void closeMenu(){
    if(!_menuToggleState){
      return;
    }
    toggleMenu();
  }

  void exportButton(){
    toggleMenu();
    AppStore.exportAsFile().then((val){
      if(!val){
        return;
      }
      if(Platform.isAndroid){
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: 'Successfully exported data!',
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 14,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
          textColor: Colors.white,
        );
      }
    });
  }

  void importButton(){
    toggleMenu();
    AppStore.importFromFile().then((val){
      if(!val){
        return;
      }
      if(Platform.isAndroid){
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: 'Successfully imported data!',
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 14,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
          textColor: Colors.white,
        );
      }
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AppHome(),
            barrierDismissible: false,
            allowSnapshotting: true,
            maintainState: true,
            fullscreenDialog: false
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1),
      body: Container(
        padding: MediaQuery.of(context).padding,
        child: SingleChildScrollView(
          controller: _scrollController,
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
      floatingActionButton: AnimatedBuilder(
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.only(left: 2, right: 2, top: 4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0x20, 0x18, 0x28, _animationDouble.value),
              borderRadius: const BorderRadius.all(Radius.circular(90))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Transform.scale(
                  scale: _animationDouble.value,
                  child: IconButton(
                    onPressed: exportButton,
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(17))
                    ),
                    icon: Icon(
                      const IconData(0xf56e, fontFamily: 'Import Export'),
                      color: Color.fromRGBO(0xA8, 0x86, 0xDF, _animationDouble.value),
                      size: 18,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _animationDouble.value,
                  child: IconButton(
                    onPressed: importButton,
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(17))
                    ),
                    icon: Icon(
                      const IconData(0xf56f, fontFamily: 'Import Export'),
                      color: Color.fromRGBO(0xA8, 0x86, 0xDF, _animationDouble.value),
                      size: 18,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _animationDouble.value,
                  child: IconButton(
                    onPressed: jumpToAddScreen,
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(14))
                    ),
                    icon: Icon(
                      Icons.add_rounded,
                      color: Color.fromRGBO(0xA8, 0x86, 0xDF, _animationDouble.value),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: toggleMenu,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color.fromRGBO(lerpDouble(0x20, 0x34, _animationDouble.value)!.round(), lerpDouble(0x18, 0x25, _animationDouble.value)!.round(), lerpDouble(0x28, 0x3F, _animationDouble.value)!.round(), 1)),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(14))
                  ),
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_arrow,
                    color: const Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
                    progress: _animationDouble,
                  ),
                ),
              ],
            ),
          );
        }, animation: _animationController,
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: jumpToAddScreen,
        backgroundColor: const Color.fromRGBO(0x20, 0x18, 0x28, 1),
        foregroundColor: const Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
        child: const Icon(Icons.menu_rounded),
      ),*/
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