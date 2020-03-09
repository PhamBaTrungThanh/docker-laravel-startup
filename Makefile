OS:=$(shell uname)

init:
	docker-compose up --build app

start:
	docker-compose up -d 