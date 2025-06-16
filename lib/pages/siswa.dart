import 'package:flutter/material.dart';
import 'package:myapp/pages/dashboard.dart';
import 'package:myapp/pages/editSiswa.dart';
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/tambahSiswa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SiswaPage extends StatefulWidget {
  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  Future<List<Map<String, dynamic>>> fetchSiswaList() async {
    final response = await supabase
        .from('siswa')
        .select('id, nama, nis, kota(id, nama), jenisKelamin');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2055f1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          "Siswa",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
          },
          icon: Icon(Icons.arrow_back, color: Color(0xffffffff), size: 24),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TambahSiswa())),
            icon: Icon(Icons.add_circle, color: Color(0xffffffff), size: 24)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: searchController,
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
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: Color(0xff9f9f9f), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: Color(0xff9f9f9f), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: Color(0xff9f9f9f), width: 1.5),
                ),
                hintText: "Pencarian",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 13,
                  color: Color(0xffa5a5a5),
                ),
                filled: true,
                fillColor: Color(0xffdfdfdf),
                isDense: false,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                suffixIcon: Icon(
                  Icons.search,
                  color: Color(0xffa5a5a5),
                  size: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchSiswaList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found.'));
                } else {
                  List<Map<String, dynamic>> siswaList = snapshot.data!;
                  String searchQuery = searchController.text.toLowerCase();

                  List<Map<String, dynamic>> filteredSiswaList =
                      siswaList.where((siswa) {
                    final nama = siswa['nama']?.toLowerCase() ?? '';
                    final nis = siswa['nis']?.toLowerCase() ?? '';
                    final kotaNama = siswa['kota']['nama']?.toLowerCase() ?? '';
                    return nama.contains(searchQuery) ||
                        nis.contains(searchQuery) ||
                        kotaNama.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredSiswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = filteredSiswaList[index];
                      final nama = siswa['nama'] ?? 'Unknown';
                      final nis = siswa['nis'] ?? 'Unknown';
                      final kotaNama = siswa['kota']['nama'] ?? 'Unknown';
                      final gender = siswa['jenisKelamin'] ?? 'Unknown';

                      final icon = (gender.toString().toLowerCase() == 'female')
                          ? Icons.female
                          : Icons.male;

                      return Card(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        color: Color(0xff4055e7),
                        shadowColor: Color(0x00939393),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Color(0x4d9e9e9e), width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(icon, color: Colors.white),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        nama,
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 11,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 4, 0, 0),
                                        child: Text(
                                          nis,
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 11,
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        kotaNama,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 11,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context, MaterialPageRoute(
                                    builder: (context) => EditSiswa(
                                      id: siswa['id']))),
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xffffffff),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context, MaterialPageRoute(
              builder: (context) => TambahSiswa()));
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
