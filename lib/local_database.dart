//Ben sql kodlarımı sadece bu sınıfın içerisinde yapacağım.
//Modeller belirli bir sınıfa ayit nesneleri tek bir çatı altına toplamak içinde kullanılır.

class LocalDataBase {
  LocalDataBase._privateConstructor();
  static final LocalDataBase _object = LocalDataBase._privateConstructor();
  factory LocalDataBase() {
    return _object;
  }
}
