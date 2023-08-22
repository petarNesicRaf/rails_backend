require 'rails_helper'

describe 'Books API', type: :request do
    let(:first_author){FactoryBot.create(:author, first_name: 'George', last_name: 'Orwell', age: 44)}
    let(:second_author){FactoryBot.create(:author, first_name: 'hgg', last_name: 'wells', age: 44)}

    describe 'GET /books'do

        before do 
            FactoryBot.create(:book, title: '1984', author: first_author)
            FactoryBot.create(:book, title: 'the time machine', author: second_author)
        end
        it 'returns all books' do       
         
            get '/api/v1/books'
            
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body).size).to eq(2) #proveri ako ima 2 objekta u odgovoru
        end
    end

    describe 'POST /books' do
        it 'creates a new book' do 
            expect{
                post '/api/v1/books', params: 
                {
                    book: {title:'martian', author:'andy'},
                    author: {first_name: 'Andy', last_name: 'Weir', age: '48'}
                }
            }.to change{Book.count}.from(0).to(1)

            expect(response).to have_http_status(:created)
            expect(Author.count).to eq(1)
            expect(JSON.parse(response.body)).to eq(
                {
                    "id"=> 1,
                    "title"=> "martian",
                    "author_name"=> "Andy Weir",
                    "author_age"=> 48
                }
            )
        end
    end

    describe 'DELETE /books/:id' do
        let!(:book) { FactoryBot.create(:book, title: '1984', author: first_author) }

        it 'delete a book' do
            expect{
                delete "/api/v1/books/#{book.id}"
            }.to change {Book.count}.from(1).to(0)
           
            expect(response).to have_http_status(:no_content)
        end
    end

    it 'returns a subset of books based on pagination' do 
        get '/api/v1/books', params: {limit: 1}
        expect(response).to have_http_status(:success)
        expect(response_body.size).to eq(1)
        expect(response_body).to eq(
            [
                {
                    "id"=> 1,
                    "title"=> "martian",
                    "author_name"=> "Andy Weir",
                    "author_age"=> 48
                },
            ]
        )
    end

end