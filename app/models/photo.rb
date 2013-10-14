class Photo
  include MongoMapper::Document

  key :source_id

  key :image_url
  key :width
  key :height

  key :filter
  key :caption
  key :url
  key :uploaded_at

  key :faces

  key :author_username
  key :author_name
  key :author_picture

  def filter_class
    return "normal" if self.filter.nil?
    
    self.filter.to_s.downcase.split(' ').join('-').strip
  end
end