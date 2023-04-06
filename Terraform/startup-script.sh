#! /bin/bash

PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
SQL=$(sudo curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SQL" -H "Metadata-Flavor: Google")
DB_USER=$(sudo curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_USER" -H "Metadata-Flavor: Google")
DB_NAME=$(sudo curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_NAME" -H "Metadata-Flavor: Google")
DB_PASS=$(sudo curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/DB_PASS" -H "Metadata-Flavor: Google")
BUCKET=$(sudo curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BUCKET" -H "Metadata-Flavor: Google")

apt-get update
apt-get install -yq git python3-pip
pip3 install ansible==2.9.27

export HOME=/root
git config --global credential.helper gcloud.sh


git clone https://source.developers.google.com/p/$PROJECTID/r/ansible-bookshelf /opt/ans
ansible-playbook /opt/ans/main.yml -e "SQL=$SQL" -e "DB_USER=$DB_USER" -e "DB_NAME=$DB_NAME" -e "DB_PASS=$DB_PASS" -e "BUCKET=$BUCKET" -e "PROJECTID=$PROJECTID"

