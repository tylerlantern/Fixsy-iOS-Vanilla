SHELL := /bin/bash

fmt:
	swiftformat .

loadSecret:
	@chmod +x ./bin/load-secret.sh
	sh ./bin/load-secret.sh

saveSecret:
	@chmod +x ./bin/save-secret.sh
	sh ./bin/save-secret.sh
