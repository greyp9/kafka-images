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

// container filesystem 
[appuser ~]$ ls -la /etc/kafka/secrets/   [folder shared from host filesystem]
[appuser ~]$ ls -la /usr/share/java/kafka/   [Kafka runtime JARs]

// topic management
/usr/bin/kafka-topics --create --topic TOPIC1 --bootstrap-server kafka-ssl-1:19092 --partitions 1 --replication-factor 1  --command-config /etc/kafka/secrets/host.consumer.ssl.config 
/usr/bin/kafka-topics --describe --topic TOPIC1 --bootstrap-server kafka-ssl-1:19092 --command-config /etc/kafka/secrets/host.consumer.ssl.config 
/usr/bin/kafka-console-consumer --bootstrap-server kafka-ssl-1:19092 --topic TOPIC1 --from-beginning --consumer.config /etc/kafka/secrets/host.consumer.ssl.config 
/usr/bin/kafka-console-producer --bootstrap-server kafka-ssl-1:19092 --topic TOPIC1 --producer.config /etc/kafka/secrets/host.producer.ssl.config 
/usr/bin/kafka-consumer-groups --describe --group GROUP1 --bootstrap-server kafka-ssl-1:19092 --command-config /etc/kafka/secrets/host.consumer.ssl.config 

// verify keystore
keytool -list -rfc -keystore kafka.producer.truststore.jks -storepass confluent >producer.trust.txt
openssl verify -verbose -CAfile producer.trust.txt 1.cer
openssl verify -verbose -partial_chain -trusted 1.cer 0.cer
```
