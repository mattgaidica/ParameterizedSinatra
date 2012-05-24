class CreateBooksCoursesTeachers < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string :title
      t.string :isbn
      t.integer :course_id
    end
    create_table :courses do |t|
      t.string :title
      t.string :term
      t.integer :teacher_id
    end
    create_table :teachers do |t|
      t.string :name
    end
  end

  def down
  end
end
