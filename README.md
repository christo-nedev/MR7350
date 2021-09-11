# linksys-mr7350
dropbear and transmission for mr7350

Serial UART -> Serial UART.png

mkdir /tmp/var/config/opt

cd tmp

curl -LJOk https://github.com/christo-nedev/linksys-mr7350/archive/refs/heads/main.zip

unzip linksys-mr7350-main.zip -d /tmp/var/config/opt

rm linksys-mr7350-main.zip

ln -s /tmp/var/config/opt/etc/registration.d /tmp/var/config/run_script

reboot
