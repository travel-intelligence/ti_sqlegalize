# encoding: utf-8

Mime::Type.register 'application/vnd.api+json', :jsonapi unless Mime[:jsonapi]
