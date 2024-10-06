import 'package:flutter/material.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/view/section_detail_page.dart';
import '../local_database.dart';
import '../model/section.dart';

class SectionsPage extends StatefulWidget {
  final Book _book;

  const SectionsPage(this._book, {super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  //Yerel veri tabanı türünden nesne oluşturuyoruz.
  LocalDataBase _localDataBase = LocalDataBase();

  //Okuduğumuz listeyi sınıf değişkenine atama işlemi;
  List<Section> _sections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildSectionAddFab(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text(widget._book.name),
    );
  }

  //body
  Widget _buildBody() {
    //Future builder init state de kullanabilirdik ama ona alternatif olarak kullandık.
    //Future atadığım işlem bitinde builde atadığım fonksiyonu döndürüyor yani ekrana döndürüyor.
    return FutureBuilder(future: _bringAllSections(), builder: _buildListView);
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return ListView.builder(
      itemCount: _sections.length,
      itemBuilder: _buildListItem,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_sections[index].id.toString()),
      ),
      //Rowla direk sardığımızda row bütün satırı kaplar.
      trailing: Row(
        //Rowun tüm satırı kaplamasını engellemek için yapılır.
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                _sectionUpdate(context, index);
              },
              icon: Icon(Icons.edit)),
          IconButton(
              //Biz 4 kitabı sildiğimizde kitap eklediğimizde sildiğimiz veri id yerine hiç bir zaman bir eklenmez sayı en sonda olduğı sayıdan devam eder.
              onPressed: () {
                _sectionDelete(index);
              },
              icon: Icon(Icons.delete))
        ],
      ),
      title: Text(_sections[index].title),
      onTap: () {
        _sectionDetailPageOpen(context, index);
      },
    );
  }

//floating Action Button = Fab
  Widget _buildSectionAddFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _sectionAdd(context);
      },
      child: Icon(Icons.add),
    );
  }

  //Kitap ekleme
  void _sectionAdd(BuildContext context) async {
    //Onayla butonunun döndürdüğü değeri kullanma
    //Open window future döndürdüğü için await async kullanılır.
    //Pencere ne zaman kapanırsa String değer o zaman dönecek.
    String? sectionTitle = await _openWindow(context);

    int? idBook = widget._book.id;

    //Pencere kapandığında dönen değeri al
    // print(bookName ?? "Null Döndü");//Ktap adı yoksa konsolda null döndü yazdır.//Burada kontrol yaptık.
    if (sectionTitle != null && idBook != null) {
      //kitapadı null değilse yeni bir kitap oluşturalım.
      Section newSection = Section(idBook,
          sectionTitle); //Datetime.now kitabın eklendiği tarihi bize verir.
      //Oluşturulan nesneyi veri tabanına değer olarak verilme işlemi; Döndüreceği id kullanıyoruz.
      int sectionId = await _localDataBase.createSection(newSection);
      print("Bölüm id: $sectionId");

      //Veri ekleme işleminden sonra sayfanın veri eklendiğinde güncellenmesi için setstate çağırıyoruz.Artık floatin button eklediğimiz direk güncellenecek.

      setState(() {});
    }
  }

  //Kitapları Güncelleme//Open contextini ve update için indexti aldık.
  void _sectionUpdate(BuildContext context, int index) async {
    String? newSectionTitle = await _openWindow(context);
    if (newSectionTitle != null) {
      Section section = _sections[index];
      section.title = newSectionTitle;
      await _localDataBase.updateSection(section);
      await _bringAllSections(); // Tüm bölümleri yeniden al
      setState(() {});
    }
  }

  void _sectionDelete(int index) async {
    Section section = _sections[index];
    await _localDataBase.deleteSection(section);
    await _bringAllSections(); // Tüm bölümleri yeniden al
    setState(() {});
  }

  //   if (newSectionTitle != null) {
  //     Section section = _sections[index]; //Önce eski kitabı listeden alacak.
  //     section.title = newSectionTitle; //İsmi yeni kitap adıyla değiştireceğiz.
  //     //Ve bunu yerel kitap ağının update fonksiyonuna göndereceğim.
  //     int numberOfRowsUpdated = await _localDataBase.updateSection(section);
  //     //Güncellenen satır sayısı 0dan büyük değilse;
  //     if (numberOfRowsUpdated > 0) {
  //       setState(() {});
  //     }
  //   }
  // }

  // //Kitapları silme fonksiyonu
  // void _sectionDelete(int index) async {
  //   //Listeden kitabı alma işlemi
  //   Section section = _sections[index];
  //   //Yerel kitao ağına silme fonksiyonunu gönderecek.
  //   int numberOfDeletedRows = await _localDataBase.deleteSection(section);
  //   if (numberOfDeletedRows > 0) {
  //     setState(() {});
  //   }
  // }

  //Tüm kitapları getirme fonksiyonu
  Future<void> _bringAllSections() async {
    //readAllSection() bu benden kitap id istiyor bu sebeple alttaki işlemi yapıyoruz.
    int? bookId = widget._book.id;

    if (bookId != null) {
      _sections = await _localDataBase.readAllSection(bookId);
    }
  }

  //+ butonuna tıklandığında pencere açma
  Future<String?> _openWindow(BuildContext context) {
    //Diolog açıyor.Show dialog future string null değer döndürür.
    return showDialog<String>(
      context: context,
      builder: (context) {
        //TextFieldın içerisine girilen değeri döndürmek
        String? conclusion;
        //Widget döndürecek
        //Alert dialog arka sayfayı kapatmaz yarı saydam bir görüntü verir.
        return AlertDialog(
          title: Text("Bölüm Adını Giriniz"),
          content: TextField(
            onChanged: (newValue) {
              //Yeni değeri sonuç değişkenine atama işlemi
              conclusion = newValue;
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
                Navigator.pop(context, conclusion);
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
  void _sectionDetailPageOpen(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(builder: (context) {
      return SectionDetailPage(_sections[index]);
    });
    Navigator.push(context, pageRoute);
  }
}
