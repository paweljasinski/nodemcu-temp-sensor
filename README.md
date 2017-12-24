# nodemcu-temp-sensor
Lua scripts to capture temperature sensor reading

What you need:
- esp8266 controller, with 4MB flash (e.g. wemos D1 mini, or lolin v3)
- ads1015 (tested) or ads1115
- temperature sensor, KTX-81-110
- resistors, 2 x 3k3, 1 x 1k
- patch cables
- usb power supplier
- env to flash esp/upload code to esp (pc)

Wiring:
 
``` 
  +-----+---------------+--------------->> +3.3
  |     |               |                                  
  |     |          ---------------------           ------ 
  |     |          |   VDD(8)          |           |
  |     |          |                   |           |
  1k    KTX        |      ADS1x15      |           |  esp8266
  |     |          |                   |           |
  +----------------| AIN1(4)    SCL(10)|-----------| D1
  |     +----------| AIN0(5)    SDA(9) |-----------| D2
  |     |          |                   |           |
  |     |          |   GND(3) ADDR(1)  |           |
  3k3   3k3        ---------------------           ------
  |     |               |       |
  |     |               |       |
  +-----+---------------+-------+------->> GND
```

What needs to be configured in config.lue:
- access point name and key

Firmware:
1. floating build
2. enabled modules: ads1115,encoder,file,gpio,http,i2c,net,node,rtctime,sntp,tmr,uart,wifi

What happens on boot:
1. wifi is up, ip is obtained
2. time is synchronized using ntp
3. once a minute write utc timestamp and input reading to temp.log file

TODO:
1. provide temperature reading in Celcius
2. a way to retrieve temp.log (other than esplorer)
