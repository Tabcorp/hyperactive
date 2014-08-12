BIN = ./node_modules/.bin

node_modules: package.json
	@npm install

compile: node_modules
	@$(BIN)/coffee --output target --compile src

watch: node_modules
	@$(BIN)/coffee --output target --watch --compile src

lint: node_modules compile
	@$(BIN)/require-lint

test: node_modules lint
	@SRC=src $(BIN)/mocha

test-js: node_modules lint
	@SRC=target $(BIN)/mocha

publish: compile lint test-js
	@$(BIN)/irish-pub
	@echo
	@echo "Verify that the content above is correct"
	@read -p "Press [Enter] to publish to npm"
	@npm publish

.PHONY: compile watch lint test test-js publish
