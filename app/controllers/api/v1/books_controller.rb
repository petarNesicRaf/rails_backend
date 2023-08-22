require_relative '../../../representers/books_representer'
require 'net/http'
module Api
  module V1
    class BooksController < ApplicationController
      include ActionController::HttpAuthentication::Token

      before_action :authenticate_user, only: [:create, :destroy]
      before_action :check_user_role, only: [:create, :destroy, :update]
      
      def index
        book = Book.includes(:author, :genre).all
        render json: book.map(&:as_json_with_author_and_genre)
      end


      def find
        book = Book.includes(:author, :genre).find_by(title: params[:title])
        render json: book.as_json_with_author_and_genre, status: :ok
      end

      def create
        author = Author.find_by(first_name: params[:author][:first_name])
        genre = Genre.find_by(keyword: params[:genre][:keyword])

        #author = Author.find_by(first_name: params[:author][:first_name])

        if author && genre
            book = Book.new(book_params.merge(author_id: author.id, genre_id: genre.id))
        else
            author = Author.create!(author_params)
            genre = Genre.create!(genre_params)
            book = Book.new(book_params.merge(author_id: author.id, genre_id: genre.id))
        end

        if book.save 
            render json: book, status: :created
        else
            render json: book.errors, status: :unprocessable_entity
        end
     end
    
      def destroy
        Book.find(params[:id]).destroy!
        head :no_content
      end

      def unique_genres
        genres = Book.select(:genre_id).distinct.pluck(:genre_id)
        render json: Genre.where(id: genres), only: [:id, :keyword]
      end

      def update
        book = Book.find(params[:id])
        author = Author.find_by(first_name: params[:author][:first_name])
        genre = Genre.find_by(keyword: params[:genre][:keyword])

        if author && genre
            book.update(book_params.merge(author_id: author.id))
            render json: book, status: :ok
        elsif !author && !genre
          author = Author.create!(author_params)
          genre = Genre.create!(genre_params)

          book.update(book_params.merge(author_id: author.id, genre_id: genre.id))
          render json: book, status: :ok
        else
          render json: book.errors, status: :unprocessable_entity
        end
    end
    
      private 

      def author_params
        params.require(:author).permit(:first_name, :last_name, :age)
      end

      def book_params
        params.require(:book).permit(:title, :description, :pages, :year)
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

      def check_user_role
        token, _options = token_and_options(request)
        #raise token.inspect
        decoded_data = AuthenticationTokenService.decode(token)
        role = decoded_data['role']
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
