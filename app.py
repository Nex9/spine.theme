#!/usr/bin/env python

import os, re, logging

from base import decorators
from base.handlers import BaseHandler, StaticFileHandler
from base.models import CacheFlushCounter

# custom app imports
from imageapp import models


from appengine_config import DEBUG



class Main(BaseHandler):
    @decorators.normalize_url
    @decorators.cache_page(with_keywords=True)
    def get(self, path):
        if not path: path = '/'
        assetlookup = models.AssetLookup.by_path(path)
        if assetlookup is None:
            return self.status(404, 'Collection Not Found')

        page = assetlookup.assetkey.get()
        self.render('online.html', page = page)



settings = {
    "template_path": os.path.join(os.path.dirname(__file__), "public"),
    "static_path": os.path.join(os.path.dirname(__file__), "public"),
    "xsrf_cookies": True,
    "debug": DEBUG,
    "cacheflushcounter" : CacheFlushCounter.get_count()
}

routes = [
    (r"/(.*\.\w{2,4}$)/?", StaticFileHandler),
    (r"/(.*)/?", Main)
]
