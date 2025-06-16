import 'package:flutter/material.dart';
import 'package:myapp/pages/kota.dart';
import 'package:myapp/pages/login.dart'; // Pastikan ini hanya jika diperlukan
import 'package:supabase_flutter/supabase_flutter.dart'; // Jika belum diimpor

class EditKota extends StatefulWidget {
  final int id;

  EditKota({required this.id});

  @override
  State<EditKota> createState() => _EditKotaState();
}

class _EditKotaState extends State<EditKota> {
  TextEditingController _namaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKotaDetails();
  }

  void _fetchKotaDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('kota')
          .select()
          .eq('id', widget.id)
          .single();

      setState(() {
        _namaController.text = response['nama'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data not found or error: $e')),
      );
    }
  }

  void _updateKota() async {
    try {
      final response = await Supabase.instance.client.from('kota').update({
        'nama': _namaController.text,
      }).eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City updated successfully')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => KotaPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update city, $e')),
      );
    }
  }

  void _deleteKota() async {
    try {
      final response = await Supabase.instance.client
          .from('kota')
          .delete()
          .eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City deleted successfully')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => KotaPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete city, $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xff3a57e8),
        title: Text(
          "Edit Kota Asal",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Color(0xffffffff),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => KotaPage())),
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xffffffff),
            size: 24,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _deleteKota,
              icon: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Kota",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: "Nama",
                  filled: true,
                  fillColor: Color(0xffcecece),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: _updateKota,
                color: Color(0xff3645e7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(16),
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                height: 40,
                minWidth: 140,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
