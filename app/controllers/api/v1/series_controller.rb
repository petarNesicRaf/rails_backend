require 'net/http'
module Api
    module V1
        class SeriesController < ApplicationController
            include ActionController::HttpAuthentication::Token

            before_action :authenticate_user, only: [:create, :destroy]
            before_action :check_user_role, only: [:create, :destroy, :update ]

            def index
                series = Series.includes(:director, :genre).all
            
                render json: series.map(&:as_json_with_director_and_genre)
            end

            def find
                series = Series.includes(:director, :genre).find_by(title: params[:title])
                render json: series.as_json_with_director_and_genre, status: :ok
            end


            def create
                director = Director.find_by(first_name: params[:director][:first_name])
                genre = Genre.find_by(keyword: params[:genre][:keyword])

                if director && genre
                    series = Series.new(series_params.merge(director_id: director.id, genre_id: genre.id))
                else
                    director = Director.create!(director_params)
                    genre = Genre.create!(genre_params)

                    series = Series.new(series_params.merge(director_id: director.id, genre_id: genre.id))
                end

                if series.save 
                    render json: series, status: :created
                else
                    render json: series.errors, status: :unprocessable_entity
                end
            end
            
            def destroy
                Series.find_by(params[:id]).destroy!

                head :no_content
            end


            def update
                series = Series.find(params[:id])
                director = Director.find_by(first_name: params[:director][:first_name])
                genre = Genre.find_by(keyword: params[:genre][:keyword])
        
                if director && genre
                  series.update(series_params.merge(director_id: director.id, genre_id: genre.id))
                  render json: series, status: :ok
                elsif !director && !genre
                  director = Director.create!(director_params)
                  genre = Genre.create!(genre_params)
                  series.update(series_params.merge(director_id: director.id, genre_id: genre.id))
                  render json: series, status: :ok
                else
                  render json: series.errors, status: :unprocessable_entity
                end
              end

              def unique_genres
                genres = Series.select(:genre_id).distinct.pluck(:genre_id)
                render json: Genre.where(id: genres), only: [:id, :keyword]
              end
            private 

            def series_params
                params.require(:series).permit(:title, :year, :episodes, :seasons)
            end

            def authenticate_user
                #Authorization: Bearer <token>
                token, _options = token_and_options(request)
                #raise token.inspect
                decoded_data = AuthenticationTokenService.decode(token)
                username = decoded_data['username']
                role = decoded_data['role']
        
                User.find_by(username: username)
        
              rescue ActiveRecord::RecordNotFound, JWT::DecodeError
                render status: :unauthorized
            end

            def director_params
                params.require(:director).permit(:first_name, :last_name, :nationality, :age)
            end


            def genre_params
                params.require(:genre).permit(:keyword)
            end


            def director_name_param
                params.require(:director).permit(:first_name)
            end

            def check_user_role
                token, _options = token_and_options(request)
                #raise token.inspect
                decoded_data = AuthenticationTokenService.decode(token)
                role = decoded_data['role']
                if role != "admin"
                  render json: {error: 'Unauthorized'}, status: :unauthorized
                end
            end
        end
    end
end