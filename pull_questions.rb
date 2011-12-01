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

a = @coll.find({})
a.each {|d| puts d["question"], "\n", d["answer"], "\n"}
