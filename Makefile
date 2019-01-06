SHELL := /usr/bin/env bash
# All is the first target in the file so it will get picked up when you just run 'make' on its own
all: check_shell check_terraform check_docker check_base_files check_trailing_whitespace

# The .PHONY directive tells make that this isn't a real target and so
# the presence of a file named 'check_shell' won't cause this target to stop
# working
.PHONY: check_shell
check_shell:
	@source test/make.sh && check_shell

.PHONY: setup-project
setup-project:
	# Enables the Google Cloud APIs needed
	./enable-apis.sh

.PHONY: tf-plan
tf-plan:
	# Downloads the terraform providers and plan the configuration
	cd terraform && terraform init && terraform plan

.PHONY: tf-apply
tf-apply:
	# Downloads the terraform providers and applies the configuration
	cd terraform && terraform init && terraform apply

.PHONY: tf-destroy
tf-destroy:
	# Downloads the terraform providers and applies the configuration
	cd terraform && terraform destroy

.PHONY: check_terraform
check_terraform:
	@source test/make.sh && check_terraform

.PHONY: check_docker
check_docker:
	@source test/make.sh && docker

.PHONY: check_base_files
check_base_files:
	@source test/make.sh && basefiles

.PHONY: check_shebangs
check_shebangs:
	@source test/make.sh && check_bash

.PHONY: check_trailing_whitespace
check_trailing_whitespace:
	@source test/make.sh && check_trailing_whitespace
