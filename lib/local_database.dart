//Ben sql kodlarımı sadece bu sınıfın içerisinde yapacağım.
//Modeller belirli bir sınıfa ayit nesneleri tek bir çatı altına toplamak içinde kullanılır.

import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class LocalDataBase {
  //Dartta singelton nasıl yapılır.
  LocalDataBase._privateConstructor(); //Başka bir sınıftan buna bağlı nesne üretilebilir ben bunu istemiyorum(LocalDataBase.privateConstructor()).
//_ koyarak bunu erişilemez yapıyorum.

//Bunun içerisinde bir nesne oluşturacağım.
  static final LocalDataBase _object = LocalDataBase
      ._privateConstructor(); //Burada bir constructer tanımladım ve dışarıdan bu constructera
//erişilsin istemiyorum Çünkü bu sınıf _nesne oluşturmak için kullanılacak ama bunu ben dışarıya kullandırmak için;

//Bu sebeple d2 nin değeri olmadığından d2 dede bu constructer çalıştırıldığı için final olduğundanda  değiştirilmeden geri döndürülür.
//Aynı nesneyi farklı isimlerle kullanıyoruz yani.

  factory LocalDataBase() {
    //Factory constructerın döndüreceği değer statik olmalıdır.Bu sebeple üst kısım static yapılır.
//Factory constructer bir nesne üretmez başka bir constructerın ürettiği nesneyi düzenleyip geri döndürmemizi sağlar.

    //Yukarıda zaten oluşturulmuş bir nesne var ben bunu dışarıya döndürsün istiyorum.
    return _object;
  }

//Veri tabanı nesnesi
  Database?
      _dataBase; //Başlangıçta null olucak. Bu veri tabanına bir nesne eklerken bu nesneyi kullanacağım.Bu nesneyi doğrudan kullanmayız.

//VEri tabanından gelen değerlerin türünü burada yazıyorum.
  String _booksTableName = "books";
  String _booksId = "id";
  String _booksName = "name";
  String _booksCreationDate = "creationDate";

//Section veritabanına gelen değerlerin türü
  String _sectionsTableName = "section";
  String _idSections = "id";
  String _bookIdSections = "bookId";
  String _titleSections = "title";
  String _contentsSections = "contents";
  // String _creationDateSections = "creationDate";

//Üsteki nesneyi döndüreceğinden buda database döndürür.Üsteki nesneyi bu fonksiyon aracılığıyla kullanırız.
////Bu veri tabanı döndürüleceği için fonksiyonda null olur.
  Future<Database?> _dataBaseBring() async {
    //İçerisinde uzun sürecek işlem olduğundan doğrudan data base döndürülmez future içerisinde data base döndürülür.
//Veri tabanı null iste if gövdesi çalışacak.Eğer null değilse direk olarak veri tabanı döndürülecek.
    if (_dataBase == null) {
      //Önce veritabanının dosya yoluna ulaşılır.
      String filePath =
          await getDatabasesPath(); //Future döndürduğü için await async ve future olacak.
      //Dosya yoluna yazar dosyasının db yolunu eklerim.
      String dataBasePath = join(filePath, "writer.db");
      // "filePath/writer.db";//Bu şekilde neden yapmadık derseniz bazı işletim sistemlerinde / bu kullanılırken bazılarında \ bu kullanılır.
      //join bunu işletim sistemine göre ayarlıyor.
      
      // //Veri tabanını sil
      // await deleteDatabase(dataBasePath);
      //Eğer veri tabanı oluşmuşsa geri döndürecek eğer oluşmamışsa oluşturacaktır veri tabanını.O fonksiyonun ismide altta yazdığım fonksiyondur.
      _dataBase = await openDatabase(
        dataBasePath,
        version: 1,
        //Tablo oluşturacağım fonksiyonu yazarım buraya,
        //Tablo oluşturma kısmı veri tabanını ilk kez oluşturduğumuzda çalıştığı için bölümler sayfasında fab basarak değer girdiğimizde çalışmadı.
        //oncreat parametresi oluşturulduğunda demektir.
        onCreate: _createTable,
      ); //Future döndürdüğünden bunu veri tabanı nesneme atıyorum ve awaiti unutmuyorum.
    }
    return _dataBase;
  }

  Future<void> _createTable(Database db, int version) async {
    //sqfliteda doğrudan tablo oluştur fonksiyonu yok bu sebeple burada sql kodu oluşturmamız gerekir.
    //sqllife programından aldığımız kodun "" işaretlerini temizledikten sonra
    //Uzun sürecek fonksiyon olduğundan başına await fonksiyonuda async yapıyoruz.
    await db.execute("""
   CREATE TABLE  $_booksTableName (
	$_booksId	INTEGER NOT NULL UNIQUE,
	$_booksName	TEXT NOT NULL,
	$_booksCreationDate	INTEGER,
	PRIMARY KEY($_booksId AUTOINCREMENT)
);
   """);
    await db.execute("""
   CREATE TABLE  $_sectionsTableName (
	$_idSections	INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
	$_bookIdSections	INTEGER NOT NULL,
  $_titleSections	TEXT NOT NULL,
  $_contentsSections	TEXT,
	$_booksCreationDate	TEXT DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY("$_bookIdSections") REFERENCES "$_sectionsTableName"("$_booksId") ON UPDATE CASCADE ON DELETE CASCADE
);
   """);
  }
  // int? number;//Başlangıçta null olsun.
  //Singelton yapmaya neden ihityaç duyuyoruz.
  // Matematik m1 = Matematik();
  // Matematik m2 = Matematik();
  //Benim burada kullandığım pi sayısı ikisindede aynı bu sebeple iki tane nesne oluşturmaya gerek yok Matematip.pi şeklinde çağırmıştık.
  //Ancaqk veritabanında statik yapamayacağımız nesnelerimiz olacak veritabanında bir nesnesi oluşturacağımda değer atamam gerektiği için statik yapamam.
  //Bu sebeple tek tek üsteki gibi nesne oluşturmak mantıklı olacaktır.

  //Book Crud Operasyonları
  Future<int> createBook(Book book) async {
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //db.insert int id döndüreceğinden ve detayında awit yazdığından await yaparız ve future yaparız.Anında bir int döndürülmediği için future yaptık ve int değer alacağımız için int yazdık.
      return await db.insert(_booksTableName,
          book.toMap()); //Book nesnesi book türünde benden map istiyor book sınıfının içinde işlemler yapılır bunun için;
    } else {
      //Nullsada bir değer döndürmen lazım. id -1 olamayacağından hata var demek ve değer döndüremeyecek demektir.
      return -1;
    }
  }

  //Read
  Future<List<Book>> readAllBooks() async {
    Database? db = await _dataBaseBring();
    //b yi listeye ekleme işlemi
    List<Book> books = [];
    if (db != null) {
      //Map Türünde liste döndürecek.
      List<Map<String, dynamic>> booksMap = await db.query(
          _booksTableName); //Bu kitapları tek tek gezip map türünden kitap nesnesine çevireceğim.
      for (Map<String, dynamic> m in booksMap) {
        //m ismini verdiğim map kitaba çevireceğim.
        Book b = Book.fromMap(m);
        //Kitap ekleme
        books.add(b);
      }
    }
    return books;
  }

  //Update İşlemi
  Future<int> updateBook(Book book) async {
    //Update kitap kaç tane satırda güncelleme yaptığımızı döndürecek.
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //idsi ? işaretine eşit olanı güncelle.
      return await db.update(
        _booksTableName, book.toMap(), where: "$_booksId = ? ",
        whereArgs: [
          book.id
        ], //Kitap güncellenmiş olsada idsi aynı değişmeyecek.
      );
    } else {
      return 0; //Sıfır satır güncellenme
    }
  }

  //Silme İşlemi
  Future<int> deleteBook(Book book) async {
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //Silinen satır sayısını döndürecek.
      return await db.delete(
        _booksTableName,
        //Alttaki 2 parametre olmazsa bütün kitaplar silinir.
        where: "$_booksId = ?",
        whereArgs: [book.id],
      );
    } else {
      //Hiçbir satır silinmeyeceği için 0 döndürüyoruz.
      return 0;
    }
  }

  //Section Crud Operasyonları
  Future<int> createSection(Section section) async {
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //db.insert int id döndüreceğinden ve detayında awit yazdığından await yaparız ve future yaparız.Anında bir int döndürülmediği için future yaptık ve int değer alacağımız için int yazdık.
      return await db.insert(
          _sectionsTableName,
          section
              .toMap()); //Book nesnesi book türünde benden map istiyor book sınıfının içinde işlemler yapılır bunun için;
    } else {
      //Nullsada bir değer döndürmen lazım. id -1 olamayacağından hata var demek ve değer döndüremeyecek demektir.
      return -1;
    }
  }

  //Read
  Future<List<Section>> readAllSection(int bookId) async {
    Database? db = await _dataBaseBring();
    //b yi listeye ekleme işlemi
    List<Section> sections = [];
    if (db != null) {
      //Map Türünde liste döndürecek.
      List<Map<String, dynamic>> sectionsMap = await db.query(
        _sectionsTableName,
        //Üst kısımda int books yazdığımızdan şu olan verileri getir demek için alttaki kodu ekliyoruz.
        where: "$_bookIdSections = ?",
        whereArgs: [bookId],
      ); //Bu kitapları tek tek gezip map türünden kitap nesnesine çevireceğim.
      for (Map<String, dynamic> m in sectionsMap) {
        //m ismini verdiğim map kitaba çevireceğim.
        Section s = Section.fromMap(m);
        //Kitap ekleme
        sections.add(s);
      }
    }
    return sections;
  }

  //Update İşlemi
  Future<int> updateSection(Section section) async {
    //Update kitap kaç tane satırda güncelleme yaptığımızı döndürecek.
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //idsi ? işaretine eşit olanı güncelle.
      return await db.update(
        _sectionsTableName, section.toMap(), where: "$_idSections = ? ",
        whereArgs: [
          section.id
        ], //Kitap güncellenmiş olsada idsi aynı değişmeyecek.
      );
    } else {
      return 0; //Sıfır satır güncellenme
    }
  }

  //Silme İşlemi
  Future<int> deleteSection(Section section) async {
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null) {
      //Silinen satır sayısını döndürecek.
      return await db.delete(
        _sectionsTableName,
        //Alttaki 2 parametre olmazsa bütün kitaplar silinir.
        where: "$_idSections = ?",
        whereArgs: [section.id],
      );
    } else {
      //Hiçbir satır silinmeyeceği için 0 döndürüyoruz.
      return 0;
    }
  }
}
