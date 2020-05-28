FROM debian:stretch
RUN apt-get update && apt-get install curl jq -y
RUN apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/{apt,dpkg,cache,log}/
WORKDIR /app/
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod 777 kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
COPY . .
RUN chmod 777 entrypoint.sh
ENTRYPOINT ./entrypoint.sh
