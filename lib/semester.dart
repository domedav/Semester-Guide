class Semester{
  late int semester = 0;
  late String name = '';
  late String code = '';
  late String type = '';
  late List<String> neededsCode = [];
  late String credit = '';

  List<Semester>? dependsOn;

  Semester(this.semester, this.name, this.code, this.type, this.neededsCode, this.credit);

  static Semester loadFrom(String str){
    final vals = str.split('\n');

    final name = vals[0];
    final code = vals[1];
    final type = vals[2];
    final credit = vals[3];
    final semester = int.parse(vals[4]);
    final List<String> list = [];

    final neededs = vals[5].split('\u0000');
    for(var item in neededs){
      if(item.trim().isEmpty){
        continue;
      }
      list.add(item);
    }
    return Semester(semester, name, code, type, list, credit);
  }

  String splitList(){
    if(neededsCode.isEmpty){
      return '';
    }
    String str = '';
    for(int i = 0; i < neededsCode.length - 1; i++){
      str += '${neededsCode[i]}\u0000';
    }
    str += neededsCode[neededsCode.length - 1];
    return str.trim();
  }

  @override
  String toString() {
    return '$name\n$code\n$type\n$credit\n$semester\n${splitList()}';
  }
}