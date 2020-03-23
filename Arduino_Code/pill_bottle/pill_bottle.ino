
#include <bluefruit.h>
#define SENSORTHRESHOLD 450

int solenoidPin = 16;                    //This is the output pin on the Arduino
int lockPin = 15;
int pillSensorPin = A2;

// BLE Service
BLEDfu  bledfu;  // OTA DFU service
BLEDis  bledis;  // device information
BLEUart bleuart; // uart over ble


// Function prototypes for packetparser.cpp
uint8_t readPacket (BLEUart *ble_uart, uint16_t timeout);
void    printHex   (const uint8_t * data, const uint32_t numBytes);

// Packet buffer
extern uint8_t packetbuffer[];

// callback invoked when central connects
void connect_callback(uint16_t conn_handle)
{
  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
}

/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;

  Serial.println();
  Serial.print("Disconnected, reason = 0x"); Serial.println(reason, HEX);
}

void setup() {
  
  Serial.begin(115200);
  while ( !Serial ) delay(10);   // for nrf52840 with native usb
  Serial.println("BLEUART");

  Bluefruit.begin();
  Bluefruit.setTxPower(4);    // Check bluefruit.h for supported values
  Bluefruit.setName("PILL_BOTTLE");

  // To be consistent OTA DFU should be added first if it exists
  bledfu.begin();
  
  // Configure and Start Device Information Service
  bledis.setManufacturer("IOT");
  bledis.setModel("PILL_BOTTLE");
  bledis.begin();

  // Configure and start the BLE Uart service
  bleuart.begin();
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);
  
  // Set up and start advertising
  startAdv();
  //set up pins
  setup_pins();
}

void startAdv(void)
{
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  // Include bleuart 128-bit uuid
  Bluefruit.Advertising.addService(bleuart);

  // Secondary Scan Response packet (optional)
  // Since there is no room for 'Name' in Advertising packet
  Bluefruit.ScanResponse.addName();
  
  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

void setup_pins() {
  pinMode(solenoidPin, OUTPUT);
  digitalWrite(solenoidPin, LOW);

  pinMode(lockPin, OUTPUT);
  digitalWrite(lockPin, HIGH);
}

void lock_bottle() {
  digitalWrite(lockPin, HIGH);
}

void unlock_bottle() {
  digitalWrite(lockPin, LOW);
}

void release_pill() {
  digitalWrite(solenoidPin, HIGH);
  delay(100);
  digitalWrite(solenoidPin, LOW);
}

void send_pill_state() {
  char buf[8];
  buf[0] = 'p';
  buf[1] = ('0');
  float sensorValue = analogRead(pillSensorPin);
  Serial.println(sensorValue);
  if(sensorValue < SENSORTHRESHOLD)
    buf[1] = ('1');

  int count = 2;
  bleuart.write( buf, count );
}

void parse_ble_msg() {

  if (packetbuffer[0] == 'u') {
    Serial.print ("bottle unlocked");
    unlock_bottle();
  }
  if (packetbuffer[0] == 'l') {
    Serial.print ("bottle locked");
    lock_bottle();
  }
  if (packetbuffer[0] == 'p') {
    Serial.print ("release pill");
    release_pill();
    send_pill_state();
  }
}

void loop() {
// Wait for new data to arrive

  uint8_t len = readPacket(&bleuart, 100);
  //Serial.write(len);
  if (len == 0) return;

  // Got a packet!
  //printHex(packetbuffer, len);
   
  if (len != 0) parse_ble_msg();

}
