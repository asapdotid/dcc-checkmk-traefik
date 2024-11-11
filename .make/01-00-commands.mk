##@ [Utility Commands]

# @see https://stackoverflow.com/a/43076457
execute-in-container:
	@$(if $(DOCKER_SERVICE_NAME),,$(error DOCKER_SERVICE_NAME is undefined))
	@$(if $(COMMAND),,$(error COMMAND is undefined))
	$(EXECUTE_IN_ANY_CONTAINER) $(COMMAND)

.PHONY: traefik-shell
traefik-shell: ## Execute shell script in Traefik container with arguments ARGS="pwd"
	@$(EXECUTE_IN_TRAEFIK_CONTAINER) $(ARGS);

.PHONY: logger-shell
logger-shell: ## Execute shell script in Logger container with arguments ARGS="pwd"
	@$(EXECUTE_IN_LOGGER_CONTAINER) $(ARGS);

.PHONY: docker-shell
docker-shell: ## Execute shell script in Docker proxy container with arguments ARGS="pwd"
	@$(DOCKER_SERVICE_NAME_DOCKER_PROXY) $(ARGS);
