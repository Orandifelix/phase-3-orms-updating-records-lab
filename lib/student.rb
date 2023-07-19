require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize (id =nil, name, grade)
    @id = id 
    @name  = name 
    @grade = grade
  end

  def self.create_table
  sql = <<-SQL
    CREATE TABLE students (
      id INT PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
  SQL
  DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  # def save
  #   sql = <<-SQL
  #   INSERT INTO students (name, grade) 
  #   VALUES (?,?)
  #   SQL
  #   DB[:conn].execute(sql, self.name, self.grade)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  # end

    def save
    if persisted?
      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  private

  def persisted?
    !@id.nil?
  end

    def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id, name, grade = row 
    student = self.new(name, grade)
    student.instance_variable_set(:@id, id)
    student
  end

  def self.find_by_name(name) 
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    results = DB[:conn].execute(sql, name)[0]
    self.new_from_db(results) unless results.nil?
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  public :update

end
