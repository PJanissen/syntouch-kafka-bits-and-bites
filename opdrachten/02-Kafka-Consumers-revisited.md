# Foutje, bedankt!

De foutmelding geeft al veel van het probleem (én de oplossing) weg:


> 2019-08-23 21:32:26,103] ERROR [KafkaApi-1] Number of alive brokers '2' does not meet the required replication factor '3' for the offsets topic (configured via 'offsets.topic.replication.factor'). This error can be ignored if the cluster is starting up and not all brokers are up yet. (kafka.server.KafkaApis)

Het probleem is dus dat we een té klein cluster hebben om met de standaard-instelling voor de replicatie factor van het "offsets" topic (sneak preview: dit is een soort boekenlegger) te kunnen werken.
Het publiceren van events gaat dus __wel__ goed, alleen het lezen van de events (waarbij de offsets dus kennelijk worden gemanipuleerd) werkt niet naar behoren.

Sluit de kafka consumers/producers/brokers af met \<CTRL\>-C, voeg een nieuwe regel toe aan beide configuratie files /opt/kafka/config/server-{1,2}.properties:

```
offsets.topic.replication.factor=1
```
Herstart hierna de servers (tip: als je de vensters open hebt gelaten, dan kun je de commando historie gebruiken met de pijl-omhoog/omlaag toetsen).

Wacht even tot de servers volledig zijn opgestart en start opnieuw de kafka-console-producer om wat messages e publiceren.
Start nu opnieuw de kafka-console-consumer om de berichten uit te lezen.

Als je inderdaad éérst de producer hebt gestart en daarna de consumer, dan kun je geen berichten hebben gezien. Waarom dat wordt zo duidelijk...

Publiceer - terwijl de consumer nog actief is - vanuit de producer nogmaals een bericht (met een onderscheidende tekst ten opzichte van de voorgaande berichten): dit bericht kun je wel voorbij zien komen in de consumer!
Wat is het geval: het standaard gedrag van de consumer is dat deze alleen berichten ontvangt vanaf het moment dat deze zich heeft aangemeld (d.w.z. de eerste keer met deze identificatie).
Gelukkig meldt de kafka-console-consumer zich iedere keer met een _nieuwe_ identificatie aan, dus als je de consumer stopt, dan kun je 'm hierna herstarten met een extra optie: --from-beginning.

Als je even geduld hebt, dan zul je alle berichten voorbij zien komen, maar deze berichten zijn __niet helemaal__ in dezelfde volgorde waarin zij zijn aangeboden aan Kafka.

Stop de consumer en producer met \<CTRL\>-C, stop de kafka-brokers netjes met het broker stop script:
```
/opt/confluent/bin/kafka-server-stop <pad-naar-het-configuratie-bestand>
```
