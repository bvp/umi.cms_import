#!/usr/bin/env ruby
# coding: utf-8

require 'mechanize'
require 'yaml'

CONF = YAML.load_file("#{File.dirname(__FILE__)}/catalog_import.yml") unless defined? CONF

$complete = $updated = $created = $deleted = $errors = $logs_count = 0

def time_diff(start_time, end_time)
  seconds_diff = (start_time - end_time).to_i.abs

  hours = seconds_diff / 3600
  seconds_diff -= hours * 3600

  minutes = seconds_diff / 60
  seconds_diff -= minutes * 60

  seconds = seconds_diff

  "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
end

start_time = Time.now
puts "============ The task is started at " + start_time.strftime("%d.%m.%Y %H:%M") + " ============"
agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'

page = agent.get(CONF[:login_url])
login_form = page.forms[0]
login_form['from_page'] = '/admin/content/sitetree/'
login_form['login'] = CONF[:admin_login]
login_form['password'] = CONF[:admin_password]
login_form['ilang'] = 0
page = agent.submit login_form

while($complete == 0)
  import_data = agent.get(CONF[:exchange_import_url])
  p = import_data.body.force_encoding("UTF-8")

  doc = Nokogiri::XML(p)
  $complete += doc.at_xpath("/result/data/@complete").value.to_i
  $updated += doc.at_xpath("/result/data/@updated").value.to_i
  $created += doc.at_xpath("/result/data/@created").value.to_i
  $deleted += doc.at_xpath("/result/data/@deleted").value.to_i
  $errors += doc.at_xpath("/result/data/@errors").value.to_i

#  root = doc.root
#  logs = root.xpath("/result/data/log")
#  $logs_count += logs.count
#  print("\rProcessed #$logs_count records")
end

end_time = Time.now

#puts ""
puts "Updated - #$updated"
puts "Created - #$created"
puts "Deleted - #$deleted"
puts "Errors - #$errors"
puts "===== The task is completed in " + time_diff(start_time, end_time) + " at " + end_time.strftime("%d.%m.%Y %H:%M") + " ====="
