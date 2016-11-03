require 'csv'

# date_slash:string
# is_twenty:boolean
def convert_date(date_slash,is_twenty)
  date_array = date_slash.split("/")
  if date_array.length == 3
    header = is_twenty ? "20" : "19"
    return "#{header}#{date_array[2]}/#{date_array[0]}/#{date_array[1]}"
  else
    return ""
  end
end

csv_data = CSV.read('topix_1996.csv', headers: true)
puts "start..."

File.open("output.csv", 'w') do |file|
  file.write("Date,Close\n")
  index = 0
  csv_data.reverse_each do |data|
    is_twenty = index <= 983 ? false : true
    date = convert_date("#{data["Date"]}", is_twenty)
    intro_msg = "#{date},#{data[" Close"]}\n"
    puts intro_msg
    file.write(intro_msg)
    index = index + 1
  end
end

puts "complete!"
