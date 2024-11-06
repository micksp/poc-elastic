
# Notitieblok

## accounts
pgadmin: admin@localhost / admin

kibana: 

## Index bijwerken
Op dit moment loopt de  index via logstash, elke minuut (gescheduled).
Zie logstash.conf voor de configuratie.

Dat is niet echt de bedoeling voor productie. Mogelijke oplossingen:

- In de middleware een transactie starten die behalve updates ook de indexer aanroept.
- De indexer in de middleware inbouwen.
- Een message queue gebruiken om de indexer aan te roepen. bijvoorbeeld RabbitMQ.


## lege index aanmaken
```bash
curl -XPUT "http://0.0.0.0:9200/person_index" -H 'Content-Type: application/json'
curl -XPUT "http://0.0.0.0:9200/city_index" -H 'Content-Type: application/json'
curl -XPUT "http://0.0.0.0:9200/person_city_index" -H 'Content-Type: application/json'
```
## index verwijderen
```bash
curl -XDELETE "http://0.0.0.0:9200/person_index" -H 'Content-Type: application/json'
curl -XDELETE "http://0.0.0.0:9200/city_index" -H 'Content-Type: application/json'
```

## voorbeeld tabel
(bijvoorbeeld in pgadmin, zie model.sql)
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

## voorbeeld in Kibana
In kibana onder management -> dev tools

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
