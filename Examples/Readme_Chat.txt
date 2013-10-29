Chat Demo

1. Chat_iOS - This Demo App is to demonstrate how to use our BLE Framework to connect to BLE Shield.

2. Chat_Sketch - This is a demo to show how to use BLE library for Arduino firmware to work with the BLE Shield and communicates to iOS App.

-----

1. Chat_iOS

The framework provide four delegate function for your App which will be called back from the low layer of the framework.

When the framework connected to a BLE device, it will call back your App to tell you it connected to a device successfully.
-(void) bleDidConnect;

When the framework disconnected from your BLE device (e.g. link lost, Arduino reset button, etc.), this function will be called.
-(void) bleDidDisconnect;

When connected to a device and if the RSSI value changes, it will call this function.
-(void) bleDidUpdateRSSI:(NSNumber *) rssi;

When the BLE device sends data to your App, it will call this function.
-(void) bleDidReceiveData:(unsigned char *) data length:(int) length;

You can write data to BLE device use write function, you can write up to 19-bytes at a time.
-(void) write:(NSData *)d;

This is for retrieving the library version of the Arduino BLE library that used with the Arduino firmware.
-(UInt16) readLibVer;

This will return the current BLEShield framework version.
-(UInt16) readFrameworkVersion;

This will return the vendor name, which is "Red Bear Lab."
-(NSString *) readVendorName;

This is for checking if it connected to a BLE device.
-(BOOL) isConnected;

This is for searching BLE devices.
-(int) findBLEPeripherals:(int) timeout;

This is for connecting to a BLE device. 
-(void) connectPeripheral:(CBPeripheral *)peripheral;



Program flow:

When the App starts, it will call viewDidLoad, and there, we need to init the BLE framework,

    bleShield = [[BLE alloc] init];
    [bleShield controlSetup:1];
    bleShield.delegate = self;

The App has a button for scanning available BLE devices, this button calls BLEShieldScan action. If connected before, it will disconnect the current connection.

Once connected, you can type text to BLE device and it will shows typed text to serial.


-----

2. Chat_Sketch

Connect your Arduino with BLE Shield to PC. Use Serial Monitor to type and receive data.

Serial Monitor settings:
-Carriage return
-57600 baud

Text typed from iPhone will be transferred to PC and vice versa.

The program first setup SPI pins and then it initials the BLE library by using ble_begin().

And then it enters to the loop() which doing some tasks repeatedly.

The loop first reads if any data comes from iOS App using ble_available() and ble_read() and if so, it will send it out via the Serial interface of Arduino.

And then it reads from Serial port to see any data from PC, if so, it transfers data using ble_write() to send to iOS App.

Currently, you can send up to 19 bytes at a time.

After all, it calls ble_do_events() so that to allow the low layer BLE library to do its house-keeping tasks.








