#!/bin/sh
BIN="$( cd "$( dirname "$0" )" && pwd )"   # https://stackoverflow.com/a/20434740

# Inject through pod environment variables
#echo -e "\n\n+ Load environment variables..."
#source $BIN/setenv   # https://stackoverflow.com/a/13360474
#cat $BIN/setenv      # for logging

BACKUP_NAME=jenkins-home-$(TZ='KST+9' date +%Y%m%d-%H%M)
BACKUP=$BACKUP_DIR/$BACKUP_NAME
mkdir -p $BACKUP

POD=$(kubectl get pods --no-headers=true -o custom-columns=:.metadata.name | grep -- $JENKINS_DEPLOY)
if [ -z "$POD" ]; then
	echo -e '\n\n+ ERROR :: There is no jenkins pod.'
	kubectl get pods
	echo 'ERROR' > $S3_TRIGGER
	exit 1
fi

echo -e "\n\n+ Copy... [pod/$POD -> $BACKUP]"
time kubectl exec -it $POD mkdir appdata
#time kubectl exec -it $POD -- cp -rf /var/jenkins_home /appdata/$BACKUP_NAME

echo -e '\n\n+ Compress...'
time kubectl exec -it $POD -- tar -zcvf /appdata/$BACKUP_NAME.tgz /var/jenkins_home
time kubectl exec -it $POD -- rm -rf appdata/$BACKUP_NAME


time kubectl cp $POD:/appdata/$BACKUP_NAME.tgz $BACKUP

ls -l $BACKUP
ls -l $BACKUP_DIR

# Trigger s3 upload
echo 'START' > $S3_TRIGGER
