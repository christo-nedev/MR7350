#!/bin/sh

ln -s /tmp/var/config/opt /tmp/opt

sysctl -w net.core.rmem_max=4194304
sysctl -w net.core.wmem_max=1048576

sysctl -w net.ipv4.tcp_adv_win_scale=4

