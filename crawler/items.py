from scrapy.item import Item, Field

class Car(Item):
    cid = Field()
    content = Field()
    cat = Field()

