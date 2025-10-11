SHELL := /bin/bash

SECRETS_SH := ./bin/secrets.sh

.PHONY: fmt loadSecret saveSecret secrets-get secrets-put chmod-secrets

fmt:
	swiftformat .

chmod-secrets:
	@chmod +x $(SECRETS_SH)

# Backward compatible names
loadSecret: secrets-get
saveSecret: secrets-put

secrets-get: chmod-secrets
	$(SECRETS_SH) get

secrets-put: chmod-secrets
	$(SECRETS_SH) put
