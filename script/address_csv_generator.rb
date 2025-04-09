#!/usr/bin/env ruby

require "faker"

puts "Street Address,Secondary Address,City,State,Zip code"

10.times do
  puts "#{Faker::Address.street_address},#{rand(2) == 0 ? nil : Faker::Address.secondary_address},#{Faker::Address.city},#{Faker::Address.state_abbr},#{Faker::Address.zip_code}"
end
