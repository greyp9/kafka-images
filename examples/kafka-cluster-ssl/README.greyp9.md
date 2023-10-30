Slight trouble getting this to work with local docker.  Instructs to use this branch:

### SETUP

1) run script `create-certs.sh` from `kafka-images/examples/kafka-cluster-ssl/secrets`

1) add to `/etc/hosts`
    ```
    127.0.0.1 kafka-ssl-1
    127.0.0.1 kafka-ssl-2
    127.0.0.1 kafka-ssl-3
    ```

1) `export KAFKA_SSL_SECRETS_DIR=./secrets`

### UTILITY COMMANDS
```
// container control
docker compose up -d
docker ps
docker attach kafka-cluster-ssl-kafka-ssl-1-1
docker exec -it kafka-cluster-ssl-kafka-ssl-1-1  /bin/bash
docker compose down

// verify keystore
keytool -list -rfc -keystore kafka.producer.truststore.jks -storepass confluent >producer.trust.txt
openssl verify -verbose -CAfile producer.trust.txt 1.cer
openssl verify -verbose -partial_chain -trusted 1.cer 0.cer
```
