#!/bin/sh

source /etc/init.d/ulog_functions.sh
source /etc/init.d/event_handler_functions.sh

SERVICE_NAME="transmission"
SELF_NAME="`basename $0`"

DAEMON=/opt/bin/transmission-daemon
PID_FILE=/var/run/transmission.pid
CFG_DIR=/mnt/sda1/.transmission

STOP_TIMEOUT=3

do_start() {
   # echo "[utopia] Starting transmission daemon" > /dev/console                            
   export TRANSMISSION_WEB_HOME="/mnt/sda1/.transmission/web"
   
#   start-stop-daemon --start \
#   --pidfile $PID_FILE \
#   --exec $DAEMON -- --pid-file $PID_FILE --config-dir $CFG_DIR
#   iptables -I INPUT -p tcp --dport 9393:9595 -j ACCEPT                                     

   transmission-daemon --pid-file $PID_FILE --config-dir $CFG_DIR
   # sysevent set transmission_daemon_state up
}

do_stop() {
   # echo "[utopia] Stopping transmission daemon" > /dev/console
   # sysevent set transmission_daemon_state down

#   start-stop-daemon --stop --quiet \
#   --pidfile $PID_FILE \
#   --exec $DAEMON --retry $STOP_TIMEOUT \
#   --oknodo

   kill -9 `cat $PID_FILE`
   rm -f $PID_FILE
#   iptables -D INPUT -p tcp --dport 9393:9595 -j ACCEPT
   export -n TRANSMISSION_WEB_HOME
}

service_start() {

   wait_till_end_state ${SERVICE_NAME}                                                       

   STATUS=`sysevent get ${SERVICE_NAME}-status`                                              

   if [ "started" != "$STATUS" ] ; then                                                      
      sysevent set ${SERVICE_NAME}-errinfo                                                    
      sysevent set ${SERVICE_NAME}-status starting                                            

      echo "Starting ${SERVICE_NAME} ... "
      
      if [ ! -f "$PID_FILE" ] ; then                                                    
         do_start
      fi
      
      check_err $? "Couldnt handle start"                                                     
      sysevent set ${SERVICE_NAME}-status started                                             
   fi
                                                                                           
   sysevent set ${SERVICE_NAME}-isready yes

#   ulog ${SERVICE_NAME} status "starting ${SERVICE_NAME} service" 

#   if [ ! -f "$PID_FILE" ] ; then
#     do_start
#   fi
   
#   sysevent set ${SERVICE_NAME}-errinfo
#   sysevent set ${SERVICE_NAME}-status "started"
}

service_stop () {

   wait_till_end_state ${SERVICE_NAME}                                                       

   STATUS=`sysevent get ${SERVICE_NAME}-status`                                              

   if [ "stopped" != "$STATUS" ] ; then                                                      
      sysevent set ${SERVICE_NAME}-errinfo                                                    
      sysevent set ${SERVICE_NAME}-status stopping                                            

      echo "Stoppping ${SERVICE_NAME} ..."                                                    

      if [ -f "$PID_FILE" ] ; then                                                            
         do_stop                                                                              
      fi

      sleep 1                                                                                 

      check_err $? "Couldnt handle stop"                                                      
      sysevent set ${SERVICE_NAME}-status stopped                                             
   fi                                                                                        

   sysevent set ${SERVICE_NAME}-isready no                                                   

#   ulog ${SERVICE_NAME} status "stopping ${SERVICE_NAME} service" 

#   if [ -f "$PID_FILE" ] ; then
#      do_stop
#   fi

#   sysevent set ${SERVICE_NAME}-errinfo
#   sysevent set ${SERVICE_NAME}-status "stopped"
}

service_lanwan_status ()
{
   CURRENT_WAN_STATE=`sysevent get wan-status`
   CURRENT_LAN_STATE=`sysevent get lan-status`      

   if [ "started" = "$CURRENT_WAN_STATE" ] && [ -d "$CFG_DIR" ] ; then
     service_stop
     service_start
   else
     service_stop
   fi
}

service_mountremove_usb_drive ()
{
   CURRENT_WAN_STATE=`sysevent get wan-status`                        
   CURRENT_LAN_STATE=`sysevent get lan-status`
        
   if [ "started" = "$CURRENT_WAN_STATE" ] && [ -d "$CFG_DIR" ] ; then
      service_stop
      service_start
   else
      service_stop
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
  mount_usb_drives)
      service_mountremove_usb_drive
      ;;
  remove_usb_drives)                                                                               
      service_mountremove_usb_drive
      ;;      
  *)
        echo "Usage: $SELF_NAME [${SERVICE_NAME}-start|${SERVICE_NAME}-stop|${SERVICE_NAME}-restart|ssh_server_restart|lan-status|wan-status]" >&2
        exit 3
        ;;
esac
