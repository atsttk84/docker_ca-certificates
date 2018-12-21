#!/bin/sh -eux

function make_base(){
	local CATOP=$1
  rm -rf ${CATOP}
  mkdir ${CATOP}
  mkdir "${CATOP}/certs"
  mkdir "${CATOP}/crl"
  mkdir "${CATOP}/newcerts"
  mkdir "${CATOP}/private"
  touch "${CATOP}/index.txt"
  echo 01 > "${CATOP}/crlnumber"
  echo 01 > "${CATOP}/serial"
}
rm -rf ./dist
rm -rf ./tmp
mkdir -p ./dist/server
mkdir -p ./dist/client
mkdir -p ./tmp

make_base ./CA
make_base ./ICA

openssl genrsa -out ./CA/private/cakey.pem 2048
echo -e "\n\n\n\n\n\n\nprivate\n\ny\n" | openssl req -config ./openssl.cnf.ca -new -key ./CA/private/cakey.pem -out ./CA/careq.pem
openssl ca -config ./openssl.cnf.ca -create_serial -out ./CA/cacert.pem -days 1095 -batch -keyfile ./CA/private/cakey.pem -selfsign -extensions v3_ca  -infiles ./CA/careq.pem
openssl x509 -in CA/cacert.pem -out dist/client/ca.crt

openssl genrsa -out tmp/newkey.pem 2048
echo -e "\n\n\n\n\n\n\nprivate\n\n" | openssl req -config ./openssl.cnf.ica -new  -key tmp/newkey.pem -out tmp/newreq.pem -days 3650

echo -e "y\ny\nprivate\nprivate\n" | openssl ca -config ./openssl.cnf.ca -policy policy_anything -out tmp/newcert.pem -extensions v3_ca  -infiles tmp/newreq.pem


cp ./CA/cacert.pem ./ICA/cacert.pem
cp ./CA/private/cakey.pem ./ICA/private/cakey.pem

openssl x509 -in tmp/newcert.pem -out dist/server/ica.crt
openssl x509 -in ./ICA/cacert.pem -out dist/client/ica.crt


openssl genrsa 2048 > tmp/newkey.pem
openssl rsa -in tmp/newkey.pem -out tmp/newkey.pem
echo -e "\n\n\n\n\n*.amazonaws.com\n\nprivate\n\n" | openssl req -new -key tmp/newkey.pem -out tmp/newreq.pem
echo -e "y\ny\nprivate\nprivate\n" | openssl ca -config ./openssl.cnf.ica -policy policy_anything -out tmp/newcert.pem  -infiles tmp/newreq.pem
openssl x509 -in tmp/newcert.pem -out dist/server/server.crt
mv tmp/newkey.pem dist/server/server.key
cat dist/server/server.crt dist/server/ica.crt > dist/server/server.nginx.crt
