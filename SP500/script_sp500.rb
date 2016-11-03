require 'csv'
require 'date'


def should_buy_priod(date_str)
  date = DateTime.parse(date_str)
  month = date.month.to_i
  return month >= 11 || month <= 4
end

csv_data = CSV.read('rawdata_sp500.csv', headers: true)
csv_vix_data = CSV.read('rawdata_vix.csv', headers: true)

puts "start..."

new_data = []
# new_csv_data.push("Date,Close\n")
csv_data.reverse_each do |data|
  date_str = data["Date"]
  close_str = data["Close"]
  hash = {"Date" => date_str,"Close" => close_str}
  new_data.push(hash)
end

k = 0
csv_vix_data.reverse_each do |data|
  close_str = data["Close"]
  hash = new_data[k]
  hash["Vix"] = close_str
  new_data[k] = hash
  k = k + 1
end

base = new_data[0]["Close"].to_f

File.open("output_sp500.csv", 'w') do |file|
  file.write("Date,Value,Ratio,HALF_YEAR,VIX_STS,VIX_VAL\n")
  # S&P500value	S&P500	半年投資(4月〜翌11月)	半年投資+VIX26	VIX
  i = 0
  temp_half_year = ""
  temp_ratio = 100.0
  temp_vix_sts = 100.0
  temp_vix_value = 12.0

  new_data.each do |data|
    value = data["Close"].to_f
    date_str = data["Date"]
    vix_value = data["Vix"].to_f
    ratio = (value - base) / base * 100.0 + 100.0

    if i > 0 && should_buy_priod(date_str)
      prev_ratio = temp_ratio
      prev_half_year = temp_half_year.to_f
      half_year = (ratio - prev_ratio) / prev_ratio * prev_half_year + prev_half_year
      # puts "should buy! #{date_str} "

      prev_vix_value = temp_vix_value
      if vix_value > 26.0
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

puts "complete!"
