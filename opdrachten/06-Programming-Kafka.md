# Kafka Clients & Producers
Laten we eens kijken hoe complex het is om zelf een programma te schrijven dat berichten verstuurt naar Kafka en deze ook consumeert van Kafka.

Alhoewel Java misschien de meest voor de hand liggende programmeertaal is om interactie met Kafka te hebben, gaan we dit nu toch doen in Python, omdat:
- het kan (er is een Python library voor Kafka)
- Python een script taal is (dus je hoeft niets te compileren of bouwen)
- Python erg hip en elegant is

## Kafka Producers & Consumers
Een Kafka Producer is een Kafka client die berichten produceert, de berichten worden gelezen door Kafka clients die consumers heten. Je kunt eenvoudig een Kafka client schrijven in Python. Ik heb geen tijd meer om zelf een voorbeeld uit te werken, maar als je aan de slag wilt gaan met Python (staat geïnstalleerd op je VM, inclusief de benodigde library) dan vind je hier de voorbeelden:
- [Kafka Producer](https://github.com/confluentinc/confluent-kafka-python/blob/master/examples/producer.py)
- [Kafka Consumer](https://github.com/confluentinc/confluent-kafka-python/blob/master/examples/consumer.py)
