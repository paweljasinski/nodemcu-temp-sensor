# nodemcu-temp-sensor

## Lua scripts to capture temperature sensor reading

What you need:
- esp8266 controller, with 4MB flash (e.g. wemos D1 mini, or lolin v3)
- ads1015 (tested) or ads1115
- temperature sensor, KTX-81-110
- resistors, 2 x 3k3, 1 x 1k
- patch cables
- usb power supplier
- env to flash esp/upload code to esp (pc)

Note: you can use different KTX-81-xxx sensor and adjust the resistor values.
For example, using KTX-81-210, replace 1k with 2k, 3k3 with 6k8.

Wiring:
 
``` 
  +-----+---------------+--------------->> +3.3
  |     |               |                                  
  |     |          ---------------------           ------ 
  |     |          |   VDD(8)          |           |
  |     |          |                   |           |
  1k    KTX        |      ADS1x15      |           |  wemos D1 mini (esp8266)
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

## What needs to be configured in config.lue:
- access point name and key

## Firmware:
- float build
- enabled modules: ads1115,encoder,file,gpio,http,i2c,net,node,rtctime,sntp,tmr,uart,wifi

## What happens on boot:
- wifi is up, ip is obtained
- time is synchronized using ntp
- once a minute write utc timestamp and input reading to temp.log file

## Read out value:
Current value as well as entire log can be retrieved over the network.

Retrieve single value
```
echo -n "value" | nc -q1 -v  192.168.1.105 4242
```


Retrieve entire log
```
echo -n "log" | nc -q1 -v  192.168.1.105 4242
```

## TODO:
- store temperature reading in Celcius
- allow for calibration
- find out the device (mdns?)
- use standard protocol for communication
- add missing capacitors

## Why not to use build-in analog input of esp?
The build in analog converter is 10 bit and measure relative to GND
(no differential mode). Small changes of temperature (0.1 °C) are smaller than quantization step.
The exact calculation:

- temperature range: 70 °C (-20..+50)
- resistance change: 525 Ω (684..1209)
- voltage delta when connected with 3k3 resistor: 9.64% (684/(684+3300)-1209/(1209+3300))
- discrete steps: 99 (1024 * 0.0964)
- discrete steps per °C: 99/70 = 1.41 which is less than 2 discrete steps per °C


## References:
[KTY81 series Silicon temperature sensors](http://www.micropik.com/PDF/KTY81.pdf)

[General Silicon sensors for temperature measurement](https://www.mikrocontroller.net/attachment/243481/KTY-Philips.pdf)

[ADS1015](http://www.ti.com/lit/ds/symlink/ads1015.pdf)

[ADS1115](http://www.ti.com/lit/ds/symlink/ads1115.pdf)

[wemos D1](https://wiki.wemos.cc/products:d1:d1_mini)

