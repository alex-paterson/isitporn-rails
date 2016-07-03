class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  process :convert => 'png'
  process resize_to_limit: [800, 800]

  process :composite
  process :watermark
  process :text

  def composite
    manipulate! do |img|
      #Image Resize
      rows = img.height.to_f
      cols = img.width.to_f
      ratio = rows/cols
      if img.width < 400
        img.resize "400x#{400*ratio}"
      end

      #Pink Background
      overlay_path = Rails.root.join("app/assets/images/pinkbackground.png")
      overlay = MiniMagick::Image.open(overlay_path)
      overlay.resize "#{img.width}x140!"

      img = img.composite(overlay) do |c|
        c.compose 'Over'
        c.gravity 'South'
        c.geometry '+0+0'
      end

      chance = model.chance.to_f
      if chance < 0.6
        stamp_path = Rails.root.join("app/assets/images/stampsafe.png")
      elsif chance < 0.8
        stamp_path = Rails.root.join("app/assets/images/stampcaution.png")
      else
        stamp_path = Rails.root.join("app/assets/images/stampporn.png")
      end
      overlay = MiniMagick::Image.open(stamp_path)
      img = img.composite(overlay) do |c|
        c.gravity 'SouthEast'
        c.geometry '-10-20'
        c.compose 'Over'
      end
      img
    end
  end

  def text
    manipulate! do |img|
      chance = model.chance.to_f
      puts "HERE\n", model, "HERE"
      puts "HERE\n", model.to_json, "HERE"
      puts "HERE\n", chance, "HERE"
      text = '%.1f' % (chance * 100) + "%"

      pointsize = 56
      stroke_width = pointsize / 30.0

      img.combine_options do |c|
        c.gravity 'Southwest'
        c.font "#{Rails.root}/app/uploaders/fonts/impact.ttf"
        c.pointsize "#{pointsize}"
        c.fill "#FFFFFF"
        c.strokewidth "#{stroke_width}"
        c.stroke "#000000"
        c.draw "text 7,35 '#{text}'"
      end

      if chance < 0.3
        text2 = "CERTIFIED NOT PORN"
      elsif chance < 0.6
        text2 = "PROBABLY NOT PORN"
      elsif chance <0.8
        text2 = "VERY WELL COULD BE PORN"
      elsif chance <0.9
        text2 = "PRETTY SURE THIS IS PORN"
      else
        text2 = "PORN. THIS IS PORN."
      end

      img.combine_options do |c|
        c.gravity 'Southwest'
        c.font "#{Rails.root}/app/uploaders/fonts/impact.ttf"
        c.pointsize "#{pointsize * 0.6}"
        c.fill "#FFFFFF"
        c.strokewidth "#{stroke_width}"
        c.stroke "#000000"
        c.draw "text 7,5 '#{text2}'"
      end
      img
    end
  end

  def watermark
    manipulate! do |img|
      img.combine_options do |c|
        c.gravity 'Southeast'
        c.pointsize "15"
        c.fill "#000000"
        c.weight "900"
        c.draw "text 2,2 'isitporn.com'"
      end
      img.combine_options do |c|
        c.gravity 'Southeast'
        c.pointsize "15"
        c.fill "#000000"
        c.weight "900"
        c.draw "text 2,4 'isitporn.com'"
      end
      img.combine_options do |c|
        c.gravity 'Southeast'
        c.pointsize "15"
        c.fill "#000000"
        c.weight "900"
        c.draw "text 4,2 'isitporn.com'"
      end
      img.combine_options do |c|
        c.gravity 'Southeast'
        c.pointsize "15"
        c.fill "#000000"
        c.weight "900"
        c.draw "text 4,4 'isitporn.com'"
      end

      img.combine_options do |c|
        c.gravity 'Southeast'
        c.pointsize "15"
        c.fill "#FFFFFF"
        c.weight "900"
        c.draw "text 3,3 'isitporn.com'"
      end
      img
    end
  end

  def filename
    super.chomp(File.extname(super)) + '.png'
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  #Defines URL for if image is missing for some reason
  def default_url
      "http://i.stack.imgur.com/ILTQq.png"
  end
end
