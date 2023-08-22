class Director < ApplicationRecord
    has_many :movies
    has_many :series

    validates_uniqueness_of :first_name

end
