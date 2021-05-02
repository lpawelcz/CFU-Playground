# GEM sfabric test - A
# requires: ftdilib-dev sfabric
# purpose:
# communicate with interposer via sfabric script and FTDI JTAG
# reads chip ID and enters LED blink loop
# tested with FT232H and 1.2.0 baseboard + Gem1

# FTDI permission denied?
# sudoedit /etc/udev/rules.d/51-ftdi.rules
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666"
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="0666"
# ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="0666"

set -x
sudo systemctl stop ModemManager.service 
sudo rmmod ftdi_sio qcserial usb_wwan
sudo rmmod usbserial

sfabric get devs 1 2>/dev/null
# search for programmer ID : 0x3, 0x7 excluded
FID=$(sfabric get devs 1 2>/dev/null| awk '/Dev/ {no=$2} /Type=/ {if (!(($1~'0x3')||($1~'0x7'))) {print no;exit;}}')
#FID=0
echo Using FTDI device $FID

sfabric set ftdevid $FID
sfabric init
sleep 0.3
sfabric chipid # - not always works, but proceeds anyway
sfabric led configdef 1
sfabric led enable 1

sudo modprobe usbserial 
sudo modprobe ftdi_sio
ls /dev/ttyUSB*
