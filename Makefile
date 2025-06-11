VERSION = 5.24.1

print_version:
	@echo $(VERSION)

clean:
	rm -rf public .query_enabled v*.tar.gz

build: enable_query_config

deploy: build
	firebase deploy --only hosting

v$(VERSION).tar.gz:
	@echo -e '\n##############################################'
	@echo -e '### Fetching swagger-ui release $(VERSION) ###'
	@echo -e '##############################################\n'
	wget https://github.com/swagger-api/swagger-ui/archive/refs/tags/v$(VERSION).tar.gz

public: v$(VERSION).tar.gz
	@echo -e '\n############################################'
	@echo -e '### Extracting swagger-ui dist to public ###'
	@echo -e '############################################\n'
	tar -xf v$(VERSION).tar.gz swagger-ui-$(VERSION)/dist --strip-components 1 && mv dist public

enable_query_config: .query_enabled

.query_enabled: public
	@if grep -qF '    queryConfigEnabled: true' public/swagger-initializer.js; then \
		echo -e '\n#######################################################################'; \
		echo -e '### queryConfigEnabled already set in public/swagger-initializer.js ###'; \
		echo -e '#######################################################################\n'; \
		echo 'touch .query_enabled'; \
		touch .query_enabled; \
	else \
		echo -e '\n###################################################################'; \
		echo -e '### Setting queryConfigEnabled in public/swagger-initializer.js ###'; \
		echo -e '###################################################################\n'; \
		echo "sed -i -E 's/  window\.ui = SwaggerUIBundle\(\{/  window.ui = SwaggerUIBundle({\n    queryConfigEnabled: true,/' public/swagger-initializer.js && touch .query_enabled"; \
		sed -i -E 's/  window\.ui = SwaggerUIBundle\(\{/  window.ui = SwaggerUIBundle({\n    queryConfigEnabled: true,/' public/swagger-initializer.js && touch .query_enabled; \
	fi

