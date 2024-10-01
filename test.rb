require 'mini_magick'
require 'aws-sdk-s3' 
require 'csv'

puts "STARTED  #{Time.now}"


s3 = Aws::S3::Resource.new

# Specify the S3 bucket and file details
bucket_name = 'swatch-variant-for-image-replicas'       # Replace with your bucket name
# file_path = '/Users/manoj/Downloads/eren-yeager-3840x2160-10354.png'       # Local path to the file
s3_key = 'ImagesReplicas'                # S3 object key (destination path in the bucket)




# Convert to WebP, keeping animation, and compressing
sizes=["50x50","100x100","200x200","300x300"]
sizes.each do |img_size|
image = MiniMagick::Image.open("https://cdn.starapps.studio/v2/apps/vsk/meroeu/groups/3803542/dark-brown-2weft.media")
image.resize img_size 

image.gravity "center"
image.interlace "plane"  # For progressive rendering
image.filter "Triangle"
image.format "webp"

begin
  obj = s3.bucket(bucket_name).object("#{s3_key}/#{img_size}/test.webp")
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
  # puts "File uploaded successfully to #{bucket_name}/#{s3_key}"
rescue StandardError => e
  puts "Error uploading file: #{e.message}"
end
image.write("eren-yeager-#{img_size}.png")
# puts "Conversion complete with compression: output.webp"
end

# puts data

# CSV.open(export_csv_path, "wb") do |csv|
#   data.each do |row|
#     csv << row 
#   end
# end