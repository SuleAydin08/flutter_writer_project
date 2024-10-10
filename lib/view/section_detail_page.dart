import 'package:flutter/material.dart';
import 'package:flutter_writer_project/view_model/sections_detail_view_model.dart';
import 'package:provider/provider.dart';

class SectionDetailPage extends StatelessWidget {
  //Text field controlü
  TextEditingController _contentController = TextEditingController();

  SectionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
     SectionsDetailViewModel viewModel = Provider.of<SectionsDetailViewModel>(context, listen: false,);
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text(viewModel.section.title),
      actions: [IconButton(onPressed: (){viewModel.saveContent(_contentController.text);}, icon: Icon(Icons.save))],
    );
  }

  Widget _buildBody(BuildContext context) {
    SectionsDetailViewModel viewModel = Provider.of<SectionsDetailViewModel>(context, listen: false,);
    //Body oluşturulmadan section içeriğini veriyoruz.Ekran oluşturulduğunda artık bölümün içeriğini göstermesi gerektiğini biliyor.
    _contentController.text = viewModel.section.contents;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        //Burda üstte _section verdik ama kontroller sectionun içeriğini okuyamıyor bu sebeple ekranda girip çıktıktan sonra görüntüleyemiyoruz.
        controller: _contentController,
        maxLines: 1000,
        decoration: InputDecoration(
            border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        )),
      ),
    );
  }
}
