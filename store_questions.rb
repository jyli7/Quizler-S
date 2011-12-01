require 'mongo'

def connect_to_db!
  @conn = Mongo::Connection.new("localhost")
end

def create_db_and_collection!(database_name, collection_name)
  @db = @conn.db(database_name)
  @coll = @db.collection(collection_name)
end

def form_qa_array!
  myfile = File.open("data/packets/abt2006-solor1.txt")
  
  @qa_array = []
  question = ""

  myfile.each do |line|
    if line[0].to_i != 0
      question_with_numbers = line.chomp.to_s
      #get rid of the question number
      number_and_spaces = question_with_numbers.match /^[\d]*\.[\s]*/
      if number_and_spaces
        question = question_with_numbers[(0 + number_and_spaces.to_s.length)..-1]
      end
    end
    if line.include? "ANS"
      answer = line.chomp.to_s
      @qa_array << [question, answer]
    end
  end
end

def add_questions_to_database!
  @coll.remove({})
  @qa_array.each do |qa_pair|
   doc = {"question" => "#{qa_pair[0]}", "answer" => "#{qa_pair[1]}"}
   @coll.insert(doc)
  end
end

connect_to_db!
create_db_and_collection!("questions_test", "batch_0")
form_qa_array!
add_questions_to_database!

@a = @coll.find({})
@a.each {|d| puts d["question"], "\n", d["answer"], "\n"}