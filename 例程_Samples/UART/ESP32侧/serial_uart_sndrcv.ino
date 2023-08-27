#include<HardwareSerial.h>

HardwareSerial serial_1(2);
void setup() {
  // put your setup code here, to run once:
    serial_1.begin(115200, SERIAL_8N1, 18, 19);
    serial_1.setRxBufferSize(8192);
    //18接收  19发送
    Serial.begin(115200);
    // serial_1.write("hello world\n");
}

char c;
String s = "hello world\n";
// String s = "hello";
String ans;
void loop() {
    ans.clear();
    // Serial.print(s);
    for (auto it : s){
        serial_1.write(it);
        delay(500);
        // while(serial_1.available()) 
            c = serial_1.read(), ans += c;
    }
    Serial.print(ans);
    delay(500);
}
