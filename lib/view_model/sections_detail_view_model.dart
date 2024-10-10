import 'package:flutter/material.dart';
import 'package:flutter_writer_project/local_database.dart';
import 'package:flutter_writer_project/model/section.dart';

class SectionsDetailViewModel with ChangeNotifier{

  //Veri tabanı
  LocalDataBase _localDataBase = LocalDataBase();
  final Section _section;

  Section get section => _section;

  SectionsDetailViewModel(this._section);

  

  void saveContent(String contents) async {
//Controllerın içeriğini okuma işlemi;
    _section.contents = contents;
    //Bölümü fonksiyona verme işlemi
    await _localDataBase.updateSection(_section);
  }
}
