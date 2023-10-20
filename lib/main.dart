// import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';

import 'utils/time.dart';
import 'utils/futures.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nostr NIP-38 Live Music',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(135, 70, 208, 1)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Nostr NIP-38 Live Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _relaysList = ['wss://relay.damus.io'];
  final List<Widget> _events = [];
  String _relaysConnectedCount = "0";
  late final RelayPoolApi _relayPool;

  void _addRelay() {
    setState(() {
      _events.insert(
          0,
          const Card(
            child: Text("Testing..."),
          ));
    });
  }

  _connectToRelay() async {
    // _relay = RelayApi(relayUrl: 'wss://relay.damus.io');
    _relayPool = RelayPoolApi(relaysList: _relaysList);
    //final stream = await _relay.connect();
    final stream = await _relayPool.connect();

    _relayPool.on((event) {
      if (event == RelayEvent.connect) {
        // setState(() {
        //   _events.add(Row(
        //     children: [Text('[+] connected to: ${_relayPool.connectedRelays}')],
        //   ));
        // });
        setState(() {
          _relaysConnectedCount = _relayPool.connectedRelays.length.toString();
        });
      } else if (event == RelayEvent.error) {
        _relaysConnectedCount = _relayPool.connectedRelays.length.toString();
      }
    });

    // filter NIP-38 user statuses:
    // https://github.com/nostr-protocol/nips/blob/master/38.md
    _relayPool.sub([
      Filter(
        kinds: [30315],
        limit: 25,
        since: DateTime.now().millisecondsSinceEpoch ~/ 5000,
      )
    ]);

    // listen stream
    stream.listen((Message message) async {
      if (message.type == 'EVENT') {
        Event event = message.message;
        // get only the music tag
        if (event.tags[0].join(",") == "d,music") {
          print("Another status: ${event.content}");
          final nip19 = Nip19();
          String eventPubKey = nip19.npubEncode(event.pubkey);
          String profilePicture =
              "https://rafaturis.com.br/wp-content/uploads/2014/01/default-placeholder.png";

          // get username -------

          final relayGetUserData = RelayPoolApi(relaysList: _relaysList);

          final streamUserdata = await relayGetUserData.connect();
          relayGetUserData.sub([
            Filter(
              kinds: [0],
              authors: [event.pubkey],
              limit: 1,
              //since: DateTime.now().millisecondsSinceEpoch ~/ 5000,
            )
          ]);

          streamUserdata.listen((Message message2) async {
            if (message2.type == 'EVENT') {
              Event eventMetadata = message2.message;

              //profilePicture = eventMetadata.content.runtimeType;
              final userJson = json.decode(eventMetadata.content);

              if (userJson["picture"] != null) {
                profilePicture = userJson["picture"];
              }
              String displayName = userJson["name"];
              if (userJson["display_name"] != null) {
                displayName = userJson["display_name"];
              }

              Widget musicLink = const SizedBox();

              // if there is a link, then show it
              if (event.tags[1][0].toString() == "r") {
                musicLink = TextButton(
                    onPressed: () {
                      launchWeb(event.tags[1][1]);
                    },
                    child: const Text("Listen"));
              }

              // add event to the interface
              setState(() {
                _events.insert(
                    0,
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(profilePicture),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(event.content),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            launchWeb(
                                                "https://iris.to/$eventPubKey");
                                          },
                                          child: const Text("Profile")),
                                      musicLink,
                                      TextButton(
                                        onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text('Tags'),
                                            content: Text(event.tags.join(",")),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'OK'),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.info,
                                              size: 20,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text("Info")
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ]),
                            // Text(event.tags[0].join(","))
                            Text(timeAgoDifference(event.created_at))
                          ],
                        ),
                      ),
                    ));
                //streamUserDataSubscription.cancel(); // cancel stream
                relayGetUserData.close();
              });
            }
          });

          // get username --------
        }
      } else if (message.type == 'OK') {
        // print('[+] Event Published: ${message.message}');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToRelay();
    });
  }

  @override
  void dispose() {
    // you dispose your stream here
    // or check if that works out _connectivity.dispose();
    _relayPool.close();
    //_connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: InkWell(
          onTap: () {
            print("Relays");
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.cable,
                  size: 20,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text("$_relaysConnectedCount"),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: _events,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRelay,
        tooltip: 'Add Relay',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
