# Zcp-tools-backup

zcp-tools-backup 은 CronJob 기반의 백업 실행과 S3 전송 기능을 지원한다.

`resources` 하위의 쉘 스크립트를 기반으로 동작하며 각 파일의 실행 순서와 기능은 아래와 같다.
* `resources/backup-*.sh` : 백업 스크립트
* `resources/upload-*.sh` : S3 업로드 스크립트
* `resources/restore-*.sh` : 복구 스크립트 (수동)

지원되는 백업 대상은 다음과 같다.
* Jenkins
* Gitea

## Job History
CronJob에 의해 Job을 통해 histroy를 확인 할 수 있다.
기본 값은 `suceess=3, failed=1`로 유지되고 아래의 값을 통해 변경 가능하다.

```
# https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
spec:
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

재 설치 등으로 인해 CronJob이 삭제되어도 Job은 지워지지 않는다.
`metadata.ownerReferences`가 없는 Job은 삭제된 CronJob의 history 이므로 삭제하도록 한다.
