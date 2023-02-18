build-docker:
	docker build -t mattwiley/shellspec -f docker/shellspec.Dockerfile .

clean:
	rm -rf report tmp 

local-test:
	.scripts/local_test_runner.sh

test:
	docker run -it --rm \
		-v "$(shell pwd):$(shell pwd)" \
		-w "$(shell pwd)" \
		--network host \
		mattwiley/shellspec bash -c ".scripts/test_runner.sh docker"