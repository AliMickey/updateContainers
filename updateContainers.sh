#!/bin/bash

#User Variables
webhook=""
githubToken=""
username="Docker"
avatar="https://assets.gitlab-static.net/uploads/-/system/project/avatar/7024001/AppLogo_Docker.png?width=64"
updatesEnabled=true

#Add your container names/repos below (Must be in same order).
containerNames=(authelia bazarr jackett jellyfin letsencrypt lidarr nextcloud ombi pihole plex tautulli traccar transmission youtube-dl)
lsio="linuxserver/docker"
containerRepos=(authelia/authelia $lsio-bazarr $lsio-jackett $lsio-jellyfin $lsio-letsencrypt $lsio-lidarr $lsio-nextcloud $lsio-ombi pi-hole/pi-hole $lsio-plex $lsio-tautulli traccar/traccar haugene/docker-transmission-openvpn tzahi12345/youtubedl-material)

declare -i count=0

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
#Cleanup
rm updateContainersTemp.json