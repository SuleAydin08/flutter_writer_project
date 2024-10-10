import 'package:flutter/material.dart';
import 'package:flutter_writer_project/model/book.dart';
import 'package:flutter_writer_project/model/section.dart';
import 'package:flutter_writer_project/view_model/sections_view_model.dart';
import 'package:provider/provider.dart';

class SectionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildSectionAddFab(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    SectionsViewModel viewModel =
        Provider.of<SectionsViewModel>(context, listen: false);
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text(viewModel.book.name),
    );
  }

  //body
  Widget _buildBody() {
    return Consumer<SectionsViewModel>(
      builder: (context, viewModel, child) => ListView.builder(
        itemCount: viewModel.sections.length,
        itemBuilder: (BuildContext context, int index) {
          return ChangeNotifierProvider.value(
            value: viewModel.sections[index],
            child: _buildListItem(context, index),
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    SectionsViewModel viewModel =
        Provider.of<SectionsViewModel>(context, listen: false);
    return Consumer<Section>(
      builder: (context, section, child) => ListTile(
        leading: CircleAvatar(
          child: Text(section.id.toString()),
        ),
        //Rowla direk sardığımızda row bütün satırı kaplar.
        trailing: Row(
          //Rowun tüm satırı kaplamasını engellemek için yapılır.
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  viewModel.sectionUpdate(context, index);
                },
                icon: Icon(Icons.edit)),
            IconButton(
                //Biz 4 kitabı sildiğimizde kitap eklediğimizde sildiğimiz veri id yerine hiç bir zaman bir eklenmez sayı en sonda olduğı sayıdan devam eder.
                onPressed: () {
                  viewModel.sectionDelete(index);
                },
                icon: Icon(Icons.delete))
          ],
        ),
        title: Text(section.title),
        onTap: () {
          viewModel.sectionDetailPageOpen(context, index);
        },
      ),
    );
  }

//floating Action Button = Fab
  Widget _buildSectionAddFab(BuildContext context) {
    SectionsViewModel viewModel =
        Provider.of<SectionsViewModel>(context, listen: false);
    return FloatingActionButton(
      onPressed: () {
        viewModel.sectionAdd(context);
      },
      child: Icon(Icons.add),
    );
  }
}
