# Streams as in BEER!
Voor de volgende opdracht gaan we de streaming data mogelijkheden van Kafka bekijken. Kafka heeft naast de Consumer en Producer APIs ook nog een API voor Kafka Streams, dat is een Java API waarvan je gebruik kunt maken om streaming data te manipuleren in Apache Kafka.

Naast een Java API is er nog een andere hulpmiddel beschikbaar dat misschien niet alle mogelijkheden van de Kafka Streams API heeft, maar wel vele malen gebruiksvriendelijker is en misschien wel 80% van de typische scenario's waarin je Kafka Streams zou kunnen gebruiken, afdekt: KSQL.

Met behulp van KSQL kun je met een SQL-achtige commando taal objecten definieren in Kafka Streams, nl. KStreams en KTables.

## Omgeving
Voor deze opdracht ga je gebruik maken van het Confluent Kafka platform, omdat KSQL hierin al is geïntegreerd. [KSQL](https://github.com/confluentinc/ksql) zelf is ook verkrijgbaar als los component.

Zorg ervoor dat al je Kafka brokers, consumers, zookeepers etc. zijn afgesloten door een \<CONTROL\>-C in de desbetreffende vensters. Het kan even duren voordat het component definitief is afgesloten, begin met de brokers en eindig bij de zookeeper.

Start vervolgens de KSQL-server op het Confluent Platform met:
`confluent local start ksql-server`. Hiermee worden automatisch ook alle overige  benodigde componentent gestart (zoals ZooKeeper, Kafka en de schema-registry)
Hierna kun je het Confluent Control Center dashboard starten met `confluent start local control-center`.
Het control center is een webapplicatie op poort 9021 van je lokale server.

## Control center
Start een browser sessie naar port 9021 op je lokale machine; selecteer vervolgens je cluster  in de blauwe linker balk en kies "Topics" om een nieuw topic aan te gaan maken:
![Control Center](../assets/CCC-Create-topic.png)

Maak vervolgens een nieuw topic COUNTRIES aan met één partitie; de replicatiefactor is nu per definitie  1, want het confluent cluster is lokaal in ontwikkelmodus gestart.
In de folder 'data' in de Git repository is een data file aangeleverd waarin een countries.csv file aanwezig is. Laadt deze in je nieuw aangemaakte topic door de inhoud van de file naar de kafka-console-producer te cat'ten in het nieuwe aangemaakte topic, de broker draait op de standaard poort 9092 ([zo dus ongeveer ...](code\load-countries-csv-to-kafka.sh)).

## KSQL, here we come!
Start hierna een KSQL client op om streams te kunnen manipuleren; start een terminal venster naar keuze en voer `ksql` uit.
Na enkele seconden i KSQL actief en toont een vriendelijke prompt 'ksql>'. Maximaliseer het venster en vraag uit welke topics er nu gedefinieerd zijn op het cluste waarmee je verbinding het gemaakt:

`show topics;`

Je eindigt je commando's met een puntkomma!

Uit de uitvoer zie je dat er een heleboel interne kafka topics aangemaakt zijn door het control center zelf, maar als het goed is zie je je eigen topic COUNTRIES ook terug.

Laten we proberen de inhoud van het topic (de berichten dus) te tonen:
`print COUNTRIES;`

Geen data ... hier is hetzelfde aan de hand als we eerder hebben meegemaakt, waarbij een Kafka client die zich aanmeldt __nadat__ de data is geproduceerd, deze standaard niet te zien krijgt!

Beëindig de lopende opdracht met een enkele welgemeende \<CONTROL\>-C.

Nog een keer, maar nu met een _from beginning_ toegevoegd aan het commando:
`print COUNTRIES from beginning;`

Nu wordt de data wel getoond (samen met de ontvangstdatum en sleutelwaarde NULL), maar ook nu blijft het commando wachten op data ...
Het toevoegen van een _limit_ biedt hier uitkomst om eenvoudig een sectie van de data te kunnen bekijken:
`print COUNTRIES from beginning limit 20;`

### Streams of data
Laten we een stream definieren op de data in dit topic; zie het commando in [<GitHub_REPO>data/countries-format.txt](data/countries-format.txt) om een stream te declareren in KSQL.

Maak de  countries_stream aan met het commando.

Mmm, KSQL klinkt als SQL ... laten we eens proberen om een SELECT op de stream uit te voeren:
`SELECT * FROM countries_stream;`

Helaas, pindakaas. Weer hetzelfde probleem als met de andere opdrachten. Dit probleem is (voor de huidige sessie) in een keer op te lossen door:
`SET 'auto.offset.reset'='earliest';` uit te voeren op de KSQL prompt!

### Streams or tables?
Brouw een query om per continent de naam van het continent, het aantal landen en de totale populatie per continent te bepalen (_tip: KSQL is niet voor niets de naam, het is net SQL ..._ Mocht je er niet uitkomen, kijk dan [hier](../code/ksql-landen-populatie-per-continent.ksql))

Laat deze query maar draaien in KSQL, maar stuur ondertussen de data nogmaals door Kafka heen ... Let op de resultaten in KSQL.

Je ziet dat de totalen nu verdubbelen ... Kafka Streams neemt simpelweg alle data in beschouwing, de resultaten worden bijgewerkt en getoond zodra er verandering optreedt. Nu is het mogelijk om gebruik te maken van WINDOW clausules waarmee tijdsvenster worden gedefinieerd, maar dat is niet altijd een oplossing - zeker niet hier.
Log compaction is ook onbetrouwbaar in deze, omdat dit garandeert dat er per sleutel __minimaal__ de meest recente waarde overbijft (en daarvoor moet je op het Kafka topic een SLEUTEL meeleveren).

Gelukkig is er een alternatief, KTables. Dit is een Kafka tabel, waarbij iedere sleutel slechts één keer voorkomt. Laten we een tabel definiëren op het bestaande topic:
```
create table first_countries_table (
  country_name      VARCHAR,
  country_code      VARCHAR,
  continent         VARCHAR,
  capital           VARCHAR,
  population        INTEGER,
  area              INTEGER,
  coastline         INTEGER,
  government        VARCHAR,
  currency          VARCHAR,
  currency_code     VARCHAR,
  phone_prefix      VARCHAR,
  birthrate         DOUBLE,
  deathrate         DOUBLE,
  life_expectancy   DOUBLE,
  url               VARCHAR
) WITH (KAFKA_TOPIC='COUNTRIES', VALUE_FORMAT='DELIMITED',KEY='country_code');
```

Kun je hieruit resultaten zien als je een zoekvraag stelt op deze tabel?

#### Geen data?!
Helaas, op deze manier is het NIET mogelijk om data op te vragen ... Waarom dat is, kun je [hier](https://stackoverflow.com/questions/49057102/ksql-table-not-showing-data-but-stream-with-same-structure-returning-data) nalezen.

De eenvoudigste manier om dit nu op te lossen, is om de data opnieuw aan te bieden op een (ander) topic en om te sleutelen zodat er een KEY wordt aangeleverd. Laten we shell scripten ...

```bash
cat countries.csv \
  | awk 'FS="," { print $2"#"$1","$3","$4","$5","$6","$7","$8","$9","$10","$11","$12","$13","$14","$15 }' \
  | kafka-console-producer --topic COUNTRIES2 --broker-list :9092 --property "parse.key=true" --property "key.separator=#"
```  
Wat gebeurt er hier? De eerste regel leest het bestand uit, de tweede regel herschikt de velden (veld 2, de landcode wordt als eerste veld gebruikt en wordt van de rest gescheiden door een #, de achterliggende datavelden worden gescheiden door een komma, zoals daarvoor).
De laatste regel verstuurt de omgekatte regel tenslotte naar de Kafka producer, waarbij een sleutel en een message worden aangeleverd, gescheiden door een hekje.
Het bericht zelf (dat de komma's bevat) wordt nu ook weer eenvoudigweg als een tekststring weggeschreve ...

Definieer vervolgens een Kafka table op het nieuw aangemaakte topic (standaard staan de topics op autocreate, dus die hoef je niet van te voren aan te maken ...):
```
create table countries2_table (
  country_name      VARCHAR,
  continent         VARCHAR,
  capital           VARCHAR,
  population        INTEGER,
  area              INTEGER,
  coastline         INTEGER,
  government        VARCHAR,
  currency          VARCHAR,
  currency_code     VARCHAR,
  phone_prefix      VARCHAR,
  birthrate         DOUBLE,
  deathrate         DOUBLE,
  life_expectancy   DOUBLE,
  url               VARCHAR
) WITH (KAFKA_TOPIC='COUNTRIES2', VALUE_FORMAT='DELIMITED');
```
Omdat het TOPIC al was gedefinieerd met een KEY, wordt de tabel automatisch ook met dezelfde key aangemaakt.

Voer nu de aggregatie query uit op de nieuwe __Kafka tabel__, d.w.z. tel het aantal landen en de totale populate per continent - _laat de query draaien_ !
Als de resultaten worden getoond, open dan een tweede venster en biedt daarin __nogmaals__ de data aan zoals je dat de laatste keer hebt gedaan, dus met sleutel.

Als het goed is, dan moet je nu kunnen vaststellen dat de aggregaties opnieuw worden berekend, want er is nieuwe data het topic (en dus de stream) ingegaan. De totalen (landen, inwoners) zijn nu echter *niet* veranderd!
