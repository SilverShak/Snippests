# Nginx-Proxy

Nginx container with Proxy to other containers that are not exposed directly, using the same IP and Port


### Run
docker compose up

### Test
curl localhost - should return "selcome to nginx"
curl localhost/web1 - should return "selcome to web1"
curl localhost/web2 - should return "selcome to web2"

### Tear down
docker compose down -v --rmi all
