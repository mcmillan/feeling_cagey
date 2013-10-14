require File.expand_path(File.dirname(__FILE__) + '/boot')
require "fileutils"

Photo.destroy_all 

max_id = nil

(1..5).each do |depth|
  puts "- Depth level #{depth} (we need to go deeper)"

  puts "-- Hitting Instagram for media tagged with #{ENV["TAG"]}, max_id #{max_id || 'not set'}"
  media = Instagram.client.tag_recent_media(ENV["TAG"], max_id ? { max_id: max_id, count: 50 } : { count: 50 })
  puts "-- #{media.count} results returned from Instagram"

  media.each do |m|
    puts "-- Processing media item #{m.id}"

    if m.type != 'image'
      puts "--- Media is not an image, skipping"
      next
    end

    p = Photo.new({
      source_id: m.id,

      image_url: m.images.standard_resolution.url,
      width: m.images.standard_resolution.width,
      height: m.images.standard_resolution.height,

      filter: m.filter,
      caption: m.caption ? m.caption.text : nil,
      url: m.link,
      uploaded_at: m.created_time,

      author_username: m.user.username,
      author_name: m.user.full_name,
      author_picture: m.user.profile_picture
    })

    detector    = OpenCV::CvHaarClassifierCascade::load(File.expand_path(File.dirname(__FILE__) + '/haar.xml'))
    output_file = "tmp/#{p.source_id}.jpg"
    begin
      puts "--- Downloading image..."
      `wget --quiet -O #{output_file} #{p.image_url}` # lol

      puts "--- Running face detection..."
      cv_image = OpenCV::CvMat.load(output_file)
      p.faces  = []

      detector.detect_objects(cv_image).each do |region|
        next if region.width < 100 # Smaller faces are more likely to be false-positives and aren't as funny

        p.faces << {
          width: region.width,
          height: region.height,
          top: region.top_left.y,
          left: region.top_left.x
        }
      end

      File.delete(output_file)
    rescue => e
      puts "!!! Something went horrendously wrong during the download/face recognition phase - skipping"
      puts "!!! #{e}"
      next
    ensure
      FileUtils.rm_f(output_file)
    end

    puts "--- #{p.faces.count} faces found"

    next unless p.faces.any?

    puts "--- Saving..."

    p.save
  end

  puts "-- All media processed"

  max_id = media.pagination.next_max_id
end