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

csv_data = CSV.read('rawdata_topix.csv', headers: true)
csv_vix_data = CSV.read('rawdata_vix.csv', headers: true)

puts "start..."

new_data = []
index = 0
csv_data.reverse_each do |data|
  is_twenty = index <= 983 ? false : true
  date_str = convert_date("#{data["Date"]}", is_twenty)
  close_str = data[" Close"]
  hash = {"Date" => date_str,"Close" => close_str}
  new_data.push(hash)
  index = index + 1
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

File.open("output_topix_with_vix.csv", 'w') do |file|
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

=begin
base = new_data[0]["Close"].to_f

File.open("output_topix.csv", 'w') do |file|
  file.write("Date,Value,Ratio,HALF_YEAR,VIX_STS,VIX_VAL\n")

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
=end

puts "complete!"
