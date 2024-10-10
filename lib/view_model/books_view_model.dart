import 'package:flutter/material.dart';
import 'package:flutter_writer_project/constants.dart';
import 'package:flutter_writer_project/local_database.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/view/sections_page.dart';
import 'package:flutter_writer_project/view_model/sections_view_model.dart';
import 'package:provider/provider.dart';

//Uygulamanın işleyişi ile ilgili olan fonksiyonlarda view model katmanı ile ilgilidir.Her viewım bir view modeli olmalıdır.

class BooksViewModel with ChangeNotifier {
  //Yerel veri tabanı türünden nesne oluşturuyoruz.
  LocalDataBase _localDataBase = LocalDataBase();

  ScrollController _scrollController = ScrollController();
  //Scrool controller için getter oluşturacağım.
  ScrollController get scrollController => _scrollController;

  //Okuduğumuz listeyi sınıf değişkenine atama işlemi;
  List<Book> _books = [];

  //Kitaplar listesinin getiri;
  List<Book> get books => _books;

  //Tüm kategorileri görüntüleme işlemi
  List<int> _allCategories = [
    -1
  ]; //Sıfırdan önceki -1 ise bütün kategorileri oluşturmasın demek istiyorum.-1 hiç bir kategoriye verilmeyecek.

  List<int> get allCategories => _allCategories;

  int _selectedCategory = -1; //Seçilen kategori defaultda -1dir yani hepsidir.

  int get selectedCategory => _selectedCategory;

  set selectedCategory(int value) {
    _selectedCategory = value;
    notifyListeners();
  }

  //in anahtar kelimesini mesela verilerin hepsini silmekı istiyoruz checkbox yardımıyla ve in anahtar kelimesi ile bunu kolaylıkla yapabiliriz.
  List<int> _selectedBookId = [];

  List<int> get selectedBookId => _selectedBookId;

  BooksViewModel() {
    //addAll bir liste alır ve verdiğim tüm öğeleri bu listeye ekler.
    _allCategories.addAll(Constants.categories.keys);
    _scrollController.addListener(_scrollControl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bringTheFirstBooks();
    });
  }

  //Kitap ekleme
  //Burada for döngüsü ile 100 tane veri ekleyeceğiz.
  void bookAdd(BuildContext context) async {
    //Onayla butonunun döndürdüğü değeri kullanma
    //Open window future döndürdüğü için await async kullanılır.
    //Pencere ne zaman kapanırsa String değer o zaman dönecek.
    List<dynamic>? conclusion = await _openWindow(context);

    //Kontrol etmesonuç null değilse ve sonuçların kadar.
    if (conclusion != null && conclusion.length > 1) {
      String bookName = conclusion[0];
      int category = conclusion[1];
      Book newBook = Book(bookName, DateTime.now(),
          category); //Datetime.now kitabın eklendiği tarihi bize verir.
      //Oluşturulan nesneyi veri tabanına değer olarak verilme işlemi; Döndüreceği id kullanıyoruz.
      int bookId = await _localDataBase.createBook(newBook);
      newBook.id = bookId;
      print("Book id: $bookId");
      _books.add(newBook);
      notifyListeners();
      // _books = [];
      // //Veri ekleme işleminden sonra sayfanın veri eklendiğinde güncellenmesi için setstate çağırıyoruz.Artık floatin button eklediğimiz direk güncellenecek.
      // // setState(() {});
    }

    //100 tane veri ekleme işlemi;
    // for (int i = 1; i <= 100; i++) {
    //   Book newBook = Book(i.toString(), DateTime.now(), 0);
    //   int bookId = await _localDataBase.createBook(newBook);
    // }
    // setState(() {});

    // //Pencere kapandığında dönen değeri al
    // // print(bookName ?? "Null Döndü");//Ktap adı yoksa konsolda null döndü yazdır.//Burada kontrol yaptık.

    // if (bookName != null) {
    //   //kitapadı null değilse yeni bir kitap oluşturalım.
    //   Book newBook = Book(bookName,
    //       DateTime.now()); //Datetime.now kitabın eklendiği tarihi bize verir.
    //   //Oluşturulan nesneyi veri tabanına değer olarak verilme işlemi; Döndüreceği id kullanıyoruz.
    //   int bookId = await _localDataBase.createBook(newBook);
    //   print("Book id: $bookId");

    //   //Veri ekleme işleminden sonra sayfanın veri eklendiğinde güncellenmesi için setstate çağırıyoruz.Artık floatin button eklediğimiz direk güncellenecek.
    //   setState(() {});
    // }
  }

  //Kitapları Güncelleme//Open contextini ve update için indexti aldık.
  void bookUpdate(BuildContext context, int index) async {
    Book book = _books[index];
    List<dynamic>? conclusion = await _openWindow(context,
        availableName: book.name, availableCategory: book.category);

    if (conclusion != null && conclusion.length > 1) {
      String newBookName = conclusion[0];
      int newCategory = conclusion[1];
      //İkiside aynıysa veri tabanı işlemi yapmaya gerek yok bu sebeple buraya girilmeyecek.
      if (book.name != newBookName || book.category != newCategory) {
        book.update(newBookName, newCategory); //Listedeki elemanı güncelleme

        //Ve bunu yerel kitap ağının update fonksiyonuna göndereceğim.
        int numberOfRowsUpdated = await _localDataBase.updateBook(book);
        //Güncellenen satır sayısı 0dan büyük değilse;
        if (numberOfRowsUpdated > 0) {}
      }
    }
  }

  //Kitapları silme fonksiyonu
  void bookDelete(int index) async {
    //Listeden kitabı alma işlemi
    Book book = _books[index];
    //Yerel kitao ağına silme fonksiyonunu gönderecek.
    int numberOfDeletedRows = await _localDataBase.deleteBook(book);
    if (numberOfDeletedRows > 0) {
      _books.removeAt(index);
      notifyListeners();
    }
  }

  //Seçilen kitapları silmek için oluşturulan fonksiyon
  void selectedBookDelete() async {
    //Book book = _books[index]; bu kısıma ihtiyaç yok çünkü belirli indexteki kitapları silmiyoruz.
    //Yerel kitao ağına silme fonksiyonunu gönderecek.
    int numberOfDeletedRows = await _localDataBase.deleteBooks(_selectedBookId);
    if (numberOfDeletedRows > 0) {
      //Anlık olarak güncelleyerek verileri silmesi için boş liste ekledim.
      _books.removeWhere((book) => _selectedBookId.contains(book.id));
      notifyListeners();
    }
  }

  Future<void> _bringTheFirstBooks() async {
    if (_books.isEmpty) {
      _books = await _localDataBase.readAllBooks(_selectedCategory, 0);
      print("İlk kitaplar");
      for (Book b in _books) {
        print("${b.name}, ");
      }
      notifyListeners();
    }
  }

  Future<void> _bringTheLastBooks() async {
    int? lastBookId = _books.last.id;

    if (lastBookId != null) {
      List<Book> lastBooks =
          await _localDataBase.readAllBooks(_selectedCategory, lastBookId);
      _books.addAll(lastBooks);
      print("Sonraki kitaplar");
      for (Book b in _books) {
        print("${b.name}, ");
      }
      notifyListeners();
    }
  }

  //Tüm kitapları getirme fonksiyonu
  // Future<void> _bringAllBooks() async {
  //   _books = await _localDataBase.readAllBooks(
  //       _selectedCategory); //Seçilen kategoriye göre listelemeyi sağlayacak.
  // }

  //+ butonuna tıklandığında pencere açma
  //Altta sonuç ve kategoy olduğu için artık liste olara geleceği için String değil listedir.Strink ve int aldığımızdan
  Future<List<dynamic>?> _openWindow(
    BuildContext context, {
    String availableName = "",
    int availableCategory = 0,
  }) {
    //Burada zorunlu olmayan parametre alacağız.
    TextEditingController nameController =
        TextEditingController(text: availableName);

    //Diolog açıyor.Show dialog future string null değer döndürür.
    return showDialog<List<dynamic>?>(
      //Üst kısımda liste gönderdiği içim
      context: context,
      builder: (context) {
        // //TextFieldın içerisine girilen değeri döndürmek
        // String? conclusion;
        int category = availableCategory;
        //Widget döndürecek
        //Alert dialog arka sayfayı kapatmaz yarı saydam bir görüntü verir.
        return AlertDialog(
          title: Text("Kitap Adını Giriniz"),
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Column(
                //Column boş bıraktığımız için çok yer kaplamış bu sebeple
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    // onChanged: (newValue) {
                    //   //Yeni değeri sonuç değişkenine atama işlemi
                    //   conclusion = newValue;
                    // },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  //Category seçme dropdownı.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kategori: "),
                      DropdownButton<int>(
                        items: Constants.categories.keys.map((categoryId) {
                          //Categoy key gezip atama işlemi yapılıyor.
                          return DropdownMenuItem<int>(
                            value: categoryId,
                            child: Text(
                              Constants.categories[categoryId] ?? "",
                            ),
                          );
                        }).toList(),
                        //Değer değiştiğinde değer yani fonksiyon atanır.
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              //Yeni değer null değilse categorydeki değeri yeni değere ata demek.
                              category =
                                  newValue; //Burada yaptığımız işleme rağmen sayfada seçtiğimiz değer gelmedi bunun sebebi burda
                              //kullandığımız setstate BooksPage sayfasınındır çünkü dialog her ne kadar o sayfada açılmış gibi gözüksede ayrı sayfadır.
                              //Yani dialogun ayrı bir stateti olması gerekir.
                              //O halde burda ne yapacağız biz üst ksıımda yaptığımız columnı ayrı bir widget olarak tanımlayıp bu sayfada content
                              //içerisinde onu çağırabiliriz.Ama biz buu önceki projelerde yaptığımız için farklı bir yöntem ile yapacağız.
                            });
                          }
                        },
                        // //Bu kategori bilgisidir.
                        value: category,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                //AlertDialoğu kapatma
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                //AlertDialoğu kapatma
                //TextFieldın içerisine yazılan değeri geri döndürme işlemi yani onaylaya tıkladığımızda
                //sonuç değişkeninin değerini döndüreceğiz.
                Navigator.pop(context, [
                  nameController.text.trim(),
                  category
                ]); //Artık 2 değerimiz olduğu için iki değer yaotım.
              },
              child: Text("Onayla"),
              //Yani iptale tıklandığında geriye null dönecek onaylaya tıkladığımda sonuç dönecek.Textfieldın içerisine değer girilmezse
              //sonuç değişkenine değer atanmaz sonuç yine null döner.
            ),
          ],
        );
      },
    );
  }

  //Bölümler söyfasını açıcak kodu yazıyoruz.
  void sectionPageOpen(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider(
        create: (context) => SectionsViewModel(_books[index]),
        child: SectionsPage(),
      );
    });
    Navigator.push(context, pageRoute);
  }

  void _scrollControl() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      _bringTheLastBooks();
    }
  }
}
