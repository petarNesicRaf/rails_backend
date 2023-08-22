
describe 'Authentication', type: :request do
    describe 'POST /authenticate' do
        it 'authenticates the client' do
            post 'api/v1/authenticate', params: {username: 'bookseller00', password: 'Password1'}
        end
    end
end