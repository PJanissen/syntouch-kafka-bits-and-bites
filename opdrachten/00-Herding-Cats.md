# Herding Cats
Zookeeper wordt gebruikt om de verschillende servers/taken binnen het Kafka-cluster te coördineren, zoals configuratiebeheer en verkiezingen. Zonder Zookeeper kun je geen Kafka-cluster starten noch draaien, dus normaliter wordt Zookeeper ook uitgevoerd (zoals zovele componenten binnen het Kafka ecosysteem) als cluster met een aantal nodes.
Naast Apache Kafka zijn er ook andere projecten die gebruik maken van Zookeeper, zoals bijvoorbeeld Neo4J, Hadoop, Mesos etc.
Meer informatie op de website van [Apache Zookeeper](https://zookeeper.apache.org/).

## Zookeeper cluster
Een Zookeeper cluster wordt gevormd door één of meer Zookeeper servers; in onze workshop zullen we slechts één Zookeeper instance gebruiken.

![Zookeeper Cluster](../assets/ZookeeperService.jpeg)

Hetzelfde Zookeeper cluster kan worden gebruikt om meerdere Kafka cluster tegelijkertijd te draaien, maar niet voor productie-doeleinden.
Binnen zookeeper bestaat het concept van "namespaces" (chroot):

![Zookeeper Namespaces](../assets/ZookeeperNamespaces.jpeg)

Het concept van namespace voor zover het betrekking heeft op de verschillende Kafka Clusters is eenvoudig: iedere namespace is een eigen cluster. Als Kafka brokers tot hetzelfde cluster behoren, dan moeten ze in ieder geval gebruik maken van dezelfde namespace (chroot, path) binnen het Kafka-cluster.

## Configuratie
Zoals de meeste componenten, heeft Zookeeper een configuratiebestand nodig om te kunnen starten.
Voordat we aan de slag gaan, moeten we eerst een aantal directories aanmaken om de verschillende bestandstypen onder te kunnen brengen.

Type bestand             | Locatie
-------------------------|-------------
Configuratie-bestanden:  | /opt/kafka/config
Zookeeper databestanden: | /opt/data
Kafka server logs        | /opt/kafka/logs/\<servername\>\*

\* Hier moet (later) je per broker een directory aanmaken

Open een terminal (Konsole of Terminator) en maak de directories aan (de optie -p maakt eventuele ontbrekende tussenliggende directory niveau's aan):

```bash
mkdir -p /opt/kafka/config   /opt/data   /opt/kafka/logs/
```

### Zookeeper configuratie
Maak voor je Zookeeper-cluster-van-een-server een configuratiebestand zookeeper.properties aan in /opt/kafka/config. Dit kun je doen met kwrite (visueel) of met vi.
Het configuratiebestand zelf is een aantal properties (name=value), hiervoor is het verstandig er twee expliciet te zetten:
```
dataDir=/opt/data
clientPort=2181
```

Sla je configuratiebestand op en verlaat je editor. De confluent distributie van Kafka bevat een aantal scripts om componenten te starten en stoppen; deze zijn ondergebracht onder /opt/confluent/bin/ en staan al in je zoekpad ($PATH).

Je kunt je Zookeeper server starten met het script zookeeper-server-start en als argument opgeven welke configuratiefile moet worden gebruikt, dus:
```bash
zookeeper-server-start  /opt/kafka/config/zookeeper.properties
```

#### Zookeeper status
Met behulp van de zookeeper shell (of good-old telnet) kun je de zookeeper instance controleren en monitoren. Hiervoor geef je als argument hostname:portnummer op, waarbij je hostname kunt weglaten als het de lokale server betreft. Maak connectie naar je zookeeper server met:
```bash
zookeeper-shell :2181
```

Als je succesvol connectie hebt gemaakt, dan kun je met help de commando's opvragen. Zo kun je vanuit de shell controleren hoeveel clients er verbonden zijn met de root namespace door:
```bash
stat /
```
