#!/usr/bin/bash

cho "* Start postgresql"
systemctl daemon-reload
pg_createcluster 15 main --start || true
sudo -u postgres psql -c "CREATE USER peertube;" || true
sudo -u postgres createdb -O peertube -E UTF8 -T template0 peertube_prod
sudo -u postgres psql -c "CREATE EXTENSION pg_trgm;" peertube_prod
sudo -u postgres psql -c "CREATE EXTENSION unaccent;" peertube_prod

MAIL_UID=$(/native/usr/sbin/mdata-get mail_auth_user)
MAIL_PWD=$(/native/usr/sbin/mdata-get mail_auth_pass)
MAIL_HOST=$(/native/usr/sbin/mdata-get mail_smarthost)

DOMAIN=$(/native/usr/sbin/mdata-get peertube_domain)
ADMIN_EMAIL=$(/native/usr/sbin/mdata-get admin_email)
FROM_EMAIL=$(/native/usr/sbin/mdata-get from_email)
SECRET=$(openssl rand -hex 32)

sed -i \
    -e "s/hostname: 'example.com'/hostname: '${DOMAIN}'/" \
    -e "s/peertube: ''/peertube: '${SECRET}'/" \
    -e "s/email: 'admin@example.com'/email: '${ADMIN_EMAIL}'/" \
    -e "s/from_address: 'admin@example.com'/from_address: '${FROM_EMAIL}'/" \
    /var/www/peertube/config/production.yaml

echo "* Setup postgresql backup"
mkdir -p /var/lib/postgresql/backups
chown postgres:postgres /var/lib/postgresql/backups
echo "0 1 * * * /usr/local/bin/psql_backup" >> /var/spool/cron/crontabs/postgres
echo "0 2 1 * * /usr/bin/vacuumdb --all" >> /var/spool/cron/crontabs/postgres
chown postgres:crontab /var/spool/cron/crontabs/postgres
chmod 0600 /var/spool/cron/crontabs/postgres

sed -i 's/WEBSERVER_HOST/${DOMAIN}/g' /etc/nginx/sites-available/peertube

systemctl enable peertube || true
systemctl start peertube || true
systemctl restart nginx || true

exit 0