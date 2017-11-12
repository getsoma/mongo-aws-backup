FROM ubuntu:trusty
MAINTAINER Stephen Pope <spope@projectricochet.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list && \
    apt-get update && \
    apt-get install -y mongodb-org-shell mongodb-org-tools && \
    echo "mongodb-org-shell hold" | dpkg --set-selections && \
    echo "mongodb-org-tools hold" | dpkg --set-selections && \
    apt-get install -y python-pip && pip install awscli && \
    mkdir /backup

ENV RESTORE=false

ADD run.sh /run.sh
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
ADD restore_latest.sh /restore_latest.sh

RUN chmod +x *.sh

HEALTHCHECK --interval=5s --timeout=3s CMD pgrep cron || exit 1

CMD ["/run.sh"]
