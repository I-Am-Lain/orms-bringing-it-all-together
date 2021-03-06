class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
      DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        doggie = Dog.new(name: name, breed: breed)
        doggie.save
        doggie
    end

    def self.new_from_db(row)
        new_doggie = self.new(name: row[1], breed: row[2], id: row[0])  # self.new is the same as running doggie.new
        new_doggie
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

        doggie = DB[:conn].execute(sql, name, breed)
        if !doggie.empty?
            dog_data = doggie[0]
            doggie = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        else
            doggie = self.create(name: name, breed: breed)
        end
        doggie
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
