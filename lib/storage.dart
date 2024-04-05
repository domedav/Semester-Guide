import 'package:semester_guide/semester.dart';
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
}