.PHONY: help
help: ## list all make commands available
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: deps
deps: ## Install dependencies
	poetry install
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

.PHONY: pre-commit
pre-commit: ## Setup pre-commit in your local repo
	poetry run pre-commit install

.PHONY: local-test
local-test: ## Run all tests and export coverage in html format
	poetry run pytest --cov='$(shell make package_folder)' --cov-report=html tests/

.PHONY: local-test-no-cov
local-test-no-cov: ## Run all tests and export coverage in html format
	poetry run pytest tests/

.PHONY: run-lint
run-lint: # Run pre-commit
	poetry run pre-commit run -a

.PHONY: build-src-docs
build-src-docs: poetry run sphinx-apidoc -o source/ ../src

.PHONY: build-libs-docs
build-libs-docs: poetry run sphinx-apidoc -o source/ ../libs
