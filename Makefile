node_modules: package.json
	@npm install

compile: node_modules
	@./node_modules/.bin/coffee --output target --compile src

watch: node_modules
	@./node_modules/.bin/coffee --output target --watch --compile src

lint: compile
	@./node_modules/.bin/require-lint

test: node_modules lint
	@SRC=src ./node_modules/.bin/mocha

test-js: node_modules compile lint
	@SRC=target ./node_modules/.bin/mocha

.PHONY: compile watch lint test test-js
