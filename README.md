This script will allow you to replace the log & alert server across all your gateway types on a given MDS or SMS server. If using MDS you will need to run the script for each domain separately.  

## How to use ##
 - cp scripts over to mgmt station (this script is intended to run directly on the mgmt station)
    - I highly recommend that you do this in it's own folder
 - execute ./replace_log_alerts_server.sh
    - Follow the prompts
    - Output will be in a txt mgmt_cli-replace-logging-alert.txt-$DOMAIN.txt ($DOMAIN will the IP of your domain or SMS)
      - this file is already executable and will contain all of the mgmt_cli to make the changes simply execute './mgmt_cli-replace-logging-alert.txt-$DOMAIN.txt'

##Enjoy!##
