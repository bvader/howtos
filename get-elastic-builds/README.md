## Commands / Tips for getting Elastic Stack Builds

Base url Tip use Firefox If you want to see pretty print

**Note**  as versions approach Release the go from 7.x to 7.12 as an example
https://artifacts-api.elastic.co/v1/branches

**Note** the commands beload use `jq` which is a json parser & formatter. The retrun either the full path to the artifacts or meta data about the artifacts
- https://stedolan.github.io/jq/
- https://jqplay.org/
- https://httpie.org/

```
curl and HTTP(ie)
Equivalent
curl -s https://artifacts-api.elastic.co/v1/versions/ | jq
http https://artifacts-api.elastic.co/v1/versions/

Equivalent
curl -O
http --download

# After you get results use `curl -O` or `http --download` to download actual build
# Docker can get any image from artifact repo, but AFAICT 
# I can only get the latest official build or SNAPSHOT

# List versions
curl -s  https://artifacts-api.elastic.co/v1/versions/ | jq

# List branches
curl -s  https://artifacts-api.elastic.co/v1/branches/ | jq

# List of Projects in 7.12 and 7.x
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.x' | jq '.branch.builds[0].projects | keys'
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[0].projects | keys'

# Get all the URLS for the latest 7.x Builds 
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.x' | jq '.branch.builds[0].projects[].packages[] | select(.type == "tar").url'

# Get Latest 7.x Builds for filebeat
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.x' | jq '.branch.builds[0].projects[].packages[] | select(.type == "tar").url' | grep linux | grep filebeat

# Get Latest 7.x Builds for specfic build filebeat-7.10.0-SNAPSHOT-linux-x86_64.tar.gz
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.x' | jq '.branch.builds[0].projects[].packages[] | select(.type == "tar").url' | grep linux | grep filebeat-7.10.0-SNAPSHOT-linux-x86_64.tar.gz

# Get Latest 7.12 Builds for filebeat
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[0].projects[].packages[] | select(.type == "tar").url' | grep linux | grep filebeat

# Get the last 3 builds 7.12 Builds for filebeat
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[0,1,2].projects[].packages[] | select(.type == "tar").url' | grep linux | grep filebeat

# Get the attributes for the latest Build
curl -s  'https://artifacts-api.elastic.co/v1/branches/7.x' | jq '.branch.builds[0]' | head -n 20 

# Get the last 3 builds 7.12 Builds for filebeat
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[0,1,2].projects[].packages[] | select(.type == "tar").url' | grep linux | grep filebeat

# Get Attributes for specfic build 7.12.0-c32dea82 then get build
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[] | select(.build_id == "7.12.0-c32dea82")' | head -n 20

# Get Metadata about 3 most recent 7.12 builds
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[0,1,2] | { branch, build_id, end_time, manifest_version, release_branch, start_time, version }'

# Get Filebeat Specific Build 7.12.0-c32dea82 tar
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[].projects[].packages[] | select(.type == "tar").url' | grep linux | grep 7.12.0-c32dea82 | grep filebeat

# Get Docker Images for that specfic build
curl -s 'https://artifacts-api.elastic.co/v1/branches/7.12' | jq '.branch.builds[].projects[].packages[] | select(.type == "docker").url' | grep linux | grep 7.12.0-7bee7813 | grep filebeat
```

Todo
- Create Script to Download Entire Stack



