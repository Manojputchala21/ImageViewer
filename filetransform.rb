require 'csv'


exportcsv = CSV.open('urls.csv', "wb") 

# Read the CSV file
CSV.foreach('image_urls_data.csv') do |row|
url = row[0];
exportcsv << [url+ ',']
end
exportcsv.close()