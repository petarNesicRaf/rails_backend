require 'net/http'
module Api
    module V1
        class AnimeController < ApplicationController
            include ActionController::HttpAuthentication::Token

            before_action :authenticate_user, only: [:create, :destroy]
            before_action :check_user_role, only: [:create, :destroy, :update]

            def index
                anime = Anime.includes(:author, :genre).all
                render json: anime.map(&:as_json_with_author_and_genre)
            end

            def unique_genres
                genres = Anime.select(:genre_id).distinct.pluck(:genre_id)
                render json: Genre.where(id: genres), only: [:id, :keyword]
            end

            def find
                anime = Anime.includes(:author, :genre).find_by(title: params[:title])
                render json: anime.as_json_with_author_and_genre, status: :ok
            end

            def create
                author = Author.find_by(first_name: params[:author][:first_name])
                genre = Genre.find_by(keyword: params[:genre][:keyword])

                #author = Author.find_by(first_name: params[:author][:first_name])

                if author && genre
                    anime = Anime.new(anime_params.merge(author_id: author.id, genre_id: genre.id))
                else
                    author = Author.create!(author_params)
                    genre = Genre.create!(genre_params)
                    anime = Anime.new(anime_params.merge(author_id: author.id, genre_id: genre.id))
                end

                if anime.save 
                    render json: anime, status: :created
                else
                    render json: anime.errors, status: :unprocessable_entity
                end
            end
            
            def destroy 
                Anime.find_by(params[:id]).destroy!

                head :no_content
            end
            
            def update
                anime = Anime.find(params[:id])
                author = Author.find_by(first_name: params[:author][:first_name])
                genre = Genre.find_by(keyword: params[:genre][:keyword])

                if author && genre
                    anime.update(anime_params.merge(author_id: author.id))
                    render json: anime, status: :ok
                elsif !author && !genre
                  author = Author.create!(author_params)
                  genre = Genre.create!(genre_params)

                  anime.update(anime_params.merge(author_id: author.id, genre_id: genre.id))
                  render json: anime, status: :ok
                else
                  render json: anime.errors, status: :unprocessable_entity
                end
            end

            private 
           
            def anime_params
                params.require(:anime).permit(:title, :author, :studio, :year, :chapters, :episodes, :seasons, :description)
            end

            def authenticate_user
                token, _options = token_and_options(request)
                #raise token.inspect
                decoded_data = AuthenticationTokenService.decode(token)
                username = decoded_data['username']
                role = decoded_data['role']
        
                User.find_by(username: username)

              rescue ActiveRecord::RecordNotFound, JWT::DecodeError
                render status: :unauthorized
        
            end
        
            def author_params
                params.require(:author).permit(:first_name, :last_name, :age)
            end

                    
            def check_user_role
                token, _options = token_and_options(request)
                #raise token.inspect
                decoded_data = AuthenticationTokenService.decode(token)
                role = decoded_data['role']
                p "roleeeee " + role
                if role != "admin"
                render json: {error: 'Unauthorized'}, status: :unauthorized
                end
            end

            def genre_params
                params.require(:genre).permit(:keyword)
            end

        
        end
    end
end