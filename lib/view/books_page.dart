import 'package:flutter/material.dart';
import 'package:flutter_writer_project/constants.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/view_model/books_view_model.dart';
import 'package:provider/provider.dart';

class BooksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildBookAddFab(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    BooksViewModel viewModel = Provider.of<BooksViewModel>(
      context,
      listen: false,
    );
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text("Kitaplar Sayfası"),
      actions: [
        IconButton(
          onPressed: (){viewModel.selectedBookDelete();},
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

  //body
  Widget _buildBody() {
    return Column(
      //Column içerisinde listview builder kullandığımız içinde listviewbuilderı expanded ile sarmamız gerekir.
      children: [
        _buildCategoryFiltering(),
        Expanded(
          child: Consumer<BooksViewModel>(
            builder: (context, viewModel, child) => ListView.builder(
              //Kitaplar listesinde yapılacak değişiklikleri dinlemek istediğimiz için consumer ile yapıyıoruz.
              controller: viewModel.scrollController,
              itemCount: viewModel.books.length,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                  value: viewModel.books[index],
                  child: _buildListItem(context, index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFiltering() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Kategori: "),
        Consumer<BooksViewModel>(
          builder: (context, viewModel, child) => DropdownButton<int>(
            items: viewModel.allCategories.map((categoryId) {
              //Categoy key gezip atama işlemi yapılıyor.
              return DropdownMenuItem<int>(
                value: categoryId,
                child: Text(
                  //Kategori id -1 ise hepsini yazdır değilse alttaki ifadeyi yazdır demek.
                  categoryId == -1
                      ? "Hepsi"
                      : Constants.categories[categoryId] ??
                          "", //Burada hangi anahtarda ise buna karşılık gelen değeri getirecek.
                ),
              );
            }).toList(),
            //Değer değiştiğinde değer yani fonksiyon atanır.
            onChanged: (int? newValue) {
              if (newValue != null) {
                viewModel.selectedCategory = newValue;
                // setState(() {
                //   //Yeni değer null değilse categorydeki değeri yeni değere ata demek.
                //   _selectedCategory =
                //       newValue; //Burada yaptığımız işleme rağmen sayfada seçtiğimiz değer gelmedi bunun sebebi burda
                //   //kullandığımız setstate BooksPage sayfasınındır çünkü dialog her ne kadar o sayfada açılmış gibi gözüksede ayrı sayfadır.
                //   //Yani dialogun ayrı bir stateti olması gerekir.
                //   //O halde burda ne yapacağız biz üst ksıımda yaptığımız columnı ayrı bir widget olarak tanımlayıp bu sayfada content
                //   //içerisinde onu çağırabiliriz.Ama biz buu önceki projelerde yaptığımız için farklı bir yöntem ile yapacağız.
                // });
              }
            },
            // //Bu kategori bilgisidir.
            value: viewModel.selectedCategory,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    BooksViewModel viewModel = Provider.of<BooksViewModel>(
      context,
      listen: false,
    );
    return Consumer<Book>(
      builder: (context, book, child) => ListTile(
        leading: CircleAvatar(
          child: Text(book.id.toString()),
        ),
        //Rowla direk sardığımızda row bütün satırı kaplar.
        trailing: Row(
          //Rowun tüm satırı kaplamasını engellemek için yapılır.
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  viewModel.bookUpdate(context, index);
                },
                icon: Icon(Icons.edit)),
            // IconButton(
            //   //Biz 4 kitabı sildiğimizde kitap eklediğimizde sildiğimiz veri id yerine hiç bir zaman bir eklenmez sayı en sonda olduğı sayıdan devam eder.
            //   onPressed: () {
            //     _bookDelete(index);
            //   },
            //   icon: Icon(Icons.delete),
            // ),
            Checkbox(
              value: book.isItSelected, //Seçilen kitap id denk gelen değer.
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  int? bookId = book.id;
                  if (bookId != null) {
                    if (newValue) {
                      //Seçildiyse
                      viewModel.selectedBookId.add(bookId);
                    } else {
                      //Seçilme kaldırıldığında
                      viewModel.selectedBookId.remove(bookId);
                    }
                  book.choose(newValue);
                  }
                }
              },
            ),
          ],
        ),
        title: Text(book.name),
        subtitle: Text(Constants.categories[book.category] ?? ""),
        onTap: () {
          viewModel.sectionPageOpen(context, index);
        },
      ),
    );
  }

//floating Action Button = Fab
  Widget _buildBookAddFab(BuildContext context) {
    BooksViewModel viewModel = Provider.of<BooksViewModel>(context,listen: false,);
    return FloatingActionButton(
      onPressed: () {
        viewModel.bookAdd(context);
      },
      child: Icon(Icons.add),
    );
  }
}
