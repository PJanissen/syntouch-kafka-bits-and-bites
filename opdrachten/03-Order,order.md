# John Bercow rules!
(John Bercow is de voorzitter van het Britse Lagerhuis, bekend vanwege zijn "Order, order!". Zelfs zijn kat heet naar verluidt [Order](https://nos.nl/artikel/2267757-lagerhuis-voorzitter-nu-zelf-beroemdheid-zelfs-zijn-kat-heet-order.html)...).

In ieder geval heb je net gemerkt dat Kafka toch wel verschilt van een reguliere message queue, zo is er geen echte volgorde gedefinieerd.
Het enige wat Kafka garandeert is dat berichten in dezelfde partitie geordend zijn, maar niet over de partities heen.

## Hoe te partitioneren?
Dit roept de vraag op op welke manier je berichten kunt sturen/koppelen aan een specifieke partitie en het antwoord is: niet.
Of in ieder geval: niet eenvoudig, hiervoor moet je een eigen partitioneringsschema schrijven geïmplementeerd in een [Java Partitioner implementatie](https://kafka.apache.org/23/javadoc/org/apache/kafka/clients/producer/Partitioner.html).

Wat Kafka wel garandeert is dat berichten met _dezelfde key_ altijd in _dezelfde partitie_ worden geplaatst (en dus zijn de berichten met dezelfd key geordend).

Tot nu toe hebben we berichten  verzonden zonder key, dus is er een key gegenereerd door Kafka zelf, ongerelateerd aan de message payload.

## Keyed topic
Laten we nog een topic **keyed-topic** aanmaken voor het testen van berichten met een sleutel; bij het aanmaken van het topic hoef je nog géén instellingen mee te geven (kafka gebruikt altijd een key), maar uitsluitend bij het puliceren van het bericht.
```
kafka-topics --bootstrap-server :9092,:9093 --create --topic keyed-topic --partitions 8 --replication-factor 2
```

### Keyed publish
Bij het publiceren van een bericht met een sleutel in de kafka-console-producer moet je aangeven dat wat je op één regel intikt, zowel een key als een message is en wat het scheidingsteken tussen beide vormt. Dit doe je door twee properties door te geven als "key=value", ieder achter een --property vlag (dus --property "key=value"). Aanhalingstekens/apostrofs zijn niet verplicht maar kunnen handig zijn ...
De properties zijn "parse.key=true" en "key.separator=<jouw-key-separator-hier>".

### Consumers
Laten we deze keer niet één maar twee consumers starten die gezamelijk het topic - in goed onderling overleg - uitlezen.
Zonder aanvullende configuratie-opties zouden beide consumers zich beide afzonderlijk abonneren op het topic en dus ieder de volledige set met berichten aangeleverd krijgen. Soms is dit wat je wilt, maar in andere gevallen wil je juist gebruik maken van een verdeling van dezelfde berichtenstroom over een aantal instanties van een afnemer om zo te kunnen schalen.

Het concept binnen Kafka dat hiervoor zorgt heet "consumer group" en is conceptueel simpel: iedere consumer binnen dezelfde consumer group krijgt een aantal partities toegewezen waaruit hij de berichten uitleest.
Hiervoor moet een group.id property worden aangeleverd en optioneel kan een  group.instance.id worden aangeleverd, deze laatste moet uniek binnen de group.id zijn en identificeert de consumer.

Consumers met dezelfde group.id werken samen
__Vraag__ Is er een bovengrens aan het aantal consumers op een topic?

Ook de kafka-console-consumer moet een aantal consumer-properties definiëren op de sleutels van de berichten te tonen, t.w. eenzelfde key-separator (maar ditmaal voor de weergave, die kan dus verschillen van de producer) en print-key=true.

#### United consumers
(_We gaan nu éérst de consumers starten en pas daarna de producer, zodat we alle berichten te zien krijgen zonder --from-beginning_)

Start een terminator venster en splits dat in drieën (of, als je graag wilt: start drie vensters ...). Start binnen de eerste twee vensters twee instanties van consumers binnen dezelfde groep met een commando als onderstaand; specificeer een __andere__ *group.instance.id* voor je tweede consumer, maar gebruik *dezelfde* __group.id__!

```
kafka-console-consumer --bootstrap-server :9092,:9093 --topic keyed-topic --property print.key=true --property key-separator=, --consumer-property group.id=UnitedConsumers --consumer-property group.instance.id=1
```

Start een kafka-console-producer met de  bovenvermelde opties en publiceer een aantal berichten met een verschillende key-waarden.
Herhaal dit en hergebruik dezelfde key-waarde (dit zou moeten leiden tot berichten die naar _dezelfde_ partitie worden gestuurd).
