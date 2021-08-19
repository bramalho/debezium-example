# MySQL Debezium Kafka ElasticSearch
Start containers

```bash
docker-compose up -d
```

It may take a while to start all the services. You can check the logs `docker-compose logs -f`

- [Confluent Control Center](http://localhost:9021/clusters)
- [Kibana](http://localhost:5601/app/kibana)

Create the MySQL connector

```json
{
  "name": "todos-connector",  
  "config": {  
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",  
    "database.hostname": "mysql",  
    "database.port": "3306",
    "database.user": "user",
    "database.password": "password",
    "database.server.id": "134094",  
    "database.server.name": "mysql",  
    "database.include.list": "todo",  
    "database.history.kafka.bootstrap.servers": "kafka:9092",  
    "database.history.kafka.topic": "schema-changes.todo"  
  }
}
```

```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{"name":"todos-connector","config":{"connector.class":"io.debezium.connector.mysql.MySqlConnector","tasks.max":"1","database.hostname":"mysql","database.port":"3306","database.user":"user","database.password":"password","database.server.id":"134094","database.server.name":"mysql","database.include.list":"todo","database.history.kafka.bootstrap.servers":"kafka:9092","database.history.kafka.topic":"schema-changes.todo"}}'
```

Create the Elastic Sink connector

```json
{
    "name": "elastic-sink",
    "config": {
        "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
        "tasks.max": "1",
        "topics": "mysql.todo.todos",
        "connection.url": "http://elastic:9200",
        "transforms": "unwrap,key",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "false",
        "transforms.key.type": "org.apache.kafka.connect.transforms.ExtractField$Key",
        "transforms.key.field": "id",
        "key.ignore": "false",
        "type.name": "todo",
        "behavior.on.null.values": "delete"
    }
}
```

```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{"name":"elastic-sink","config":{"connector.class":"io.confluent.connect.elasticsearch.ElasticsearchSinkConnector","tasks.max":"1","topics":"mysql.todo.todos","connection.url":"http://elastic:9200","transforms":"unwrap,key","transforms.unwrap.type":"io.debezium.transforms.ExtractNewRecordState","transforms.unwrap.drop.tombstones":"false","transforms.key.type":"org.apache.kafka.connect.transforms.ExtractField$Key","transforms.key.field":"id","key.ignore":"false","type.name":"todo","behavior.on.null.values":"delete"}}'
```

Check the register connectors

```bash
curl -H "Accept:application/json" localhost:8083/connectors/
```

> At this moment all contenct on table `todos` should be present in the index `mysql.todo.todos`.

Watch the consumer

```bash
docker-compose exec kafka \
    ./bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --topic mysql.todo.todos \
    --from-beginning
```

Make some changes in the `todos` table

```bash
docker-compose exec mysql mysql -p -e "INSERT INTO todo.todos (id, name, description, status) VALUES (NULL, 'Test 6', 'This is my test 6', 'IN_PROGRESS');"
```

You can get query the index using
```bash
curl -X GET "localhost:9200/mysql.todo.todos/_search?pretty"
```
