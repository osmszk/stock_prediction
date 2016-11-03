require 'csv'
require 'date'

# date_str :string
# scale :float
# topix : float
# topix_prev : float


# date_str:string
def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end

csv_data = CSV.read('rawdata_topix_with_vix.csv', headers: true)
# Date,Value,Vix
puts "start..."

base = csv_data[0]["Value"].to_f

File.open("output_topix_vix.csv", 'w') do |file|
  file.write("Date,Value,Ratio,HALF_YEAR,VIX_STS,VIX_VAL\n")
# TOPIX(index)	TOPIX	半年投資(4月〜翌11月)	半年投資+VIX26	VIX
  i = 0
  temp_half_year = ""
  temp_ratio = 100.0
  temp_vix_sts = 100.0
  temp_vix_value = 12.0

  csv_data.each do |data|
    value = data["Value"].to_f
    date_str = data["Date"]
    vix_value = data["Vix"].to_f
    ratio = (value - base) / base * 100.0 + 100.0

    if i > 0 && should_buy_priod(date_str)
      prev_ratio = temp_ratio
      prev_half_year = temp_half_year.to_f
      half_year = (ratio - prev_ratio) / prev_ratio * prev_half_year + prev_half_year
      # puts "should buy! #{date_str} "

      prev_vix_value = temp_vix_value
      if prev_vix_value > 26.0
        #not hold
        vix_sts = temp_vix_sts.to_f
      else
        #hold
        prev_vix_sts = temp_vix_sts.to_f
        vix_sts = (ratio - prev_ratio) / prev_ratio * prev_vix_sts + prev_vix_sts
      end

    elsif i > 0 && !should_buy_priod(date_str)
      prev_ratio = temp_ratio
      prev_half_year = temp_half_year.to_f
      half_year = temp_half_year.to_f
      # puts "should NOT buy! #{date_str} "

      vix_sts = temp_vix_sts.to_f
    else
      half_year = "100.0"
      vix_sts = "100.0"
    end

    intro_msg = "#{date_str},#{value},#{ratio},#{half_year},#{vix_sts},#{vix_value}\n"
    temp_half_year = half_year
    temp_ratio = ratio
    temp_vix_sts = vix_sts
    temp_vix_value = vix_value
    puts intro_msg
    file.write(intro_msg)
    i = i + 1
  end
end

#########
=begin
File.open("output_topix_result3.csv", 'w') do |file|
  file.write("Date,Close,TOPIX,HALF_YEAR\n")
  i = 0
  temp_half_year = ""
  csv_data.each do |data|
    date_str = data["Date"] # "1996/1/4"
    if i > 0 && should_buy_priod(date_str)
      prev_ratio = csv_data[i-1]["TOPIX"].to_f
      prev_half_year = temp_half_year.to_f
      ratio = data["TOPIX"].to_f
      half_year = (ratio - prev_ratio) / prev_ratio * prev_half_year + prev_half_year
      # puts "should buy! #{date_str} "
    elsif i > 0 && !should_buy_priod(date_str)
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
    i = i + 1
  end
end
=end

puts "complete!"
