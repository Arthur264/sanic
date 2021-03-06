.PHONY: help test test-coverage install docker-test black fix-import beautify

.DEFAULT: help

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "test"
	@echo "		Run Sanic Unit Tests"
	@echo "test-coverage"
	@echo "		Run Sanic Unit Tests with Coverage"
	@echo "install"
	@echo "		Install Sanic"
	@echo "docker-test"
	@echo "		Run Sanic Unit Tests using Docker"
	@echo "black"
	@echo " 	Analyze and fix linting issues using Black"
	@echo "fix-import"
	@echo "		Analyze and fix import order using isort"
	@echo "beautify [sort_imports=1] [include_tests=1]"
	@echo " 	Analyze and fix linting issue using black and optionally fix import sort using isort"
	@echo ""

clean:
	find . ! -path "./.eggs/*" -name "*.pyc" -exec rm {} \;
	find . ! -path "./.eggs/*" -name "*.pyo" -exec rm {} \;
	find . ! -path "./.eggs/*" -name ".coverage" -exec rm {} \;
	rm -rf build/* > /dev/null 2>&1
	rm -rf dist/* > /dev/null 2>&1

test: clean
	python setup.py test

test-coverage: clean
	python setup.py test --pytest-args="--cov sanic --cov-report term --cov-append "

install:
	python setup.py install

docker-test: clean
	docker build -t sanic/test-image -f docker/Dockerfile .
	docker run -t sanic/test-image tox

beautify: black
ifdef sort_imports
ifdef include_tests
	$(warning It is suggested that you do not run sort import on tests)
	isort -rc sanic tests
else
	$(info Sorting Imports)
	isort -rc sanic tests
endif
endif

black:
	black --config ./.black.toml sanic tests

fix-import: black
	isort -rc sanic tests
