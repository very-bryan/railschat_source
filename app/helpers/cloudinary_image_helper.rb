module CloudinaryImageHelper
  def cloudinary_optimized_image_tag(attachment, options = {})
    return image_tag(attachment, options) unless cloudinary_enabled?
    
    # Extract options
    size = options.delete(:size) || "300x300"
    quality = options.delete(:quality) || "auto"
    format = options.delete(:format) || "auto"
    loading = options.delete(:loading) || "lazy"
    
    # Parse size
    width, height = size.split('x').map(&:to_i)
    
    # Build Cloudinary auto-upload URL
    base_url = polymorphic_url(attachment)
    
    # Cloudinary auto-upload URL format
    cloudinary_url = "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/fetch/w_#{width},h_#{height},c_limit,q_#{quality},f_#{format}/" + base_url
    
    # Add options
    options[:loading] = loading
    options[:class] = [options[:class], "cloudinary-image"].compact.join(" ")
    
    image_tag(cloudinary_url, options)
  rescue => e
    Rails.logger.error "Cloudinary error: #{e.message}"
    # Fallback to regular image_tag
    image_tag(attachment, options)
  end
  
  def cloudinary_modal_image_url(attachment, options = {})
    return polymorphic_url(attachment) unless cloudinary_enabled?
    
    width = options[:width] || 1200
    height = options[:height] || 1200
    quality = options[:quality] || "auto:good"
    
    base_url = polymorphic_url(attachment)
    
    # Cloudinary auto-upload URL for modal (larger size)
    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/fetch/w_#{width},h_#{height},c_limit,q_#{quality},f_auto/" + base_url
  rescue => e
    Rails.logger.error "Cloudinary modal URL error: #{e.message}"
    polymorphic_url(attachment)
  end
  
  private
  
  def cloudinary_enabled?
    ENV['CLOUDINARY_CLOUD_NAME'].present? && 
    ENV['CLOUDINARY_API_KEY'].present? && 
    Rails.env.production?  # Only use in production where URLs are publicly accessible
  end
end