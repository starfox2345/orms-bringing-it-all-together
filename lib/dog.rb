class Dog
    attr_accessor :id, :name, :breed

    def initialize(options={})
        options.each do |key, value|
            self.send("#{key}=", value) if respond_to?("#{key}=")
        end
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(att)
        name = att[:name]
        breed = att[:breed]
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        # binding.pry
        dog = self.new(id: row[0],name: row[1],breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0] #.first works too
        dog = self.new(id: row[0],name: row[1], breed: row[2] ) # row[0] = id position
    end

    def self.find_or_create_by(row)
        # binding.pry
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", row[:name], row[:breed])
        if !dog.empty?
            doggo = dog[0]
            dog = Dog.new(id: doggo[0], name: doggo[1], breed: doggo[2])
        else
            dog = self.create(name: row[:name], breed: row[:breed])
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name).first
            self.new_from_db(row)
    end
end