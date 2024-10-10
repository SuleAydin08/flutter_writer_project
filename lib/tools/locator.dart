//Burada global bir getit nesnesi tanımlayacağız.
import 'package:flutter_writer_project/repository/database_repository.dart';
import 'package:flutter_writer_project/service/sqflite/sqflite_database_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

setupLocator(){
  //Singeltonlar buraya kayıt edilir.
  locator.registerLazySingleton(() => DatabaseRepository());// DatabaseRepository() singelton olarak kayıt ettim.
  //locator.registerSingleton uygulama direk başladığında oluşturulur. locator.registerLazySingleton bu7 ise ihtiyaç olan ilk yerde oluşturulur.
  //Yani ihtiyaç duyulmazsa hiç oluşturulmaz.
  locator.registerLazySingleton(() => SqfliteDatabaseService());
  //Setuplocator fonksiyonları çalıştırıldığında singeltonlarım oluşturulacak.
}