#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.0.0-p353
ruby /usr/local/bin/catalog_import.rb > /var/www/catalog_import.txt