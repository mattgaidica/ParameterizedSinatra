require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'json'

set :database, 'postgres://matt@localhost/parameterize_sinatra'

class Book < ActiveRecord::Base
  belongs_to :course
end

class Course < ActiveRecord::Base
  has_many :books
  belongs_to :teacher
end

class Teacher < ActiveRecord::Base
  has_many :courses
end

get '/' do
  "Hello!"
end

#find a course's teacher
get '/course/:id/teacher' do
  result1 = Teacher.find_by_sql(["SELECT teachers.* FROM teachers INNER JOIN courses ON courses.teacher_id = teachers.id WHERE courses.id = ?", params[:id]]).first
  result2 = Course.find(:first, params[:id]).teacher

  same = result1 == result2 ? true : false
  hash = {:result1 => result1, 
          :result2 => result2,
          :same? => same
          }.to_json

end

#find a teachers books
get '/teacher/:id/books' do
  result1 = Book.find_by_sql(["SELECT books.isbn, courses.title FROM books INNER JOIN courses ON courses.id = books.course_id INNER JOIN teachers ON teachers.id = courses.teacher_id WHERE teachers.id = ?", params[:id]])
  result2 = Book.select("books.isbn, courses.title").joins(:course => :teacher).where(:teachers => {:id => params[:id]})

  same = result1 == result2 ? true : false
  hash = {:result1 => result1, 
          :result2 => result2,
          :same? => same
          }.to_json

end

#query a book's column and value
get '/book/:column/:value' do
  col = '"' + ActiveRecord::Base.sanitize(params[:column]).chop.reverse.chop.reverse + '"'
  result1 = Book.find_by_sql(["SELECT * FROM books WHERE #{col} = ?", params[:value]])
  result2 = Book.where(params[:column] => params[:value])

  same = result1 == result2 ? true : false
  hash = {:result1 => result1, 
          :result2 => result2,
          :same? => same
          }.to_json

end

get '/make' do
  teacher = Teacher.create(:name => "Alberto Yeinstein")
  course = Course.create(:title => "General Relativity", :term => "Summer", :teacher_id => teacher.id)
  Book.create(:title => "Relativity:The Special and General Theory", :isbn => "1456548522", :course_id => course.id)
  Book.create(:title => "Spacetime and Geometry: An Introduction to General Relativity", :isbn => "0805387323", :course_id => course.id)
  Book.create(:title => "The Mathematics of Relativity for the Rest of Us", :isbn => "155212567X", :course_id => course.id)
  "Success!"
end
