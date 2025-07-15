class GoogleEmbedService
  GOOGLE_SERVICES = {
    document: {
      pattern: %r{docs\.google\.com/document/d/([a-zA-Z0-9-_]+)},
      name: 'Google 문서',
      icon_color: '#4285F4',
      embed_url: 'https://docs.google.com/document/d/%{id}/preview'
    },
    spreadsheet: {
      pattern: %r{docs\.google\.com/spreadsheets/d/([a-zA-Z0-9-_]+)},
      name: 'Google 스프레드시트',
      icon_color: '#0F9D58',
      embed_url: 'https://docs.google.com/spreadsheets/d/%{id}/preview'
    },
    presentation: {
      pattern: %r{docs\.google\.com/presentation/d/([a-zA-Z0-9-_]+)},
      name: 'Google 프레젠테이션',
      icon_color: '#F4B400',
      embed_url: 'https://docs.google.com/presentation/d/%{id}/preview'
    },
    forms: {
      pattern: %r{docs\.google\.com/forms/d/([a-zA-Z0-9-_]+)},
      name: 'Google 설문지',
      icon_color: '#673AB7',
      embed_url: 'https://docs.google.com/forms/d/%{id}/viewform?embedded=true'
    }
  }.freeze

  def self.google_doc?(url)
    GOOGLE_SERVICES.values.any? { |service| url.match?(service[:pattern]) }
  end

  def self.extract_info(url)
    GOOGLE_SERVICES.each do |type, service|
      if match = url.match(service[:pattern])
        return {
          type: type,
          id: match[1],
          name: service[:name],
          icon_color: service[:icon_color],
          embed_url: service[:embed_url] % { id: match[1] },
          original_url: url
        }
      end
    end
    nil
  end

  def self.fetch_title(url)
    info = extract_info(url)
    return nil unless info
    
    # Try to extract title from URL if it's in the format
    # https://docs.google.com/document/d/[ID]/edit#heading=...
    # The title is often in the URL after the ID
    if url.match(%r{/([^/]+?)(?:\?|#|$)})
      title_candidate = $1
      # Clean up common suffixes
      title_candidate = title_candidate.gsub(/[-_]?edit$/, '')
      # If it looks like a title (not just parameters), use it
      if title_candidate.length > 5 && !title_candidate.match?(/^[a-zA-Z0-9-_]+$/)
        return URI.decode_www_form_component(title_candidate).gsub(/[-_]/, ' ').strip
      end
    end
    
    # Default to service name
    info[:name]
  end
end