# BIG FAT DISCLAIMER OF DREAMS:
# This code isn't very nice. It was written at speed and this whole thing was built in about half a day.
# Some of it doesn't make sense and should be taken with a pinch of salt. It's an app that photomanipulates Nicolas Cage, for god's sake. 
require File.expand_path(File.dirname(__FILE__) + '/boot')
require "fileutils"
require "digest"

# Start afresh
Photo.destroy_all 

# We've not got any media yet, so we want to get the latest media we can find with no minimum ID
min_id = 0

# Set up the Haar Classifier using haar.xml. fullfrontal_alt.xml appears to work best from the default Haar cascades that are supplied with OpenCV.
detector = OpenCV::CvHaarClassifierCascade::load(File.expand_path(File.dirname(__FILE__) + '/haar.xml'))

# I will loop you until the end of time
#  - Beyonce, 2013
while true

  puts "- Clearing out photos that are >= 5 minutes old"
  count = Photo.count
  Photo.destroy_all(:created_at.lte => 5.minutes.ago)
  count = count - Photo.count
  puts "- Deleted #{count} photos"

  puts "-- Hitting Instagram for media tagged with #{ENV["TAG"]}, min_id #{min_id}"

  # Get all the media, y0
  media = Instagram.client.tag_recent_media(ENV["TAG"], min_id: min_id, count: 25)

  puts "-- #{media.count} results returned from Instagram"

  media.each do |m|
    puts "-- Processing media item #{m.id}"

    # If we try to run a video through OpenCV all hell is going to break loose, so make sure we're only getting images from Instagram
    # Irritatingly we can't filter this through the API call (sigh), so have to do it here.
    if m.type != 'image'
      puts "--- Media is not an image, skipping"
      next
    end

    if ExcludedUser.where(username: m.user.username).any?
      puts "--- User has requested exclusion, skipping"
      next
    end

    p = Photo.new({      
      image_url: m.images.standard_resolution.url,
      width: m.images.standard_resolution.width,
      height: m.images.standard_resolution.height,
      
      uploader: (Digest::SHA2.new << m.user.username).to_s,
      filter: m.filter
    })

    # Define where we're going to whack this image temporarily.
    # All Instagram images are jpegs for now
    output_file = "tmp/#{p.id}.jpg"

    begin
      puts "--- Downloading image..."

      # Download the image via wget. This is remarkably dubious and will silently fail, hence why this whole thing is wrapped in a try/catch
      # Should definitely be refactored to at least check if we get output to stderr
      `wget --quiet -O #{output_file} #{p.image_url}` 

      puts "--- Running face detection..."
      cv_image = OpenCV::CvMat.load(output_file)
      p.faces  = []

      # Do all the detection and shit
      detector.detect_objects(cv_image).each do |region|
        next if region.width < 150 # Smaller faces are more likely to be false-positives and aren't as funny, so skip them

        p.faces << {
          "width" => region.width,
          "height" => region.height,
          "top" => region.top_left.y,
          "left" => region.top_left.x
        }
      end
    rescue => e
      puts "!!! Something went horrendously wrong during the download/face recognition phase - skipping"
      puts "!!! #{e}"
      next
    ensure
      # Make sure we trash the temporarily downloaded image
      FileUtils.rm_f(output_file)
    end

    puts "--- #{p.faces.count} faces found"

    # Don't bother saving that nice model we created up there unless there's actually any faces in the bloody thing
    next unless p.faces.any?

    puts "--- Saving..."

    p.save

    Pusher["cage"].trigger("new_photo", p.filtered_for_json)
  end

  puts "-- All media processed"

  # Update the min_id, have a little sleep for 10 seconds so we don't hit any rate limits (fat chance with the
  # time it takes to process these images, however it might be a concern if you're using an obscure hashtag)
  min_id = media.pagination.min_tag_id
end