kiosk
=====

A kiosk app written in Nimrod for a Raspberry Pi based computer

This project includes incomplete libraries for
libusb
USB CCID interface
ACR122U driver
wiringpi

I intend to split these into separate projects.

The kiosk features:
* Add user accounts with balance
* Register user accounts to RFID cards
* Use RFID cards to log in
* Purchase products (subtract from user balance)
* Adjust balance (add/remove money)
* JSON data storage

Products must currently be added manually to the JSON data file.

The following screenshots shows the computer the app was built for.

![Screenshot1](https://raw.githubusercontent.com/skyfex/kiosk/master/screenshots/IMG_0004.JPG)
![Screenshot2](https://raw.githubusercontent.com/skyfex/kiosk/master/screenshots/IMG_0005.JPG)
