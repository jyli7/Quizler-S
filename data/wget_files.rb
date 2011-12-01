file = File.new("links_long_start_at_toronto.txt", "r")
r = /\/([\w]*)\/([\w]*.doc[x]*)$/
while (line = file.gets)
  match = line.match r
  name = match[1] + "-" + match[2]
  `wget -O #{name} #{line}`
end
file.close