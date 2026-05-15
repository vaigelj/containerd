# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PACKAGE = github.com/containerd/containerd
BINARIES = containerd ctr containerd-shim containerd-shim-runc-v1 containerd-shim-runc-v2

# Build variables
VERSION   ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0-dev")
REVISION  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GO        ?= go
GOFLAGS   ?= -trimpath
LDFLAGS   = -X $(PACKAGE)/version.Version=$(VERSION) \
             -X $(PACKAGE)/version.Revision=$(REVISION)

# Output directory
BIN_DIR ?= bin

.PHONY: all
all: binaries

.PHONY: binaries
binaries: $(BINARIES:%=$(BIN_DIR)/%)

$(BIN_DIR)/%:
	@mkdir -p $(BIN_DIR)
	$(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $@ ./cmd/$*

.PHONY: build
build:
	$(GO) build $(GOFLAGS) ./...

.PHONY: test
test:
	$(GO) test -v -count=1 ./...

.PHONY: test-unit
test-unit:
	$(GO) test -v -count=1 -short ./...

.PHONY: lint
lint:
	golangci-lint run ./...

.PHONY: fmt
fmt:
	$(GO) fmt ./...

.PHONY: vet
vet:
	$(GO) vet ./...

.PHONY: tidy
tidy:
	$(GO) mod tidy

.PHONY: vendor
vendor:
	$(GO) mod vendor

.PHONY: clean
clean:
	rm -rf $(BIN_DIR)

.PHONY: install
install:
	$(GO) install $(GOFLAGS) -ldflags "$(LDFLAGS)" ./cmd/containerd
	$(GO) install $(GOFLAGS) -ldflags "$(LDFLAGS)" ./cmd/ctr

.PHONY: version
version:
	@echo $(VERSION)

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build all binaries (default)"
	@echo "  binaries   - Build all binaries into $(BIN_DIR)/"
	@echo "  build      - Compile all packages"
	@echo "  test       - Run all tests"
	@echo "  test-unit  - Run unit tests only"
	@echo "  lint       - Run linter"
	@echo "  fmt        - Format source code"
	@echo "  vet        - Run go vet"
	@echo "  tidy       - Tidy go modules"
	@echo "  vendor     - Vendor dependencies"
	@echo "  clean      - Remove build artifacts"
	@echo "  install    - Install binaries to GOPATH"
	@echo "  version    - Print version"
