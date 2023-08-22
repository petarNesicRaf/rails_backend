require 'net/http'
module Api
  module V1
    class MoviesController < ApplicationController
      include ActionController::HttpAuthentication::Token

      before_action :authenticate_user, only: [:create, :destroy]
      before_action :check_user_role, only: [:create, :destroy, :update]

      def index
        movies = Movie.includes(:director, :genre).all
        render json: movies.map(&:as_json_with_director_and_genre)
      end

      def find
        movie = Movie.includes(:director, :genre).find_by(title: params[:title])
        render json: movie.as_json_with_director_and_genre, status: :ok
      end

      def create
        director = Director.find_by(first_name: params[:director][:first_name])
        genre = Genre.find_by(keyword: params[:genre][:keyword])

        if director && genre
            movie = Movie.new(movie_params.merge(director_id: director.id, genre_id: genre.id))
        else
            director = Director.create!(director_params)
            genre = Genre.create!(genre_params)

            movie = Movie.new(movie_params.merge(director_id: director.id, genre_id: genre.id))
        end

        if movie.save 
            render json: movie, status: :created
        else
            render json: movie.errors, status: :unprocessable_entity
        end
      end
    

      def destroy
        Movie.find(params[:id]).destroy!

        head :no_content
      end

      def update
        movie = Movie.find(params[:id])
        director = Director.find_by(first_name: params[:director][:first_name])
        genre = Genre.find_by(keyword: params[:genre][:keyword])

        if director && genre
          movie.update(movie_params.merge(director_id: director.id, genre_id: genre.id))
          render json: movie, status: :ok
        elsif !director && !genre
          director = Director.create!(director_params)
          genre = Genre.create!(genre_params)
          movie.update(movie_params.merge(director_id: director.id, genre_id: genre.id))
          render json: movie, status: :ok
        else
          render json: movie.errors, status: :unprocessable_entity
        end
      end
      

      def unique_genres
        genres = Movie.select(:genre_id).distinct.pluck(:genre_id)
        render json: Genre.where(id: genres), only: [:id, :keyword]
      end

      private 
      def json_param
       return "include:{director: {only: [:first_name, :last_name]},genre: {only: [:keyword]}}"
      end

      def movie_params
        params.require(:movie).permit(:title,:year, :description)
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
