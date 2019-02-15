printf  "This script will help you globally replace a log server across all gateways.\nUse with caution as it does modify your configuration...\nIf for any reason you make a typo and need to exit use CTRL+C.\nPress ENTER  to continue\n"
read ANYKEY

printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nListing Log Server Names\n"
mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output '."objects"[] | select(."management-blades"."logging-and-status"==true) | (.name)'

printf "\nWhat is the Log Server you want to remove?\n"
read REMOVE_LOG

printf "\nGathering Remove Log Server UID\n"
REMOVE_LOG_UID=$(mgmt_cli -r true -d $DOMAIN show gateways-and-servers limit 500 --format json | jq --raw-output --arg r $REMOVE_LOG '.objects[] | select(.name==$r) | .uid')
printf "the UID for the $REMOVE_LOG is $REMOVE_LOG_UID\n"

printf "\nWhat is the Log Server you want to add?\n"
read ADD_LOG

printf "\nGathering Add Log Server UID\n"
ADD_LOG_UID=$(mgmt_cli -r true -d $DOMAIN show gateways-and-servers limit 500 --format json | jq --raw-output --arg a $ADD_LOG '.objects[] | select(.name==$a) | .uid')
printf "the UID for the $ADD_LOG is $ADD_LOG_UID\n"

printf "\nGenerating Mgmt_CLI Script for Standard Gateways\n"
mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg RBN "$ADD_LOG" '."objects"[] | select(.type=="simple-gateway") | (" set simple-gateway name " + (.name) + " send-logs-to-server.add")' > log-tmp1.txt; sed "s,$, '$ADD_LOG'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN/" log-tmp2.txt > add-log.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg RBN "$REMOVE_LOG" '."objects"[] | select(.type=="simple-gateway") | (" set simple-gateway name " + (.name) + " send-logs-to-server.remove")' > log-tmp1.txt; sed "s,$, '$REMOVE_LOG'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN/" log-tmp2.txt > remove-log.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg RBN "$ADD_LOG" '."objects"[] | select(.type=="simple-gateway") | (" set simple-gateway name " + (.name) + " send-alerts-to-server.add")' > log-tmp1.txt; sed "s,$, '$ADD_LOG'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN/" log-tmp2.txt > add-alerts.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg RBN "$REMOVE_LOG" '."objects"[] | select(.type=="simple-gateway") | (" set simple-gateway name " + (.name) + " send-alerts-to-server.remove")' > log-tmp1.txt; sed "s,$, '$REMOVE_LOG'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN/" log-tmp2.txt > remove-alerts.txt; rm *tmp*.txt; paste -d '\n' add-log.txt remove-log.txt add-alerts.txt remove-alerts.txt > mgmt_cli-replace-logging-alert-gateway.txt; rm *log.txt; rm *alerts.txt;  chmod 777 mgmt_cli-replace-logging-alert-gateway.txt

printf "\nGenerating Mgmt_CLI Script for Clusters\n"
mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" limit 500 --format json | jq --raw-output --arg q "'" '."objects"[] | select(.type=="CpmiGatewayCluster") | ("set-generic-object uid " + $q + (.uid) + $q + " logServers.sendLogsTo.add")' > log-tmp1.txt; sed "s,$, '$ADD_LOG_UID'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN /" log-tmp2.txt > add-log.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg q "'" '."objects"[] | select(.type=="CpmiGatewayCluster") | ("set-generic-object uid " + $q + (.uid) + $q + " logServers.sendLogsTo.remove")' > log-tmp1.txt; sed "s,$, '$REMOVE_LOG_UID'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN /" log-tmp2.txt > remove-log.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg q "'" '."objects"[] | select(.type=="CpmiGatewayCluster") | ("set-generic-object uid " + $q + (.uid) + $q + " logServers.sendAlertsTo.add")' > log-tmp1.txt; sed "s,$, '$ADD_LOG_UID'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN /" log-tmp2.txt > add-alerts.txt; rm *tmp*.txt; mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level "full" --format json | jq --raw-output --arg q "'" '."objects"[] | select(.type=="CpmiGatewayCluster") | ("set-generic-object uid " + $q + (.uid) + $q + " logServers.sendAlertsTo.remove")' > log-tmp1.txt; sed "s,$, '$REMOVE_LOG_UID'," log-tmp1.txt > log-tmp2.txt; sed "s/^/mgmt_cli -s id.txt -d $DOMAIN /" log-tmp2.txt > remove-alerts.txt; rm *tmp*.txt; paste -d '\n' add-log.txt remove-log.txt add-alerts.txt remove-alerts.txt > mgmt_cli-replace-logging-alert-cluster.txt; rm *log.txt; rm *alerts.txt;  chmod 777 mgmt_cli-replace-logging-alert-cluster.txt

cat mgmt_cli-replace-logging-alert-gateway.txt mgmt_cli-replace-logging-alert-cluster.txt > mgmt_cli-replace-logging-alert-$DOMAIN.txt
rm mgmt_cli-replace-logging-alert-cluster.txt
rm mgmt_cli-replace-logging-alert-gateway.txt

sed -i '1s/^/mgmt_cli -r true login > id.txt\n/' mgmt_cli-replace-logging-alert-$DOMAIN.txt
echo "mgmt_cli -s id.txt publish" >> mgmt_cli-replace-logging-alert-$DOMAIN.txt
echo "mgmt_cli -s id.txt logout" >> mgmt_cli-replace-logging-alert-$DOMAIN.txt
chmod +x mgmt_cli-replace-logging-alert-$DOMAIN.txt
echo "You can execute host_set.txt using ./mgmt_cli-replace-logging-alert.txt-$DOMAIN"
