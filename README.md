# updateContainers
Bash script to update docker containers and send release notes to Discord

Features:
- Use docker-compose to update provided list of containers.
- Send Discord embed messages with release note information.
- Keep track of container versioning.

![](screenshot.png)


Notes:
- Discord has a 2000 character limit, as such any release notes greater than the limit will NOT send. Will fix.
- Not all repositories follow the standard release template, so sometimes this may not work as intended.

