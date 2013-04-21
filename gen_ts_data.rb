require 'pp'
require 'yaml'
require 'sequel'

# mysql login conf
sql_conf = {}
File.open("/home/shizhan/.mysql_pearl_login", "r") { |f| sql_conf = YAML.load(f) }
sql_conf["DBName"] = 'foursquare'
# mysql connection
DB = Sequel.mysql(sql_conf["DBName"], :user => sql_conf["DBID"], :password => sql_conf["DBPW"], :host => sql_conf["DBServer"])
# dataset
sxsw_vs = DB[:vis_venues]
checkinn = DB[:checkin_number]

# File.open('sxsw2013_venues.csv', 'w') do |vcsv|
#   vcsv.puts "venueID,name"
#   sxsw_vs.order(:name).each do |rec|
#     vcsv.puts "\"#{rec[:venueID]}\",\"#{rec[:name]}\""
#   end
# end

ntime = Time.now
etime = Time.new(ntime.year, ntime.month, ntime.day, ntime.hour)
btime = etime - 3600 * 24 * 45

sxsw_vs.select(:venueID).each do |qr|
  vid = qr[:venueID]
  cdata = checkinn.where(:venueID => vid).where("checktime >= \"#{btime}\"").where("checktime < \"#{etime}\"").select(:checktime, :number).all
  result = {}
  btime.to_i.step(etime.to_i-3600, 3600) do |ctime|
    result[Time.at(ctime)] = 0
  end
  cdata.each do |c|
    ctime = c[:checktime]
    result[Time.new(ctime.year, ctime.month, ctime.day, ctime.hour)] = c[:number]
  end
  f = File.open("/home/shizhan/4q/austin/data/#{vid}.csv", 'w')
  f.puts "ctime,numb"
  result.each do |ctime, n|
    f.puts "#{ctime},#{n}"
  end
  f.close
end
