require 'csv'

csv_data = CSV.read('rawdata_sp500.csv', headers: true)
puts "start..."

new_data = []
# new_csv_data.push("Date,Close\n")
csv_data.reverse_each do |data|
  date_str = data["Date"]
  close_str = data["Close"]
  hash = {"Date" => date_str,"Close" => close_str}
  new_data.push(hash)
end

File.open("output_sp500.csv", 'w') do |file|
  file.write("Date,Close\n")
  index = 0
  new_data.each do |data|
    intro_msg = "#{data["Date"]},#{data["Close"]}\n"
    puts intro_msg
    file.write(intro_msg)
    index = index + 1
  end
end

puts "complete!"
