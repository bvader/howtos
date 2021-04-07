
## Single Node Secured Elasticsearch + Kibana with Self Signed Certs

#### NOTE / DISCLAIMER: **This configuration should only be used for Dev / POC purposes this is NOT suitable for production use.**

For Further Details Please Refer to the Official Documentation:
[Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
[Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)

### What we are doing?

This is simple / minimal quickstart to create a single Elasticsearch node and Kibana with basic authentication and SSL/TLS enabled. We will then be able to bind the Elasticsearch and Kibana to the network so it can be reached from another system.  **Do NOT bind your Elasticsearch node or cluster to the network unless you secure your cluster and Kibana FIRST!**

**Notes:** 
* This example is Ubuntu 18.04
* We are colocating Elasticsearch and Kibana for Dev / POC only for POC / Dev only
* Many of these commands / directores require `root` access so either be prepared to `sudo` most of the commands or just do a `sudo -i` for the duration of the session... your choice...
* There are many important settings for Elasticsearch that are not in the example please review them [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html) before moving on from POC / Dev mode
* All the IP Adresses are just examples and are not to be taken literally.

The Macro Steps we are going to follow are below. These are documented in more detail in the [Configuring Security](https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-security.html) of the Elasticsearch documentation. I have also added a few other helpful hints.  

* Install Elastic Search. 
* Enable Security and Setup SSL/TLS
* Setup Authentication
* Install Kibana
* Setup SSL/TLS
* Test 

### Lets get started...
[Download and Install Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html)

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch
```
[Set the JVM Heap Size](https://www.elastic.co/guide/en/elasticsearch/reference/current/jvm-options.html) in `jvm.options` file. The JVM defaults to 1G, you will want to make it bigger if you want to have better performance. Remember no more than 1/2 the machines RAM.

```bash
sudo vi /etc/elasticsearch/jvm.options
```
Example this sets the heap size to 8GB
```
-Xms8g
-Xmx8g
```

Check the nework interfaces, the output should look something like the below. Note The nework interface name and the inet address in this case. We will use this information later in this case `ens4` and `10.168.0.69`

```bash
ifconfig

ens4: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1460
        inet 10.168.0.71  netmask 255.255.255.255  broadcast 0.0.0.0
....

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
...
```

We will be [setting up TLS on the node](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/ssl-tls.html). Setup the certs, we will [creating self signed certs](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/configuring-tls.html#node-certificates) using the `elasticsearch-certutil` tool. Note you will want to create the cert with the internal address, and loopback and a dns entry for `localhost`. If you have an addition external IP you would add to the ip list as well. We also added `localhost` and the `hostname` for the DNS section. We are also going to extract / create the ca for later use, you will need it. We are going to create them and then put them in a certs directory in the elasticsearch config directory. 

Just take the defaults for all the question and skip the passwords for the .p12s, you can try that later if you like. 



``` bash
sudo -i
cd /usr/share/elasticsearch
./bin/elasticsearch-certutil ca
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --ip 10.168.0.71,127.0.0.1 --dns hostname,localhost
openssl pkcs12 -in elastic-stack-ca.p12 -out selfca.pem -clcerts -nokeys
mkdir /etc/elasticsearch/certs
chmod 755 /etc/elasticsearch/certs
mv *.p12 /etc/elasticsearch/certs/.
mv *.pem /etc/elasticsearch/certs/.
chmod 664 /etc/elasticsearch/certs/*
```

Configure the `elasticsearch.yml`. The `_ens4_` is the name of the network interface, `_local_` is the loopback. This means that elasticsearch will be available on both.

``` bash 
cd /etc/elasticsearch
vi elasticsearch.yml
```


```
# Update this setting
network.host: ["_ens4_", "_local_"]

# Add the rest of these settings at the bottom of the file
discovery.type: single-node

# Enable security
xpack.security.enabled: true

# Enable auditing if you want, uncomment
# xpack.security.audit.enabled: true

# SSL Settings
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/elastic-certificates.p12
xpack.security.http.ssl.truststore.path: certs/elastic-certificates.p12

xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: certs/elastic-certificates.p12

```

Start elasticseearch
```bash
sudo systemctl start elasticsearch.service
```
For reference here is the stop and status commands as well
```bash 
sudo systemctl stop elasticsearch.service

sudo systemctl status elasticsearch.service
```

Elasticsearch Setup Basic Authentication. At this point the is a random bootstrap password and now you are required to set the passwords for all the built in users... make sure you keep track of them all. 

```bash
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
```

Test with `curl`. If you have done everything right you should get an out similar to this, if so congratulations you have a single elasticsearch node with authentication and SSL/TLS!

```bash
cd /etc/elasticsearch
curl -u "elastic:myawesomepassword" --cacert certs/selfca.pem https://localhost:9200
{
  "name" : "my-host-name",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "9KvUe4eoROC1X0hTELYPTg",
  "version" : {
    "number" : "7.5.2",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "8bec50e1e0ad29dad5653712cf3bb580cd1afcdf",
    "build_date" : "2020-01-15T12:11:52.313576Z",
    "build_snapshot" : false,
    "lucene_version" : "8.3.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

If you need to debug / it is not working you find find the Elasticsearchlogs in `/var/log/elasticsearch/elasticsearch.log `

## Next Up Kibana

[Install Kibana](https://www.elastic.co/guide/en/kibana/current/deb.html)

```bash
sudo apt-get update && sudo apt-get install kibana

```


Create Self Signed Certs. These certs will needed to be added "trusted" on the Browser side or you will need to create real certs from a CA. Use the internal or external IP as the common name. 

```bash
sudo -i
cd /etc/kibana
mkdir certs
chmod 755 certs
cd certs
openssl req -newkey rsa:4096 -x509 -sha256  -days 365 -nodes -out kibana.crt -keyout kibana.key
openssl x509 -in kibana.crt -out kibana.pem
cp /etc/elasticsearch/certs/selfca.pem .
chmod 644 *
```

Create a [Kibana keystore](https://www.elastic.co/guide/en/kibana/current/secure-settings.html) and put the elasticsearch password in it, this way it is not exposed in the `kibana.yml` file. 

```bash
/usr/share/kibana/bin/kibana-keystore --allow-root create
/usr/share/kibana/bin/kibana-keystore --allow-root add elasticsearch.password
```


Update the kibana setting in `kibana.yml`

```bash
cd /etc/kibana
vi kibana.yml
```

These are just the settings you need to change, you do not need to change any other settings. 
```
# Note bind to nic address
server.host: "10.168.0.71"

# The URLs of the Elasticsearch instances to use for all your queries.
# NOTE https on the loopback, if not on same host use the ip
elasticsearch.hosts: ["https://127.0.0.1:9200"]

# If your Elasticsearch is protected with basic authentication, these settings provide
# the username and password that the Kibana server uses to perform maintenance on the Kibana
# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
# is proxied through the Kibana server.
elasticsearch.username: "kibana"
#elasticsearch.password: "password" #<- Leave this commented out, it will come from the keystore


# Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
# These settings enable SSL for outgoing requests from the Kibana server to the browser.
server.ssl.enabled: true
server.ssl.certificate: /etc/kibana/certs/kibana.pem
server.ssl.key: /etc/kibana/certs/kibana.key


# Optional setting that enables you to specify a path to the PEM file for the certificate
# authority for your Elasticsearch instance.
elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/certs/selfca.pem" ]

# To disregard the validity of SSL certificates, change this setting's value to 'none'.
#elasticsearch.ssl.verificationMode: none

# Saved Object Encryption Key : Pick your own
xpack.encryptedSavedObjects.encryptionKey: "salkdjfhasldfkjhasdlfkjhasdflkasjdfhslkajfhasldkfjhasdlaksdjfh"
```

Start, stop and status commands

```bash
sudo systemctl start kibana.service
sudo systemctl stop kibana.service
sudo systemctl status kibana.service
```

At this point you should have a secured Kibana running as well. 

Navigate in this example to https://10.168.0.71:5601 You will need to accept the self signed cert and there you have it

A Secured Elasticsearch Node configured with a secured Kibana

![Kibana](./kibana.png) 

All the cert issues can be solved if you create real certs from a real CA.

Note if you need to debug you can start kibana from the command line as a **non root user** with the following command.

```bash
/usr/share/kibana/bin/kibana -c /etc/kibana/kibana.yml
```

## Sending data to Elasticsearch with Logstash and Beats

To connect Logstash to an Elasticsearch cluster that is secured with a self signed certificate you will need to reference the Self CA that you created earlier. This will allow vaildation of the CA and a secure connection. 

```
output {
  elasticsearch {
    hosts => ["https://localhost:9200"]
    user => "elastic"
    password => "password"
    cacert => "/etc/pki/root/selfca.pem"
  }
 stdout {codec => rubydebug}
}
```


