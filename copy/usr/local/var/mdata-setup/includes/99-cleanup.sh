#!/usr/bin/bash

mdata-delete mail_smarthost || true
mdata-delete mail_auth_user || true
mdata-delete mail_auth_pass || true
mdata-delete mail_adminaddr || true

apt-get -y purge git make g++ build-essential || true
apt-get -y autoremove || true
