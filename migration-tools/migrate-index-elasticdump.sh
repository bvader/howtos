#!/bin/bash

INPUT_ES="http://localhost:9200"
OUTPUT_ES="https://elastic:mysecretpassword@1234567894c4084c36cb3bd74c467.us-west1.gcp.cloud.es.io:443"
INPUT_INDEX_NAME="kibana_sample_data_flights"
OUTPUT_INDEX_NAME="reindex-kibana_sample_data_flights"
# INPUT_INDEX_NAME="filebeat-7.9.0-2020.08.03-000001"
# OUTPUT_INDEX_NAME="reindex-filebeat-7.9.0-2020.08.03-000001"

elasticdump \
  --input=${INPUT_ES}/${INPUT_INDEX_NAME} \
  --output=${OUTPUT_ES}/${OUTPUT_INDEX_NAME} \
  --type=settings
elasticdump \
  --input=${INPUT_ES}/${INPUT_INDEX_NAME} \
  --output=${OUTPUT_ES}/${OUTPUT_INDEX_NAME} \
  --type=mapping
elasticdump \
  --input=${INPUT_ES}/${INPUT_INDEX_NAME} \
  --output=${OUTPUT_ES}/${OUTPUT_INDEX_NAME} \
  --type=data \
  --limit=10000 \
  --noRefresh