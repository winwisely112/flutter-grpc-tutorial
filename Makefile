.DEFAULT_GOAL       := help
VERSION             := v0.0.0
TARGET_MAX_CHAR_NUM := 20

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help build prepare flu-web-run flu-mob-run clean

## Show help
help:
	@echo 'Package eris provides a better way to handle errors in Go.'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build the code
build:
	@echo Building
	@docker build -t grpc-chat-server:0.1 go-server


## Run the code
prepare:
	@echo Running
	@docker rm -f grpc-chat-server  || true
	@docker rm -f grpc-web-envoy || true
	@docker run -d --name grpc-chat-server -p 9074:9074 grpc-chat-server:0.1
	@docker run -d --name grpc-web-envoy --volume `pwd`/envoy/envoy.yaml:/etc/envoy/envoy.yaml:ro -p 8074:8074 --link grpc-chat-server:grpc-chat-server envoyproxy/envoy

## Run flutter web
flu-web-run:
	@echo FlutterWebRun
	@cd flutter_client/ && flutter run -d chrome 

## Run flutter all
flu-mob-run:
	@echo FlutterMobRun
	@cd flutter_client/ && flutter run -d all

clean:
	@echo Clean
	@docker rm -f grpc-chat-server  || true
	@docker rm -f grpc-web-envoy || true