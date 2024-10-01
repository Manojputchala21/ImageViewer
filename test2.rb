require 'mini_magick'
require 'aws-sdk-s3' 
require 'csv'

puts "STARTED  #{Time.now}"

s3 = Aws::S3::Resource.new

# Specify the S3 bucket and file details
bucket_name = 'swatch-variant-for-image-replicas'       # Replace with your bucket name
# file_path = '/Users/manoj/Downloads/eren-yeager-3840x2160-10354.png'       # Local path to the file
s3_key = 'ImagesReplicas'                # S3 object key (destination path in the bucket)
cdn_prefix = "https://d2y06cp21k9356.cloudfront.net/ImagesReplicas"


# Load the animated GIF

data= [
  ["Source Image URL","Non resized URL","Non resized size ", "50x50","50x50_size","100x100","100x100_size","200x200","200x200_size","300x300","300x300_size"]
]

csv_file_path = "/Users/manoj/Downloads/Image_urls_part.csv"
export_csv_path = "image_urls_data.csv" 


exportcsv = CSV.open(export_csv_path, "wb") 
exportcsv << data[0]
s3counter=0
# Read the CSV file
CSV.foreach(csv_file_path) do |row|
  data_record=[]
  # Access the data in each row
  image_url = row[6]
  begin
    puts "File URL: #{image_url} "
    data_record.push(image_url)
    file_name=image_url.split("/").last.split(".media")[0]

    # Convert to WebP, keeping animation, and compressing
    sizes=["org","50x50","100x100","200x200","300x300"]
    sizes.each do |img_size|
      image = MiniMagick::Image.open(image_url)
      if img_size != "org"
        image.resize img_size 
        resize_file_size = File.size(image.path).to_f/1024
      # puts " After resize File size #{resize_file_size.to_f / 1024}"
        image.gravity "center"
      end  
      image.format "webp"
      
      compress_file_size = File.size(image.path).to_f/1024
      # puts "After compression File size #{compress_file_size.to_f / 1024}"
      
      # Save the result
      # Upload the file to the specified bucket
      if s3counter <=500
        begin
          obj = s3.bucket(bucket_name).object("#{s3_key}/#{img_size}/#{file_name}.webp")
          # obj.upload_file(image.path)
          image_buffer=StringIO.new(image.to_blob)
          obj.put(
            body: image_buffer,
            content_type: 'image/webp',
            cache_control: "must-revalidate, max-age=60",
            metadata: {
              "Content-Type" => 'image/webp',
              "Cache-Control" => "must-revalidate, max-age=60",
            },
            )
            data_record.push("#{cdn_prefix}/#{img_size}/#{file_name}.webp")
            data_record.push(compress_file_size)
            # puts "File uploaded successfully to #{bucket_name}/#{s3_key}"
        rescue StandardError => e
          puts "Error uploading file: #{e.message}"
        end
      end
      # puts s3counter
      # image.write("eren-yeager-#{img_size}.png")
      # puts "Conversion complete with compression: output.webp"
    end
  rescue  StandardError =>e 
    puts "Failed to read URL #{image_url} #{e}" 
  end 
  
  if s3counter >500
    break
  end
    s3counter+=1
    data.push(data_record)
    exportcsv << data_record
end
exportcsv.close()

puts "ENDED  #{Time.now}"

# puts data

# CSV.open(export_csv_path, "wb") do |csv|
#   data.each do |row|
#     csv << row 
#   end
# end