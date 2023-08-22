require 'net/http'
module Api
  module V1
    class ReviewsController < ApplicationController
        include ActionController::HttpAuthentication::Token

        before_action :authenticate_user, only: [:create, :destroy]
        before_action :check_user_role, only: [:create, :destroy, :update]

        def index 
            render json: Review.all
        end
        
        def find
            movie_id = params[:movie_id]
            reviews = Review.where(movie_id: movie_id)

            render json: reviews
        end

        def create
            movie = Movie.find_by(title: params[:movie_name])
            
            review = Review.new(review_params.merge(movie_id: movie.id))

            if review.save
                render json: review, status: :created
            else
                render json: review.errors, status: :unprocessable_entity
            end
        end

        def destroy
            Review.find_by(params[:id]).destroy!

            head :no_content
        end
        

        private 
        def review_params
            params.require(:review).permit(:review, :stars, :movie_name)
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
