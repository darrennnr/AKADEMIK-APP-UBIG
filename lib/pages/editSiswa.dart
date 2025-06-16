///File download from FlutterViz- Drag and drop a tools. For more details visit https://flutterviz.io/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/siswa.dart' hide supabase;
import 'package:myapp/pages/tambahSiswa.dart';

class EditSiswa extends StatefulWidget {
final int id;

EditSiswa({required this.id});

  @override
  State<EditSiswa> createState() => _EditSiswaState();
}



class _EditSiswaState extends State<EditSiswa> {
  TextEditingController namaController = TextEditingController();
  TextEditingController nisController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noOrtuController = TextEditingController();
  TextEditingController kotaController = TextEditingController();
  bool _isMale = true;

  DateTime? _selectedDate;
  String? _selectedCity;
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchSiswaDetails();
  }

  void _fetchSiswaDetails() async {
    final response =
        await supabase.from('siswa').select().eq('id', widget.id).single();

    if (response != null) {
      setState(() {
        namaController.text = response['nama'] ?? '';
        nisController.text = response['nis'] ?? '';
        tanggalLahirController.text = response['date'] ?? '';
        _isMale = response['jenisKelamin'] == 'male' ? true : false;
        alamatController.text = response['alamat'] ?? '';
        noOrtuController.text = response['noOrtu'] ?? '';

        if (response['id_kota'] != null) {
          final idKota = response['id_kota'];
          final city = _cities.firstWhere(
            (city) => city['id'] == idKota,
            orElse: () => {'nama': ''}, // Default if not found
          );
          _selectedCity = city['nama'] ?? '';
        } else {
          _selectedCity = '';
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data not found')));
    }
  }

  void _editData() async {
    if (namaController.text.isEmpty ||
    nisController.text.isEmpty ||
      tanggalLahirController.text.isEmpty ||
       alamatController.text.isEmpty ||
        noOrtuController.text.isEmpty ||
         _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Isi Semua Data Terlebih Dahulu')));
    } else {
      try{  

      final response = await supabase.from('siswa').update({
        'nama': namaController.text,
        'nis': nisController.text,
        'date': tanggalLahirController.text,
        'alamat': alamatController.text,
        'noOrtu': noOrtuController.text,
        'jenisKelamin': _isMale ? 'male' : 'female',
        'id_kota':
            _cities.firstWhere((city) => city['nama'] == _selectedCity!)['id']
      }).eq('id', widget.id);


      if (response == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data siswa berhasil diubah, $response')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SiswaPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    }
  }

  void _deleteSiswa() async {
    try {
      final response = await supabase.from('siswa').delete().eq('id', widget.id);

      if (response == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Siswa deleted successfully')));

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SiswaPage())); // Go back to the previous page
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete siswa, $e')));
    }
  }

  void _fetchCities() async {
    final response = await supabase.from('kota').select();
    if (response != null) {
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cities: ${response}')),
      );
    }
  }

  

  void _presentDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        tanggalLahirController.text = DateFormat('yyyy-MM-dd')
            .format(pickedDate); // Format the date as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff3a57e8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "Edit Siswa",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 15,
            color: Color(0xffffffff),
          ),
        ),
        leading: IconButton(
          onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SiswaPage()),
                  ),
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xffffffff),
            size: 24,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              onPressed: _deleteSiswa,
              icon: Icon(Icons.delete, color: Color(0xffffffff), size: 24)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Text(
                          "Nama",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: namaController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      hintText: "Nama",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffcecece),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                        child: Text(
                          "NIS",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: nisController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      hintText: "NIS",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffc5c5c5),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                        child: Text(
                          "Tanggal Lahir",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    onTap: _presentDatePicker,
                    controller: tanggalLahirController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      hintText: "Tanggal Lahir",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffcbcbcb),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon:
                          Icon(Icons.event, color: Color(0xff212435), size: 24),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Jenis Kelamin",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 5),
                      Radio(
                        value: true,
                        groupValue: _isMale,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMale = value!;
                          });
                        },
                      ),
                      Text('Laki-Laki'),
                      Radio(
                        value: false,
                        groupValue: _isMale,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMale = value!;
                          });
                        },
                      ),
                      Text('Perempuan')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Text(
                          "Alamat",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: alamatController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      hintText: "Alamat",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffc1c1c1),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "No. Ortu",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: noOrtuController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Color(0x00000000), width: 1),
                      ),
                      hintText: "Nomor HP",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffc2c2c2),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Kota Asal",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['nama'] ?? '',
                        child: Text(city['nama'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    // Handle the null case here: if _selectedCity is null, provide a default value
                    value: _selectedCity != null &&
                            _cities.any((city) => city['nama'] == _selectedCity)
                        ? _selectedCity
                        : null,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          onPressed: () {
                            _editData();
                          },
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
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          textColor: Color(0xffffffff),
                          height: 40,
                          minWidth: 140,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}