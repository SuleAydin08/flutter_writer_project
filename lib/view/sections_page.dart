import 'package:flutter/material.dart';
import 'package:flutter_writer_project/model/book.dart';

class SectionsPage extends StatelessWidget {
  SectionsPage(Book book);

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
      title: Text(_book.name),
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
}
