-- show analog input
--
function blinker_on(count)
    if count == 0 then return end
    gpio.write(4, 0)
    one_shot = tmr.create()
    one_shot:alarm(25, tmr.ALARM_SINGLE, function()
        blinker_off(count)
    end)
end

function blinker_off(count)
    gpio.write(4, 1)
    one_shot = tmr.create()
    one_shot:alarm(100, tmr.ALARM_SINGLE, function()
        blinker_on(count-1)
    end)
end

id, scl, sda = 0, 1, 2
i2c.setup(id, sda, scl, i2c.SLOW)
ads1115.setup(ads1115.ADDR_GND)
ads1115.setting(ads1115.GAIN_0_512V, ads1115.DR_8SPS, ads1115.DIFF_0_1, ads1115.CONTINUOUS)

blinker_on(5)

main_timer = tmr.create()
main_timer:alarm(60000, tmr.ALARM_AUTO, function()
    blink()
    volt, volt_dec, adc = ads1115.read()
    print(volt)
	fd = file.open("temp.log", "a+")
	if fd then
  		fd:write(rtctime.get())
        fd:write(" ")
        fd:writeline(volt)
	    fd:close()
	end
end)

