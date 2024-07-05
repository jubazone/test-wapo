#!/bin/bash
sudo dnf update
sudo dnf install postgresql15.x86_64 postgresql15-server -y

sudo postgresql-setup --initdb

sudo systemctl enable postgresql && sudo systemctl start postgresql
sudo sed -i "59i listen_addresses = '*'" /var/lib/pgsql/data/postgresql.conf
sudo sed -i 's/ident$/md5/' /var/lib/pgsql/data/pg_hba.conf

sudo useradd postgres

sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo -i -u postgres psql -c "CREATE USER ${userdb} WITH PASSWORD '${passdb}';"
sudo -i -u postgres psql -c "CREATE DATABASE ${namedb};"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${namedb} TO ${userdb};"
sudo -i -u postgres psql -c "CREATE USER usr_read WITH PASSWORD 'usr_read';"

sudo -i -u postgres psql -c "GRANT CONNECT ON DATABASE ${namedb} TO usr_read;"
sudo -i -u postgres psql -d ${namedb} -c "CREATE TABLE table_name1 (username  VARCHAR ( 50 ) PRIMARY KEY, password VARCHAR ( 50 ), created_on TIMESTAMP);"
sudo -i -u postgres psql -d ${namedb} -c "CREATE TABLE table_name2 (username  VARCHAR ( 50 ) PRIMARY KEY, password VARCHAR ( 50 ), created_on TIMESTAMP);"
sudo -i -u postgres psql -d ${namedb} -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO usr_read;"

sudo systemctl restart postgresql