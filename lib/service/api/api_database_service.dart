
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/service/base/database_service.dart';

class ApiDatabaseService implements DatabaseService {
  @override
  Future createBook(Book book) async {
    return 1;
  }

  @override
  Future createSection(Section section) async {
   return 1;
  }

  @override
  Future<int> deleteBook(Book book) async {
   return 1;
  }

  @override
  Future<int> deleteBooks(List booksId) async {
   return 1;
  }

  @override
  Future<int> deleteSection(Section section) async {
   return 1;
  }

  @override
  Future<List<Book>> readAllBooks(int categoryId, lastBookId) async {
    List<Book> books = [];
    for(int i = 1; i<=10; i++){
      Book book = Book("Kitap $i", DateTime.now(), 0);
      book.id = i;
      books.add(book);
    }
    return books;
  }

  @override
  Future<List<Section>> readAllSection(bookId) async {
      List<Section> sections = [];
    for(int i =1; i<=10;i++){
      Section section = Section(1, "Bolum $i");
      section.id = i;
      sections.add(section);
    }
    return sections;
  }

  @override
  Future<int> updateBook(Book book) async {
    return 1;
  }

  @override
  Future<int> updateSection(Section section) async {
    return 1;
  }
}