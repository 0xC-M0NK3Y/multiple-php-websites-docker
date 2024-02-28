./stopper.sh
docker system prune --all --force --volumes
docker network prune --force
docker volume prune --force
docker volume rm -f srcs_data-volume
docker volume rm -f srcs_db-volume
