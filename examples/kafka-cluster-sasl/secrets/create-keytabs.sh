#!/bin/bash

rm secrets/sasl/*.keytab

export ZK_KEYTAB_HOSTNAME=localhost
export KEYTAB_HOSTNAME_LO=kafka-sasl-lo
export KEYTAB_HOSTNAME_EN0=kafka-sasl-en0

for ordinal in "1" "2" "3"
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zookeeper/zk-sasl-${ordinal}.eden@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/zk${ordinal}.keytab zookeeper/zk-sasl-${ordinal}.eden@TEST.CONFLUENT.IO"
done

#for principal in zookeeper1 zookeeper2 zookeeper3
#do
#  docker exec -it kerberos kadmin.local -q "addprinc -randkey zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#  docker exec -it kerberos kadmin.local -q "ktadd -norandkey -k /tmp/keytab/${principal}.keytab zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#done

for ordinal in "1" "2" "3"
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zkclient/zk-sasl-${ordinal}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/zkclient${ordinal}.keytab zkclient/zk-sasl-${ordinal}@TEST.CONFLUENT.IO"
done

for ordinal in "1" "2" "3"
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey kafka/kafka-sasl-${ordinal}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/broker${ordinal}c.keytab kafka/kafka-sasl-${ordinal}@TEST.CONFLUENT.IO"

  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey kafka/kafka-sasl-${ordinal}.eden@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/broker${ordinal}s.keytab kafka/kafka-sasl-${ordinal}.eden@TEST.CONFLUENT.IO"
done

for principal in producer1 consumer1
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey ${principal}/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab ${principal}/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
done

for principal in producer2 consumer2
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey ${principal}/${KEYTAB_HOSTNAME_EN0}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab ${principal}/${KEYTAB_HOSTNAME_EN0}@TEST.CONFLUENT.IO"
done
