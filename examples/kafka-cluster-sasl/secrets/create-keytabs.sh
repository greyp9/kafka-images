#!/bin/bash

rm sasl/*.keytab

export ZK_KEYTAB_HOSTNAME=localhost
export KEYTAB_HOSTNAME_LO=kafka-sasl-lo
export KEYTAB_HOSTNAME_EN0=kafka-sasl-en0

for principal in zookeeper
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zookeeper/${ZK_KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab zookeeper/localhost@TEST.CONFLUENT.IO"
done

#for principal in zookeeper1 zookeeper2 zookeeper3
#do
#  docker exec -it kerberos kadmin.local -q "addprinc -randkey zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#  docker exec -it kerberos kadmin.local -q "ktadd -norandkey -k /tmp/keytab/${principal}.keytab zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#done

for principal in zkclient
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zkclient/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab zkclient/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
done

for principal in broker1 broker2 broker3
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey kafka/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab kafka/${KEYTAB_HOSTNAME_LO}@TEST.CONFLUENT.IO"
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
