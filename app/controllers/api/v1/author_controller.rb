module Api
    module V1
        class AuthorController < ApplicationController
            before_action :authenticate_user, only: [:create, :destroy]

            def index
                render json: Author.all
            end

            def create
                author = Author.new(author_params)

                if author.save
                    render json: author, status: :created
                else
                    render json: author.errors, status: :unprocessable_entity
                end
            end
            
            def destroy
                Author.find_by(params[:id]).destroy!

                head :no_content
            end
            
            def update 
                author = Author.find(params[:id])
                if author
                    author.update(author_params)
                    render json: author, status: :ok
                else
                    render json: author.errors, status: :unprocessable_entity
                end
            end

            private 

            def author_params
                params.require(:author).permit(:first_name, :last_name, :age)
            end

            def authenticate_user
                #Authorization: Bearer <token>
                token, _options = token_and_options(request)
                #raise token.inspect
                user_id = AuthenticationTokenService.decode(token)
                User.find(user_id)
              
              rescue ActiveRecord::RecordNotFound, JWT::DecodeError
                render status: :unauthorized
        
              end
        
        end
    end
end