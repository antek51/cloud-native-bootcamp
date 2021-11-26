#!/bin/sh
# Change the Fiesta configuration code so it works in the container
sed -i "s/REPLACE_DB_NAME/FiestaDB/g" /code/Fiesta/config/config.js
sed -i "s/REPLACE_DB_HOST_ADDRESS/$MARIADB_IP/g" /code/Fiesta/config/config.js
sed -i "s/REPLACE_DB_DIALECT/mysql/g" /code/Fiesta/config/config.js
sed -i "s/REPLACE_DB_USER_NAME/fiesta/g" /code/Fiesta/config/config.js
sed -i "s/REPLACE_DB_PASSWORD/fiesta/g" /code/Fiesta/config/config.js
sed -i "s/REPLACE_DB_DOMAIN_NAME/\/\/DB_DOMAIN_NAME/g" /code/Fiesta/config/config.js

# Run the NPM Application
cd /code/Fiesta
npm start
