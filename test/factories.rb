# test/test_helper.rb

require 'factory_girl'

Factory.define :language do |f|
  f.name "English"
  f.short "en"
end

Factory.define :user do |f|
  f.sequence(:id) {|n| "#{n}"}
  f.sequence(:username) {|n| "John #{n}"}
  f.sequence(:email) {|n| "john#{n}@email.com"}
end

Factory.define :orig do |f|
  f.sequence(:id) {|n| "#{n}"}
  f.sequence(:url) {|n| "http://www.web#{n}.com"}
  f.title "Original Blog"
  f.content "<p>Paragraph 1</p><p>Paragraph 2</p>"
  f.origin_id "1"
  f.association :user
end

Factory.define :post do |f|
  f.sequence(:id) {|n| "#{n}"}
  f.association :orig
  f.association :user
  f.ted_id "2"
end

