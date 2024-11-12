# @see https://stackoverflow.com/a/43076457
execute-in-container:
	@$(if $(DOCKER_SERVICE_NAME),,$(error DOCKER_SERVICE_NAME is undefined))
	@$(if $(COMMAND),,$(error COMMAND is undefined))
	$(EXECUTE_IN_ANY_CONTAINER) $(COMMAND)

##@ [Checmk: Commands]

.PHONY: cmk-omd
cmk-omd: ## Execute omd script in container with ARGS="status"
## @$(EXECUTE_IN_CHECKMK_CONTAINER) su - cmk
	@$(EXECUTE_IN_CHECKMK_CONTAINER) omd $(ARGS)

.PHONY: cmk-passwd
cmk-passwd: ## Execute cmk-passwd script in container with USER="cmkadmin"
	@$(EXECUTE_IN_CHECKMK_CONTAINER) omd su cmk
	@$(EXECUTE_IN_CHECKMK_CONTAINER) cmk-passwd $(USER)

##@ [Utility Commands]

.PHONY: traefik-shell
traefik-shell: ## Execute shell script in Traefik container with arguments ARGS="pwd"
	@$(EXECUTE_IN_TRAEFIK_CONTAINER) $(ARGS);

.PHONY: logger-shell
logger-shell: ## Execute shell script in Logger container with arguments ARGS="pwd"
	@$(EXECUTE_IN_LOGGER_CONTAINER) $(ARGS);

.PHONY: docker-shell
docker-shell: ## Execute shell script in Docker socket container with arguments ARGS="pwd"
	@$(DOCKER_SERVICE_NAME_DOCKER_SOCKET) $(ARGS);

.PHONY: cmk-shell
cmk-shell: ## Execute shell script in Checkmk container with arguments ARGS="pwd"
	@$(DOCKER_SERVICE_NAME_CHECKMK) $(ARGS)
