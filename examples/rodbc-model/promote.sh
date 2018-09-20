
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
# ACCEPT_EULA=Y
ACCEPT_EULA=Y apt-get -y install msodbcsql17
apt-get -y install unixodbc-dev

apt-get -y install r-cran-rodbc
apt-get -y install libiodbc2-dev