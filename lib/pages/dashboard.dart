import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/pages/editSiswa.dart';
import 'package:myapp/pages/kota.dart';
import 'package:myapp/pages/login.dart' hide supabase;
import 'package:myapp/pages/siswa.dart' hide supabase;
import 'package:myapp/pages/tentangaplikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class Siswa {
  final int kotaId;

  Siswa({required this.kotaId});

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(kotaId: json['id_kota']);
  }
}

class JenkelData {
  final String gender;
  final int count;

  JenkelData({required this.gender, required this.count});
}

class KotaData {
  final int id;
  final String nama;
  final int total;

  KotaData({required this.id, required this.nama, required this.total});
}

class TahunData {
  final int tahun;
  final int jumlah;

  TahunData({required this.tahun, required this.jumlah});
}

class _DashboardState extends State<Dashboard> {
  final SelectionBehavior _selectionBehavior = SelectionBehavior(enable: true);

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email == null || email.isEmpty) {
      // Fallback: Try to get email from current session
      final session = supabase.auth.currentSession;
      email = session?.user?.email ?? 'No Email Found';

      // Save to SharedPreferences for future use
      if (email != 'No Email Found') {
        await prefs.setString('user_email', email);
      }
    }

    return email;
  }

  Future<List<JenkelData>> fetchJenkel() async {
    try {
      final response = await supabase.from('siswa').select('jenisKelamin');

      // Aggregate counts directly from the response
      int maleCount =
          response
              .where(
                (data) =>
                    data['jenisKelamin'].toString().toLowerCase() == 'male',
              )
              .length;
      int femaleCount =
          response
              .where(
                (data) =>
                    data['jenisKelamin'].toString().toLowerCase() == 'female',
              )
              .length;

      return [
        JenkelData(gender: 'Male', count: maleCount),
        JenkelData(gender: 'Female', count: femaleCount),
      ];
    } catch (e) {
      if (e.toString().contains(
        "Connection closed before full header was received",
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan koneksi. Silakan coba lagi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      throw e;
    }
  }

  Future<List<KotaData>> fetchKota() async {
    try {
      // Fetch all kota data
      final kotaResponse = await supabase.from('kota').select('id, nama');
      if (kotaResponse == null) {
        throw Exception('Failed to fetch kota data');
      }

      // Fetch all siswa data
      final siswaResponse = await supabase.from('siswa').select('id_kota');
      if (siswaResponse == null) {
        throw Exception('Failed to fetch siswa data');
      }

      // Convert fetched data into lists
      final List<Map<String, dynamic>> kotaList =
          List<Map<String, dynamic>>.from(kotaResponse);
      final List<Map<String, dynamic>> siswaList =
          List<Map<String, dynamic>>.from(siswaResponse);

      // Parse siswa data into a list of Siswa objects
      List<Siswa> siswaData =
          siswaList.map((siswa) => Siswa.fromJson(siswa)).toList();

      // Create a map to count the number of students per city
      Map<int, int> siswaCountByKota = {};

      for (var siswa in siswaData) {
        siswaCountByKota[siswa.kotaId] =
            (siswaCountByKota[siswa.kotaId] ?? 0) + 1;
      }

      // Create a list of KotaData from the kota list and siswa count map
      List<KotaData> kotaData =
          kotaList.map((kota) {
            int kotaId = kota['id'];
            String nama = kota['nama']?.toString() ?? 'Unknown';
            int total = siswaCountByKota[kotaId] ?? 0;
            return KotaData(id: kotaId, nama: nama, total: total);
          }).toList();

      // Filter out cities with a total count of 0
      kotaData = kotaData.where((kota) => kota.total > 0).toList();

      return kotaData;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSiswaByKota(int idKota) async {
    final response = await Supabase.instance.client
        .from('siswa')
        .select()
        .eq('id_kota', idKota); // pastikan filter berdasarkan id

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchSiswaByGender(String gender) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('siswa')
        .select()
        .eq('jenisKelamin', gender.toLowerCase());

    if (response.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchSiswaByTahun(int tahun) async {
    final data = await Supabase.instance.client
        .from('siswa')
        .select()
        .eq('date', tahun); // Pastikan 'date' itu INT

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<TahunData>> fetchTahun() async {
    try {
      final response = await supabase.from('siswa').select('date');

      // Extract and count the years
      Map<int, int> yearCounts = {};

      for (var data in response) {
        if (data['date'] != null) {
          DateTime date = DateTime.parse(data['date'].toString());
          int year = date.year;

          if (yearCounts.containsKey(year)) {
            yearCounts[year] = yearCounts[year]! + 1;
          } else {
            yearCounts[year] = 1;
          }
        }
      }

      // Convert the yearCounts map to a list of YearlyBirthData
      List<TahunData> result =
          yearCounts.entries
              .map((entry) => TahunData(tahun: entry.key, jumlah: entry.value))
              .toList();

      // Optionally sort the list by year
      result.sort((a, b) => a.tahun.compareTo(b.tahun));

      return result;
    } catch (e) {
      if (e.toString().contains(
        "Connection closed before full header was received",
      )) {
        // Handle connection error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan koneksi. Silakan coba lagi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      throw e;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 15,
            color: Color(0xffffffff),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Color(0xffffffff), size: 24),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(5),
            child: IconButton(
              icon: Icon(Icons.account_circle, color: Color(0xffffffff)),
              onPressed: () async {
                try {
                  String email = await getUserEmail();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('User Email'),
                        content: Text('Login sebagai $email'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch user email: $e')),
                  );
                }
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('images/LogoApp.png', height: 68, width: 174),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Siswa'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SiswaPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Kota'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => KotaPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TentangAplikasi()),
                );
              },
            ),
            Spacer(),
            Divider(thickness: 1, color: Colors.grey),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Perform logout and navigate to the Login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          GridView(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            children: [
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xff332de9),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<List<JenkelData>>(
                      future: fetchJenkel(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error'); // Handle error state
                        } else if (snapshot.hasData) {
                          List<JenkelData> jenkel = snapshot.data!;
                          int femaleCount =
                              jenkel
                                  .firstWhere((data) => data.gender == 'Female')
                                  .count;
                          int maleCount =
                              jenkel
                                  .firstWhere((data) => data.gender == 'Male')
                                  .count;
                          int totalCount = femaleCount + maleCount;
                          return Text(
                            totalCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                              color: Color(0xffffffff),
                            ),
                          );
                        } else {
                          return Text('N/A'); // Handle empty data
                        }
                      },
                    ),
                    Text(
                      "Total Siswa",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 11,
                        color: Color(0xfffff5f5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xff322beb),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<List<JenkelData>>(
                      future: fetchJenkel(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error'); // Handle error state
                        } else if (snapshot.hasData) {
                          List<JenkelData> jenkel = snapshot.data!;
                          int maleCount =
                              jenkel
                                  .firstWhere((data) => data.gender == 'Male')
                                  .count;
                          return Text(
                            maleCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                              color: Color(0xffffffff),
                            ),
                          );
                        } else {
                          return Text('N/A'); // Handle empty data
                        }
                      },
                    ),
                    Text(
                      "Laki-Laki",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 11,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xff342ee7),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<List<JenkelData>>(
                      future: fetchJenkel(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error'); // Handle error state
                        } else if (snapshot.hasData) {
                          List<JenkelData> jenkel = snapshot.data!;
                          int femaleCount =
                              jenkel
                                  .firstWhere((data) => data.gender == 'Female')
                                  .count;
                          return Text(
                            femaleCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                              color: Color(0xffffffff),
                            ),
                          );
                        } else {
                          return Text('N/A'); // Handle empty data
                        }
                      },
                    ),
                    Text(
                      "Perempuan",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 11,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GridView(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            children: [
              // Kartu Jenis Kelamin
              Container(
                decoration: BoxDecoration(
                  color: Color(0xff342ee4),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        "Jenis Kelamin",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<JenkelData>>(
                          future: fetchJenkel(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              List<JenkelData> jenkel = snapshot.data!;
                              return SfCircularChart(
                                palette: <Color>[Colors.lightBlue, Colors.pink],
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CircularSeries>[
                                  DoughnutSeries<JenkelData, String>(
                                    dataSource: jenkel,
                                    xValueMapper:
                                        (JenkelData data, _) => data.gender,
                                    yValueMapper:
                                        (JenkelData data, _) => data.count,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                    ),
                                    enableTooltip: true,
                                    sortingOrder: SortingOrder.descending,
                                    onPointTap: (
                                      ChartPointDetails details,
                                    ) async {
                                      String selectedGender =
                                          jenkel[details.pointIndex!].gender;
                                      List<Map<String, dynamic>> siswaByGender =
                                          await fetchSiswaByGender(
                                            selectedGender,
                                          );

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            builder: (
                                              context,
                                              scrollController,
                                            ) {
                                              return Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Siswa dengan Jenis Kelamin $selectedGender',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        controller:
                                                            scrollController,
                                                        itemCount:
                                                            siswaByGender
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final siswa =
                                                              siswaByGender[index];
                                                          return Card(
                                                            color: Color(
                                                              0xff342ee8,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: ListTile(
                                                              leading: Icon(
                                                                siswa['jenisKelamin']
                                                                            ?.toLowerCase() ==
                                                                        'male'
                                                                    ? Icons.male
                                                                    : Icons
                                                                        .female,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              title: Text(
                                                                siswa['nama'],
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Kartu Asal Kota
              Container(
                decoration: BoxDecoration(
                  color: Color(0xff342ee8),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Text(
                        "Asal Kota",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<KotaData>>(
                          future: fetchKota(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              List<KotaData> kota = snapshot.data!;
                              return SfCircularChart(
                                palette: <Color>[
                                  Colors.amber,
                                  Colors.orange,
                                  Colors.cyan,
                                  Colors.redAccent,
                                  Colors.lightBlue,
                                  Colors.limeAccent,
                                ],
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CircularSeries>[
                                  PieSeries<KotaData, String>(
                                    dataSource: kota,
                                    xValueMapper:
                                        (KotaData data, _) => data.nama,
                                    yValueMapper:
                                        (KotaData data, _) => data.total,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                    ),
                                    enableTooltip: true,
                                    onPointTap: (
                                      ChartPointDetails details,
                                    ) async {
                                      int idKota =
                                          kota[details.pointIndex!]
                                              .id; // ✅ ambil id kota (int)
                                      String namaKota =
                                          kota[details.pointIndex!].nama;

                                      List<Map<String, dynamic>> siswaKota =
                                          await fetchSiswaByKota(
                                            idKota,
                                          ); // ✅ kirim int

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            builder: (
                                              context,
                                              scrollController,
                                            ) {
                                              return Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Siswa dari $namaKota',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        controller:
                                                            scrollController,
                                                        itemCount:
                                                            siswaKota.length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final siswa =
                                                              siswaKota[index];
                                                          return Card(
                                                            color: Color(
                                                              0xff342ee8,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: ListTile(
                                                              leading: Icon(
                                                                siswa['jenisKelamin'] ==
                                                                        'male'
                                                                    ? Icons.male
                                                                    : Icons
                                                                        .female,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              title: Text(
                                                                siswa['nama'],
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                namaKota,
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white70,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            flex: 1,
            child: GridView(
              padding: EdgeInsets.all(16),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              children: [
                Container(
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xff322ce8),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Tahun Kelahiran",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xffffffff),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child: FutureBuilder<List<TahunData>>(
                              future: fetchTahun(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else {
                                  List<TahunData> tahun =
                                      snapshot.data!..sort(
                                        (a, b) => b.jumlah.compareTo(a.jumlah),
                                      );
                                  return SfCartesianChart(
                                    primaryXAxis: CategoryAxis(
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    primaryYAxis: NumericAxis(
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                      textStyle: TextStyle(color: Colors.white),
                                    ),
                                    onSelectionChanged: (
                                      SelectionArgs args,
                                    ) async {
                                      final selectedTahun =
                                          tahun[args.pointIndex!].tahun;

                                      final siswaFiltered =
                                          await fetchSiswaByTahun(
                                            selectedTahun,
                                          );

                                      if (siswaFiltered.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Tidak ada siswa ditemukan untuk tahun $selectedTahun',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            builder: (
                                              context,
                                              scrollController,
                                            ) {
                                              return Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Siswa lahir tahun $selectedTahun',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        controller:
                                                            scrollController,
                                                        itemCount:
                                                            siswaFiltered
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final siswa =
                                                              siswaFiltered[index];
                                                          return Card(
                                                            color: Color(
                                                              0xff342ee8,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: ListTile(
                                                              leading: Icon(
                                                                siswa['jenisKelamin'] ==
                                                                        'male'
                                                                    ? Icons.male
                                                                    : Icons
                                                                        .female,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              title: Text(
                                                                siswa['nama'],
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                'NIS: ${siswa['nis']}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white70,
                                                                ),
                                                              ),
                                                              trailing: Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onTap: () {
                                                                // Navigasi ke halaman detail kalau mau
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    tooltipBehavior: TooltipBehavior(
                                      enable: true,
                                    ),
                                    series: <CartesianSeries>[
                                      ColumnSeries<TahunData, String>(
                                        name: "Tahun",
                                        dataSource: tahun,
                                        color: Colors.amber,
                                        xValueMapper:
                                            (TahunData data, _) =>
                                                data.tahun.toString(),
                                        yValueMapper:
                                            (TahunData data, _) => data.jumlah,
                                        dataLabelSettings: DataLabelSettings(
                                          color: Colors.white,
                                          isVisible: true,
                                        ),
                                        enableTooltip: true,
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
