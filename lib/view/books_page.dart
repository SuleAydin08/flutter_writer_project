import 'package:flutter/material.dart';
import 'package:flutter_writer_project/constants.dart';
import 'package:flutter_writer_project/local_database.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/view/sections_page.dart';

class BooksPage extends StatefulWidget {
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  //Yerel veri tabanı türünden nesne oluşturuyoruz.
  LocalDataBase _localDataBase = LocalDataBase();

  //Okuduğumuz listeyi sınıf değişkenine atama işlemi;
  List<Book> _books = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildBookAddFab(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text("Kitaplar Sayfası"),
    );
  }

  //body
  Widget _buildBody() {
    //Future builder init state de kullanabilirdik ama ona alternatif olarak kullandık.
    //Future atadığım işlem bitinde builde atadığım fonksiyonu döndürüyor yani ekrana döndürüyor.
    return FutureBuilder(future: _bringAllBooks(), builder: _buildListView);
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: _buildListItem,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_books[index].id.toString()),
      ),
      //Rowla direk sardığımızda row bütün satırı kaplar.
      trailing: Row(
        //Rowun tüm satırı kaplamasını engellemek için yapılır.
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                _bookUpdate(context, index);
              },
              icon: Icon(Icons.edit)),
          IconButton(
              //Biz 4 kitabı sildiğimizde kitap eklediğimizde sildiğimiz veri id yerine hiç bir zaman bir eklenmez sayı en sonda olduğı sayıdan devam eder.
              onPressed: () {
                _bookDelete(index);
              },
              icon: Icon(Icons.delete))
        ],
      ),
      title: Text(_books[index].name),
      //Kategorileri başlığın altında görüntüleme işlemi.
      subtitle: Text(Constants.categories[_books[index].category] ?? ""),
      onTap: () {
        _sectionPageOpen(context, index);
      },
    );
  }

//floating Action Button = Fab
  Widget _buildBookAddFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _bookAdd(context);
      },
      child: Icon(Icons.add),
    );
  }

  //Kitap ekleme
  void _bookAdd(BuildContext context) async {
    //Onayla butonunun döndürdüğü değeri kullanma
    //Open window future döndürdüğü için await async kullanılır.
    //Pencere ne zaman kapanırsa String değer o zaman dönecek.
    List<dynamic>? conclusion = await _openWindow(context);

    //Kontrol etmesonuç null değilse ve sonuçların kadar.
    if (conclusion != null && conclusion.length > 1) {
      String bookName = conclusion[0];
      int category = conclusion[1];

      //kitapadı null değilse yeni bir kitap oluşturalım.
      Book newBook = Book(bookName, DateTime.now(),
          category); //Datetime.now kitabın eklendiği tarihi bize verir.
      //Oluşturulan nesneyi veri tabanına değer olarak verilme işlemi; Döndüreceği id kullanıyoruz.
      int bookId = await _localDataBase.createBook(newBook);
      print("Book id: $bookId");

      //Veri ekleme işleminden sonra sayfanın veri eklendiğinde güncellenmesi için setstate çağırıyoruz.Artık floatin button eklediğimiz direk güncellenecek.
      setState(() {});
    }
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
  void _bookUpdate(BuildContext context, int index) async {
    Book book = _books[index];
    List<dynamic>? conclusion = await _openWindow(context,
        availableName: book.name, availableCategory: book.category);

    if (conclusion != null && conclusion.length > 1) {
      String newBookName = conclusion[0];
      int newCategory = conclusion[1];
      //İkiside aynıysa veri tabanı işlemi yapmaya gerek yok bu sebeple buraya girilmeyecek.
      if (book.name != newBookName || book.category != newCategory) {
        Book book = _books[index]; //Önce eski kitabı listeden alacak.
        book.name = newBookName; //İsmi yeni kitap adıyla değiştireceğiz.
        //Kategori güncelleme kısmı
        book.category = newCategory;
        //Ve bunu yerel kitap ağının update fonksiyonuna göndereceğim.
        int numberOfRowsUpdated = await _localDataBase.updateBook(book);
        //Güncellenen satır sayısı 0dan büyük değilse;
        if (numberOfRowsUpdated > 0) {
          setState(() {});
        }
      }
    }
  }

  //Kitapları silme fonksiyonu
  void _bookDelete(int index) async {
    //Listeden kitabı alma işlemi
    Book book = _books[index];
    //Yerel kitao ağına silme fonksiyonunu gönderecek.
    int numberOfDeletedRows = await _localDataBase.deleteBook(book);
    if (numberOfDeletedRows > 0) {
      setState(() {});
    }
  }

  //Tüm kitapları getirme fonksiyonu
  Future<void> _bringAllBooks() async {
    _books = await _localDataBase.readAllBooks();
  }

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
                        //Bu kategori bilgisidir.
                        value: category,
                      ),
                    ],
                  )
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
  void _sectionPageOpen(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(builder: (context) {
      return SectionsPage(_books[index]);
    });
    Navigator.push(context, pageRoute);
  }
}
