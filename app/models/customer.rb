# app/models/customer.rb
class Customer < ApplicationRecord
    has_many :bikes
end