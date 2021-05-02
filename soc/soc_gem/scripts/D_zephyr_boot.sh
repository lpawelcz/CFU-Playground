# GEM sfabric test - D
# requires: ftdilib-dev sfabric
# purpose:
# program interposer with map allowing proper FPGA boot (from SPI Flash)
# Gem1.D1 module has this map preprogrammed in OTP ROM

# FTDI permission denied?
# sudoedit /etc/udev/rules.d/51-ftdi.rules
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666"
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="0666"
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="0666"

set -x

sudo systemctl stop ModemManager.service 
sudo rmmod ftdi_sio qcserial usb_wwan
#sleep 1
sudo rmmod usbserial
#sleep 1
sfabric get devs 1 2>/dev/null
FID=$(sfabric get devs 1 2>/dev/null| awk '/Dev/ {no=$2} /Type=/ {if (!(($1~'0x3')||($1~'0x7'))) {print no;exit;}}')
echo Using FTDI device $FID
sfabric set ftdevid $FID
sfabric init

# upload interposer map necessary for Zephyr boot
sfabric reg program segger_2565_dragon.csv
sleep 1
sfabric reg compare segger_2565_dragon.csv -
sleep 1

sudo modprobe usbserial 
sudo modprobe ftdi_sio
ls /dev/ttyUSB*
