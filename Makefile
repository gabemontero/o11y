SHELL=/usr/bin/env bash -o pipefail

VPATH ?= $(shell pwd):$(PATH)
export PATH := $(VPATH)
# Runtime CLI to use for running images
CONTAINER_ENGINE ?= $(shell command -v podman 2>/dev/null || echo docker)
IMG_VERSION=1.0.4

BASE_DATA_CMD=$(CONTAINER_ENGINE) run -v "$(shell pwd):/work" --rm --privileged -t quay.io/rhobs/obsctl-reloader-rules-checker:$(IMG_VERSION) -t rhtap -d rhobs/alerting/data_plane -y -p
BASE_CONTROL_CMD=$(CONTAINER_ENGINE) run -v "$(shell pwd):/work" --rm --privileged -t quay.io/rhobs/obsctl-reloader-rules-checker:$(IMG_VERSION) -t rhtap -d rhobs/alerting/control_plane -y -p

.PHONY: all
all: check-and-test

.PHONY: check-and-test
check-and-test:
	$(BASE_DATA_CMD) --tests-dir test/promql/tests/data_plane
	$(BASE_CONTROL_CMD) --tests-dir test/promql/tests/control_plane

.PHONY: check
check:
	$(BASE_DATA_CMD)
	$(BASE_CONTROL_CMD)

