require 'csv'
require 'date'

# 新半年投資(10,11,12,3,4)がワークするかの検証

OUTPUT_FILE_NAME = "output_sp500_v3.csv"

def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 10 || month == 3 || month == 4
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

File.open(OUTPUT_FILE_NAME, 'w') do |file|
  file.write("Date,Value,Ratio,NEW_HALF_YEAR\n")
  # S&P500value	S&P500	半年投資(10,11,12,3,4)
  i = 0
  temp_half_year = ""
  temp_ratio = 100.0

  new_data.each do |data|
    value = data["Close"].to_f
    date_str = data["Date"]
    ratio = (value - base) / base * 100.0 + 100.0

    if i > 0 && should_buy_priod(date_str)
      prev_ratio = temp_ratio
      prev_half_year = temp_half_year.to_f
      half_year = (ratio - prev_ratio) / prev_ratio * prev_half_year + prev_half_year
      # puts "should buy! #{date_str} "

    elsif i > 0 && !should_buy_priod(date_str)
      prev_ratio = temp_ratio
      prev_half_year = temp_half_year.to_f
      half_year = temp_half_year.to_f
      # puts "should NOT buy! #{date_str} "

    else
      half_year = "100.0"
    end

    intro_msg = "#{date_str},#{value},#{ratio},#{half_year}\n"
    temp_half_year = half_year
    temp_ratio = ratio
    puts intro_msg
    file.write(intro_msg)
    i = i + 1
  end
end

puts "complete!"
