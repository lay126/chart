#!/bin/sh

RELEASE=zcp-jenkins
POD=$(kubectl get pods --no-headers=true -o custom-columns=:.metadata.name | grep -- $RELEASE-jenkins)

ARCHIVE=$(ls -t jenkins-home-*.zip | head -n1)

# Upload backup
kubectl cp $ARCHIVE $POD:/tmp
kubectl exec -it $POD -- bash -c "ls -l /tmp"
kubectl exec -it $POD -- bash -c "cd /tmp && mkdir jenkins-home && unzip -o $ARCHIVE -d jenkins-home"

# Restore Jenkins Home
#kubectl exec -it $GIT_POD -- bash -c "cd /tmp/jenkins-home && cp data/conf/app.ini /data/gitea/conf/"
#kubectl exec -it $GIT_POD -- bash -c "cd /tmp/jenkins-home && unzip gitea-repo.zip -d /data/git"
#kubectl exec -it $GIT_POD -- bash -c "cd /tmp/jenkins-home && cp data/attachments /data/gitea/"

# Restore DB_PODB
# http://pgclks.tistory.com/437
#unzip -o $ARCHIVE gitea-db.sql
#kubectl cp gitea-db.sql $DB_POD:/tmp/gitea-db.sql
#kubectl exec -it $DB_POD -- bash -c "psql gitea < /tmp/gitea-db.sql"

# Restart Service
#kubectl scale --replicas=0 deploy/git-gitea
#kubectl scale --replicas=1 deploy/git-gitea
