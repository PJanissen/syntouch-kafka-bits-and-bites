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

Git repo uitchecken op initiële VBox, daarna een git pull laten uitvoeren bij aanvang workshop.

code/message-generator.sh uitvoerbaar maken

- consistentie naamgeving streams/tables/kolommen opgave 8
- queries bedenken:
- totalen bier/gebruiker
- best gewaardeerd bier (hoogste gemiddelde score)
- windowing queries
- totale hoeveelheid alcohol geconsumeerd in liters
- totale hoeveelheid bier geconsumeerd per biertype
