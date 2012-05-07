# fake company generator
# usage: `ruby fake_people.rb > people.tsv`

require 'rubygems'
require 'faker' #might need to run `gem install faker` for this

2000.times {
  puts "#{Faker::Name.first_name}\t#{Faker::Name.last_name}\t#{Faker::Internet.email}"
}
