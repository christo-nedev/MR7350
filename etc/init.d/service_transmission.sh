#!/bin/sh

source /etc/init.d/ulog_functions.sh
source /etc/init.d/event_handler_functions.sh

SERVICE_NAME="transmission"

PID_FILE=/var/run/transmission.pid
CFG_DIR=/mnt/sda1/.transmission

SELF_NAME="`basename $0`"

service_start() {

   wait_till_end_state ${SERVICE_NAME}

   STATUS=`sysevent get ${SERVICE_NAME}-status`

   if [ "started" != "$STATUS" ] ; then
      sysevent set ${SERVICE_NAME}-errinfo
      sysevent set ${SERVICE_NAME}-status starting

      echo "starting ${SERVICE_NAME} ..."

      if [ ! -f "$PID_FILE" ] ; then
         # echo "[utopia] Starting transmission daemon" > /dev/console
         iptables -I INPUT -p tcp --dport 9393:9595 -j ACCEPT
         export TRANSMISSION_WEB_HOME="$CFG_DIR/web"
         transmission-daemon --pid-file $PID_FILE --config-dir $CFG_DIR
      fi

      check_err $? "Couldnt handle start"
      sysevent set ${SERVICE_NAME}-status started
   else
      echo "${SERVICE_NAME} already started ..."
   fi

   sysevent set ${SERVICE_NAME}-isready yes
}

service_stop () {

   wait_till_end_state ${SERVICE_NAME}

   STATUS=`sysevent get ${SERVICE_NAME}-status`

   if [ "stopped" != "$STATUS" ] ; then
      sysevent set ${SERVICE_NAME}-errinfo
      sysevent set ${SERVICE_NAME}-status stopping

      echo "stoppping ${SERVICE_NAME} ..."

      if [ -f "$PID_FILE" ] ; then
         # echo "[utopia] Stopping transmission daemon" > /dev/console
         kill -9 `cat $PID_FILE`
         rm -f $PID_FILE
         export -n TRANSMISSION_WEB_HOME
         iptables -D INPUT -p tcp --dport 9393:9595 -j ACCEPT
      fi

      sleep 1

      check_err $? "Couldnt handle stop"
      sysevent set ${SERVICE_NAME}-status stopped
   else
      echo "${SERVICE_NAME} already stoped ..."
   fi

   sysevent set ${SERVICE_NAME}-isready no
}

service_set_status ()
{
   WAN_STATE=`sysevent get wan-status`
   FIREWALL_STATE=`sysevent get firewall-status`

   if [ "started" = "$WAN_STATE" ] && [ "started" = "$FIREWALL_STATE" ] && [ -d "$CFG_DIR" ] ; then
     service_start
   else
     service_stop
   fi
}

case "$1" in
  ${SERVICE_NAME}-start)
      service_set_status
      ;;
  ${SERVICE_NAME}-stop)
      service_stop
      ;;
  ${SERVICE_NAME}-restart)
      service_stop
      service_set_status
      ;;
  lan-status)
      service_set_status
      ;;
  wan-status)
      service_set_status
      ;;
  firewall-status)
      service_set_status
      ;;
  mount_usb_drives)
      service_set_status
      ;;
  remove_usb_drives)
      service_set_status
      ;;
  *)
      echo "Usage: $SELF_NAME [${SERVICE_NAME}-start|${SERVICE_NAME}-stop|${SERVICE_NAME}-restart|ssh_server_restart|lan-status|wan-status]" >&2
      exit 3
      ;;
esac

