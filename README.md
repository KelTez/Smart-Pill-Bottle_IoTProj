# Smart-Pill-Bottle_IoTProj
A smart pill dispenser used for tracking user pill adherence:
* Utilizes a Bluefruit microcontroller for easy bluetooth usage
* Mobile app to be built using flutter
* To start with flutter, simply follow the steps illustrated [here](http://flutter.io/setup)
* For flutter bluetooth, [here](https://pub.dev/packages/flutter_blue)
* Other resources to get started with flutter blue [here](https://medium.com/flutter-community/flutter-adding-bluetooth-functionality-1b9715ccc698) and [here](https://blog.kuzzle.io/communicate-through-ble-using-flutter)
* Useful apps for testing: [Bluefruit Connect IOS](https://apps.apple.com/ca/app/bluefruit-connect/id830125974), [Bluefruit Playground IOS](https://apps.apple.com/us/app/bluefruit-playground/id1489549571), [Bluefruit Connect Android](https://play.google.com/store/apps/details?id=com.adafruit.bluefruit.le.connect&hl=en_CA), [Bluefruit Playground Android](https://play.google.com/store/apps/details?id=com.adafruit.bluefruit_playground&hl=en_CA)
* To test the device with the apps mentioned above, simply send a UART message with character 'u' to unlock the dispenser, 'l' to lock.

