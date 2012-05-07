# fake company generator
# usage: `ruby fake_company.rb > company.tsv`

require 'rubygems'
require 'faker' #might need to run `gem install faker` for this

2000.times {
  puts "#{Faker::Company.name}\t#{Faker::Company.catch_phrase}\t#{Faker::Company.catch_phrase}"
}
