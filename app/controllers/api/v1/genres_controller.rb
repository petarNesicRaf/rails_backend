require 'net/http'
module Api
    module V1
        class GenresController < ApplicationController
            include ActionController::HttpAuthentication::Token

            before_action :authenticate_user, only: [:create, :destroy]
            before_action :check_user_role, only: [:create, :destroy, :update]
            def index
                render json: Genre.all
            end
        
            def create
                genre = Genre.new(genre_params)

                if genre.save
                    render json: genre, status: :created
                else
                    render json: genre.errors, status: :unprocessable_entity
                end
            end

            def destroy!
                Movie.find(params[:id]).destroy!

                head :no_content
            end

            def update 
                genre = Genre.find(params[:id])
                if genre
                    genre.update(genre_params)
                    render json: genre, status: :ok
                else
                    render json: genre.errors, status: :unprocessable_entity
                end
            end
            
            private 
            def genre_params
                params.require(:genre).permit(:keyword)
            end
            
            def authenticate_user
                #Authorization: Bearer <token>
                token, _options = token_and_options(request)
                #raise token.inspect
                username = AuthenticationTokenService.decode(token)
                User.find_by(username: username)
        
              rescue ActiveRecord::RecordNotFound, JWT::DecodeError
                render status: :unauthorized
            end
            def check_user_role
                token, _options = token_and_options(request)
                #raise token.inspect
                decoded_data = AuthenticationTokenService.decode(token)
                role = decoded_data['user']
                if role != "user"
                  render json: {error: 'Unauthorized'}, status: :unauthorized
                end
            end
        end 
    end
end

