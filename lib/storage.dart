import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:semester_guide/semester.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AppStore{
  static final List<Semester> _semesters = [];

  static Future<void> loadData()async{
    final prefs = await SharedPreferences.getInstance();
    final dbLen = prefs.getInt('Length');
    if(dbLen == null || dbLen == 0){
      return;
    }
    for(int i = 0; i < dbLen; i++){
      final semester = prefs.getString('Semestr_$i');
      addData(Semester.loadFrom(semester!));
    }
  }

  static Future<void> saveData()async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('Length', _semesters.length);

    int i = 0;
    for(var item in _semesters){
      prefs.setString('Semestr_$i', item.toString());
      i++;
    }
  }

  static void addData(Semester s){
    _semesters.add(s);
  }

  static void removeData(Semester s){
    _semesters.remove(s);
  }

  static List<Semester> getList(){
    List<Semester> ordered = _semesters;

    for(int i = 0; i < ordered.length; i++){
      for(int j = i; j < ordered.length; j++){
        if(ordered[i].semester > ordered[j].semester){
          final tmp = ordered[i];
          ordered[i] = ordered[j];
          ordered[j] = tmp;
        }
      }
    }
    return ordered;
  }

  static String getNameOfSemesterByCode(String code){
    for(var item in _semesters){
      if(item.code == code){
        return item.name;
      }
    }
    return '';
  }

  static Future<bool> exportAsFile()async{
    final prefs = await SharedPreferences.getInstance();
    final dbLen = prefs.getInt('Length');
    final Map<String, String> map = <String, String>{};

    for(int i = 0; i < _semesters.length; i++){
      final item = _semesters[i];
      map.addAll(<String, String>{'Semestr_$i': item.toString()});
    }

    final json = jsonEncode({'dbLen': dbLen ?? 0, 'values': map});

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Select the path you want to export to',
      fileName: 'SemesterGuide_${DateTime.now().millisecondsSinceEpoch}.semesterguide',
      type: FileType.any,
      allowedExtensions: ['.semesterguide'],
      bytes: utf8.encode(json)
    );
    if(result == null){
      return false;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/SemesterGuide_${DateTime.now().millisecondsSinceEpoch}.semesterguide');
    file.createSync(recursive: true);
    file.writeAsStringSync(json, flush: true);
    if(Platform.isAndroid){
      await _shareFile(file, json).whenComplete(()async{
        await file.delete();
      });
    }
    return true;
  }

  static Future<void> _shareFile(File file, String json)async{
    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<bool> importFromFile()async{
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select the file you want to import from',
    );
    if (result == null || result.files.single.path == null) {
      return false;
    }
    try{
      final file = File(result.files.single.path!);
      final content = jsonDecode(await file.readAsString());
      final map = content as Map<String, dynamic>;
      final dbLen = map['dbLen'];
      final Map<String, dynamic> semesters = map['values'];
      _semesters.clear();
      for(int i = 0; i < dbLen; i++){
        final str = semesters['Semestr_$i'].toString();
        addData(Semester.loadFrom(str));
      }
      await saveData();
      return true;
    }
    on Exception {
      if(Platform.isAndroid){
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: 'Select a valid Semester Guide file (.semesterguide)',
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 14,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: const Color.fromRGBO(0x22, 0x22, 0x22, 1.0),
          textColor: Colors.white,
        );
      }
      return false;
    }
  }
}