#!/bin/sh

source /etc/init.d/service_registration_functions.sh

SERVICE_NAME="sshd"

SERVICE_DEFAULT_HANDLER="/opt/etc/init.d/service_${SERVICE_NAME}.sh"

SERVICE_CUSTOM_EVENTS="\
                        lan-status|$SERVICE_DEFAULT_HANDLER; \
                        wan-status|$SERVICE_DEFAULT_HANDLER; \
                        bridge-status|$SERVICE_DEFAULT_HANDLER \
                      "

do_stop() {
   sm_unregister $SERVICE_NAME   
}

do_start () {
   sm_register $SERVICE_NAME $SERVICE_DEFAULT_HANDLER "$SERVICE_CUSTOM_EVENTS" 
}
  
case "$1" in
   start|"")
      do_start
      ;;
   restart|reload|force-reload)
      do_start
      ;;
   stop)
      do_stop
      ;;

   *)
      echo "Usage: $SERVICE_NAME [start|stop|restart]" >&2
      exit 3
      ;;
esac

