#!/bin/bash
# GEM fpga/camera test - C
# requires: ftdilib-dev sfabric stty
# 1.2.0 mechanical switch must be set to I2C
# purpose:
# communicate with Zephyr console
# perform blink-by-FPGA test
# configure RPi camera via I2C
# switch MIPI to FPGA
# perform blink-frequency-by-camera-brightness test

# tty permission denied?
# sudoedit /etc/udev/rules.d/50-myusb.rules
# KERNEL=="ttyUSB[0-9]*",MODE="0666"
# KERNEL=="ttyACM[0-9]*",MODE="0666"


chk_devices () {
    for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
        (
            syspath="${sysdevpath%/dev}"
            devname="$(udevadm info -q name -p $syspath)"
            [[ "$devname" == "bus/"* ]] && exit
            eval "$(udevadm info -q property --export -p $syspath)"
            [[ -z "$ID_SERIAL" ]] && exit
            echo -ne "/dev/$devname - $ID_SERIAL\n"
        )
    done
}

# get 3rd port of FTDI quad device
# chk_devices
CONS=$(chk_devices | grep 'FTDI_Quad_RS232' | sort | sed -n 3p | awk '{print $1}' ) 
echo "---- GEM 1 blink & cam test ----"
echo Perform just after reset! /console reconnect or interposer reset/
echo console assumed at $CONS

stty -F $CONS ispeed 115200 ospeed 115200 cs8 -cstopb -parenb raw
sleep 0.5
echo -ne "toggle_mipi\r" > $CONS
echo
echo Programming FPGA
sudo iceprog -I A -d i:0x0403:0x6011 -S camera.bin
echo
echo Blink Test
sleep 1
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS
sleep 0.5
echo -ne "toggle_fpga\r" > $CONS


echo "Camera test (LED brightness)"
sudo ./rpi_i2c_config
sleep 0.5
echo -ne "toggle_mipi\r" > $CONS


