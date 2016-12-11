require 'csv'
require 'date'

# 1月のパフォーマンスを検証(1月は売ったほうがいいのか？)

def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end

def is_first_day_in_jan(date_str, prev_date_str)
  date = DateTime.parse(date_str)
  prev_date = DateTime.parse(prev_date_str)
  return date.month.to_i == 1 && prev_date.month.to_i == 12
end

def is_last_day_in_jan(date_str, next_date_str)
  date = DateTime.parse(date_str)
  next_date = DateTime.parse(next_date_str)
  return date.month.to_i == 1 && next_date.month.to_i == 2
end



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

base = new_data[0]["Close"].to_f


output_data = []
File.open("output_sp500_v2.csv", 'w') do |file|
  file.write("Year,Percent\n")
  i = 0

  temp_first_value = 0.0
  temp_last_value = 0.0
  new_data.each do |data|
    value = data["Close"].to_f
    date_str = data["Date"]

    if i > 0
      prev_date_str = new_data[i-1]["Date"]
      if is_first_day_in_jan(date_str,prev_date_str)
        temp_first_value = value
        puts "first!! #{temp_first_value} at #{DateTime.parse(date_str)} "
      end
    end

    if i < new_data.length - 1
      next_date_str = new_data[i+1]["Date"]
      if is_last_day_in_jan(date_str,next_date_str)
        temp_last_value = value
        puts "last!! #{temp_last_value} at #{DateTime.parse(date_str)} "
        date = DateTime.parse(date_str)
        percent = (temp_last_value-temp_first_value)/temp_first_value * 100.0
        output_msg = "#{date.year},#{percent}\n"
        file.write(output_msg)
      end
    end
    i = i + 1
  end
end

puts "complete!"
