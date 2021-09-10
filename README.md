# linksys-mr7350
dropbear (SSH) and transmission to mr7350

Serial UART -> check serial.jpg

cd tmp

curl -LJOk https://github.com/christo-nedev/linksys-mr7350/archive/refs/heads/main.zip

unzip linksys-mr7350-main.zip -d /tmp/var/config/opt

rm master.zip

ln -s /tmp/var/config/opt /tmp/opt

ln -s /tmp/var/config/opt/etc/registration.d /tmp/var/config/run_script

reboot
