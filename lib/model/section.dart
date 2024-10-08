class Section{
  dynamic id;//Bunu ben vermeyeceğim kendi otomatik olarak gelecek bu sebeple constructerda verilecek bu sebeple null
  int bookId;
  String title;
  String contents;

  Section(this.bookId, this.title)
  :contents = "";
  ////Başlangıçta içerik kısmı boş gelecek ama başlık ve id gelecek.

  //FromMap isimlendirilmiş constructerı ile toMap fonksiyonuda oluşturacağız.Veri tabanı işlemlerinde işimiz olacağı için şimdiden oluşturuyoruz.
  //Frommap Constructerı
  Section.fromMap(Map<String, dynamic> map):
    id = map["id"],
    bookId = map["bookId"],
    title = map["title"],
    contents = map["contents"];

  //ToMap Constructerı
  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "bookId": bookId,
      "title": title,
      "contents": contents,
    };
  }
  
}