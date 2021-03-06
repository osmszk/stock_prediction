require 'csv'
require 'date'


def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end

csv_data = CSV.read('rawdata_kokusai_with_vix.csv', headers: true)
puts "start..."

base = csv_data[0]["Value"].to_f

File.open("output_kokusai.csv", 'w') do |file|
  file.write("Date,Value,Ratio,HALF_YEAR\n")
  i = 0
  temp_half_year = ""
  temp_ratio = 100.0
  csv_data.each do |data|
    value = data["Value"].to_f
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
