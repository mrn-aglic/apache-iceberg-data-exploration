#postgres catalog instructions
down-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml down

run-pg-catalog:
	make down-pg-catalog && docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml up

build-pg-catalog:
	make down-pg-catalog && docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml build

clean-pg-catalog:
	docker compose -f docker-compose.yml -f docker-compose-pg-catalog.yml down --rmi="all" --volumes
