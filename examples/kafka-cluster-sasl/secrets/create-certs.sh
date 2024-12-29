#!/bin/bash

rm ssl/*.csr ssl/*.jks ssl/*.key ssl/*.srl ssl/*.crt ssl/*creds ssl/*.req ssl/*.pem

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

# Generate CA key
openssl req -new -x509 -keyout ssl/snakeoil-ca-1.key -out ssl/snakeoil-ca-1.crt -days 365 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US' -passin pass:confluent -passout pass:confluent

# Kafkacat
openssl genrsa -des3 -passout "pass:confluent" -out ssl/kafkacat.client.key 1024
openssl req -passin "pass:confluent" -passout "pass:confluent" -key ssl/kafkacat.client.key -new -out ssl/kafkacat.client.req -subj '/CN=kafkacat.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US'
openssl x509 -req -CA ssl/snakeoil-ca-1.crt -CAkey ssl/snakeoil-ca-1.key -in ssl/kafkacat.client.req -out ssl/kafkacat-ca1-signed.pem -days 9999 -CAcreateserial -passin "pass:confluent"


# kafka-sasl-1 kafka-sasl-2 kafka-sasl-3
for i in kafka-sasl-lo producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i, OU=TEST, O=CONFLUENT, L=PaloAlto, S=Ca, C=US" \
				 -keystore ssl/kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass confluent \
				 -keypass confluent

	# Create CSR, sign the key and import back into keystore
	keytool -keystore ssl/kafka.$i.keystore.jks -alias $i -certreq -file ssl/$i.csr -storepass confluent -keypass confluent

	openssl x509 -req -CA ssl/snakeoil-ca-1.crt -CAkey ssl/snakeoil-ca-1.key -in ssl/$i.csr -out ssl/$i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:confluent

	keytool -noprompt -keystore ssl/kafka.$i.keystore.jks -alias CARoot -import -file ssl/snakeoil-ca-1.crt -storepass confluent -keypass confluent

	keytool -noprompt -keystore ssl/kafka.$i.keystore.jks -alias $i -import -file ssl/$i-ca1-signed.crt -storepass confluent -keypass confluent

	# Create truststore and import the CA cert.
	keytool -noprompt -keystore ssl/kafka.$i.truststore.jks -alias CARoot -import -file ssl/snakeoil-ca-1.crt -storepass confluent -keypass confluent

  echo "confluent" > ssl/${i}_sslkey_creds
  echo "confluent" > ssl/${i}_keystore_creds
  echo "confluent" > ssl/${i}_truststore_creds
done
