override COMPOSE_DC_NODE_FLAGS = --file docker/network.compose.yml --file docker/dc1.compose.yml --file docker/dc2.compose.yml --file docker/dc3.compose.yml

DC_NODE ?= scylla-dc1-n1

.PHONY: dc-up
dc-up: ## Bring up the multi-datacenter setup in detached mode
	@$(DOCKER_COMMAND) compose $(COMPOSE_DC_NODE_FLAGS) up --detach

.PHONY: dc-down
dc-down: ## Bring down the multi-datacenter setup and remove volumes
	@$(DOCKER_COMMAND) compose $(COMPOSE_DC_NODE_FLAGS) down --volumes

.PHONY: dc-nt-status
dc-nt-status: ## Check the nodetool status of the specified node (default: scylla-dc1-n1)
	@$(DOCKER_COMMAND) compose $(COMPOSE_DC_NODE_FLAGS) exec $(DC_NODE) nodetool status

.PHONY: dc-cqlsh
dc-cqlsh: ## Start a cqlsh session on the specified node (default: scylla-dc1-n1)
	@$(DOCKER_COMMAND) compose $(COMPOSE_DC_NODE_FLAGS) exec -it $(DC_NODE) cqlsh

.PHONY: dc-logs
dc-logs: ## Shows DC logs
	@$(DOCKER_COMMAND) compose $(COMPOSE_DC_NODE_FLAGS) logs --follow
