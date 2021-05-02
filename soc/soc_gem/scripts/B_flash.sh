# GEM sfabric test - B
# requires: ftdilib-dev sfabric iceprog
# 1.2.0 mechanical switch must be set to CTRL
# purpose:
# upload SPI Flash programming map to interposer
# read Flash chip ID
# program Flash with FPGA's boot image
# verify write

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
FID=$(sfabric get devs 1 2>/dev/null| awk '/Dev/ {no=$2} /Type=/ {if (!(($1~'0x3')||($1~'0x7'))) {print no;exit;}}')
echo Using FTDI device $FID
sfabric set ftdevid $FID
sfabric init

sfabric reg program $GEM_FLASH_MAP
sfabric reg compare $GEM_FLASH_MAP -

#verify flash ID
sudo iceprog -I B -d i:0x0403:0x6011 -t
sleep 1
#bulk erase
sudo iceprog -I B -d i:0x0403:0x6011 -b
sudo iceprog -I B -d i:0x0403:0x6011 -t
sleep 1
#upload
sudo iceprog -I B -d i:0x0403:0x6011 $CFU_GATEWARE
#upload bios
sudo iceprog -I B -d i:0x0403:0x6011 -o 0x020000 $CFU_BIOS
#sudo iceprog -I B -d i:0x0403:0x6011 combined_image.bin

sudo modprobe usbserial 
sudo modprobe ftdi_sio
ls /dev/ttyUSB*
