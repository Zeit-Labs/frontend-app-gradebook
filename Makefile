intl_imports = ./node_modules/.bin/intl-imports.js

npm-install-%: ## install specified % npm package
	npm install $* --save-dev
	git add package.json

NPM_TESTS=build i18n_extract lint test is-es5

.PHONY: test
test: $(addprefix test.npm.,$(NPM_TESTS))  ## validate ci suite

.PHONY: test.npm.*
test.npm.%: validate-no-uncommitted-package-lock-changes
	test -d node_modules || $(MAKE) requirements
	npm run $(*)

.PHONY: requirements
requirements:  ## install ci requirements
	npm ci

i18n.extract:
	# Pulling display strings from .jsx files into .json files...	
	npm run-script i18n_extract


extract_translations: | requirements i18n.extract i18n.concat

# Pulls translations
pull_translations:
	rm -rf src/i18n/messages
	mkdir src/i18n/messages
	cd src/i18n/messages \
      && atlas pull \
               translations/paragon/src/i18n/messages:paragon \
               translations/frontend-component-header/src/i18n/messages:frontend-component-header \
               translations/frontend-component-footer/src/i18n/messages:frontend-component-footer \
               translations/frontend-app-learning/src/i18n/messages:frontend-app-learning
	$(intl_imports) paragon frontend-component-header frontend-component-footer frontend-app-learning

# This target is used by CI.
validate-no-uncommitted-package-lock-changes:
	# Checking for package-lock.json changes...
	git diff --exit-code package-lock.json
