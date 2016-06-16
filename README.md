# mongo-aws-backup

This image runs mongodump to backup data using cronjob to an to Amazon S3, it can also restore data from an S3 backup.

## Usage:

    docker run -d \
        --env MONGODB_HOST=mongo.host \
        --env MONGODB_PORT=27017 \
        --env MONGODB_USER=admin \
        --env MONGODB_PASS=password \
        --env MONGODB_DB=db_name \
        --env AWS_ACCESS_KEY_ID=key	\
        --env AWS_DEFAULT_REGION=region \		
        --env AWS_SECRET_ACCESS_KEY=access_key \
        --env BACKUP_NAME=name \
        --env CRON_TIME=time \
        --env S3_BUCKET_NAME=bucket_name \
        mongo-aws-backup

## Parameters
    MONGODB_HOST        the host/ip of your mongodb database
    MONGODB_PORT        the port number of your mongodb database
    MONGODB_USER        the username of your mongodb database
    MONGODB_PASS        the password of your mongodb database
    MONGODB_DB          the database name to dump.
    EXTRA_OPTS          the extra options to pass to mongodump command
    CRON_TIME           the interval of cron job to run mysqldump. `0 0 * * *` by default, which is every day at 00:00
    AWS_ACCESS_KEY_ID	set the AWS access key
    AWS_DEFAULT_REGION	set an aws region to use	
    AWS_SECRET_ACCESS_KEY set your secret access key
    BACKUP_NAME         the name to be used for the backup		
    MYSQL_DB			the database to use	
    S3_BUCKET_NAME      S3 bucket name
    RESTORE             if set to true, it will restore latest backup

## Restore from a backup



To restore database from a certain backup, simply run:

    docker exec mongo-aws-backup /restore_latest.sh
