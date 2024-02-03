import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

void main() {
  runApp(const MainWidget());
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  int _deviceStatus = Device.disconnected;
  String _deviceStatusStr = "连接已断开";
  String _currentDevice = "";
  Uint8List _data = Uint8List(0);
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((event) {
      setState(() {
        _deviceStatus = event;
        _deviceStatusStr = _deviceStatus == Device.connected
            ? "连接成功"
            : _deviceStatus == Device.connecting
                ? "正在连接"
                : "连接已断开";
      });
    });
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      setState(() {
        _data = Uint8List.fromList([..._data, ...event]);
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    setState(() {
      _devices = res;
    });
  }

  Future<void> _scan() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      await _bluetoothClassicPlugin.startScan();
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (event) {
          setState(() {
            _discoveredDevices = [..._discoveredDevices, event];
          });
        },
      );
      setState(() {
        _scanning = true;
      });
    }
  }

  Future<void> getDeviceAddress(Device address) async {
    _currentDevice = address.name!;
    await _bluetoothClassicPlugin.connect(
        address.address, "00001101-0000-1000-8000-00805f9b34fb");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'search bluetooth',
            onPressed: () async {
              await _bluetoothClassicPlugin.initPermissions();
              await _getDevices();
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectDevices(
                        devices: _devices, deviceAddress: getDeviceAddress)),
              );
            },
          ),
          backgroundColor: Colors.blue,
          title: const Text('喂鱼系统',
              style: TextStyle(
                color: Colors.white,
              )),
          actions: const [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: null,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //const Expanded(child: Text("")),
              Center(
                child: Row(children: [
                  Text(_currentDevice),
                  const Text(":"),
                  Text(_deviceStatusStr)
                ]),
              ),
              Row(
                children: [
                  const Text("电机微调"),
                  TextButton(
                    onPressed: _deviceStatus == Device.connected
                        ? () async {
                            await _bluetoothClassicPlugin.write("l");
                          }
                        : null,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    child: const Text("向左微调",
                        style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: _deviceStatus == Device.connected
                        ? () async {
                            await _bluetoothClassicPlugin.write("r");
                          }
                        : null,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    child: const Text("向右微调",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              TextButton(
                onPressed: _deviceStatus == Device.connected
                    ? () async {
                        await _bluetoothClassicPlugin.write("e");
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                child: const Text("喂食", style: TextStyle(color: Colors.white)),
              ),
              Column(
                children: [
                  const Text("喂食等级"),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _deviceStatus == Device.connected
                            ? () async {
                                await _bluetoothClassicPlugin.write("1");
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: const Text("1",
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _deviceStatus == Device.connected
                            ? () async {
                                await _bluetoothClassicPlugin.write("2");
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: const Text("2",
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _deviceStatus == Device.connected
                            ? () async {
                                await _bluetoothClassicPlugin.write("3");
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: const Text("3",
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _deviceStatus == Device.connected
                            ? () async {
                                await _bluetoothClassicPlugin.write("4");
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: const Text("4",
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _deviceStatus == Device.connected
                            ? () async {
                                await _bluetoothClassicPlugin.write("5");
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: const Text("5",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SelectDevices extends StatelessWidget {
  SelectDevices(
      {required this.devices, required this.deviceAddress, super.key});
  final List<Device> devices;
  void Function(Device device) deviceAddress;
  void clicked(BuildContext context, Device device) {
    deviceAddress(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('select device'),
        ),
        body: Column(
          children: [
            for (var device in devices)
              DeviceItem(clicked: clicked, device: device)
          ],
        ));
  }
}

// ignore: must_be_immutable
class DeviceItem extends StatelessWidget {
  DeviceItem({required this.clicked, required this.device, super.key});
  void Function(BuildContext context, Device device) clicked;
  Device device;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text("")),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(device.name!), Text(device.address)],
        ),
        const Expanded(child: Text("       ")),
        TextButton(
            onPressed: () => clicked(context, device),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
            child:
                const Text("connect", style: TextStyle(color: Colors.white))),
        const Expanded(child: Text("")),
      ],
    );
  }
}
