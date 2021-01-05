#!/bin/bash

#User Variables
webhook=""
githubToken=""
username="Docker"
avatar="https://assets.gitlab-static.net/uploads/-/system/project/avatar/7024001/AppLogo_Docker.png?width=64"
updatesEnabled=true
pruneEnabled=true

#Add your container names/repos below (Must be in same order).
containerNames=(bazarr jellyfin pihole)
lsio="linuxserver/docker"
containerRepos=($lsio-bazarr $lsio-jellyfin pi-hole/pi-hole)

declare -i count=0
logFile=updateContainersLog.txt

#Update loop
for i in "${containerRepos[@]}"
do	
	curl -H "Authorization: token $githubToken" -H "Accept: application/vnd.github.v3.json" https://api.github.com/repos/$i/releases/latest > updateContainersTemp.json
	version=$(jq -r '.tag_name' updateContainersTemp.json)

	#If latest version is not recorded in file then update the container.
	if ! grep "${containerNames[$count]}:$version" updateContainersVersion.txt
	then
		if $updatesEnabled = true
			then 
				docker-compose pull ${containerNames[$count]}
				docker-compose up -d ${containerNames[$count]}
				echo ${containerNames[$count]} "updated at" $(date +"%m/%d/%Y") >> $logFile
		fi
		releaseNotes=$(jq '.body' updateContainersTemp.json)
		url=$(jq -r '.html_url' updateContainersTemp.json)
		
		#If notes exceed character limit then trim it down. 
		if (( ${#releaseNotes} > 1950 ))
			then 
				releaseNotes=$(echo "$releaseNotes" | cut -c -1950)'"'
		fi
		curl -H "Content-Type: application/json" \
			-d '{"username": "'$username'", "avatar_url": "'$avatar'", "embeds": [{"title": "Updated '${containerNames[$count]}' to '$version'", "url": "'$url'", "description": '"$releaseNotes"', "color": 2332140}]}' \
			$webhook
		#Replace version with updated version
		sed -i '/'${containerNames[$count]}'/d' updateContainersVersion.txt
		echo "${containerNames[$count]}:$version" >> updateContainersVersion.txt
	fi
	let "count++"
done
#Restart plex container for automatic update.
if [[ " ${containerNames[*]} " == *" plex "* ]] && [[ " $updatesEnabled " ]]
then
	docker-compose restart plex
fi
#Cleanup
rm updateContainersTemp.json
if $pruneEnabled = true
	then
		docker image prune
fi
