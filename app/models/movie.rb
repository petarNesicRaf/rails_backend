class Movie < ApplicationRecord
    belongs_to :director
    belongs_to :genre
    has_many :reviews, dependent: :destroy

    validates_presence_of :title, :year
    validates_uniqueness_of :title
    validates_numericality_of :year, greater_than: 0, only_integer: true

    def as_json_with_director_and_genre
    
        {
          id: id,
          title: title,
          year: year,
          description: description,
          director_id: director_id,
          genre_id: genre_id,
          director: {
            name: director.first_name + " " + director.last_name,
          },
          genre: {
            keyword: genre.keyword
          },
        }
      end
end
