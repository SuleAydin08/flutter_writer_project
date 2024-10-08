import 'package:flutter/material.dart';
import 'package:flutter_writer_project/constants.dart';

class BooksPage extends StatelessWidget {
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
      actions: [
        IconButton(
          onPressed: _selectedBookDelete,
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

  //body
  Widget _buildBody() {
    //Future builder init state de kullanabilirdik ama ona alternatif olarak kullandık.
    //Future atadığım işlem bitinde builde atadığım fonksiyonu döndürüyor yani ekrana döndürüyor.
    return FutureBuilder(
        future: _bringTheFirstBooks(), builder: _buildListView);
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return Column(
      //Column içerisinde listview builder kullandığımız içinde listviewbuilderı expanded ile sarmamız gerekir.
      children: [
        _buildCategoryFiltering(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _books.length,
            itemBuilder: _buildListItem,
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
        DropdownButton<int>(
          items: _allCategories.map((categoryId) {
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
              setState(() {
                //Yeni değer null değilse categorydeki değeri yeni değere ata demek.
                _selectedCategory =
                    newValue; //Burada yaptığımız işleme rağmen sayfada seçtiğimiz değer gelmedi bunun sebebi burda
                //kullandığımız setstate BooksPage sayfasınındır çünkü dialog her ne kadar o sayfada açılmış gibi gözüksede ayrı sayfadır.
                //Yani dialogun ayrı bir stateti olması gerekir.
                //O halde burda ne yapacağız biz üst ksıımda yaptığımız columnı ayrı bir widget olarak tanımlayıp bu sayfada content
                //içerisinde onu çağırabiliriz.Ama biz buu önceki projelerde yaptığımız için farklı bir yöntem ile yapacağız.
              });
            }
          },
          // //Bu kategori bilgisidir.
          value: _selectedCategory,
        ),
      ],
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
          // IconButton(
          //   //Biz 4 kitabı sildiğimizde kitap eklediğimizde sildiğimiz veri id yerine hiç bir zaman bir eklenmez sayı en sonda olduğı sayıdan devam eder.
          //   onPressed: () {
          //     _bookDelete(index);
          //   },
          //   icon: Icon(Icons.delete),
          // ),
          Checkbox(
            value: _selectedBookId.contains(
                _books[index].id), //Seçilen kitap id denk gelen değer.
            onChanged: (bool? newValue) {
              if (newValue != null) {
                int? bookId = _books[index].id;
                if (bookId != null) {
                  setState(() {
                    //Bu işlemlerisetsate içerisinde yapmazsak checkbox bassak bile bir değişim göremeyiz.
                    if (newValue) {
                      //Seçildiyse
                      _selectedBookId.add(bookId);
                    } else {
                      //Seçilme kaldırıldığında
                      _selectedBookId.remove(bookId);
                    }
                  });
                }
              }
            },
          ),
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
}
