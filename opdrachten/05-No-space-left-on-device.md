# No space left on device
Mooi hoor, zo'n message broker als Kafka ... maar niet iedereen heeft een batterij vol met schijven beschikbaar om de berichten op de topics op te kunnen blijven slaan. Om de ongebreidelde data-verzamelwoede beter het hoofd te kunnen bieden, biedt Kafka een aantal opties om ruimte te kunnen besparen, configureerbaar per topic:
- compressie: GZIP, LZ4 & Snappy - standaard uit
- bericht vervaltijden - standaard 168h
- logs samenduwen ("log compaction") - bewaar minimaal het laatste bericht per sleutel


## Log compaction
Bij het gebruik van "log compaction" wordt gegarandeerd dat minimaal het laatste bericht per sleutel bewaard blijft. Als berichten een toestand volledig representeren is het dus mogelijk om voor alle sleutels die ooit gepasseerd zijn deze toestand vast te houden.
Bijvoorbeeld een order, het laatst bekende adres van een klant, of een laatste meetpunt in een reeks.

### Kafka Cluster
Zorg ervoor dat je een kafka cluster hebt draaien. In dit voorbeeld ga ik ervan uit dat je een zookeeper server op 2181 draait en drie Kafka brokers op de poorten 9092, 9093 en 9094. Zo niet, dan moet je de onderstaande commando's naar je eigen situatie aanpassen.


### Compacterend topic
Om gebruik te maken van deze functionaliteit (nl. van het compacteren van een topic), moeten we op het topic een aantal instellingen configureren:

`kafka-topics --bootstrap-server :9092,:9093, :9094 --create --topic compacted-topic --partitions 1 --replication-factor 3 --config "cleanup.policy=compact"  --config "segment.ms=1000" --config "min.cleanable.dirty.ratio=0.001"`


De instellingen zorgen er voor dat:
- kafka het topic compact houdt (cleanup.policy=compact)
- het compacteren snel kan gebeuren (vanaf een segment-leeftijd van 1000 ms)
- al bij weinig duplicaten (ratio duplicaat/totaal >= 0.001)

_Uiteraard zijn dit agressieve instellingen om dit effect snel duidelijk te laten worden een geen instellingen voor op een echt cluster!_

### Message generator
In de subdirectory code is een bash shell script "message-generator.sh" dat een opgegeven aantal berichten genereert en dat een aantal keren herhaalt.
Je start het script door het uit te voeren in de bash shell, bijvoorbeeld:
`pad-naar-script/message-generator.sh AANTAL-BERICHTEN   AANTAL-HERHALINGEN`

De berichten worden op STDOUT gegenereerd in het formaat:
`key,message`
Test het script maar even met bijvoorbeeld 5 berichten in twee iteraties, dan zie je wat er gebeurt:
`~/git-repo/code/message-generator.sh 5 2`

### Berichten loodgieterij
Het script schrijft de berichten naar STDOUT en de kafka-console-producer leest berichten van STDIN ... kunnen we die niet aan elkaar knopen?

![Yes we can!](../assets/yes-we-can.png)

Stuur 100 verschillende berichtsleutels in een iteratie door naar het compacted-topic; hierbij moet je een tweetal extra configuratie-opties meegeven om te verzorgen dat de sleutel en het bericht uit de invoerregels worden gelezen:
Deze properties zijn:
`--property "parse.key=true" --property "key.separator=,"`.

Als je er niet (helemaal) uitkomt, dan staat [hier een voorbeeld](code/pipe-generator-to-producer.md)

### Inspection
Kijk naar het compacted-topic in KafkaTool; als het goed is, dan zul je daar alle berichten nog moeten zien staan, want je hebt alle sleutels maar een keer aangeleverd.

### Meer! Meer! Meer!
Laten we er nog wat berichten bij plaatsen op hetzelfde topic, laten we zeggen nog 100 berichten en 9 herhalingen.
Wacht een paar seconden als de generator is uitgeraasd en biedt nu nogmaals eenmalig 5 berichten (dit forceert een nieuw log segment in Kafka)

Controleer nu nogmaals wat er met de berichten is gebeurd ... Hoeveel berichten heb je in de voorgaande iteraties geproduceerd op het topic? Hoeveel berichten zijn er nog aanwezig op je topic? Zijn er dubbele berichten (misschien kunnen we deze vraag straks eenvoudiger beantwoorden ... :sweat_drops:)
