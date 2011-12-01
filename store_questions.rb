require 'mongo'

def connect_to_db!
  @conn = Mongo::Connection.new("localhost")
end

def create_db_and_collection!(database_name, collection_name)
  @db = @conn.db(database_name)
  @coll = @db.collection(collection_name)
end

def form_qa_array!(file)
  myfile = File.open(file)
  
  @qa_array = []
  question = ""

  myfile.each do |line|
    if line[0].to_i != 0
      question_with_numbers = line.chomp.to_s
      #get rid of the question number
      begin
        number_and_spaces = question_with_numbers.match /^[\d]*\.[\s]*/
      rescue
        next
      end
      if number_and_spaces
        question = question_with_numbers[(0 + number_and_spaces.to_s.length)..-1]
      end
    end
    if line.include? "ANS"
      begin
        answer_with_prefix = line.chomp.to_s
        semicolon_location = answer_with_prefix.index(":")
        answer = answer_with_prefix[(semicolon_location + 1)..-1].to_s.strip!
      rescue
        next
      end
      @qa_array << [question, answer]
    end
  end
end

def add_questions_to_database!
  @qa_array.each do |qa_pair|
    begin
      doc = {"question" => "#{qa_pair[0]}", "answer" => "#{qa_pair[1]}", "num" => "#{@question_count}"}
      @coll.insert(doc)
      @question_count += 1
    rescue
      next
    end
  end
end

connect_to_db!
@question_count = 0
(1..16).each do |num|
  create_db_and_collection!("questions", "batch_0")
  form_qa_array!("data/packets/abt2006-solor#{num}.txt")
  add_questions_to_database!
end

total = @coll.count
puts "#{total} questions stored!"
