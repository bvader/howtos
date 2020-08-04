# Migrating Data from 
### Question / Problem Statement
I want to migrate 1 or more indices from y existing  cluster(s) however they are in my data center and I would need to open a network firewall rule so that the reindex API can reach the prod cluster. For this, I need the origin IP of the new cluster. How do I get it? I tried adding the IP of the Elastic node of the new cluster (via DNS lookup). It did not work.

### Answer
Yes that is a problem. That IP you get from the DNS is the IP of the proxy which NATs / Forwards to the correct cluster and nodes it is not the actual node IP.  The actual node IPs are hidden and could change like any other SaaS endpoint / service. Currently, you would need to Open the FW with a very permissive rule like for a block of GCP / CIDR addresses.

### Option 1: 
You could also restore from a snapshot, this is the most used for large dataset. I seem to remember your entire data set is less than 100GB, that is why I was thinking of reindex / streaming.
https://www.elastic.co/guide/en/cloud/current/ec-migrate-data.html

### Option 2: 
There are 2 simple "push" scripts / methods that you can run to push data that way the data is pushed outbound and should alleviate the FW issue.

### Options 2a:
Elasticdump : Very easy perhaps a bit slow. I attached a simple script that should work, it may be a bit slow but it should work.
https://www.npmjs.com/package/elasticdump
1. Install elasticdump
2. Edit the `migrate-index-elasticdump.sh` script to put your index and endpoint parameters in it. It Loads, the index setting, mappings then the index data. 
3. Run `$ ./migrate-index-elasticdump.sh`

### Option 2b: 
Logstash: Little more work, much much faster. Very straightforward and there are some additional settings you can use to affect performance.  It simply uses the logstash elasticsearch input and output plugins

You will need to put the index mapping in first manually (you could actually use the first 2 parts of the elasticdump script to do this or just do a PUT in the dev tools)

1. Download the logstash tarball and untar it (don't install the package that will make it harder)
https://www.elastic.co/downloads/logstash
2. Logstash requires Java
3. Place the `migrate-index-logstash.conf` in the `./config` directory
Edit `migrate-index-logstash.conf` put in your index and credentials, the output section can use your cloud id and cloud auth
4. Test your config from the logstash home directory
`$ ./bin/logstash -t -f ./config/migrate-index-logstash.conf`
It hould exit with a message
`Using config.test_and_exit mode. Config Validation Result: OK. Exiting Logstash`

5. Run your migration
Remember to put your mapping in first
NOTE:  the -r will reload your config to you can trial and error without restarting logstash
NOTE : Logstash does not stop after the migration, it is waiting for additional documents so you will need to ^C
`$ ./bin/logstash -r -f ./config/migrate-index-logstash.conf`

Performance tuning if needed

1. Increase the JVM heap
edit `./config/jvm.options`
and increase the heap size to 4-8g. They must be equal.
```
# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms8g
-Xmx8g
```
