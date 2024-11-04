
# Notitieblok

## accounts
pgadmin: admin@localhost:admin
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
```
## index verwijderen
```bash
curl -XDELETE "http://0.0.0.0:9200/person_index" -H 'Content-Type: application/json'
curl -XDELETE "http://0.0.0.0:9200/city_index" -H 'Content-Type: application/json'
```

## voorbeeld tabel
(bijvoorbeeld in pgadmin)
```sql
CREATE TABLE IF NOT EXISTS public.person
(
    id bigint NOT NULL,
    name character varying(150) COLLATE pg_catalog."default" NOT NULL,
    city character varying(75) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT mytable_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.person
    OWNER to myuser;
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

## voorbeeld: join person en city in het resultaat
```
GET /person_index/_search
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "group_by_city": {
        "terms": {
            "field": "city.keyword"
        }
    }
  }
}