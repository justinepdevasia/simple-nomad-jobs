FROM rabbitmq:3.11.11-management
COPY rabbitmq.conf /etc/rabbitmq
RUN rabbitmq-plugins enable --offline rabbitmq_peer_discovery_consul rabbitmq_prometheus