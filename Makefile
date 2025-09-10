VERSION = 5.29.0

TGZ_URL = https://github.com/swagger-api/swagger-ui/archive/refs/tags/v$(VERSION).tar.gz
TMPDIR = /tmp/swagger-ui
BUILDDIR = $(TMPDIR)/v$(VERSION)
TGZ_PATH = $(TMPDIR)/v$(VERSION).tar.gz

print_version:
	@echo $(VERSION)

clean:
	rm -rf $(BUILDDIR) $(TGZ_PATH) public

build: public

public: $(BUILDDIR)/.built $(BUILDDIR)/.query_enabled
	$(call PRINT_HEADER,Copying $(BUILDDIR)/dist to public)
	cp -r $(BUILDDIR)/dist public

deploy: build
	firebase deploy --only hosting

$(TGZ_PATH):
	mkdir -p $(TMPDIR)
	$(call PRINT_HEADER,Fetching swagger-ui release $(VERSION))
	wget -O $(TGZ_PATH) $(TGZ_URL)

# target is a stamp file
# Build is at $(BUILDDIR)
$(BUILDDIR)/.built: $(TGZ_PATH)
	$(call PRINT_HEADER,Unpacking and rebuilding swagger-ui release $(VERSION))
	rm -rf $(BUILDDIR)
	mkdir $(BUILDDIR)
	tar -xf $(TGZ_PATH) -C $(BUILDDIR) --strip-components 1
	cd $(BUILDDIR) && npm ci && npm run build
	touch $(BUILDDIR)/.built

$(BUILDDIR)/.query_enabled: $(BUILDDIR)/.built
	$(eval SIJS := $(BUILDDIR)/dist/swagger-initializer.js)
	$(eval ENABLED := $(shell grep -qF '    queryConfigEnabled: true' $(SIJS) && echo 1 || echo 0))
	echo 'XXXXXXX $(ENABLED) $(SIJS)'
ifeq ($(ENABLED), 1)
		$(call PRINT_HEADER,queryConfigEnabled already set in $(SIJS))
else 
		$(call PRINT_HEADER,Setting queryConfigEnabled in $(SIJS))
		sed -i -E 's/  window\.ui = SwaggerUIBundle\(\{/  window.ui = SwaggerUIBundle({\n    queryConfigEnabled: true,/' $(SIJS)
endif
	touch $(BUILDDIR)/.query_enabled

define PRINT_HEADER
	$(eval LEN := $(shell printf '%s' '$(1)' | wc -c))
	$(eval BARLEN := $(shell expr $(LEN) + 8))
	$(eval BAR := $(shell printf '%0.s\#' $$(seq 1 $(BARLEN))))
	@echo -e '\n$(BAR)'
	@echo -e '### $(1) ###'
	@echo -e '$(BAR)\n'
endef

