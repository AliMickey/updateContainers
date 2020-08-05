#!/bin/bash

#User Variables
webhook=""
username="Docker"
avatar="https://assets.gitlab-static.net/uploads/-/system/project/avatar/7024001/AppLogo_Docker.png?width=64"

#Add your contiainer names below, place all linuxserver maintained containers first. 
linuxserver=(bazarr jackett jellyfin letsencrypt lidarr nextcloud ombi plex tautulli)
other=(authelia/authelia haugene/docker-transmission-openvpn pi-hole/pi-hole traccar/traccar tzahi12345/youtubedl-material)

#Pull images
#docker-compose pull $linuxserver $other


#Update loop
for i in "linuxserver/docker-${linuxserver[@]}" "${other[@]}"
do	
	curl -H "Accept: application/vnd.github.v3.json" https://api.github.com/repos/$i/releases/latest > updateContainersTemp.json
	version=$(jq -r '.tag_name' updateContainersTemp.json)

	#If latest version is not recorded in file then update the container.
	if ! grep "'$i':'$version'" updateContainerVersion.txt
	then
		#docker-compose up -d $i
		releaseNotes=$(jq '.body' updateContainersTemp.json)
		url=$(jq '.html_url' updateContainersTemp.json)
		curl -H "Content-Type: application/json" \
			-d '{"username": "'$username'", "avatar_url": "'$avatar'", "embeds": [{"title": "Updated '$i' to '$version'", "url": "'$url'", "description": '"$releaseNotes"', "color": 2332140}]}' \
			$webhook
		echo "'$i':'$version'" >> updateContainerVersion.txt
	fi
done