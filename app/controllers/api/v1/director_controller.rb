require 'net/http'
module Api
    module V1
        class DirectorController < ApplicationController
            include ActionController::HttpAuthentication::Token

            before_action :authenticate_user, only: [:create, :destroy]
            before_action :check_user_role, only: [:create, :destroy, :update]

            def index
                render json: Director.all
            end

            def create
                director = Director.new(director_params)

                if director.save
                    render json: director, status: :created
                else
                    render json: director.errors, status: :unprocessable_entity
                end
            end
            
            def destroy
                Director.find_by(params[:id]).destroy!

                head :no_content
            end
            
            def update 
                director = Director.find(params[:id])
                if director
                    director.update(director_params)
                    render json: director, status: :ok
                else
                    render json: director.errors, status: :unprocessable_entity
                end
            end

            private 

            def director_params
                params.require(:director).permit(:first_name, :last_name, :nationality, :age)
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