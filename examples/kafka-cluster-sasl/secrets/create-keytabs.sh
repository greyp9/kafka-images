#!/bin/bash

rm sasl/*.keytab

export KEYTAB_HOSTNAME=kafka-sasl

for principal in localhost
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zookeeper/localhost@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab zookeeper/localhost@TEST.CONFLUENT.IO"
done

#for principal in zookeeper1 zookeeper2 zookeeper3
#do
#  docker exec -it kerberos kadmin.local -q "addprinc -randkey zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#  docker exec -it kerberos kadmin.local -q "ktadd -norandkey -k /tmp/keytab/${principal}.keytab zookeeper/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
#done

for principal in zkclient1 zkclient2 zkclient3
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey zkclient/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab zkclient/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
done

for principal in broker1 broker2 broker3
do
  docker exec -it kerberos-kerberos-1 kadmin.local -q "addprinc -randkey kafka/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
  docker exec -it kerberos-kerberos-1 kadmin.local -q "ktadd -norandkey -k /tmp/keytab/sasl/${principal}.keytab kafka/${KEYTAB_HOSTNAME}@TEST.CONFLUENT.IO"
done
