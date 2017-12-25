function blinker_on(count)
    gpio.write(4, 0)
    one_shot = tmr.create()
    one_shot:alarm(25, tmr.ALARM_SINGLE, function()
        blinker_off(count)
    end)
end

function blinker_off(count)
    gpio.write(4, 1)
    if count <= 0 then
        return
    end
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

function done(socket)
    socket:close()
end

sv = net.createServer(net.TCP, 10)
if sv then
    sv:listen(4242, function(socket)
        socket:on("receive", dispatch)
    end)
end

function dispatch(socket, data)
    if data == "value" then
        socket:send(volt, done)
        return
    end
    if data == "log" then
        send_temp_log(socket)
        return
    end
    socket:send("unrecognized command: "..data, done)
end

function send_temp_log(socket)
    local fd = file.open("temp.log", "r")
    if not fd then
        socket:send("failed to open log", done)
        return
    end
    socket:on("disconnection", function()
        fd:close()
    end)
    local function send_next_line(socket)
        local buf = fd:read(512)
        if buf then
            socket:send(buf)
        else
            fd:close()
            socket:close()
            collectgarbage()
        end
    end
    socket:on("sent", send_next_line)
    send_next_line(socket)
end


volt = 0
main_timer = tmr.create()
main_timer:alarm(6000, tmr.ALARM_AUTO, function()
    blink()
    volt, volt_dec, adc = ads1115.read()
    print(volt)
    local fd = file.open("temp.log", "a+")
    if fd then
        fd:write(rtctime.get())
        fd:write(" ")
        fd:writeline(volt)
        fd:close()
    end
end)

