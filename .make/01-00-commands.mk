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

.PHONY: socket-shell
socket-shell: ## Execute shell script in Socket container with arguments ARGS="pwd"
	@$(EXECUTE_IN_DOCKER_SOCKET_CONTAINER) $(ARGS);

.PHONY: cmk-shell
shell: ## Running shell script in Checkmk container with arguments ARGS="ls -al"
	@$(EXECUTE_IN_CHECKMK_CONTAINER) $(ARGS)

##@ [Checkmk: Commands]

.PHONY: omd
omd: ## Running omd script in container with ARGS="status"
    # @$(DOCKER_SERVICE_CHECKMK_NAME) omd su cmk
	@$(EXECUTE_IN_CHECKMK_CONTAINER) omd $(ARGS)

.PHONY: passwd
passwd: ## Running cmk-passwd script in container with USER="cmkadmin"
	@$(EXECUTE_IN_CHECKMK_CONTAINER) omd su cmk
	@$(EXECUTE_IN_CHECKMK_CONTAINER) cmk-passwd $(USER)
