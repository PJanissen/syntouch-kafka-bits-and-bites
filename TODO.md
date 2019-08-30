# Milco's to-dos

## VBox image
- [ ] Kan er nu gewoon een Kafka broker worden gestart ?
- [ ] Start Zookeeper zonder foutmeldingen?
- [ ] Konsole op desktop plaatsen!
- [ ] sudo chmod 777 /var/log/

## Opgaven
- [ ] Item 1


mkdir /opt/confluent/config
cd /opt/confluent
cp ./etc/kafka/server.properties ./config
cp ./etc/kafka/zookeeper.properties ./config

mkdir -p /opt/logs/server-{1,2,3}
/opt/confluent/bin/zookeeper-server-start /opt/confluent/config/zookeeper.properties

Git repo uitchecken!
code/message-generator.sh uitvoerbaar maken
