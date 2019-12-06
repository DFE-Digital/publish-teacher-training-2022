FROM nginx

# These are symlinks to /dev/std{out,err}, filebeat can't pick those up, and we
# don't have a way to use the stdout from this docker so allow nginx to write out normal log files
RUN rm /var/log/nginx/*

# Install Filebeat
RUN apt-get update -y && \
  apt-get install -y wget apt-transport-https gnupg && \
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  echo 'deb https://artifacts.elastic.co/packages/oss-6.x/apt stable main' | tee /etc/apt/sources.list.d/beats.list && \
  apt-get update -y && apt-get install -y filebeat && \
  filebeat modules enable nginx

# Install logrotate, but not all the extra cruft we don't need.
RUN apt-get install --no-install-recommends --no-install-suggests -y logrotate

ADD filebeat.yml /etc/filebeat/filebeat.yml
ADD nginx-default.conf /etc/nginx/conf.d/default.conf
ADD run.sh .
ADD maintenance.html /usr/share/nginx/html/

CMD ./run.sh



