
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';

//Burada tüm öğeler için ortak olan veritabanı işlemleri alınır.
abstract class DatabaseBase {//Abstractla soyut sınıfa dönüştürdük.
//Fonksiyonları farklı tür veri tabanına uygun hale getiriyor.
  Future<dynamic> createBook(Book book);//Soyut fonksiyondur soyuf fonksiyonların olduğu sınıfada soyut sınıf denir.BAzı veri tabanı sisteminde 
  //id string olabilir biz her veri tabanına uygun hale getirmek ortak bir hale getireceğiz.
  Future<List<Book>> readAllBooks(int categoryId, dynamic lastBookId);

  Future<int> updateBook(Book book);//Bu kitap alıyor ve geriye kitap parametresi döndürüyor yani döndürdüğü değer 
  //güncellenmiş verilerin sayısı her zaman integer
  Future<int> deleteBook(Book book);

  Future<int> deleteBooks(List<dynamic> booksId);//Kitap id stringte olabilir.

  Future<dynamic> createSection(Section section);

  Future<List<Section>> readAllSection(dynamic bookId);

  Future<int> updateSection(Section section);

  Future<int> deleteSection(Section section);
}