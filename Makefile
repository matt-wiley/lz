test:
	docker run -it --rm -v "$(shell pwd):$(shell pwd)" -w "$(shell pwd)" --network host mattwiley/shellspec bash -c ".scripts/test_runner.sh docker"