class Anime < ApplicationRecord
    belongs_to :author
    belongs_to :genre
    has_many :reviews, dependent: :destroy

    validates_presence_of :title, :author, :year
    validates_uniqueness_of :title
    validates_numericality_of :year, :chapters, :seasons, :episodes, greater_than: 0, only_integer: true


    def as_json_with_author_and_genre
        {
          id: id,
          title: title,
          year: year,
          studio: studio,
          chapters: chapters,
          episodes: episodes,
          seasons: seasons,
          description: description,
          author_id: author_id,
          genre_id: genre_id,
          author: {
            name: author.first_name + " " + author.last_name,
         
          },
          genre: {
            keyword: genre.keyword
          }
        }
      end

end
