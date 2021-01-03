# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html

# import re
# import json
# 
# class WebcrawlPipeline(object):
# 
# 
#     def open_spider(self, spider):
#         self.file = open('./data/items.jl', 'w')
# 
#     def close_spider(self, spider):
#         self.file.close()
# 
#     def process_item(self, item, spider):
#         line = json.dumps(dict(item)) + "\n"
#         self.file.write(line)
#         return item

import pymongo

MONGODB_URI = "mongodb://root:example@mongo:27017"
MONGODB_DATABASE = "cars"
MONGODB_COLLECTION = "all_cars"

class MongoPipeline(object):

    def open_spider(self, spider):
        self.client = pymongo.MongoClient(MONGODB_URI)
        self.db = self.client[MONGODB_DATABASE]
        self.col = self.db[MONGODB_COLLECTION]

    def close_spider(self, spider):
        self.client.close()

    def process_item(self, item, spider):
        
        if item["cat"] == "listing":
            self.col.replace_one(
                {"cid": item["cid"]},
                item["content"],
                upsert=True
            )
            
        if item["cat"] == "initial":
            self.col.update_one(
                {"cid": item["cid"]}, 
                {"$set": {"initial": item["content"]}}
            )
        
        if item["cat"] == "lazy":
            self.col.update_one(
                {"cid": item["cid"]}, 
                {"$set": {"lazy": item["content"]}}
            )
        
        return item




