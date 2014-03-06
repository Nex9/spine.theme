#!/usr/bin/env python

import os, re, logging

from base import decorators
from base.handlers import BaseHandler, StaticFileHandler
from base.models import CacheFlushCounter

# custom app imports
from imageapp import models


from appengine_config import DEBUG



class Main(BaseHandler):

    def pagelinks(self, next=None, prev=None):
        if not next and not prev:
            return None, None
        rgx = re.search(r'/page/(\d+)', self.path)
        num = int(rgx.group(1)) if rgx else 1
        if num == 1 and not rgx:
            nextlink = self.path.rstrip('/') + '/page/2'
        else:
            nextlink = self.path.replace(rgx.group(), '/page/%s'%(num+1)) if next else None
        prevlink = self.path.replace(rgx.group(), '/page/%s'%(num-1)) if prev else None
        return nextlink, prevlink

    def get_assets(self, *args, **kwargs):
        return models.Collection.get_assets(*args, **kwargs)


    def pagenum(self, pagenum, page):
        if self.imago.get(page, 'pagesize', 0):
            return 1 if not pagenum else int(pagenum)
        return None


    @decorators.normalize_url
    @decorators.cache_page(with_keywords=True)
    def get(self, path, pagenum=None):
        if not path: path = '/'
        assetlookup = models.AssetLookup.by_path(path)
        if assetlookup is None:
            return self.status(404, 'Collection Not Found')

        page    = assetlookup.assetkey.get()

        self.render('index.html', page=page, pagenum=self.pagenum(pagenum, page))



settings = {
    "template_path": os.path.join(os.path.dirname(__file__), "public"),
    "static_path": os.path.join(os.path.dirname(__file__), "public"),
    "xsrf_cookies": True,
    "debug": DEBUG,
    "cacheflushcounter" : CacheFlushCounter.get_count()
}

routes = [
    (r"/(.*\.\w{2,4}$)/?", StaticFileHandler),
    (r"/(.*)/page/([0-9]+)/?", Main),
    (r"/(.*)/?", Main)

]
