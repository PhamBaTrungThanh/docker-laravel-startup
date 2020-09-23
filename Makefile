OS:=$(shell uname)
USER_ID:=$(shell id -u)
GROUP_ID:=$(shell id -g)

test:
	echo "${USER_ID}"
build:
	docker-compose build --build-arg USER_ID=${USER_ID} --build-arg GROUP_ID=${GROUP_ID} app
start:
	docker-compose up -d 