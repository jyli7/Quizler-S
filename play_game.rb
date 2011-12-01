require 'mongo'

def connect_to_db!
  @conn = Mongo::Connection.new("localhost")
end

def connect_to_db_and_collection!(database_name, collection_name)
  @db = @conn.db(database_name)
  @coll = @db.collection(collection_name)
end

connect_to_db!
connect_to_db_and_collection!("questions", "batch_0")
coll_total = @coll.count()

#Start user interaction here
while true
  puts "---------"
  puts "QUESTION:"
  @qa_pair = @coll.find("num" => "#{rand(coll_total).to_s}")
  @qa_pair.each do |row|
    question = row["question"]
    answer = row["answer"]
    puts question, "\n"
    print "What is your answer? "

    user_answer = gets.chomp!
    puts answer
    correct = answer.match /#{user_answer}/i
    if correct != nil
      puts "CORRECT!"
      puts "Full answer was: #{answer}", "\n"
    else
      puts "Sorry, incorrect."
      puts "The actual answer was: #{answer}", "\n"
    end
  end
  print "Hit [enter] to continue"
  gets
end

