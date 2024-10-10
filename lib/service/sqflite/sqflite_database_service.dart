import 'package:flutter_writer_project/base/database_base.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/service/base/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteDatabaseService implements DatabaseService {
  //Veri tabanı nesnesi
  Database?
      _dataBase; //Başlangıçta null olucak. Bu veri tabanına bir nesne eklerken bu nesneyi kullanacağım.Bu nesneyi doğrudan kullanmayız.

//VEri tabanından gelen değerlerin türünü burada yazıyorum.
  String _booksTableName = "books";
  String _booksId = "id";
  String _booksName = "name";
  String _booksCreationDate = "creationDate";
  String _categoryBooks = "category";

//Section veritabanına gelen değerlerin türü
  String _sectionsTableName = "section";
  String _idSections = "id";
  String _bookIdSections = "bookId";
  String _titleSections = "title";
  String _contentsSections = "contents";
  String _creationDateSections = "creationDate";

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
        //Onupgrade çalışması için versiyonun değişmesi gerekir.
        version: 3,
        //Tablo oluşturacağım fonksiyonu yazarım buraya,
        //Tablo oluşturma kısmı veri tabanını ilk kez oluşturduğumuzda çalıştığı için bölümler sayfasında fab basarak değer girdiğimizde çalışmadı.
        //oncreat parametresi oluşturulduğunda demektir.
        //Veri tabanı hali hazırda oluştuğu zaman bşuna on create çlışmıyor.
        onCreate: _createTable,
        onUpgrade: _updateApplication,
      ); //Future döndürdüğünden bunu veri tabanı nesneme atıyorum ve awaiti unutmuyorum.
    }
    return _dataBase;
  }

  Future<void> _createTable(Database db, int version) async {
    //sqfliteda doğrudan tablo oluştur fonksiyonu yok bu sebeple burada sql kodu oluşturmamız gerekir.
    //sqllife programından aldığımız kodun "" işaretlerini temizledikten sonra
    //Uzun sürecek fonksiyon olduğundan başına await fonksiyonuda async yapıyoruz.
    await db.execute("""
    CREATE TABLE $_booksTableName (
      $_booksId INTEGER PRIMARY KEY AUTOINCREMENT,
      $_booksName TEXT NOT NULL,
      $_booksCreationDate INTEGER,
      $_categoryBooks INTEGER DEFAULT 0
    );
  """);
    await db.execute("""
    CREATE TABLE $_sectionsTableName (
      $_idSections INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
      $_bookIdSections INTEGER NOT NULL,
      $_titleSections TEXT NOT NULL,
      $_contentsSections TEXT,
      $_booksCreationDate TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY($_bookIdSections) REFERENCES $_booksTableName($_booksId) ON UPDATE CASCADE ON DELETE CASCADE
    );
  """);
  }

  Future<void> _updateApplication(
      Database db, int oldVersion, int newVersion) async {
    List<String> updateCommands = [];

    for (int i = oldVersion - 1; i < newVersion - 1; i++) {
      await db.execute(updateCommands[i]);
    }
  }

  @override
  Future createBook(Book book) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.insert(_booksTableName, _bookToMap(book));
    } else {
      return -1;
    }
  }

  @override
  Future<List<Book>> readAllBooks(int categoryId, lastBookId) async {
    Database? db = await _dataBaseBring();

    List<Book> books = [];
    if (db != null) {
      String filter = "$_booksId > ?";

      List<dynamic> filterArguments = [lastBookId];

      if (categoryId >= 0) {
        filter += " and $_categoryBooks = ?";
        filterArguments.add(categoryId);
      }

      List<Map<String, dynamic>> booksMap = await db.query(
        _booksTableName,
        where: filter,
        whereArgs: filterArguments,
        orderBy: "$_booksId ",
        limit: 15,
      );

      for (Map<String, dynamic> m in booksMap) {
        Book b = _mapToBook(m);

        books.add(b);
      }
    }
    return books;
  }

  @override
  Future<int> updateBook(Book book) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.update(
        _booksTableName,
        _bookToMap(book),
        where: "$_booksId = ? ",
        whereArgs: [book.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteBook(Book book) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.delete(
        _booksTableName,
        where: "$_booksId = ?",
        whereArgs: [book.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteBooks(List booksId) async {
    Database? db = await _dataBaseBring();

    if (db != null && booksId.isNotEmpty) {
      String filter = "$_booksId in (";

      for (int i = 0; i < booksId.length; i++) {
        if (i != booksId.length - 1) {
          filter += "?,";
        } else {
          filter += "?)";
        }
      }

      return await db.delete(
        _booksTableName,
        where: filter,
        whereArgs: booksId,
      );
    } else {
      return 0;
    }
  }

  @override
  Future createSection(Section section) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.insert(_sectionsTableName, section.toMap());
    } else {
      return -1;
    }
  }

  @override
  Future<List<Section>> readAllSection(bookId) async {
    Database? db = await _dataBaseBring();

    List<Section> sections = [];
    if (db != null) {
      List<Map<String, dynamic>> sectionsMap = await db.query(
        _sectionsTableName,
        where: "$_bookIdSections = ?",
        whereArgs: [bookId],
      );
      for (Map<String, dynamic> m in sectionsMap) {
        Section s = Section.fromMap(m);

        sections.add(s);
      }
    }
    return sections;
  }

  @override
  Future<int> updateSection(Section section) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.update(
        _sectionsTableName,
        section.toMap(),
        where: "$_idSections = ? ",
        whereArgs: [section.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteSection(Section section) async {
    Database? db = await _dataBaseBring();

    if (db != null) {
      return await db.delete(
        _sectionsTableName,
        where: "$_idSections = ?",
        whereArgs: [section.id],
      );
    } else {
      return 0;
    }
  }

  //Ortak fonksiyon
  Map<String, dynamic> _bookToMap(Book book) {
    Map<String, dynamic> bookMap = {
      "id": book.id,
      "name": book.name,
      // Diğer alanlar...
    };

    if (book.creationDate != null) {
      bookMap["creationDate"] =
          book.creationDate!.millisecondsSinceEpoch; // int olarak sakla
    } else {
      bookMap["creationDate"] = null; // null olursa null sakla
    }

    return bookMap;
  }

//Model katmanını servis katmanından ayırmış olduk
  Book _mapToBook(Map<String, dynamic> m) {
    Map<String, dynamic> bookMap = Map.from(m);
    int? creationDate = bookMap["creationDate"];
    if (creationDate != null) {
      bookMap["creationDate"] =
          DateTime.fromMillisecondsSinceEpoch(creationDate);
    }
    return Book.fromMap(bookMap);
  }
}
