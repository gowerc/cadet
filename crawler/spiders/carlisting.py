# -*- coding: utf-8 -*-
import scrapy
import random
import math
from crawler.items import Car

class carListing(scrapy.Spider):

    name = 'carlisting'
    allowed_domains = ['autotrader.co.uk']

    def start_requests(self):
        self.logger.debug("Entered 'start_requests'")
        ## set constants
        self.SELF_PAGE_LIMIT = 70   # max = 100
        self.PAGE_LIMIT = 100
        self.CARS_PER_PAGE = 12
        self.URL_TEMPLATE = "https://www.autotrader.co.uk/car-search?make={}&model={}&postcode=AL71GA&sort=distance&page={}"
        self.cars = [
            ["VAUXHALL", "CORSA"],
            ["VAUXHALL", "ASTRA"],
            ["FORD", "FOCUS"],
            ["FIAT", "500"],
            ["FORD", "FIESTA"],
            ["SEAT", "LEON"],
            ["HONDA", "CIVIC"],
            ["TOYOTA", "YARIS"],
            ["VOLKSWAGEN", "GOLF"],
            ["PEUGEOT", "308"],
            ["AUDI", "A3"],
            ["BMW",  "1 SERIES"],
            ["RENAULT", "CLIO"],
            ["MAZDA" , "MAZDA3"],
            ["TOYOTA", "COROLLA"],
            ["ALFA", "ROMEO"],
            ["BMW", "1 SERIES"],
            ["SKODA", "OCTAVIA"],
            ["SKODA", "SCALA"]
        ]
        
        for car in self.cars:
            url =  self.URL_TEMPLATE.format(car[0], car[1], 1)
            self.logger.debug( "Starting request url = {}".format(url))
            yield scrapy.Request(
                url=url, 
                callback=self.parse_for_pages, 
                meta={"make":car[0], "model":car[1]} 
            )

    def parse_for_pages(self, response):
        #self.logger.info("\n\n\nTEST\n\n\n")
        for url in self.extract_page_urls(response):
            yield scrapy.Request(
                url,
                callback=self.parse_for_cid,
                meta=response.meta,
                dont_filter=True 
            )
        
    def parse_for_cid(self, response):
        cids = self.extract_car_ids(response)
        for cid in cids:
            itm = Car(
                cid = cid,
                cat = "listing",
                content = {
                    "cid" : cid,
                    "make" : response.meta["make"],
                    "model" : response.meta["model"],
                    "initial" : None,
                    "lazy" : None
                }
            )
            yield itm
            
            
    def extract_car_ids(self, response):
        ## Get the id value from all "li" elements that have a child called "article" whose class does not contain "new-car-listing"
        car_ids = response.xpath("//li[child::article[not(contains(@class, 'new-car-listing'))]]/@id").getall()
        return car_ids
        
    def extract_page_urls(self, response): 
        
        ### Extract total number of available cars from first page
        total_number_of_cars_chr = response.css(".search-form__count::text").extract_first()
        total_number_of_cars_chr = total_number_of_cars_chr.replace("cars found", "")
        total_number_of_cars_chr = total_number_of_cars_chr.replace(",", "")
        total_number_of_cars = int(total_number_of_cars_chr)
        
        ### Calculate total number of available pages (12 cars per page)
        max_page_num = math.ceil(total_number_of_cars / self.CARS_PER_PAGE)
        
        ### Restrict to a maximium of 100 pages (they wont allow you to see past page 100)
        max_page_num = min(self.PAGE_LIMIT, max_page_num)
       
        ### Apply self restriction if required 
        max_page_num = min(self.SELF_PAGE_LIMIT, max_page_num)
            
        ### Derive page urls
        page_urls= [ 
            self.URL_TEMPLATE.format(response.meta["make"], response.meta["model"], i)
            for i in range(1, max_page_num + 1)
        ]
        
        ### Return webpages
        return page_urls 









