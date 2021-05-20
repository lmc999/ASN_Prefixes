#! /bin/bash
filenameV4=$(curl -s https://publicdata.caida.org/datasets/routing/routeviews-prefix2as/pfx2as-creation.log | tail -n 1 | awk '{print $3}')
downlinkV4=https://publicdata.caida.org/datasets/routing/routeviews-prefix2as/${filenameV4}
filenameV6=$(curl -s https://publicdata.caida.org/datasets/routing/routeviews6-prefix2as/pfx2as-creation.log | tail -n 1 | awk '{print $3}')
downlinkV6=https://publicdata.caida.org/datasets/routing/routeviews6-prefix2as/${filenameV6}

ASN=$1

if [[ "$2" == "4" ]]
	then
		wget -O /tmp/pfx2asV4.gz ${downlinkV4}
		zcat /tmp/pfx2asV4 > /tmp/routeviewsV4.pfx2as
		cat /tmp/routeviewsV4.pfx2as | grep -w ${ASN} >> /tmp/$ASN.draft
		while read -r line || [[ -n $line ]];do
			ip=$(echo $line | awk '{print $1}')
			mask=$(echo $line | awk '{print $2}')
    
			echo ${ip}/${mask} >> ~/$ASN.txt


		done < /tmp/$ASN.draft
		rm -rf /tmp/*.gz /tmp/*.pfx2as /tmp/*.draft
		echo "Successfully Generated AS${ASN} IPv4 Prefixes!"
		echo " "
		echo "Please refer to ~/$ASN.txt"
		echo " "
		
elif [[ "$2" == "6" ]]	
	then
		wget -O /tmp/pfx2asV6.gz ${downlinkV6}
		zcat /tmp/pfx2asV6.gz > /tmp/routeviewsV6.pfx2as
		cat /tmp/routeviewsV6.pfx2as | grep -w ${ASN} >> /tmp/$ASN.draft
		while read -r line || [[ -n $line ]];do
			ip=$(echo $line | awk '{print $1}')
			mask=$(echo $line | awk '{print $2}')
    
			echo ${ip}/${mask} >> ~/$ASN.txt


		done < /tmp/$ASN.draft
		rm -rf /tmp/*.gz /tmp/*.pfx2as /tmp/*.draft
		echo "Successfully Generated AS${ASN} IPv6 Prefixes!"
		echo " "
		echo "Please refer to ~/$ASN.txt"	
		echo " "	
		
elif [[ "$2" == "46" ]]	
	then
		wget -O /tmp/pfx2asV4.gz ${downlinkV4}
		zcat /tmp/pfx2asV4 > /tmp/routeviewsV4.pfx2as
		cat /tmp/routeviewsV4.pfx2as | grep -w ${ASN} >> /tmp/$ASN.draft
		
		wget -O /tmp/pfx2asV6.gz ${downlinkV6}
		zcat /tmp/pfx2asV6.gz > /tmp/routeviewsV6.pfx2as
		cat /tmp/routeviewsV6.pfx2as | grep -w ${ASN} >> /tmp/$ASN.draft
		
		while read -r line || [[ -n $line ]];do
			ip=$(echo $line | awk '{print $1}')
			mask=$(echo $line | awk '{print $2}')
    
			echo ${ip}/${mask} >> ~/$ASN.txt

    done < /tmp/$ASN.draft
    
		rm -rf /tmp/*.gz /tmp/*.pfx2as /tmp/*.draft
		echo "Successfully Generated AS${ASN} IPv4 and IPv6 Prefixes!"
		echo " "
		echo "Please refer to ~/$ASN.txt"	
		echo " "	
else
	echo "You have input the wrong configuration! Exiting the Script Now!"
	exit 1

fi
