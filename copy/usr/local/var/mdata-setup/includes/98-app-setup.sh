#!/usr/bin/bash

echo "* Setup postgresql backup"
mkdir -p /var/lib/postgresql/backups
chown postgres:postgres /var/lib/postgresql/backups
echo "0 1 * * * /usr/local/bin/psql_backup" >> /var/spool/cron/crontabs/postgres
echo "0 2 1 * * /usr/bin/vacuumdb --all" >> /var/spool/cron/crontabs/postgres
chown postgres:crontab /var/spool/cron/crontabs/postgres
chmod 0600 /var/spool/cron/crontabs/postgres

# sed -i 's/${WEBSERVER_HOST}/[peertube-domain]/g' /etc/nginx/sites-available/peertube
# sed -i 's/${PEERTUBE_HOST}/127.0.0.1:9000/g' /etc/nginx/sites-available/peertube

systemctl restart nginx || true

exit 0