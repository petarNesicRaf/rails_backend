class Book < ApplicationRecord
    belongs_to :author
    belongs_to :genre


    def as_json_with_author_and_genre
        {
          id: id,
          title: title,
          year: year,
          description: description,
          author_id: author_id,
          genre_id: genre_id,
          pages: pages,
          author: {
            name: author.first_name + " " + author.last_name,
          },
          genre: {
            keyword: genre.keyword
          }
        }
      end

end
