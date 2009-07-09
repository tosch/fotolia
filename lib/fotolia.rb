require 'xmlrpc/client'

[
  'base',
  'category',
  'conceptual_category',
  'representative_category',
  'categories',
  'conceptual_categories',
  'representative_categories',
  'color',
  'colors',
  'country',
  'countries',
  'gallery',
  'galleries',
  'medium',
  'tag',
  'tags'
].each {|file| require File.join(File.dirname(__FILE__), 'fotolia', file)}