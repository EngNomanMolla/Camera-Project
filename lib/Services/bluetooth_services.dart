import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class BlueToothService extends GetxController {
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";
  bool _autoAcceptPairingRequests = false;

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

//  final bool _autoAcceptPairingRequests = false;

  BlueToothService(){
    connection!.input!.listen((Uint8List data) {
      print('Data incoming: ${ascii.decode(data)}');
      Fluttertoast.showToast(msg: ascii.decode(data));

      if (ascii.decode(data).contains('!')) {
        connection!.finish(); // Closing connection
        print('Disconnecting by local host');
      }
    }).onDone(() {
      print('Disconnected by remote request');
    });
  }


  Future initialize() async {
    BluetoothState state = await FlutterBluetoothSerial.instance.state;
    bluetoothState = state;
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        _address = address!;
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      _name = name!;
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      bluetoothState = state;

      // Discoverable mode is disabled when Bluetooth gets disabled
      _discoverableTimeoutTimer = null;
      _discoverableTimeoutSecondsLeft = 0;
    });
    update();
  }

  Future<bool?> toggleBluetoothState() async {
    // async lambda seems to not working
    if (!bluetoothState.isEnabled) {
      return await FlutterBluetoothSerial.instance.requestEnable();

      print("Should turn on");
    } else {
      bool? isOn = await FlutterBluetoothSerial.instance.requestDisable();
      if (isOn == true) {
        bluetoothState = BluetoothState.STATE_OFF;
      }
      return false;
      //print("Should turn off");
    }
    update();
  }

  static final clientID = 0;

  late final BluetoothDevice server;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  BluetoothConnection? connection;

  bool isDisconnecting = false;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);
  bool connected = false;

  disconnectFromBlueTooth() async {
    if (connection!.isConnected) {}
    connection!.dispose();
    connected = false;
  }

  Future connectToBluetooth() async {
    late BluetoothDevice server1;
    List<BluetoothDevice> pairedDevice =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    pairedDevice.forEach((element) {
      print(element.address);
      print(element.bondState);
      print(element.name);
      if (element.name == 'HC-05') {
        server1 = element;
      }
    });

    BluetoothConnection.toAddress(server1.address).then((_connection) {
      print('Connected to the device');
      connected = true;
      connection = _connection;

      isConnecting = false;
      isDisconnecting = false;

      //   connection!.input!.listen(_onDataReceived).onDone(() {
      //     // print(data);
      //     // Example: Detect which side closed the connection
      //     // There should be `isDisconnecting` flag to show are we are (locally)
      //     // in middle of disconnecting process, should be set before calling
      //     // `dispose`, `finish` or `close`, which all causes to disconnect.
      //     // If we except the disconnection, `onDone` should be fired as result.
      //     // If we didn't except this (no flag set), it means closing by remote.
      //     if (isDisconnecting) {
      //       print('Disconnecting locallyyyy!');
      //     } else {
      //       print('Disconnected remotelyy!');
      //     }
      //   });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  Future<bool> sendMessage(String text) async {
    if (connected != false) {

      //await connectToBluetooth();
      text = text.trim();


        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        connection!.output.allSent.then((value) {

          connection!.input!.listen((Uint8List data) {
            print('Data incoming: ${ascii.decode(data)}');
            Fluttertoast.showToast(msg: ascii.decode(data));

            if (ascii.decode(data).contains('!')) {
              connection!.finish(); // Closing connection
              print('Disconnecting by local host');
            }
          }).onDone(() {
            print('Disconnected by remote request');
          });
        });


      return true;
    } else {
      return false;
    }

    // textEditingController.clear();
    // print("hellos");
    // if (text.length > 0) {
    //   try {
    //     connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
    //     await connection!.output.allSent;
    //     print("hellsda");
    //     print(text);
    //   } catch (e) {
    //     // Ignore error, but notify state
    //     print("error");
    //     //setState(() {});
    //   }
    // }
  }

  receivedData() async {
    connection = await BluetoothConnection.toAddress(server.address);
    connection!.input!.listen((event) {
      print(event);
      Fluttertoast.showToast(msg: event.toString());
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    print(data);
    int backspacesCounter = 0;
    print("Recieved");
    String payload = utf8.decode(data);
    print(payload);
    //recieved_text = payload;
    data.forEach((byte) {
      // if (byte == 8 || byte == 127) {
      //   backspacesCounter++;
      // }
      //  payload.
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // print(buffer);
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = payload;

    int index = buffer.indexOf(13);
    //if (~index != 0) {
    //   setState(() {
    //     messages.add(
    //       _Message(
    //         1,
    //         backspacesCounter > 0
    //             ? _messageBuffer.substring(
    //                 0, _messageBuffer.length - backspacesCounter)
    //             : _messageBuffer + dataString.substring(0, index),
    //       ),
    //     );
    //     _messageBuffer = dataString.substring(index);
    //   });
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + dataString);
    // }
  }
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}
