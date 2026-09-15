# app/models/bike.rb
class Bike < ApplicationRecord
    belongs_to :customer

    has_many :repairs
end