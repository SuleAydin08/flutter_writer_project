import 'package:flutter/material.dart';
import 'package:flutter_writer_project/local_database.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/repository/database_repository.dart';
import 'package:flutter_writer_project/tools/locator.dart';
import 'package:flutter_writer_project/view/section_detail_page.dart';
import 'package:flutter_writer_project/view_model/sections_detail_view_model.dart';
import 'package:provider/provider.dart';

class SectionsViewModel with ChangeNotifier{

  DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  //Okuduğumuz listeyi sınıf değişkenine atama işlemi;
  List<Section> _sections = [];
  
  List<Section> get sections => _sections;

  final Book _book;

  Book get book => _book;


  SectionsViewModel(this._book){
    WidgetsBinding.instance.addPostFrameCallback((_){
      _bringAllSections();
    });
  }
  
  //Kitap ekleme
  void sectionAdd(BuildContext context) async {
    //Onayla butonunun döndürdüğü değeri kullanma
    //Open window future döndürdüğü için await async kullanılır.
    //Pencere ne zaman kapanırsa String değer o zaman dönecek.
    String? sectionTitle = await _openWindow(context);

    int? idBook = _book.id;

    //Pencere kapandığında dönen değeri al
    // print(bookName ?? "Null Döndü");//Ktap adı yoksa konsolda null döndü yazdır.//Burada kontrol yaptık.
    if (sectionTitle != null && idBook != null) {
      //kitapadı null değilse yeni bir kitap oluşturalım.
      Section newSection = Section(idBook,
          sectionTitle); //Datetime.now kitabın eklendiği tarihi bize verir.
      //Oluşturulan nesneyi veri tabanına değer olarak verilme işlemi; Döndüreceği id kullanıyoruz.
      int sectionId = await _databaseRepository.createSection(newSection);
      newSection.id =sectionId;
      print("Bölüm id: $sectionId");
      _sections.add(newSection);
      notifyListeners();
    }
  }

  //Kitapları Güncelleme//Open contextini ve update için indexti aldık.
  void sectionUpdate(BuildContext context, int index) async {
    String? newTitle = await _openWindow(context);
    if (newTitle != null) {
      Section section = _sections[index];
      section.update(newTitle);
      int numberOfUpdatedRows = await _databaseRepository.updateSection(section);
      if(numberOfUpdatedRows > 0){
      }
    }
  }

  void sectionDelete(int index) async {
    Section section = _sections[index];
    int numberOfDeletedRows = await _databaseRepository.deleteSection(section);
    if(numberOfDeletedRows > 0){
      _sections.removeAt(index);
      notifyListeners();
    }
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
    int? bookId = _book.id;

    if (bookId != null) {
      _sections = await _databaseRepository.readAllSection(bookId);
      notifyListeners();
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
  void sectionDetailPageOpen(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider(create: (context) => SectionsDetailViewModel(_sections[index]),child: SectionDetailPage(),);
    });
    Navigator.push(context, pageRoute);
  }
}