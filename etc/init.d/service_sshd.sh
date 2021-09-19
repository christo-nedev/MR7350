#!/bin/sh

source /etc/init.d/ulog_functions.sh

SERVICE_NAME="sshd"
SELF_NAME="`basename $0`"

PID_FILE=/var/run/dropbear.pid
PMON=/etc/init.d/pmon.sh

service_start() {
   ulog ${SERVICE_NAME} status "starting ${SERVICE_NAME} service" 

   if [ ! -f "$PID_FILE" ] ; then
     # echo "[utopia] Starting SSH daemon" > /dev/console
     dropbear -r /etc/dropbear_rsa_host_key
     sysevent set ssh_daemon_state up
   fi

   $PMON setproc ssh dropbear $PID_FILE "/opt/etc/init.d/service_sshd.sh sshd-restart"
   
   sysevent set ${SERVICE_NAME}-errinfo
   sysevent set ${SERVICE_NAME}-status "started"
}

service_stop () {
   ulog ${SERVICE_NAME} status "stopping ${SERVICE_NAME} service" 

   if [ -f "$PID_FILE" ] ; then
      # echo "[utopia] Stopping SSH daemon" > /dev/console
      sysevent set ssh_daemon_state down
      kill -9 `cat $PID_FILE`
      rm -f $PID_FILE
   fi

   $PMON unsetproc ssh 

   sysevent set ${SERVICE_NAME}-errinfo
   sysevent set ${SERVICE_NAME}-status "stopped"
}

service_lanwan_status ()
{
      CURRENT_LAN_STATE=`sysevent get lan-status`
      CURRENT_WAN_STATE=`sysevent get wan-status`
     
      if [ "stopped" = "$CURRENT_LAN_STATE" ] && [ "stopped" = "$CURRENT_WAN_STATE" ] ; then
         service_stop
      else
         service_start
      fi
}

service_bridge_status ()
{
      CURRENT_BRIDGE_STATE=`sysevent get bridge-status`

      if [ "stopped" = "$CURRENT_BRIDGE_STATE" ] ; then
         service_stop
      elif [ "started" = "$CURRENT_BRIDGE_STATE" ] ; then
         service_start
      fi
}

case "$1" in
  ${SERVICE_NAME}-start)
      service_start
      ;;
  ${SERVICE_NAME}-stop)
      service_stop
      ;;
  ${SERVICE_NAME}-restart)
      service_stop
      service_start
      ;;
  lan-status)
      service_lanwan_status
      ;;
  wan-status)
      service_lanwan_status
      ;;
  bridge-status)
      service_bridge_status
      ;;
  *)
      echo "Usage: $SELF_NAME [${SERVICE_NAME}-start|${SERVICE_NAME}-stop|${SERVICE_NAME}-restart|ssh_server_restart|lan-status|wan-status]" >&2
      exit 3
      ;;
esac
