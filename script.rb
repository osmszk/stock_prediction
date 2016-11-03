require 'csv'

# date_slash:string
def convert_date(date_slash)
  date_array = date_slash.split("/")
  if date_array.length == 3
    return "20#{date_array[2]}/#{date_array[0]}/#{date_array[1]}"
  else
    return ""
  end
end

csv_data = CSV.read('test.csv', headers: true)
puts "start..."

File.open("output.csv", 'w') do |file|
  file.write("Date,Close\n")
  csv_data.reverse_each do |data|
    date = convert_date("#{data["Date"]}")
    intro_msg = "#{date},#{data[" Close"]}\n"
    puts intro_msg
    file.write(intro_msg)
  end
end

puts "complete!"
