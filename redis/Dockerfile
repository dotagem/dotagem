# Configuration files for redis in the docker compose setup
# the configuration file makes sure the server is accessible for
# the app container.

FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
