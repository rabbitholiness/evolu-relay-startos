# Evolu Relay Start9 Package Makefile

PKG_ID := evolu-relay
PKG_VERSION := 1.0.0

.PHONY: all clean verify pack install

all: verify pack

# Verify required files exist
verify:
	@echo "Verifying package structure..."
	@test -f manifest.yaml || (echo "Missing manifest.yaml" && exit 1)
	@test -f Dockerfile || (echo "Missing Dockerfile" && exit 1)
	@test -f docker_entrypoint.sh || (echo "Missing docker_entrypoint.sh" && exit 1)
	@test -f scripts/health.sh || (echo "Missing scripts/health.sh" && exit 1)
	@test -f instructions.md || (echo "Missing instructions.md" && exit 1)
	@test -f LICENSE || (echo "Missing LICENSE" && exit 1)
	@test -f icon.png || (echo "Missing icon.png" && exit 1)
	@echo "All required files present."

# Build the .s9pk package
pack:
	@echo "Building Start9 package..."
	start-sdk pack

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(PKG_ID).s9pk

# Install to local Start9 server (requires SSH access)
install: pack
	@echo "Installing to Start9 server..."
	@echo "Upload $(PKG_ID).s9pk via StartOS web interface or use:"
	@echo "  scp $(PKG_ID).s9pk start9@<your-server>:/tmp/"
	@echo "  Then sideload from StartOS System settings"
