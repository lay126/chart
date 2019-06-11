#!bin/sh

time kubectl exec -it $POD -- tar -zcf /appdata/$BACKUP_NAME.tgz /var/jenkins_home
echo 'tar done' > /appdata/$BACKUP_NAME.log
