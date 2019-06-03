#!/bin/sh

RELEASE=zcp-git
GIT_POD=$(kubectl get pods --no-headers=true -o custom-columns=:.metadata.name | grep -- $RELEASE-gitea)
DB_POD=$(kubectl get pods --no-headers=true -o custom-columns=:.metadata.name | grep -- $RELEASE-postgresql)

ARCHIVE=$(ls -t gitea-dump-*.zip | head -n1)

# Upload backup
kubectl cp $ARCHIVE $GIT_POD:/tmp
kubectl exec -it $GIT_POD -- bash -c "ls -l /tmp"
kubectl exec -it $GIT_POD -- bash -c "cd /tmp && mkdir gitea-dump && unzip -o $ARCHIVE -d gitea-dump"

# Restore Git Repo
kubectl exec -it $GIT_POD -- bash -c "cd /tmp/gitea-dump && cp data/conf/app.ini /data/gitea/conf/"
kubectl exec -it $GIT_POD -- bash -c "cd /tmp/gitea-dump && unzip gitea-repo.zip -d /data/git"
kubectl exec -it $GIT_POD -- bash -c "cd /tmp/gitea-dump && cp data/attachments /data/gitea/"

# Restore DB_PODB
# http://pgclks.tistory.com/437
unzip -o $ARCHIVE gitea-db.sql
kubectl cp gitea-db.sql $DB_POD:/tmp/gitea-db.sql
kubectl exec -it $DB_POD -- bash -c "psql gitea < /tmp/gitea-db.sql"

# Restart Service
kubectl scale --replicas=0 deploy/git-gitea
kubectl scale --replicas=1 deploy/git-gitea
