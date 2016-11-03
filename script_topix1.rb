require 'csv'

# date_str :string
# scale :float
# topix : float
# topix_prev : float

def calc_half(date_str,scale_prev)
  # date_strが11月〜4月→自分の前の
  # それ以外　→
end


csv_data = CSV.read('output_topix1.csv', headers: true)
puts "start..."

File.open("output_topix2.csv", 'w') do |file|
  file.write("Date,Close,TOPIX,HALF_YEAR\n")
  index = 0
  temp_half_year = ""
  csv_data.each do |data|
    if index > 0
      prev_topix = csv_data[index-1]["TOPIX"].to_f
      prev_half_year = temp_half_year.to_f
      topix = data["TOPIX"].to_f
      half_year = (topix - prev_topix) / topix * 100 + prev_half_year
    else
      half_year = "100"
    end
    intro_msg = "#{date["Date"]},#{data["Close"]},#{data["TOPIX"]},#{half_year}\n"
    temp_half_year = half_year
    puts intro_msg
    file.write(intro_msg)
    index = index + 1
  end
end

puts "complete!"
