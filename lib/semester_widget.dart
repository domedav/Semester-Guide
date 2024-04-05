import 'package:flutter/material.dart';
import 'package:semester_guide/semester.dart';
import 'package:semester_guide/storage.dart';

class SemesterWidget extends StatelessWidget{
  final String name;
  final String code;
  final String type;
  final String credit;
  final List<String> dependsDisplay;

  final Semester semester;
  final Function(Semester) onDismiss;
  final bool Function(SemesterWidget) onConfirmDismiss;

  const SemesterWidget({super.key, required this.name, required this.code, required this.type, required this.credit, required this.dependsDisplay, required this.onDismiss, required this.onConfirmDismiss, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: GlobalKey(),
      confirmDismiss: (_)async{
        return onConfirmDismiss(this);
      },
      onDismissed: (_){
        onDismiss(semester);
      },
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(.1),
              borderRadius: const BorderRadius.all(Radius.circular(40))
          ),
          child: Column(
            children: [
              SelectableText(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            color: Colors.white.withOpacity(.4)
                          ),
                        ),
                        SelectableText(
                          code,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.purple.shade100
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Type',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              color: Colors.white.withOpacity(.4)
                          ),
                        ),
                        SelectableText(
                          type,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.purple.shade100
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Credit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              color: Colors.white.withOpacity(.4)
                          ),
                        ),
                        SelectableText(
                          credit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.purple.shade100
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: dependsDisplay.isEmpty ? 0 : 10),
              Visibility(
                visible: dependsDisplay.isNotEmpty,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Text(
                        dependsDisplay.length == 1 ? 'Dependency' : 'Dependencies',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            color: Colors.white.withOpacity(.4)
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        children: dependsDisplay.map((item){
                          return SelectableText(
                            '${AppStore.getNameOfSemesterByCode(item)} ($item)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.purple.shade100
                            ),
                          );
                        }).toList()
                      ),
                    )
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}