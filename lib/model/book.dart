class Book {
  //id işlevi veri tabanında her bir öğeyi birbirinden ayırmak.
  //id herkeste farklı olabilecek bir değer olmalıdır.Benzersixz ve değişmez olması gerekir.
  //id int olur ve 1den başlayarak artar.
  dynamic id;//id dynamic yaparak her veri tabanı servisine uyumlu hale getirmiş oluyoruz.
  String name;
  //Datetime dartta tarih ve saati tuttuğumuz yapıdır.
  DateTime creationDate;
  int category;//Categorinin int değerlerini alacağım için int.

  //id biz kendimiz belirlemeyecğimiz için constructerda almıyoruz.Bu sebeple id null yapılırsa sorun çözülür.
  Book(this.name, this.creationDate, this.category);

//Bu mapten kitap nesnemi üreteceğim.
  Book.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        creationDate = DateTime.fromMillisecondsSinceEpoch(map["creationDate"]),
        category = map["category"] ?? 0;

//Map oluşturma ve mapten nesne oluşturma çok yaygın işlemlerdir.Yani toMap ve fromMap çok yaygın işlemlerdir.Çok ihtiyacımız olabilecek bir şey olduğu için model sınıfına koyduk.
  //Mape dönüştürme;toMap adına yapılır.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "creationDate": creationDate
          .millisecondsSinceEpoch,
       //Burada sqlde int ama buradaki sınıfta datetime olduğu için dönüşüm yapmalıyız.
      //millisecondsSinceEpoch mili saniyeye çevirme işlemi yapar.
      "category": category,
    };
  }
}

//Neden sqlite kullanıyoruz neden shared preferences değil?
//       //Shared ile kitabı cihaz hafızasın ekleme;
//       //Kitap 1
//       //Kitap ismi
//       await prefs.setString("kitap1Isim", kitap1.isim);
//       //Yazar
//       await prefs.setString("kitap1Yazar", kitap1.yazar);
//       //Sayfa Sayısı
//       await prefs.setInt("kitap1SayfaSayisi", kitap1.sayfaSayisi);
//       //ilk basım yılı
//       await prefs.setInt("kitap1IlkBasimYili", kitap1.ilkBasimYili);

//       //Kitap 2
//       //Kitap ismi
//       await prefs.setString("kitap2Isim", kitap2.isim);
//       //Yazar
//       await prefs.setString("kitap2Yazar", kitap2.yazar);
//       //Sayfa Sayısı
//       await prefs.setInt("kitap2SayfaSayisi", kitap2.sayfaSayisi);
//       //ilk basım yılı
//       await prefs.setInt("kitap2IlkBasimYili", kitap2.ilkBasimYili);

//       //Kitap 3
//       //Kitap ismi
//       await prefs.setString("kitap3Isim", kitap3.isim);
//       //Yazar
//       await prefs.setString("kitap3Yazar", kitap3.yazar);
//       //Sayfa Sayısı
//       await prefs.setInt("kitap3SayfaSayisi", kitap3.sayfaSayisi);
//       //ilk basım yılı
//       await prefs.setInt("kitap3IlkBasimYili", kitap3.ilkBasimYili);

// //Ben shared preferences ile kaç tane kitap kaydedeceğimi bileme ve kayıt ettiğim kitapları hep kitap1,2,3,4 diye isimlendiremem.
////Her kitap adını aynı değer verevek kayıt edersem bu sefer her kayıt ettiğimde isim sürekli değişir.
//Sharedda bütün kitapları çeki listelemede yapamam.
// //Sharedda değer okuma;
// prefs.getString("kitap1Isim");//Kitapları getir diyede bir seçeneğim yok.

//Verileri bir tablo halinde veri tabanında tutuğumuz yapı sqlitedır.
//Tüm veri tabanları sql dilini kullanırlar.
//Sqlde bana sayfa sayısı bu olan kitapları getir ve şu isimde kitapları getir diye sorgu yapabiliyorum.
//Neden onca veri tabanı sistemi arasından sqlite çünkü daha küçük daha hızlı mobil cihazlarda kullanılmaya daha uygun.

//Sql komutunu sqlbrowser oluşturacak ve kod şeklinde vize verecek.
