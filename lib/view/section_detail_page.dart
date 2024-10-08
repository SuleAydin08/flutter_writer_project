import 'package:flutter/material.dart';
import 'package:flutter_writer_project/model/section.dart';

class SectionDetailPage extends StatelessWidget {
  //Text field controlü
  TextEditingController _contentController = TextEditingController();

  SectionDetailPage(Section section);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple[100],
      title: Text(_section.title),
      actions: [IconButton(onPressed: _saveContent, icon: Icon(Icons.save))],
    );
  }

  Widget _buildBody() {
    //Body oluşturulmadan section içeriğini veriyoruz.Ekran oluşturulduğunda artık bölümün içeriğini göstermesi gerektiğini biliyor.
    _contentController.text = _section.contents;
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
