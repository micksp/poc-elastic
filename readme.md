
# POC ElasticSearch

## Setup
```bash
docker-compose up -d
```

### accounts
- pgadmin: admin@example.com / admin
- kibana:

### Postgres
Open pgadmin op http://localhost:8080

Maak een nieuwe server aan met de volgende gegevens:
- naam: acnext
- host: postgres
- poort: 5432
- database: postgres
- user: myuser
- password: mypassword

open de query tool en voer de volgende sql uit:
```sql
CREATE TABLE city (
  id INT PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE person (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES city(id)
);
```
<img src="assets/querytool.png">

vul de database met mockdata (zie mocker/data.sql)

### Elasticsearch
Open kibana op http://localhost:5601 (kies "explore on my own")

Voor de connectie tot elastic via kibana heb je een enrolment-token nodig. Je krijgt dit token de eerste keer elastic opstart.
Als je dat gemist hebt kun je een nieuwe aanmaken met het volgende commando:
```bash
docker exec elasticsearch /bin/bash -c "bin/elasticsearch-create-enrollment-token -s kibana"
```  

open hamburger menu -> stack management -> index management
Creëer een index met de naam "person_index" en "city_index" en "person_city_index"
```bash
curl -XPUT "http://0.0.0.0:9200/person_index" -H 'Content-Type: application/json'
curl -XPUT "http://0.0.0.0:9200/city_index" -H 'Content-Type: application/json'
curl -XPUT "http://0.0.0.0:9200/person_city_index" -H 'Content-Type: application/json'
```
In kibana moeten de indexen nu verschijnen. Omdat ondertussen logstash al loopt, zouden er al records in de indexen moeten zitten (binnen 1 minuut). 
Behalve vie kibana kun je de indexen ook opvragen via: 
```bash
curl -X GET "localhost:9200/_cat/indices?v"
```
Ze hebben status yellow in plaats van green, omdat er maar 1 node is. Voor development is dat geen probleem.
De postgresql-xxx.jar is nodig om de jdbc driver te installeren in logstash. Dit wordt geregeld in de docker-compose.yml.


## Index bijwerken
Op dit moment loopt de  index via logstash, elke minuut (gescheduled).
Zie logstash.conf voor de configuratie.

Dat is niet echt de bedoeling voor productie. Mogelijke oplossingen:

- In de middleware een transactie starten die behalve updates ook de indexer aanroept.
- De indexer in de middleware inbouwen.
- Een message queue gebruiken om de indexer aan te roepen. bijvoorbeeld RabbitMQ.

## Notities
### index verwijderen
```bash
curl -XDELETE "http://0.0.0.0:9200/person_index" -H 'Content-Type: application/json'
curl -XDELETE "http://0.0.0.0:9200/city_index" -H 'Content-Type: application/json'
```

## Query's
In kibana onder hamburger-menu -> management -> dev tools

### Zoeken
```
GET /person_index/_search
GET /person_index/_count
```

## Voorbeeld met facetten (buckets)
```
GET /person_index/_search
{
  "size": 0,
  "aggs": {
    "group_by_city": {
        "terms": {
            "field": "city.keyword"
        }
    }
  }
}
```
## voorbeeld sortering op city
```
GET /person_index/_search
{
  "size": 10,
  "sort": [
    {
      "city.keyword": {
        "order": "asc"
      }
    }
  ]
}
```

## voorbeeld paginering
```
GET /person_index/_search
{
  "from": 10,
  "size": 10
}
```

## voorbeeld: zoek alle records met plaatsnaam Amsterdam
```
GET /person_index/_search
{
  "query": {
    "match": {
      "city": "Amsterdam"
    }
  }
}
```

## voorbeeld: zoek alle steden
```
GET /city_index/_search
```


## voorbeeld: join index
```
GET /person_city_index/_search
{
  "query": {
    "match_all": {}
  }
}
```

## voorbeeld: join index met facetten
## default = top 10
```
GET /person_city_index/_search
{
  "size": 0,
  "aggs": {
    "group_by_city": {
        "terms": {
            "field": "city.keyword"
        }
    }
  }
}
```

## voorbeeld: join index met facetten, top 5
## haalt de top 10 op, volgorde buckets is van groot naar klein
```
GET /person_city_index/_search
{
  "size": 0,
  "aggs": {
    "group_by_city": {
        "terms": {
            "field": "city.keyword",
            "size": 5
        }
    }
  }
}
```

## voorbeeld: alle facetten ophalen. gebruik compositie van aggregatie
```
GET /person_city_index/_search
{
  "size": 0,
  "aggs": {
    "all_cities": {
      "composite": {
        "sources": [
          { "city": { "terms": { "field": "city.keyword" } } }
        ],
        "size": 10
      }
    }
  }
}
```
## gebruik after_key in de eerste response om de volgende pagina op te halen
## volgorde in buckets is niet gegarandeerd (bedoeld voor grote datasets)
```
GET /person_city_index/_search
{
  "size": 0,
  "aggs": {
    "all_cities": {
      "composite": {
        "sources": [
          { "city": { "terms": { "field": "city.keyword" } } }
        ],
        "size": 10,
        "after": { "city": "laatst_verwerkte_city_naam" }
      }
    }
  }
}
```
