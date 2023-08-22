class Genre < ApplicationRecord
    has_many :movies
    has_many :series
    has_many :animes
    has_many :books

    validates_uniqueness_of :keyword
end
