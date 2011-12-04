require 'mongo'

def connect_to_db!
  @conn = Mongo::Connection.new("localhost")
end

def connect_to_db_and_collection!(database_name, collection_name)
  @db = @conn.db(database_name)
  @coll = @db.collection(collection_name)
end

def truncate_expression(expression, ending)
  if expression.include? ending
    stop_pt = expression.index(ending)
    expression = expression[0...stop_pt]
    return expression
  end
end

def check_answer(input, answer)
  input = input.downcase
  full_answer = answer
  
  possible_endings = ["(accept", "[accept", "[prompt", "(prompt"]
  
  for ending in possible_endings
    puts ending
    truncate_expression(answer, ending)
  end

  puts answer  

  #set up threshold and check match against that threshold
  threshold = 0.5
  total_char_in_answer = answer.length.to_f
  char_match = 0
  answer.each_char do |c|
    if input.include? c.downcase
      char_match += 1
      input.delete! c.downcase
    end
  end
  
  match_pct = char_match/total_char_in_answer
  if match_pct > threshold
    correct = true
  else
    correct = false
  end  

  if correct
    puts "\nCORRECT!"
    puts "The full answer was: #{full_answer}"
    return correct
  else
    puts "Sorry, incorrect."
    puts "The answer was: #{full_answer}"
    return correct
  end
end

  
def read_out_loud(to_read, sleep_time)
  to_read = to_read.split(" ")
  stop = false
  finished_reading = false
  listen_for_buzz = Thread.new do
    if finished_reading
      break
    end
    gets
    stop = true
  end
  to_read.each do |c|
    if stop
      puts "BUZZZZZ!"
      # STDOUT.flush
      break
    end    
    print c, " "    
    sleep(sleep_time)
  end
  finished_reading = true
  sleep(sleep_time)
  print "\n"
end

connect_to_db!
connect_to_db_and_collection!("questions", "batch_0")
coll_total = @coll.count()

#Start user interaction here
questions_asked = 0
questions_right = 0
while true
  puts "---------"
  puts "QUESTION:"
  @qa_pair = @coll.find("num" => "#{rand(coll_total).to_s}")
  @qa_pair.each do |row|
    question = row["question"]
    answer = row["answer"]
    read_out_loud(question, 0.001)
    print "What is your answer? "
    #following line is for debugging
    # print "The answer is: #{answer}", "\n"
    user_answer = gets.chomp!
    user_correct = check_answer(user_answer, answer)
    
    #keep track of score
    if user_correct
      questions_right += 1
    end
    questions_asked += 1
    print questions_right.to_s, "/", questions_asked.to_s,  " answered correctly so far", "\n"
  end
  print "Hit [enter] to continue"
  gets
end

