#postgres catalog instructions
down-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml down


start-pg-catalog:
	make stop-pg-catalog && docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml up

stop-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml stop

run-pg-catalog:
	make stop-pg-catalog && docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml up

spark-build-services-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml build spark-iceberg spark-worker spark-history-server --no-cache

build-pg-catalog:
	make down-pg-catalog && docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml build

clean-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml down --rmi="all" --volumes
