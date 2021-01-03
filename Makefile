


.PHONY: all up down python r autoscrape pybash build


python:
	docker-compose run py python
	
pybash:
	docker-compose run py bash
	
autoscrape:
	docker-compose run py scrapy crawl autotrader
	
	
	
##################
##
##  Docker specific commands
##
##################

up:
	docker-compose up -d 
	
down:
	docker-compose down

build:
	docker-compose build 
	
restart:
	docker-compose down 
	docker-compose build  
	docker-compose up -d 
	
