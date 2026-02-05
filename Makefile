PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)

.DELETE_ON_ERROR:

all: verify

verify: $(PKG_ID).s9pk
	@start-sdk verify s9pk $(PKG_ID).s9pk
	@echo "Done! Package ready: $(PKG_ID).s9pk"
	@echo "Filesize: $$(du -h $(PKG_ID).s9pk | cut -f1)"

clean:
	rm -rf docker-images
	rm -f $(PKG_ID).s9pk
	rm -f scripts/embassy.js

# Bundle TypeScript to JavaScript
scripts/embassy.js: scripts/embassy.ts scripts/procedures/*.ts scripts/deps.ts
	deno run --allow-read --allow-write --allow-env --allow-net scripts/bundle.ts

# Build Docker image for ARM64
docker-images/aarch64.tar: Dockerfile docker_entrypoint.sh
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) \
		--platform=linux/arm64 \
		-o type=docker,dest=docker-images/aarch64.tar .

# Build Docker image for x86_64
docker-images/x86_64.tar: Dockerfile docker_entrypoint.sh
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) \
		--platform=linux/amd64 \
		-o type=docker,dest=docker-images/x86_64.tar .

# Build the s9pk package
$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png LICENSE scripts/embassy.js docker-images/aarch64.tar docker-images/x86_64.tar
	@echo "Building $(PKG_ID).s9pk..."
	start-sdk pack

# Build only for ARM64 (faster for Start9 servers)
arm: scripts/embassy.js docker-images/aarch64.tar
	rm -f docker-images/x86_64.tar
	start-sdk pack

# Build only for x86_64
x86: scripts/embassy.js docker-images/x86_64.tar
	rm -f docker-images/aarch64.tar
	start-sdk pack

.PHONY: all verify clean arm x86
