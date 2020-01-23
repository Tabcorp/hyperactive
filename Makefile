BIN = ./node_modules/.bin

node_modules: package.json
	@npm install

lint: node_modules
	@$(BIN)/require-lint

test: node_modules lint
	@SRC=src $(BIN)/mocha

publish: lint test
	@echo "Checking unignored ..."
	@echo
	@unignored
	@echo
	@echo "Verify that the content above is correct"
	@read -p "Press [Enter] to publish to npm"
	@npm publish

.PHONY: lint test publish
