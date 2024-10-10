import 'package:flutter/material.dart';
import 'package:flutter_writer_project/local_database.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/repository/database_repository.dart';
import 'package:flutter_writer_project/tools/locator.dart';

class SectionsDetailViewModel with ChangeNotifier{

  DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  final Section _section;

  Section get section => _section;

  SectionsDetailViewModel(this._section);

  

  void saveContent(String contents) async {
//Controllerın içeriğini okuma işlemi;
    _section.contents = contents;
    //Bölümü fonksiyona verme işlemi
    await _databaseRepository.updateSection(_section);
  }
}
