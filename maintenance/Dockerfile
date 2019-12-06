FROM nginx

# These are symlinks to /dev/std{out,err}, filebeat can't pick those up, and we
# don't have a way to use the stdout from this docker so allow nginx to write out normal log files
RUN rm /var/log/nginx/* ;\
  apt-get update -y && \
  apt-get install -y wget apt-transport-https gnupg && \
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  echo 'deb https://artifacts.elastic.co/packages/oss-6.x/apt stable main' | tee /etc/apt/sources.list.d/beats.list && \
  apt-get update -y && apt-get install -y filebeat && \
  filebeat modules enable nginx

ADD filebeat.yml /etc/filebeat/filebeat.yml
ADD nginx-default.conf /etc/nginx/conf.d/default.conf
ADD run.sh .
ADD maintenance.html /usr/share/nginx/html/

CMD ./run.sh

# Uncomment and change the logstash output to match below.
#   output.logstash:
#   hosts: ["e8b57be4-4229-46fe-9ebd-eca74c92189e-ls.logit.io:22133"]
#   loadbalance: true
#   ssl.enabled: true



#### Alpine

# https://angrysysadmins.tech/index.php/2019/03/bailey/alpine-installing-filebeat/

# Append this to /etc/apk/repositories
#
# http://dl-cdn.alpinelinux.org/alpine/edge/testing
#
#   apk update
#   apk add filebeat
#
# And now remove the above line
#
#   apk update

# Add to the Logstash output section of /etc/filebeat/filebeat.yml
#
#  hosts: ["e8b57be4-4229-46fe-9ebd-eca74c92189e-ls.logit.io:22133"]
#  loadbalance: true
#  ssl.enabled: true

# Comment out the "hosts" sectino of output.elasticsearch


# Add to /etc/filebeat/filebeat.yml:
#   - module: nginx
#     access:
#       enabled: true
#     error:
#       enabled: true




