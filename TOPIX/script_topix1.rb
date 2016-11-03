require 'csv'
require 'date'

# date_str :string
# scale :float
# topix : float
# topix_prev : float

def calc_half(date_str,scale_prev)
  # date_strが11月〜4月→自分の前の
  # それ以外　→
end

# date_str:string
def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end


csv_data = CSV.read('output_topix1.csv', headers: true)
puts "start..."

File.open("output_topix_result.csv", 'w') do |file|
  file.write("Date,Close,TOPIX,HALF_YEAR\n")
  index = 0
  temp_half_year = ""
  csv_data.each do |data|
    date_str = data["Date"] # "1996/1/4"
    if index > 0 && should_buy_priod(date_str)
      prev_topix = csv_data[index-1]["TOPIX"].to_f
      prev_half_year = temp_half_year.to_f
      topix = data["TOPIX"].to_f
      half_year = (topix - prev_topix) / topix * 100 + prev_half_year
      # puts "should buy! #{date_str} "
    elsif index > 0 && !should_buy_priod(date_str)
      prev_half_year = temp_half_year.to_f
      half_year = temp_half_year.to_f
      # puts "should NOT buy! #{date_str} "
    else
      half_year = "100"
    end
    intro_msg = "#{date_str},#{data["Close"]},#{data["TOPIX"]},#{half_year}\n"
    temp_half_year = half_year
    # puts intro_msg
    file.write(intro_msg)
    index = index + 1
  end
end

puts "complete!"
