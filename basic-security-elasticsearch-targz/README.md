
# Walkthrough Single Node Secured Elasticsearch + Kibana with Elastic generated self signed certs (updated) - Easy to Debug :)

![Elastic Securty Layers](https://www.elastic.co/guide/en/elasticsearch/reference/current/images/elastic-security-overview.png)

#### NOTE / DISCLAIMER: **This configuration should only be used for Dev / POC / Leanging / Debugging purposes this is NOT suitable for production use.**

For Further Details Please Refer to the Official Documentation: [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) and [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)

## Overview
This is a super simple progressive HowTo to setup Elasticsearch and Kiban Basic Security + TLS. The aim is to show the progressive steps and help debug if there are issues. This is based on the [Manually configure security section ](https://www.elastic.co/guide/en/elasticsearch/reference/current/manually-configure-security.html#manually-configure-security) progression of the Official Elasticsearch Documentation

For Further Details Please Refer to the Official Documentation: [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) and [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)

### What we are doing?

This is simple / minimal quickstart to create a single Elasticsearch node and Kibana with basic authentication and SSL/TLS enabled (we will enable SSL for both HTTPS and Transport layer even though it is just a single node). This is a condensed / direct path to the Basic Security + HTTPs shown in the diagram [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-stack-security.html) and described [Configure security for the Elastic Stack](https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-stack-security.html#security-basic-https-overview). We will be binding Elasticsearch and Kibana to the network so it can be safely reached from another system.  
**Do NOT bind your Elasticsearch node or cluster to the network unless you secure your cluster and Kibana FIRST!** 



**Notes:** 
* This example is using Elastic Stack 7.15+, 8.0+ and Ubuntu 20.04 LTS using a tar.gz
* We will use the `tar.gz` distributions and run Elasticsearch and Kibana in the foreground for easy debugging
* We are colocating Elasticsearch and Kibana for POC / Dev purposes only.
* There are many important settings for Elasticsearch that are not in the example please review them [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html) before moving on from POC / Dev mode
* All the IP Adresses and Hostnames are just examples and are not to be taken literally, please replace with your own.
* We are not settings any other setting than necessary. 


This HowTo includes the minimalist versions of [elasticsearch.yml](./elasticsearch.yml) and [kibana.yml](./kibana.yml) which we will use to progress through the steps.



For Further Details Please Refer to the Official Documentation: [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) and [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)



## Step 0 - Setup
Open 3 Terminals on the same host one for Elasticsearch, One for Kibana and One to run some additionl commands 
Download Elasticsearch and Kibana and untar them

Elasticsearch - Terminal 1 (T1 from here on out)
```
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.10.2-linux-x86_64.tar.gz
tar -xvf elasticsearch-8.10.2-linux-x86_64.tar.gz
cd elasticsearch-8.10.2
mv config/elasticsearch.yml config/elasticsearch.yml.bak
vi config/elasticsearch.yml
```
Copy / Paste the [elasticsearch.yml](./elasticsearch.yml) provided in this repo into `config/elasticsearch.yml`


Kibana - Terminal 2 (T2 from here on out)
```
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-8.10.2-linux-x86_64.tar.gz
tar -xvf kibana-8.10.2-linux-x86_64.tar.gz
cd kibana-8.10.2
mv config/kibana.yml config/kibana.yml.bak
vi config/kibana.yml
```
Copy / Paste the [kibana.yml](./kibana.yml) provided in this repo into `config/kibana.yml`

From here on when we work on Elasticsearch stay in Terminal 1 (T1) in the base Elasticsearch directory, Kibana Terminal 2 (T2) in the base Kibana directory

Open a 3rd Terminal (T3 from here on out) in the `elasticsearch-8.10.2` directory to run `curl` and other elasticsearch setup commands etc.

Run these 3 commands and save the results for later use 
`ifconfig`
`hostname`
`hostname -f` If you want to use a FQDN

#### NOTE Hostnames
All hostnames are examples my hostname  of `stephenb-es-test` is just the example please use `localhost` or the hostname retruned by one of the commands above in all subsequent commands and in the `kibana.yml` where needed.

#### IMPORTANT
**For 7.x You do not need to make any changes in the `elasticsearch.yml` or `kibana.yml` files**

**For 8.x You do need to ucomment the Step 0 line in `elasticsearch.yml` to disable autoconfiguration, there are no changes in `kibana.yml`**

## Step 1 - Basic Non Secure Stack



T1 - Start Elastic 

`./bin/elasticsearch`

T3 - Test with simple curl, you should get a happy reponse ... *"You Know, for Search"*

`curl http://stephenb-es-test:9200`

T2 - Start Kibana

`./bin/kibana`

Navigate browser to

`http://stephenb-es-test:5601`

Should Kibana should load and connect to Elasticsearch 

T1 & T2: Stop `Ctrl+C` both Elasticsearch and Kibana

## Step 2 Config - Basic Auth

T1: Open `config/elasticsearch.yml`
`vi config/elasticsearch.yml`

And Uncomment the Step 2 Configurations
```
### Step 2
xpack.security.enabled: true
```
Save and exit `elasticsearch.yml`

T1: Start Elastic 
`./bin/elasticsearch`

T3: Generate / Set Passwords for the Elastic built-in users 
`./bin/elasticsearch-setup-passwords auto`
Store the output in a text file for further use 

T3:Test that we can connect to Elasticsearch with the new `kibana_system` user
Again, you should get a happy reponse ... *"You Know, for Search"*
`curl -u kibana_system http://stephenb-es-test:9200`

T2: Open `config/kibana.yml`
`vi config/kibana.yml`

And Uncomment the Step 2 Configurations, put in the correct `kibana_system` password

```
### Step 2
elasticsearch.username: "kibana_system"
elasticsearch.password: "aksdfjhasldkfjhasdflkj"
```
Save and exit `kibana.yml`


T2: Start Kibana 
`./bin/kibana`

Navigate browser to

`http://stephenb-es-test:5601`

Kibana should load and connect to Elasticsearch now you will need to log in with the `elastic` user and the password that was generated generate password step above.

T1, T2: Stop Both with `Ctl+c`

## Step 3 - Enable Transport SSL

T1: Uncomment the Step 3 Configurations in `elasticsearch.yml`
T2: NOTE there are no changes needed for `kibana.yml` for step 3

Generate transport certs

T1: All Defaults / No Passwords
```
./bin/elasticsearch-certutil ca
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
mv *.p12 config/.
```

Restart Both Test Both

T1: Start Elastic 
`./bin/elasticsearch`

T2: Start Kibana 
`./bin/kibana`

Navigate browser to and log in with `elastic` user

`http://stephenb-es-test:5601`

T1 & T2: Stop `Ctrl+C` both Elasticsearch and Kibana

## Step 4 - Enable Elasticsearch HTTPS 

T1: Uncomment the Step 4 Configurations in `elasticsearch.yml`
T2:  Uncomment the Step 4 Configurations in `kibana.yml` 
NOTE now that we are using HTTPS to connect Kibana with Elasticsearch comment out the `elasticsearch.hosts` line from Step 1


Generate elasticsearch http certs
Use All Defaults, No Passwords
For Hostname use `localhost` and the hostname you recorded from above in my case `stephenb-es-test` and the FQDN if you like example 
For IPs use the `127.0.0.1` plus the IP(s) you got from running th `ifconfig` command 

T1: 
```
./bin/elasticsearch-certutil http
...
Generate a CSR? [y/N]n
...
Use an existing CA? [y/N]y
...
CA Path: `/home/sbrown/es-test/elasticsearch-8.10.2/config/elastic-stack-ca.p12`
Password for elastic-stack-ca.p12:<none>
...
For how long should your certificate be valid? [5y] 
Generate a certificate per node? [y/N]y
...
Enter all the hostnames that you need, one per line.

When you are done, press <ENTER> once more to move on to the next step.

localhost
stephenb-es-test
stephenb-es-test.mydomain.internal
...
Is this correct [Y/n]y
...
Enter all the IP addresses that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

127.0.0.1
10.168.0.12
...
Is this correct [Y/n]y
...
Do you wish to change any of these options? [y/N]n
...
Provide a password for the "http.p12" file:  [<ENTER> for none]
...
What filename should be used for the output zip file? [/home/sbrown/es-test/elasticsearch-8.10.2/elasticsearch-ssl-http.zip] 
```

Move the certs to the correct location

```
mv elasticsearch-ssl-http.zip config/
cd config
unzip elasticsearch-ssl-http.zip
cd ..
```
T1: Start Elasticsearch
`./bin/elasticsearch`

Test with curl Again, you should get a happy reponse ... *"You Know, for Search"*

`curl --cacert /home/sbrown/es-test/elasticsearch-8.10.2/config/elasticsearch-ca.pem -u kibana_system https://stephenb-es-test:9200`


T1: Copy the CA generated generated from the certutil https output.
`cp config/kibana/elasticsearch-ca.pem /home/sbrown/es-test/kibana-7.16.3-linux-x86_64/config/.`

T2: Start Kibana 
`./bin/kibana`

Navigate browser to and log in with `elastic` user

`http://stephenb-es-test:5601`


# Followup Notes
**NOTE on 8.x**
You can generate the certs the same way for the .deb and .rpm installations 
Note in 8.x security will be automatically enabled, however you can still setup up security manually if you want to. Just run the cert create commands as in this and then update the appropriate.yml files 

# Gotchas
clear `/etc/host` Files
