import 'package:flutter/material.dart';
import 'package:flutter_writer_project/view/books_page.dart';

void main() {
  //Veritabanı nesneleri
//   //Burada localdatabase sayfasında oluşturduğumuz constructerı çalıştırır.
//   LocalDataBase d1 = LocalDataBase();
//   d1.number = 5;
//   print(d1.number);
//   LocalDataBase d2 = LocalDataBase();
//   print(d2.number);
// //Burada d1 veri atanması d2 etkilemez d2 console null yazdırılır.İşte ben burada birine atadıysam 
// //diğerine değer vermesem bile atadığım değer gelsin istiyorum işte bunu yapmanın yolu singeltondur.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BooksPage(),
    );
  }
}