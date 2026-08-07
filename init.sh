#!/bin/bash

sleep 2
systemctl enable --now lms

sleep 2
state=false && rpc amtinfo | grep -q "pre-provisioning state" && state=true

if [ -z "$(ls -A /agent/.data)" ]; then 
    clean=true
else
    clean=false
    echo -e "\n\nPurging cache and any old logs..." > /dev/console
    rm -fR /agent/.data/*
    rm -fR /agent/logs/*
fi

if [ $state = "true" ]; then
    echo -e "\nIntel(R) vPro Fleet Services agent is activating this device." > /dev/console
    echo -e "\n\n\n***** Please leave the device powered on. *****\n\n\n" > /dev/console
    sleep 5 && tail -f /agent/logs/log* | jq . > /dev/console &
    cd /agent && ./IntelvProFleetServicesAgent run --log-level=debug
    echo -e "\n\n\n\n\n" > /dev/console
    if grep -q -m 1 -o "Activation result: Finished successfully" /agent/logs/*; then
        echo -e "Success! This device can now be managed in Intel(R) vPro Fleet Services!\n\n\n" > /dev/console
    else
        echo "This device was not able to be activated.  Please review the logs and resolve any outstanding issues." > /dev/console
        echo -e "\n\n" > /dev/console
        echo "The most common causes of a failed activation are:" > /dev/console
        echo " - Non-Intel network connection.  This includes:" > /dev/console
        echo "   - Connected to a non-AMT approved docking station" > /dev/console
        echo "   - Active VPN connections" > /dev/console
        echo " - Outbound traffic restrictions.  Such as:" > /dev/console
        echo "   - Proxy configuration required" > /dev/console
        echo "   - Port 4433 or 8443 blocked" > /dev/console
        echo -e "Review the guides in the vPro Fleet Services web portal for additional troubleshooting information.\n\n\n" > /dev/console
    fi
else
    echo -e "\n\n\n\nHmm, it looks like this device is NOT ready to be activated.  We'll need to stop here.\n\n" > /dev/console
    echo -e "Please clear any lingering activation states and try again.\n\nExiting...\n\n\n"  > /dev/console
fi

echo "Shutting down in 5 seconds..." > /dev/console
sleep 5
systemctl poweroff --force
