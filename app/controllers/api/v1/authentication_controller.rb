require_relative '../../../services/authentication_token_service'
require 'net/http'

module Api
    module V1
      class AuthenticationController < ApplicationController
        class AuthenticationError < StandardError; end
        include ActionController::HttpAuthentication::Token


        rescue_from ActionController::ParameterMissing, with: :parameter_missing
        rescue_from AuthenticationError, with: :handle_unauthenticated

        before_action :check_user_role, only: [:index,     :destroy, :update]

        def index
            render json: User.all
        end

        #ovo je login nije za kreiranje user-a
        def create
                raise AuthenticationError unless user.authenticate(params.require(:password))
                token = AuthenticationTokenService.call(user.username, user.role)

                render json: {token: token, role: user.role}, status: :created
        end

        def register
            user = User.new(user_params)

            if user.save
                token = AuthenticationTokenService.call(user.username, user.role)
                render json: {token: token, role: user.role}, status: :created
            else
                render json: user.errors, status: :unprocessable_entity
            end
        end

        def destroy
            User.find(params[:id]).destroy!
        end

        def update 
            user = User.find(params[:id])
            if user
                user.update(user_params)
                render json: user, status: :ok
            else
                render json: user.errors, status: :unprocessable_entity
            end
        end

        private 
        
        def user 
            ##
            @user ||= User.find_by(username: params.require(:username))
        end

        def parameter_missing(e)
            render json: {error: e.message}, status: :unprocessable_entity
        end

        def handle_unauthenticated
            head :unauthorized
        end

        def user_params
            params.require(:user).permit(:username, :password, :role)
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