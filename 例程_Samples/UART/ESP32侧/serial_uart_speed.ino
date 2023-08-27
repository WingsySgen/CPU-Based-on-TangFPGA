#include<HardwareSerial.h>

hw_timer_t * timer = NULL;

int cnt;
void IRAM_ATTR onTimer(){
    Serial.println(cnt);
    cnt = 0;
}

HardwareSerial serial_1(2);
void setup() {
  // put your setup code here, to run once:
    serial_1.begin(115200, SERIAL_8N1, 18, 19);
    //18接收  19发送
    Serial.begin(115200);
    timer = timerBegin(0, 80, true);
    timerAttachInterrupt(timer, &onTimer, true);
    timerAlarmWrite(timer, 1000000, true);
    timerAlarmEnable(timer);
}

void loop() {
  // put your main code here, to run repeatedly:
    char c;
    while(serial_1.available()){
        c = serial_1.read();
        ++cnt;
    }
}
