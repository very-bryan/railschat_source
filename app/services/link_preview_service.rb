require 'open-uri'
require 'nokogiri'
require 'timeout'

class LinkPreviewService
  def self.fetch(url)
    new(url).fetch
  end
  
  def initialize(url)
    @url = url
  end
  
  def fetch
    return nil unless valid_url?
    
    # Special handling for Google Docs/Sheets/Slides
    if GoogleEmbedService.google_doc?(@url)
      google_info = GoogleEmbedService.extract_info(@url)
      return {
        url: @url,
        title: GoogleEmbedService.fetch_title(@url),
        description: google_info[:name],
        image: nil,
        favicon: nil,
        site_name: google_info[:name],
        is_google_doc: true,
        google_info: google_info
      }
    end
    
    Timeout::timeout(5) do
      doc = fetch_document
      return nil unless doc
      
      {
        url: @url,
        title: extract_title(doc),
        description: extract_description(doc),
        image: extract_image(doc),
        favicon: extract_favicon(doc),
        site_name: extract_site_name(doc)
      }
    end
  rescue => e
    Rails.logger.error "LinkPreviewService Error: #{e.message}"
    nil
  end
  
  private
  
  def valid_url?
    uri = URI.parse(@url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue
    false
  end
  
  def fetch_document
    response = URI.open(@url, 
      'User-Agent' => 'Mozilla/5.0 (compatible; VeryWorksBot/1.0)',
      redirect: true,
      read_timeout: 5,
      open_timeout: 5
    )
    
    # Only parse HTML content
    return nil unless response.content_type&.include?('text/html')
    
    Nokogiri::HTML(response.read)
  rescue
    nil
  end
  
  def extract_title(doc)
    # Try Open Graph first
    title = doc.at_css('meta[property="og:title"]')&.[]('content')
    # Fall back to Twitter Card
    title ||= doc.at_css('meta[name="twitter:title"]')&.[]('content')
    # Fall back to page title
    title ||= doc.at_css('title')&.text
    
    title&.strip&.truncate(100)
  end
  
  def extract_description(doc)
    # Try Open Graph first
    desc = doc.at_css('meta[property="og:description"]')&.[]('content')
    # Fall back to Twitter Card
    desc ||= doc.at_css('meta[name="twitter:description"]')&.[]('content')
    # Fall back to meta description
    desc ||= doc.at_css('meta[name="description"]')&.[]('content')
    
    desc&.strip&.truncate(200)
  end
  
  def extract_image(doc)
    # Try Open Graph first
    image = doc.at_css('meta[property="og:image"]')&.[]('content')
    # Fall back to Twitter Card
    image ||= doc.at_css('meta[name="twitter:image"]')&.[]('content')
    
    return nil unless image
    
    # Make relative URLs absolute
    begin
      uri = URI.parse(image)
      if uri.relative?
        base_uri = URI.parse(@url)
        uri = URI.join("#{base_uri.scheme}://#{base_uri.host}", image)
      end
      uri.to_s
    rescue
      image
    end
  end
  
  def extract_favicon(doc)
    # Try various favicon locations
    favicon = doc.at_css('link[rel="icon"]')&.[]('href')
    favicon ||= doc.at_css('link[rel="shortcut icon"]')&.[]('href')
    favicon ||= doc.at_css('link[rel="apple-touch-icon"]')&.[]('href')
    
    return "/favicon.ico" unless favicon
    
    # Make relative URLs absolute
    begin
      uri = URI.parse(favicon)
      if uri.relative?
        base_uri = URI.parse(@url)
        uri = URI.join("#{base_uri.scheme}://#{base_uri.host}", favicon)
      end
      uri.to_s
    rescue
      favicon
    end
  end
  
  def extract_site_name(doc)
    # Try Open Graph first
    site = doc.at_css('meta[property="og:site_name"]')&.[]('content')
    # Fall back to domain name
    site ||= URI.parse(@url).host&.gsub(/^www\./, '')&.capitalize
    
    site
  end
end