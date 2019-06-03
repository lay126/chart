#!/bin/sh

aws --endpoint-url $S3_ENDPOINT s3 ls $S3_BUCKET | sort -r > .raw
cat .raw | awk '{print $4 " " $1 " " $2}' > .files

#dead_line="`date +%Y-%m-%d`_23:59:59"
dead_line="2018-08-01 23:59:59"
dead_line_time=`date -d "$dead_line" "+%s"`

cat .files | while read line; do
  # Ref
  # - https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
  file="${line%% *}"
  backup="${line#* }"
  backup_time=`date -d "$backup" "+%s"`

  # Ref
  # - http://euless.tistory.com/51
  # - http://kukuta.tistory.com/85
  # - http://bahndal.egloos.com/543840
  # - http://steadypost.net/post/knowhow/id/8/

  diff=`expr $backup_time - $dead_line_time`
  del=$(test $diff -lt 0 && echo 'true' || echo 'false')

  if [ "$del" = 'true' ]; then
    echo -e "$del \t $file \t $backup \t $dead_line"
  else
    echo -e "$del \t $file \t $backup \t $dead_line"
  fi
done