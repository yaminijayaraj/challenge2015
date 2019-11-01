require 'net/http'
require 'json'
require 'pry'

$host_url = 'http://data.moviebuff.com/'
$keys = ["cast", "crew", "movies"]
$count = 0
$allowed_degree = 3


def recursive_degrees(data1, data2)

  urls1 = []
  urls2 = []
  url1 = []
  url2 = []
  $count += 1
  puts "--------------------------Degree : #{$count}-----------------------------------"
  if data1.is_a?(String) && data2.is_a?(String)
    urls1 << get_data(data1)
    urls2 << get_data(data2)
  else
    url1 << data1
    url2 << data2
    urls_data1 = (url1[0].collect {|x| x["url"]}).uniq
    urls_data2 = (url2[0].collect {|x| x["url"]}).uniq

    urls_data2.each_with_index do |dat2,index|
      data = get_data(dat2)
      urls2 << data unless data.empty?
      puts "fetching data...."
    end
    urls_data1.each_with_index do |dat1,index|
      data = get_data(dat1)
      urls1 << data unless data.empty?
      puts "fetching data...."
    end
  end
  url1 = []
  url2 = []
  urls1.uniq.compact.length.times do |index|
    urls2.uniq.compact.length.times do |ind|
      check_deg = urls1[index].collect{|x| x["url"]} & urls2[ind].collect{|x| x["url"]}
      unless urls1[index].select{|x| check_deg.include? x["url"]}.empty?
        matched_urls = urls1[index].select{|x| check_deg.include? x["url"]}.first
        print_result(matched_urls.merge({"p1arent#{$count}" => data1}).merge({"p2arent#{$count}" => data2}))
      else
        urls1[index].each {|x| url1.push(x.merge({"parent#{$count}" => data1}))}
        urls2[ind].each {|x| url2.push(x.merge({"parent#{$count}" => data2}))}
      end
    end
  end
  recursive_degrees(url1, url2) if $count <= $allowed_degree

end

def print_result(data)
  if $count > 1
    deg2_name = (get_data(data["p1arent3"][0]["parent2"][0]["url"]).collect{|x| x["url"]}) & (get_data(data["url"]).collect { |x| x["url"] })
    deg2 = (get_data(data["p2arent3"][0]["parent2"][0]["url"]).collect{|x| x["url"]}) & (get_data(data["url"]).collect { |x| x["url"] })
    deg_2_role = get_data(deg2.first).select{|x| x["url"] == data["url"]}.first["role"]
    d2_data = get_data(deg2.first).select{|u| u["url"] == data["p2arent3"][0]["parent2"][0]["url"]}
    d1_role = get_data(data["p1arent3"][0]["parent2"][0]["url"]).select{|x| x["url"] == deg2_name.first}.first
    d3_role = get_data(data["p2arent3"][0]["parent2"][0]["url"]).select{|x| x["url"] == deg2.first}.first
    puts "Degree of separation: #{$count}"
    puts
    puts "Movie: #{data["p1arent3"][0]["parent2"][0]["name"]}"
    puts "#{data["p1arent3"][0]["parent2"][0]["role"]} : #{convert_to_name(data["p1arent3"][0]["parent2"][0]["parent1"])}"
    puts "#{d1_role["role"]} :  #{convert_to_name(deg2_name.first)}"
    puts
    puts "Movie: #{data["name"]}"
    puts "#{d2_data[0]["role"]} : #{convert_to_name(deg2_name.first)}"
    puts "#{deg_2_role} : #{convert_to_name(deg2.first)}"
    puts
    puts "Movie: #{data["p2arent3"][0]["parent2"][0]["name"]}"
    puts "#{d3_role["role"]} : #{convert_to_name(deg2.first)}"
    puts "#{data["p2arent3"][0]["parent2"][0]["role"]}: #{convert_to_name(data["p2arent3"][0]["parent2"][0]["parent1"])}"
  else
    puts "Degree of separation: #{$count}"
    puts "Movie: #{data["name"]}"
    puts "#{data["role"]} :  #{convert_to_name(data["p1arent1"])}"
    dat = get_data(data["p2arent1"]).select {|x| x["url"] == data["url"]}.first
    puts "#{dat["role"]} : #{convert_to_name(data["p2arent1"])}"
  end
  exit
end

def convert_to_name(url)
  url.gsub("-"," ").capitalize
end

def  get_data(data1, header = nil)
  begin
    url = $host_url + data1
    uri = URI(url)
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)
    if header.nil?
      return(response[$keys[0]].nil? ? response[$keys[2]] : response[$keys[0]].concat(response[$keys[1]]))
    else
      return response
    end
  rescue => e
    return []
  end
end

puts "Enter artist1: "
data1 = gets.chomp()
puts "Enter artist2: "
data2 = gets.chomp()
if data1.strip.empty? || data2.strip.empty?
  puts "Invalid string found!!"
elsif data1.strip == data2.strip
  puts "You have entered the same string!!!"
else
  output = recursive_degrees(data1, data2)
end

