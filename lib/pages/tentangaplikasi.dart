import 'package:flutter/material.dart';
import 'package:myapp/pages/dashboard.dart';

class TentangAplikasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff3d55fb),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xffffffff),
            size: 24,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Color(0xffffffff),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage("images/LogoApp.png"),
                        height: 97,
                        width: 221,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          "Versi 1 (1.1.0) PT Universal Big Data (UBIG) suratkita@gmail.com",
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff2a4ef8),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Akademik App adalah aplikasi akademik yang mengelola data siswa dan data kota dengan visualisasi dashboard dengan menampilkan presentasi data dari data yang ada. Aplikasi ini sebagai standar seleksi TES MAGANG UBIG.",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 13,
                              color: Color(0xff2b48ed),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
