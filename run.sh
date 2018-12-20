#!/bin/sh

rm -rf /etc/ssl/demoCA/*
mkdir -p /etc/ssl/demoCA/private\
 && mkdir -p /etc/ssl/demoCA/newcerts\
 && mkdir -p /etc/ssl/demoCA/server

cd /etc/ssl/demoCA
openssl genrsa -out ./private/cakey.pem 2048\
 && echo -e "\n\n\n\n\n*.local\n\nprivate\n\n" | openssl req -new -key ./private/cakey.pem -out cacert.csr\
 && openssl x509 -in cacert.csr -req -signkey ./private/cakey.pem -out cacert.pem\
 && touch index.txt\
 && echo 00 > serial
cd /etc/ssl/
openssl genrsa -out ./demoCA/server/serverkey.pem 2048\
 && echo -e "\n\n\n\n\n*.amazonaws.com\n\nprivate\n\n" | openssl req -new -key ./demoCA/server/serverkey.pem -out ./demoCA/server/server.csr\
 && yes | openssl ca -out ./demoCA/server/servercert.pem -infiles ./demoCA/server/server.csr\
 && openssl x509 -in ./demoCA/server/servercert.pem -text
