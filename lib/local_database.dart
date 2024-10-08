//Ben sql kodlarımı sadece bu sınıfın içerisinde yapacağım.
//Modeller belirli bir sınıfa ayit nesneleri tek bir çatı altına toplamak içinde kullanılır.

import 'dart:async';
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
  String _categoryBooks = "category";

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
      $_idSections INTEGER PRIMARY KEY AUTOINCREMENT,
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
    //Burayı boş bırakarak bunu istenilen her projede kullanabiliriz.
    // //Veri tabanında bir güncelleme yapmasını istediğimizde kullanırız.
    // //Yeni veri eklemek istediğimizde bu kodu eklememiz gerekir ancak bunu her eklediğimizde versiyonu bir arttırmalıyız.
    // //Bunun sebebi versiyon yükselttiğimizde updateApplication fonksiyonu çalışıyor.
    // //Ancak kategori ekleme kısmıda tekrar çalıştığından farklı bir yöntem kullanmamız gerekir.
    // "ALTER TABLE $_booksTableName ADD COLUMN $_categoryBooks INTEGER DEFAULT 0",
    // "ALTER TABLE $_booksTableName ADD COLUMN test INTEGER DEFAULT 0",
    //Yeni komutları buraya ekleyeceğiz.

    //Buradada üstteki liste için for döngüsü oluşturuyoruz.
    // for(int i=oldVersion-1; i<newVersion-1; i++){
    for (int i = oldVersion - 1; i < newVersion - 1; i++) {
      //Yani listenin birinci elemanı çalışacak Burda listede
      //hangisini çalıştırmak istiyorsak onu çalıştırabiliriz.
      await db.execute(updateCommands[i]);
    }
    //Eski versiyon kullanıcı en son cihazında hangi versiyon ile çalıştığıdır.
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
      return await db.insert(
          _booksTableName,
          _bookToMap(
              book)); //Book nesnesi book türünde benden map istiyor book sınıfının içinde işlemler yapılır bunun için;
    } else {
      //Nullsada bir değer döndürmen lazım. id -1 olamayacağından hata var demek ve değer döndüremeyecek demektir.
      return -1;
    }
  }

//Filtreleme için değişikliklerimizi burada yapıyoruz.
  //Read
  Future<List<Book>> readAllBooks(int categoryId, int lastBookId) async {
    Database? db = await _dataBaseBring();
    //b yi listeye ekleme işlemi
    List<Book> books = [];
    if (db != null) {
      //Where string
      String filter = "$_booksId > ?"; //Filter başlangıçta null olsun.
      //WhereArgs Liste
      List<dynamic> filterArguments = [lastBookId];

      //Dart ve && sqlde ve and demektir.
      //Dartta veya || sqlde or demektir.
      if (categoryId >= 0) {
        //0dan büyük olduğu kısımlarda bu çalışmaz
        // filter =
        //     "$_categoryBooks = ? and $_booksId > ? and $_booksId <= ?"; //Andde bir koşula uymazsa bir diğerine mutlaka uyması gerekir.
        // //Üstteki soru işaretlerinin değerlerinide burada veriyorum.
        // filterArguments.add(categoryId);
        // filterArguments.add(2); //Buda ikiden büyük olanları getir demek.
        // filterArguments.add(5);
        // // //Sayıya göre filtreleme
        // // filter = "$_booksId = ?";
        // // filterArguments.add(3);

        // //Eğer or kullanırsak;
        // filter = "$_categoryBooks = ? or $_booksId > ?";
        // filterArguments.add(categoryId);
        // filterArguments.add(2);
        //Bu durumdada iki hariç olanları listeler.

        filter += " and $_categoryBooks = ?";
        filterArguments.add(categoryId);
      }
      //Map Türünde liste döndürecek.
      List<Map<String, dynamic>> booksMap = await db.query(
        _booksTableName, //Bu kitapları tek tek gezip map türünden kitap nesnesine çevireceğim.
        //Filtreleme işlemi;
        where: filter, //Burada üst kısımda oluşturduğumuz değerleri veriyoruz.
        whereArgs:
            filterArguments, //Burada üst kısımda oluşturduğumuz değerleri veriyoruz.
        //Verileri Alfabeye göre sıralama;
        // orderBy: _booksName,//Kitap isimlerine gmre sıralamasını istiyorum.Başka bir şekilde sıralamak istediğimizde onu çağırarak yapabilir mesela _booksId...
        // orderBy: "$_booksId desc" //Büyükten küçüğe göre id göre sıralama.
        //Kategori sıralamasına göre sıralama

        // orderBy: "$_categoryBooks desc, $_booksName asc",//Kategori sıralamasına göre alfabetik olarak sıralama.
        //desc büyükten küçüğe, asc küçükten büyüğe asc yazmayada gerek yok çünkü veriler varsayılan olarak küçükten büyüğe sıralanır.

        // orderBy: "$_booksName collate localized",//Türkçe karakterleride sıralamada gösterme en altta gözükmesini engelleme.Yerel sıralama yap demek.

        orderBy:
            "$_booksId ", //Flutterda türkçe karaktere göre sıralama nasıl yapılıyor.
        limit: 15,
        // //Databasese kayıtlı verilerin istediğimiz kadarını çekme;
        // limit: 4,//4 veri çekilecek.//Kategori seçimi yaparsak seçtiğimiz verideki 4 veriyi getirir.

        // //Son kayıt edilen kitabı getirmek.
        // orderBy: "$_booksId desc",
        // limit: 1,

        // // //es geçmek istediğimiz veri sayısı;
        // offset: 2,//İlk 2 veriyi getirme demek.
      );
      // //Bütün kitaplar getirilsin demek
      //  List<Map<String, dynamic>> booksMap = await db.query(
      //   _booksTableName, //Bu kitapları tek tek gezip map türünden kitap nesnesine çevireceğim.
      // );
      for (Map<String, dynamic> m in booksMap) {
        //m ismini verdiğim map kitaba çevireceğim.
        Book b = _mapToBook(m);
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
        _booksTableName, _bookToMap(book), where: "$_booksId = ? ",
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

  //Kitapları Silme İşlemi
  Future<int> deleteBooks(List<int> booksId) async {
    //Siliceğimiz kitapların idsinden oluşan değerleri alacak.
    Database? db = await _dataBaseBring();
    //Database nul olduğu için Null olup olmadığını kontrol etme işlemi;
    if (db != null && booksId.isNotEmpty) {
      //db null değil ve kitap id listesi boş değilse yap bu işlemi diyoruz.
      //Silinen satır sayısını döndürecek.

      String filter =
          "$_booksId in ("; //Başlangıç kısmına $_booksId in bu kısmıda ekliyorum.

      for (int i = 0; i < booksId.length; i++) {
        //son elemanı bulmamız gerekecek.
        if (i != booksId.length - 1) {
          //i != booksId.length -1 son eleman kontrolü
          filter += "?,";
        } else {
          filter += "?)";
        }
        //Üst kısımda bu where: "$_booksId in (?, ?, ?, ?)",işlemi yapıyoruz.
      }

      return await db.delete(
        _booksTableName,
        //Alttaki 2 parametre olmazsa bütün kitaplar silinir.
        where: filter,
        // where: "$_booksId in (?, ?, ?, ?)", //Silmek istediklerimiz için bunu yapabilirz ama bu çok fazla veri olduğunda doğru bir kullanım olmaz.
        //Bu nedenle bunu başka türlü halletmeliyiz.
        whereArgs:
            booksId, //deletebooks () içerisindeki listenin adını buraya yazıyoruz.
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

//Ortak fonksiyon
  Map<String, dynamic?> _bookToMap(Book book) {
    Map<String, dynamic> bookMap = book.toMap();
    DateTime? creationDate = bookMap["creationDate"];
    if (creationDate != null) {
      bookMap["creationDate"] = creationDate.millisecondsSinceEpoch;
    }
    return bookMap;
  }
//Model katmanını servis katmanından ayırmış olduk
  Book _mapToBook(Map<String, dynamic> m) {
    int? creationDate = m["creationDate"];
    if (creationDate != null) {
      m["creationDate"] = DateTime.fromMillisecondsSinceEpoch(creationDate);
    }
    return Book.fromMap(m);
  }
}
//Listenin son elemanı herzaman listeninuzunluğu -1 elemandır.

//Verileri öbek öbek bölüm bölüm çekmeye sayfala denir. Ekrana sığacak kadar olan veriler çekilir hepsini çektiğimizde uygulamada sıkıntı yaşarız.
