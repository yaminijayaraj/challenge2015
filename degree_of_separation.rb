require 'net/http'
require 'json'

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
        print_result(matched_urls)
      else
        urls1[index].each {|x| url1.push(x.merge({"parent#{$count}" => data1}))}
        urls2[ind].each {|x| url2.push(x.merge({"parent#{$count}" => data2}))}
      end
    end
  end

  puts "--------------------------Degree : #{$count}-----------------------------------"
  recursive_degrees(url1, url2) if $count <= $allowed_degree

end

def print_result(data)

  puts "Degree of separation: #{$count}"
  response = get_data(data["url"], true)
  puts "Connected via: #{response["name"] } - #{response["type"]}"
  exit
end

def get_data(data1, header = nil)
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

