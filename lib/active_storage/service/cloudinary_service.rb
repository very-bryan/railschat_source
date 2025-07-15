require "cloudinary"

module ActiveStorage
  class Service::CloudinaryService < Service
    def initialize(folder:)
      @folder = folder
    end

    def upload(key, io, checksum: nil, **)
      instrument :upload, key: key, checksum: checksum do
        begin
          result = Cloudinary::Uploader.upload(io, 
            public_id: "#{@folder}/#{key}",
            resource_type: :auto,
            use_filename: true,
            unique_filename: false,
            overwrite: true
          )
          result["public_id"]
        rescue CloudinaryException => e
          raise ActiveStorage::IntegrityError, e.message
        end
      end
    end

    def download(key, &block)
      instrument :download, key: key do
        url = cloudinary_url(key)
        response = Net::HTTP.get_response(URI(url))
        
        if response.is_a?(Net::HTTPSuccess)
          if block_given?
            yield response.body
          else
            response.body
          end
        else
          raise ActiveStorage::FileNotFoundError
        end
      end
    end

    def download_chunk(key, range)
      # Cloudinary doesn't support partial downloads, so download full file
      download(key)[range]
    end

    def delete(key)
      instrument :delete, key: key do
        Cloudinary::Uploader.destroy("#{@folder}/#{key}", resource_type: :auto)
      end
    end

    def delete_prefixed(prefix)
      # Cloudinary doesn't support prefix deletion in the same way
      # This would need to be implemented with the Admin API
    end

    def exist?(key)
      begin
        Cloudinary::Api.resource("#{@folder}/#{key}")
        true
      rescue Cloudinary::Api::NotFound
        false
      end
    end

    def url(key, expires_in:, filename:, content_type:, disposition:, **)
      instrument :url, key: key do
        cloudinary_url(key)
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:, custom_metadata: {})
      instrument :url_for_direct_upload, key: key do
        # Cloudinary doesn't support direct uploads in the same way as S3
        # Return a placeholder that will be handled by the upload action
        "cloudinary://upload/#{key}"
      end
    end

    def headers_for_direct_upload(key, content_type:, content_length:, checksum:, custom_metadata: {})
      {}
    end

    private

    def cloudinary_url(key)
      Cloudinary::Utils.cloudinary_url("#{@folder}/#{key}", resource_type: :auto, secure: true)
    end
  end
end