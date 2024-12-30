#!/bin/bash

rm secrets/ssl/*.csr secrets/ssl/*.jks secrets/ssl/*.key secrets/ssl/*.srl secrets/ssl/*.crt secrets/ssl/*creds secrets/ssl/*.req secrets/ssl/*.pem

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

# Generate CA key
openssl req -new -x509 -keyout secrets/ssl/snakeoil-ca-1.key -out secrets/ssl/snakeoil-ca-1.crt -days 365 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US' -passin pass:confluent -passout pass:confluent

# Kafkacat
openssl genrsa -des3 -passout "pass:confluent" -out secrets/ssl/kafkacat.client.key 1024
openssl req -passin "pass:confluent" -passout "pass:confluent" -key secrets/ssl/kafkacat.client.key -new -out secrets/ssl/kafkacat.client.req -subj '/CN=kafkacat.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US'
openssl x509 -req -CA secrets/ssl/snakeoil-ca-1.crt -CAkey secrets/ssl/snakeoil-ca-1.key -in secrets/ssl/kafkacat.client.req -out secrets/ssl/kafkacat-ca1-signed.pem -days 9999 -CAcreateserial -passin "pass:confluent"


# kafka-sasl-1 kafka-sasl-2 kafka-sasl-3
for i in kafka-sasl-1.eden kafka-sasl-2.eden kafka-sasl-3.eden producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i, OU=TEST, O=CONFLUENT, L=PaloAlto, S=Ca, C=US" \
				 -keystore secrets/ssl/kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass confluent \
				 -keypass confluent

	# Create CSR, sign the key and import back into keystore
	keytool -keystore secrets/ssl/kafka.$i.keystore.jks -alias $i -certreq -file secrets/ssl/$i.csr -storepass confluent -keypass confluent

	openssl x509 -req -CA secrets/ssl/snakeoil-ca-1.crt -CAkey secrets/ssl/snakeoil-ca-1.key -in secrets/ssl/$i.csr -out secrets/ssl/$i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:confluent

	keytool -noprompt -keystore secrets/ssl/kafka.$i.keystore.jks -alias CARoot -import -file secrets/ssl/snakeoil-ca-1.crt -storepass confluent -keypass confluent

	keytool -noprompt -keystore secrets/ssl/kafka.$i.keystore.jks -alias $i -import -file secrets/ssl/$i-ca1-signed.crt -storepass confluent -keypass confluent

	# Create truststore and import the CA cert.
	keytool -noprompt -keystore secrets/ssl/kafka.$i.truststore.jks -alias CARoot -import -file secrets/ssl/snakeoil-ca-1.crt -storepass confluent -keypass confluent

  echo "confluent" > secrets/ssl/${i}_sslkey_creds
  echo "confluent" > secrets/ssl/${i}_keystore_creds
  echo "confluent" > secrets/ssl/${i}_truststore_creds
done
