import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Whatsapp';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late CameraController _controller;
  bool _isSearching = false;
  var data = [];
  int totalUnread = 0;
  bool isTakePicture = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      _cameras[0],
      // Define the resolution to use.
      ResolutionPreset.max,
    );
    List<Map> stateData = [];
    int totalStateUnread = 0;
    for (int i = 0; i < Random().nextInt(20) + 10; i++) {
      var now = Moment.now().subtract(Duration(days: 365 + i));
      int numberUnread = Random().nextBool() ? Random().nextInt(20) : 0;
      stateData.add({
        "image": Random().nextBool()
            ? "https://i.pinimg.com/474x/97/7f/e7/977fe798cf2c3a037e7aa9af6ce4b9d1.jpg"
            : "https://picsum.photos/seed/${Random().nextInt(1000)}/300/300",
        "username": "username $i",
        "last_message": "last message $i",
        "numberOfUnread": numberUnread,
        "date": now.format("y/MM/D"),
        "randomMissCall": Random().nextBool(),
        "randomTypeCall": Random().nextBool()
      });
      totalStateUnread += numberUnread;
    }
    setState(() {
      data = stateData;
      totalUnread = totalStateUnread;
    });
    _tabController.addListener(_handleTabIndex);
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();

    _controller.dispose();
    super.dispose();
  }

  void _toggleSearching() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  Future<XFile?> takePicture() async {
    setState(() {
      isTakePicture = !isTakePicture;
    });

    await _controller.initialize();
    if (isTakePicture) {
      _tabController.index = 0;
      _tabController.index = 1;
    }

    debugPrint(
        'isTakingPicture is ${_controller.value.isTakingPicture.toString()}');

    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await _controller.takePicture();
      print(file.path);
    } on CameraException catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: 'Search Contacts',
                      hintStyle: TextStyle(color: Color(0xff708e89))),
                )
              : const Text("Whatsapp"),
          backgroundColor: const Color(0xff202c34),
          actions: [
            IconButton(
                onPressed: _toggleSearching, icon: const Icon(Icons.search)),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return {
                  'New group',
                  'New broadcast',
                  'Linked devices',
                  'Starred messages',
                  'Settings'
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    child: Text(choice, style: const TextStyle(fontSize: 13)),
                  );
                }).toList();
              },
            )
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xff01a984),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("CHATS",
                        style: TextStyle(
                            color: _tabController.index == 0
                                ? const Color(0xff01a984)
                                : Colors.grey)),
                    const SizedBox(width: 5, height: 5),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _tabController.index == 0
                              ? const Color(0xff01a984)
                              : Colors.grey),
                      child: Center(
                        child: Text("$totalUnread",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black)),
                      ),
                    )
                  ],
                ),
              ),
              Tab(
                child: SizedBox(
                    child: Text("STATUS",
                        style: TextStyle(
                            color: _tabController.index == 1
                                ? const Color(0xff01a984)
                                : Colors.grey))),
              ),
              Tab(
                child: SizedBox(
                    child: Text("CALLS",
                        style: TextStyle(
                            color: _tabController.index == 2
                                ? const Color(0xff01a984)
                                : Colors.grey))),
              ),
            ],
          ),
        ),
        body: isTakePicture
            ? CameraPreview(_controller)
            : Container(
                margin: const EdgeInsets.all(0),
                decoration: const BoxDecoration(color: Color(0xff181c24)),
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DetailChatWidget()))
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  height: 75,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                data[index]['image']),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 2.5),
                                                      child: Text(
                                                          data[index]
                                                              ["username"],
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2.5),
                                                      child: Text(
                                                          data[index]
                                                              ["last_message"],
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .white70)))
                                                ]),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(data[index]["date"],
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: data[index][
                                                              'numberOfUnread'] !=
                                                          0
                                                      ? const Color(0xFF1DA797)
                                                      : Colors.white70)),
                                          data[index]['numberOfUnread'] != 0
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xFF1DA797)),
                                                    child: Center(
                                                      child: Text(
                                                          "${data[index]['numberOfUnread']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 9,
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                  ),
                                                )
                                              : const Text("")
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ));
                        }),
                    ListView(
                      children: [
                        InkWell(
                          onTap: takePicture,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 75,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://i.pinimg.com/474x/97/7f/e7/977fe798cf2c3a037e7aa9af6ce4b9d1.jpg"),
                                ),
                                Container(
                                    width: 20,
                                    height: 20,
                                    transform:
                                        Matrix4.translationValues(-15, 12, 0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1DA797),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xff181c24),
                                            width: 1.5)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add_outlined,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                    )),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 2.5),
                                          child: Text("My Status",
                                              style: TextStyle(
                                                  color: Colors.white))),
                                      Padding(
                                          padding: EdgeInsets.only(top: 2.5),
                                          child: Text(
                                              "Tap to add status update",
                                              style: TextStyle(
                                                  color: Colors.white70)))
                                    ])
                              ],
                            ),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 75,
                            child: const Text("Recent updates",
                                style: TextStyle(color: Colors.white70))),
                      ],
                    ),
                    ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 20),
                            height: 75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(data[index]['image']),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2.5),
                                                child: Text(
                                                    data[index]["username"],
                                                    style: const TextStyle(
                                                        color: Colors.white))),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.5),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child: data[index][
                                                                "randomMissCall"]
                                                            ? const Icon(
                                                                Icons
                                                                    .arrow_upward,
                                                                color: Colors
                                                                    .green,
                                                                size: 15,
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .arrow_downward,
                                                                color:
                                                                    Colors.red,
                                                                size: 15,
                                                              )),
                                                    Text(data[index]["date"],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white70))
                                                  ],
                                                ))
                                          ]),
                                    )
                                  ],
                                ),
                                Icon(
                                    data[index]["randomTypeCall"]
                                        ? Icons.call
                                        : Icons.videocam,
                                    color: const Color(0xff01a984))
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
        floatingActionButton: _floatingActionButton());
  }

  Widget _floatingActionButton() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          backgroundColor: const Color(0xff17ab72),
          child: Transform.rotate(
            angle: 180 * pi / 180,
            child: const IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: null,
            ),
          ),
          onPressed: () {},
        );
      case 1:
        return SizedBox(
            height: 120,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: 45,
                        child: FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: const Color(0xff304845),
                          child: const Icon(Icons.edit, size: 23),
                        ),
                      ),
                      Container(
                        height: 15,
                      ),
                      SizedBox(
                        height: 60,
                        child: FloatingActionButton(
                          backgroundColor: const Color(0xff17ab72),
                          onPressed: takePicture,
                          child: const Icon(Icons.photo_camera),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      case 2:
        return FloatingActionButton(
          backgroundColor: const Color(0xff17ab72),
          child: const IconButton(
            icon: Icon(
              Icons.add_call,
              color: Colors.white,
            ),
            onPressed: null,
          ),
          onPressed: () {},
        );
      default:
        return FloatingActionButton(
          backgroundColor: const Color(0xff17ab72),
          child: Transform.rotate(
            angle: 180 * pi / 180,
            child: const IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: null,
            ),
          ),
          onPressed: () {},
        );
    }
  }
}

class DetailChatWidget extends StatefulWidget {
  const DetailChatWidget({super.key});

  @override
  State<DetailChatWidget> createState() => DetailChatRoute();
}

class DetailChatRoute extends State<DetailChatWidget>
    with TickerProviderStateMixin {
  var data = [
    {
      "message": "ric",
      "isUser": false,
      "first": true
    },
    {
      "message": "richard iku lapo",
      "isUser": false,
      "first": false
    },
    {
      "message": "gaji aku kecil lo di kasi ama dia",
      "isUser": false,
      "first": false
    },
    {
      "message": "lah gaopo nu koe kan wes kerja, di ajarin ambe ak ambe dion ambe richard",
      "isUser": true,
      "first": true
    },
    {
      "message": "skrg iku lagi resisi idup susah nu nyari duit iku susah, jangan ngeluh terus nu",
      "isUser": true,
      "first": false
    },
    {
      "message": "ya pie ric, aku butuh hidupin keluarga aku tiap hari makan e lontong balap tok",
      "isUser": false,
      "first": true
    },
    {
      "message": "richard iku lo ambil gaji aku 3 bulan ",
      "isUser": false,
      "first": false
    },
    {
      "message": "pie ric",
      "isUser": false,
      "first": false
    },
    {
      "message": "ya gini ae lek ga mau tak kasi tau richard kalo koe ga mau di sosbread",
      "isUser": true,
      "first": true
    },
    {
      "message": "aku cape nu nasehatin koe nu, iku batu nu",
      "isUser": true,
      "first": false
    },
    {
      "message": "kasian lo richard mati2an belain koe biar masuk sosbread biar koe kerja dapat lingkungan sama experince startup",
      "isUser": true,
      "first": false
    },
    {
      "message": "iku ga mudah lo",
      "isUser": true,
      "first": false
    },
    {
      "message": "ya ttep ae ric, aku soal e mau bikin bisnis kecil2an sama istri aku ric buat masa tua",
      "isUser": false,
      "first": true
    },
    {
      "message": "umur wes segini soal e",
      "isUser": false,
      "first": false
    },
    {
      "message": "aku itu kesel ric richard iku suruh aku banyak hal dan dia mau semuanya cepat, sedangkan aku otak ku iku kecil ga secepat koe",
      "isUser": false,
      "first": false
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff202c34),
        title: Container(
            transform: Matrix4.translationValues(-30, 0, 0),
            child: Row(
              children: [
                const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircleAvatar(
                      backgroundImage: AssetImage("assets/img.png"),
                    )),
                Container(
                  width: 2,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(bottom: 2.5, left: 5),
                          child: Text("Ibnu Fajar",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13))),
                      Padding(
                          padding:
                              EdgeInsets.only(top: 2.5, left: 5, bottom: 0),
                          child: Text("online",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)))
                    ]),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return {
                'Group Info',
                'Group Media',
                'Search',
                'Mute Notifications',
                'Disappearing Messages',
                'Wallpaper',
                'More '
              }.map((String choice) {
                return PopupMenuItem<String>(
                  child: Text(choice, style: const TextStyle(fontSize: 13)),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff181c24)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50, left: 10, right: 10),
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                bool isUser = data[index]["isUser"] == true;
                bool first = data[index]["first"] == true;
                String message = "${data[index]["message"]}";
                return Align(
                    alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.75),
                          decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xff075E54)
                                  : const Color(0xff202c34),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: const Radius.circular(13),
                                  bottomRight: const Radius.circular(13),
                                  topRight: Radius.circular(!first ? 13 : (isUser ? 0 : 13)),
                                  topLeft: Radius.circular(!first ? 13 : (isUser ? 13 : 0)))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      message,
                                      style: const TextStyle(color: Colors.white),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(right: 13, bottom: 5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("20:55",
                                            style: TextStyle(
                                                color: Colors.grey, fontSize: 12)),
                                        isUser ? const Icon(Icons.check, size: 17, color: Colors.grey) : const Text("")
                                      ],
                                    )
                                )
                              ]),
                        )));
              })
        ),
      ),
      floatingActionButton: Container(
          transform: Matrix4.translationValues(0, 10, 0),
          child: Row(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 0, left: 10, right: 5),
              height: 45,
              width: 330,
              decoration: const BoxDecoration(
                  color: Color(0xff202c34),
                  borderRadius: BorderRadius.all(Radius.circular(22.5))),
              child: Row(children: [
                const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.insert_emoticon,
                      color: Colors.white,
                    )),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  width: 210,
                  height: 45,
                  child: const TextField(
                    style: TextStyle(color: Colors.white, height: 1.5),
                    cursorHeight: 30,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Color(0xff708e89))),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(right: 15, left: 5),
                    child: Icon(IconData(0xf58e, fontFamily: 'MaterialIcons'),
                        color: Colors.grey)),
                const Icon(Icons.camera_alt, color: Colors.grey),
              ]),
            ),
            Container(
              width: 43,
              height: 45,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xff075E54)),
              child: const Icon(Icons.mic, color: Colors.white),
            )
          ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
