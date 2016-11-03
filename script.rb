require 'csv'

csv_data = CSV.read('test.csv', headers: true)
puts "start..."

# Date, Open, High, Low, Close
# 11/02/16, 1376.68, 1377.61, 1363.02, 1368.44
# 11/01/16, 1391.97, 1394.92, 1384.45, 1393.19
# test.csv
File.open("output.csv", 'w') do |file|
  file.write("Date,Close\n")
  csv_data.reverse_each do |data|
    intro_msg = "#{data["Date"]},#{data[" Close"]}\n"
    puts intro_msg
    file.write(intro_msg)
  end
end

puts "complete!"
