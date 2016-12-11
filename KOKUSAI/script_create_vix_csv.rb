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

def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end

csv_data = CSV.read('rawdata_kokusai.csv', headers: true)
csv_vix_data = CSV.read('rawdata_vix.csv', headers: true)

puts "start..."

new_data = []
index = 0

csv_data.each do |data|
  date_str = data["Date"]
  close_str = data["Value"].sub(/,/,"")
  hash = {"Date" => date_str,"Close" => close_str}
  new_data.push(hash)
end

puts "insert vix data..."

csv_vix_data.reverse_each do |data|
  close_str = data["Close"]
  date_str = data["Date"]
  vix_date = DateTime.parse(date_str)
  new_data.each_with_index do |hash,i|
    n_date = DateTime.parse(hash["Date"])
    if (vix_date.year.to_i == n_date.year.to_i &&
      vix_date.month.to_i == n_date.month.to_i &&
      vix_date.day.to_i == n_date.day.to_i )
      new_hash = hash
      new_hash["Vix"] = close_str
      new_data[i] = new_hash
      next
    end
  end
end

puts "writing..."

File.open("rawdata_kokusai_with_vix.csv", 'w') do |file|
  file.write("Date,Value,Vix\n")
  new_data.each do |data|
    value = data["Close"].to_f
    date_str = data["Date"]
    vix_value = data["Vix"].to_f

    intro_msg = "#{date_str},#{value},#{vix_value}\n"
    puts intro_msg
    file.write(intro_msg)
  end
end

puts "complete!"
