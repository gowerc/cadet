# -*- coding: utf-8 -*-
import scrapy
import pymongo
from crawler.items import Car

class carData(scrapy.Spider):

    name = 'cardata'
    allowed_domains = ['autotrader.co.uk']

    def start_requests(self):
        URL_INITIAL = "https://www.autotrader.co.uk/json/fpa/initial/{}"
        URL_LAZY = "https://www.autotrader.co.uk/json/fpa/lazy/{}"
        
        MONGODB_URI = "mongodb://root:example@mongo:27017"
        MONGODB_DATABASE = "cars"
        MONGODB_COLLECTION = "all_cars"
        
        client = pymongo.MongoClient(MONGODB_URI)
        db = client[MONGODB_DATABASE]
        col = db[MONGODB_COLLECTION]
        
        initial = [ 
            {"cat" : "initial", "cid": x["cid"]} 
            for x in col.find({"initial" : None}, {"cid"})
        ]
        
        lazy = [ 
            {"cat" : "lazy", "cid": x["cid"]} 
            for x in col.find({"lazy" : None}, {"cid"})
        ]
        
        client.close()
        
        cars = initial + lazy

        for car in cars:
            if car["cat"] == "lazy":
                URL = URL_LAZY.format(car["cid"])
            
            if car["cat"] == "initial":
                URL = URL_INITIAL.format(car["cid"])
            
            yield scrapy.Request( 
                URL , 
                callback=self.parse_for_content, 
                meta = car 
            )
        
        
    def parse_for_content(self, response):
        
        itm = Car(
            cid = response.meta["cid"],
            cat = response.meta["cat"],
            content = response.json()
        )
        yield itm
