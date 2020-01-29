Open Kibana and load the mappings and queries below into the dev tools.

Add the mapping `abc-product`
```
DELETE /abc-product

GET /abc-product/

#
# Create The Mapping
#
PUT /abc-product
{
  "mappings": {
    "properties": {
      "product_name": {
        "type": "search_as_you_type"
      },
      "category_search": {
        "type": "search_as_you_type"
      },
      "category": {
        "type": "keyword"
      },
      "price": {
        "type": "float"
      },
      "description": {
        "type": "text"
      }
    }
  }
}
```

Edit the [abcycling-logstash.conf](./abcycling-logstash.conf) to point at your elasticsearch and run logstash

```bash
sudo /home/install/7.5.1/logstash-7.5.1/bin/logstash -r -f ./abcycling-logstash.conf
```

Then we will try some [search-as-you-type](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-as-you-type.html) samples 

```
#
# Search as you type with Aggs
#
GET /abc-product/_search
{
  "_source": [
    "product_name",
    "category"
  ],
  "size": 5, 
  "query": {
    "multi_match": {
      "query": "King ISO",
      "type": "bool_prefix",
      "fields": [
        "product_name",
        "product_name._2gram",
        "product_name._3gram",
        "category_search",
        "category_search",
        "category_search"
      ]
    }
  },
  "aggs": {
    "genres": {
      "terms": {
        "field": "category"
      }
    }
  }
}

#
# Search as you type with post filter
#
GET /abc-product/_search
{
  "_source": [
    "product_name",
    "category"
  ],
  "size": 5,
  "query": {
    "multi_match": {
      "query": "Wheels",
      "type": "bool_prefix",
      "fields": [
        "product_name",
        "product_name._2gram",
        "product_name._3gram"
      ]
    }
  },
  "post_filter": {
    "term": {
      "category": "Bottom Brackets"
    }
  }
}

#
# Pure Agg
#
GET /abc-product/_search
{
  "_source": [
    "product_name",
    "category"
  ],
  "size" : 0,
  "aggs": {
    "genres": {
      "terms": {
        "field": "category"
      }
    }
  }
}

```
