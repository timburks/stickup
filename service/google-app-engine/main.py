#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


import sys

from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

from geo import geotypes
from geo.geomodel import GeoModel

import simplejson


class Account(db.Model):
  password = db.StringProperty()


class Stickup(GeoModel):
  message = db.StringProperty()
  account = db.ReferenceProperty(Account)
  created_on = db.DateTimeProperty(auto_now_add=True)


class SignupHandler(webapp.RequestHandler):
  def post(self):
    self.response.headers['Content-Type'] = 'text/plain'

    name = self.request.get('user')
    password = self.request.get('password')

    if name is not None:
      entity = Account.get_by_key_name(name)
      if entity is None:
        entity = Account(key_name=name, password=password)
        entity.put()
        self.response.out.write(simplejson.dumps({'status': 200, 'message': 'Successfully registered ' + name + '.'}))
      else:
        self.response.out.write(simplejson.dumps({'status': 403, 'message': 'This user already exists.'}))


class StickupHandler(webapp.RequestHandler):
  def post(self):
    self.response.headers['Content-Type'] = 'text/plain'

    name = self.request.get('user')
    password = self.request.get('password')
    latitude = self.request.get('latitude')
    longitude = self.request.get('longitude')
    message = self.request.get('message')

    user = Account.get_by_key_name(name)
    if user is not None:
      location = db.GeoPt(lat=float(latitude), lon=float(longitude))
      stickup = Stickup(location=location, message=message, account=user)
      stickup.update_location()
      stickup.put()
      self.response.out.write(simplejson.dumps({'status': 200, 'message': 'Thank you.'}))
    else:
      pass


class StickupsHandler(webapp.RequestHandler):
  def post(self):
    self.response.headers['Content-Type'] = 'text/plain'

    latitude = self.request.get('latitude')
    longitude = self.request.get('longitude')

    try:
      center = geotypes.Point(float(latitude),
                              float(longitude))
    except ValueError:
      self.response.out.write('latitude and longitude parameters must be valid latitude and longitude values.')

    try:
      base_query = Stickup.all()
      results = Stickup.proximity_fetch(base_query, center, max_results=100, max_distance=80000) #80 km

      json_results = []
      for result in results:
        json_results.append({
          'latitude': str(result.location.lat),
          'user': result.account.key().name(),
          'time': result.created_on.strftime('%Y-%m-%d %H:%M:%S +0000'), #2010-02-11 19:37:17 +0000
          'longitude': str(result.location.lon),
          'message': result.message,
        })
    except:
      self.response.out.write(str(sys.exc_info()[1]))

    self.response.out.write(simplejson.dumps({'status': 200, 'stickups': json_results}))


def main():
  application = webapp.WSGIApplication([('/signup', SignupHandler),
                                        ('/stickup', StickupHandler),
                                        ('/stickups', StickupsHandler)],
                                       debug=True)
  util.run_wsgi_app(application)


if __name__ == '__main__':
  main()
