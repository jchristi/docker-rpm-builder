.PHONY: srpm clean devenv

srpm: tmp 	
	[ -z "$(shell git status --porcelain)" ]
	git archive $(shell git rev-parse --abbrev-ref HEAD) -o tmp/docker-rpm-builder.tar.gz
	perl -p -i -e 's/\$$\{([^}]+)\}/defined $$ENV{$$1} ? $$ENV{$$1} : $$&/eg' < docker-rpm-builder.spectemplate > tmp/docker-rpm-builder.spec
	rpmbuild --define '_sourcedir ./tmp'  --define '_srcrpmdir ./tmp' -bs tmp/docker-rpm-builder.spec


tmp:
	mkdir -p tmp

clean:
	rm -rf tmp build dist 

distclean: clean
	rm -rf devenv

devenv:
	virtualenv-2.7 devenv
	devenv/bin/pip install --editable .
	devenv/bin/pip install wheel


pypirelease: devenv
ifndef BUILD_NUMBER
	@echo "Must pass BUILD_NUMBER for upload"
	@exit 1
endif
	devenv/bin/python setup.py egg_info --tag-build ${BUILD_NUMBER} bdist_wheel sdist register upload