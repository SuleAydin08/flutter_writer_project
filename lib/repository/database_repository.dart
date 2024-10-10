import 'package:flutter_writer_project/base/database_base.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/service/base/database_service.dart';
import 'package:flutter_writer_project/service/sqflite/sqflite_database_service.dart';
import 'package:flutter_writer_project/tools/locator.dart';

class DatabaseRepository implements DatabaseBase{
  //Burdaki amaç servisteki fonksiyona ulaşıp servisteki fonksiyonu çağırmaktır.
  final DatabaseService _service = locator<SqfliteDatabaseService>(); 

  //Future şeklide değişkensiz belirtilenler dynamic kabul edilir.
  @override
  Future createBook(Book book) async {
    return await _service.createBook(book);
  }

  @override
  Future<List<Book>> readAllBooks(int categoryId, lastBookId) async {
    return await _service.readAllBooks(categoryId, lastBookId);
  }

  @override
  Future<int> updateBook(Book book) async {
    return await _service.updateBook(book);
  }

  @override
  Future<int> deleteBook(Book book) async {
    return await _service.deleteBook(book);
  }

  @override
  Future<int> deleteBooks(List booksId) async {
    return await _service.deleteBooks(booksId);
  }

  @override
  Future createSection(Section section) async {
    return await _service.createSection(section);
  }

  @override
  Future<List<Section>> readAllSection(bookId) async {
    return await _service.readAllSection(bookId);
  }
  
  @override
  Future<int> updateSection(Section section) async {
    return await _service.updateSection(section);
  }

  @override
  Future<int> deleteSection(Section section) async {
    return await _service.deleteSection(section);
  }

}