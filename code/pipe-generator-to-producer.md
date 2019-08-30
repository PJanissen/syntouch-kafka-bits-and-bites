# Voorbeeld generator-naar-producer
`~/git-repo/code/message-generator.sh 100 1 | kafka-console-producer --property "parse.key=true" --property "key.separator=," --broker-list :9092, :9093, :9094 --topic compacted-topic`
