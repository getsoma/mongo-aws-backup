#!/bin/bash

MONGODB_HOST=${MONGODB_PORT_27017_TCP_ADDR:-${MONGODB_HOST}}
MONGODB_HOST=${MONGODB_PORT_1_27017_TCP_ADDR:-${MONGODB_HOST}}
MONGODB_PORT=${MONGODB_PORT_27017_TCP_PORT:-${MONGODB_PORT}}
MONGODB_PORT=${MONGODB_PORT_1_27017_TCP_PORT:-${MONGODB_PORT}}
MONGODB_USER=${MONGODB_USER:-${MONGODB_ENV_MONGODB_USER}}
MONGODB_PASS=${MONGODB_PASS:-${MONGODB_ENV_MONGODB_PASS}}

[[ ( -z "${MONGODB_USER}" ) && ( -n "${MONGODB_PASS}" ) ]] && MONGODB_USER='admin'

[[ ( -n "${MONGODB_USER}" ) ]] && USER_STR=" --username ${MONGODB_USER}"
[[ ( -n "${MONGODB_PASS}" ) ]] && PASS_STR=" --password ${MONGODB_PASS}"
[[ ( -n "${MONGODB_DB}" ) ]] && USER_STR=" --db ${MONGODB_DB}"

BACKUP_CMD="mongodump --out /backup/"'${BACKUP_NAME}'" --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR}${DB_STR} ${EXTRA_OPTS}"

echo "=> Creating backup script"
rm -f /backup_mongodb.sh
cat <<EOF >> /backup_mongodb.sh
#!/bin/bash

BACKUP_DIR_NAME=\$(date +\%Y.\%m.\%d.\%H\%M\%S).sql

echo "=> Backup started: \${BACKUP_DIR_NAME}"
if ${BACKUP_CMD} ;then
    echo "   MongoDB Backup succeeded"
    echo "   Pushing to AWS"
    /backup.sh
else
    echo "   Backup failed"
fi

#rm -rf /backup/*

echo "=> Backup done"
EOF
chmod +x /backup_mongodb.sh

echo "=> Creating restore script"
rm -f /restore_mongodb.sh
cat <<EOF >> /restore_mongodb.sh
#!/bin/bash
echo "=> Restore database from \$1"
if mongorestore --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR} \$1; then
    echo "   Restore succeeded"
else
    echo "   Restore failed"
fi
echo "=> Done"
EOF
chmod +x /restore_mongodb.sh

touch /mongodb_backup.log
tail -F /mongodb_backup.log &

if [ -n "${INIT_BACKUP}" ]; then
    echo "=> Create a backup on the startup"
    /backup_mongodb.sh
elif [ -n "${INIT_RESTORE_LATEST}" ]; then
    /restore_latest.sh
fi

echo "${CRON_TIME} /backup_mongodb.sh >> /mongodb_backup.log 2>&1" > /crontab.conf
env | grep 'AWS\|BACKUP_NAME\|S3_BUCKET_NAME' | cat - /crontab.conf > temp && mv temp /crontab.conf
crontab  /crontab.conf
echo "=> Running cron job"
exec cron -f
