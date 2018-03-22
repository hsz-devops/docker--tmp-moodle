


.PHONY: all
all:
	exit

.PHONY: build-test-mdl34
build-test-mdl34:
	docker build \
			-t tmp-test--mdl34x:3xx \
		-f moodle34.docker .

.PHONY: run-test-mdl34
run-test-mdl34:
	#docker run --rm -it --entrypoint sh tmp-test--mdl34x:latest
	docker run --rm -it --entrypoint sh tmp-test--mdl34x:3xx
