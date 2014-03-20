#!/bin/bash

source inc/functions
source inc/ew_connector

SUMMARYFILE="$OUTPUT/$MONTH-mbox_summary.csv"

ACCOUNTQUERY="https://$DASHBOARD/api/account/list?token=$TOKEN"
ACCOUNTLIST=$(curl -s $ACCOUNTQUERY)
printf "$ACCOUNTLIST" > "$XMLACCOUNT"

while read_dom; do
	if [[ "$ENTITY" == account* ]]
	then
	
		ACCOUNT=$(echo $ENTITY | awk -F\" '{print $2}')
		ACCOUNTID=$(echo $ENTITY | awk -F\" '{print $4}')
#		echo "Found account ID# "$ACCOUNTID $ACCOUNT
		
#		echo "Looking up "$ACCOUNT" domains"
		
		sleep 2
		
		DOMAINQUERY="https://$DASHBOARD/api/domain/list?token=$TOKEN&account=$ACCOUNTID"
		DOMAINLIST=$(curl -s $DOMAINQUERY)
		printf "$DOMAINLIST" > "$XMLDOMAINS"
		
		while read_dom; do
			if [[ "$ENTITY" == domain* ]]
			then
				DOMAIN=$(echo $ENTITY | awk -F\" '{print $2}')
				ACCOUNTID=$(echo $ENTITY | awk -F\" '{print $6}')
#				echo "Found "$DOMAIN" under account "$ACCOUNT
				
				CSVFILE="$OUTPUT/$MONTH-$ACCOUNTID-mbox_list.csv"
				MBOXQUERY="https://$DASHBOARD/api/mailbox/list?token=$TOKEN&domain=$DOMAIN"
				MBXLIST=$(curl -s $MBOXQUERY)
#				echo "Writing mailboxes to $CSVFILE"
				
				printf "$MBXLIST" > "$XMLMBOX"
				MBOXCOUNTER=0
				while read_dom; do
#					echo $ENTITY
					if [[ "$ENTITY" == *active* && "$ENTITY" != *inactive* ]]
					then
						MBOXCOUNTER=$((MBOXCOUNTER + 1))
				    	USERNAME=$(echo $ENTITY | awk -F\" '{print $2}')
						echo $DOMAIN","$USERNAME"@"$DOMAIN  >> "$CSVFILE"
					fi
				done < "$XMLMBOX"
				rm "$XMLMBOX"
				
				echo $ACCOUNT","$DOMAIN","$MBOXCOUNTER >> "$SUMMARYFILE"
				
			fi
		done < "$XMLDOMAINS"
		rm "$XMLDOMAINS"

#		echo "Finished "$ACCOUNT" domains."
#		echo ""
#		echo ""
#		sleep 2
		


	fi
done < "$XMLACCOUNT"
rm "$XMLACCOUNT"