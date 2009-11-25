module Fotolia
  #
  # Represents a medium in Fotolia's database.
  #
  class Medium
    #
    # A thumbnail attached to a Medium object. Just holds its url, width, height
    # and an html tag to include it on web pages.
    #
    class Thumbnail
      attr_reader :url, :html_tag, :width, :height

      def initialize(attributes)
        @url = attributes['thumbnail_url']
        @html_tag = attributes['thumbnail_html_tag']
        @width = attributes['thumbnail_width']
        @height = attributes['thumbnail_height']
      end
    end

    #
    # Represents a license in which Fotolia's media are available.
    #
    # See http://www.fotolia.com/Info/SizesAndUses for an overview of available
    # licenses.
    #
    class License
      attr_reader :name, :price

      def initialize(medium, attributes)
        @medium = medium
        @name = attributes['name']
        @price = attributes['price']
      end

      def width
        begin
          @width ||= @medium.details['licenses_details'][self.name]['width']
        rescue
          nil
        end
      end

      def height
        begin
          @height ||= @medium.details['licenses_details'][self.name]['height']
        rescue
          nil
        end
      end

      def dpi
        begin
          @dpi ||= @medium.details['licenses_details'][self.name]['dpi']
        rescue
          nil
        end
      end

      def ratio
        begin
          @ratio ||= @medium.details['licenses_details'][self.name]['ratio']
        rescue
          nil
        end
      end

      def phrase
        begin
          @phrase ||= @medium.details['licenses_details'][self.name]['phrase']
        rescue
          nil
        end
      end
    end

    #
    # I never got to know what a CompImage should be, least Fotolia's API has a
    # method to get one for a medium. So this is a class holding the info that
    # method returns.
    #
    class CompImage
      attr_reader :url, :width, :height

      def initialize(attributes)
        @url = attributes['url']
        @width = attributes['width']
        @height = attributes['height']
      end

      def self.find(medium)
        CompImage.new(medium.fotolia.remote_call('getMediaComp', medium.id))
      end
    end

    #
    # Fotolia has media in three types: Photo, illustration and vector. In the
    # API they are referenced by ids, so we keep this hash to ease the handling
    # for human developers...
    #
    MEDIA_TYPES = {1 => :photo, 2 => :illustration, 3 => :vector}

    # The id of the medium in Fotolia's DB.
    attr_reader :id
    #
    # The thumbnail attached to the medium. Note that its size may vary
    # according to the :thumbnail_size option you give at Base#search.
    #
    attr_reader :thumbnail
    # An array of Licenses the medium is available in.
    attr_reader :licenses
    attr_reader :fotolia #:nodoc:

    #
    # Needs an instance of Fotolia::Base (so you won't have to give the API_KEY
    # each time you call a method which requires interaction with the API) and
    # some attributes as parameters.
    #
    #   Fotolia::Medium.new Fotolia.new(:api_key => 'AAA...'), :id => 12345678
    #
    # should be enough to get a valid object -- missing values will be collected
    # from the API automatically (with an default size of 400px for the
    # thumbnail).
    #
    def initialize(fotolia_client, attributes)
      @fotolia = fotolia_client
      @id = attributes['id'].to_i
      @title = attributes['title'] if(attributes['title'])
      @creator_id = attributes['creator_id'] if(attributes['creator_id'])
      @creator_name = attributes['creator_name'] if(attributes['creator_name'])
      @thumbnail = Thumbnail.new(attributes) if(attributes['thumbnail_url'])
      @nb_views = attributes['nb_views'] if(attributes['nb_views'])
      @nb_downloads = attributes['nb_downloads'] if(attributes['nb_downloads'])
      @keywords = attributes['keywords'].split(',').collect{|k| k.strip} if(attributes['keywords'])
      @licenses = attributes['licenses'].collect{|l| License.new(self, l)} if(attributes['licenses'])
    end

    #
    # See Fotolia::Medium::CompImage
    #
    def comp_image
      @comp_image ||= CompImage.find(self)
    end

    def details #:nodoc:
      @details ||= @fotolia.remote_call('getMediaData', self.id, 400, @fotolia.language.id)
    end

    #
    # Returns the number of times this medium has been viewed on Fotolia's page.
    #
    def nb_views
      @nb_views ||= self.details['nb_views']
    end

    #
    # Returns the number of times this medium has been purchased at Fotolia.
    #
    def nb_downloads
      @nb_downloads ||= self.details['nb_downloads']
    end

    #
    # Returns an array of keywords attached to this medium. May be translated to
    # the language the client has been set to, but don't rely on it.
    #
    def keywords
      unless(@keywords)
        @keywords = []
        @keywords = self.details['keywords'].collect{|k| k['name']} if(self.details['keywords'])
      end
      @keywords
    end

    #
    # Returns the Fotolia::Country object associated with this medium.
    #
    def country
      @country ||= Fotolia::Country.new({'id' => self.details['country_id'], 'name' => self.details['country_name']})
    end

    #
    # Returns the Fotolia::ConceptualCategory object this medium is in.
    #
    # If the medium is in a child or grand-child category of the root level, the
    # parent relations will be set properly. Call
    # <tt>medium.conceptual_category.parent_category</tt> to use this feature.
    #
    def conceptual_category
      #@conceptual_category ||= (self.details['cat2'] ? Fotolia::ConceptualCategory.new(@fotolia, self.details['cat2']) : nil)
      unless(@conceptual_category)
        @conceptual_category = if(self.details['cat2_hierarchy'])
          cats = Array.new
          self.details['cat2_hierarchy'].each_with_index do |cat, i|
            parent = if(i > 0 && cats[i - 1]) then cats[i - 1] else nil end
            cats[i] = Fotolia::ConceptualCategory.new(@fotolia, {'parent_category' => parent}.merge(cat))
          end
          cats.last
        else
          nil
        end
      end
      @conceptual_category
    end

    #
    # Same as Fotolia::Medium#conceptual_category, but returns the associated
    # Fotolia::RepresentativeCategory instead.
    #
    def representative_category
      #@representative_category ||= (self.details['cat1'] ? Fotolia::RepresentativeCategory.new(@fotolia, self.details['cat1']) : nil)
      unless(@representative_category)
        @representative_category = if(self.details['cat1_hierarchy'])
          cats = Array.new
          self.details['cat1_hierarchy'].each_with_index do |cat, i|
            parent = if(i > 0 && cats[i - 1]) then cats[i - 1] else nil end
            cats[i] = Fotolia::RepresentativeCategory.new(@fotolia, {'parent_category' => parent}.merge(cat))
          end
          cats.last
        else
          nil
        end
      end
      @representative_category
    end

    #
    # Returns the media type id used by Fotolia's API. See MEDIA_TYPES and
    # #media_type
    #
    def media_type_id
      @media_type_id ||= self.details['media_type_id']
    end

    #
    # Returns the media type of this medium as symbol. May be one of :photo,
    # :illustration, :vector or -- in desperate cases -- :unknown.
    #
    def media_type
      MEDIA_TYPES[self.media_type_id] || :unknown
    end

    # No need for explanation, isn't there?
    def title
      @title ||= self.details['title']
    end

    # The id of the medium's creator. May be used to find more media by the same
    # creator.
    def creator_id
      @creator_id ||= self.details['creator_id']
    end

    # The name of the creator.
    def creator_name
      @creator_name ||= self.details['creator_name']
    end

    #
    # An array of licenses the medium is available in. See
    # Fotolia::Medium::License.
    #
    def licenses
      @licenses ||= self.details['licenses'].collect{|l| License.new(self, l)}
    end

    #
    # A thumbnail for this medium. See Fotolia::Medium::Thumbnail.
    #
    def thumbnail
      @thumbnail ||= Thumbnail.new(self.details)
    end

    # Returns true if this medium is a photo.
    def is_photo?
      :photo == self.media_type
    end

    # Returns true if this medium is an illustration.
    def is_illustration?
      :illustration == self.media_type
    end

    # Returns true if this medium is a vector image.
    def is_vector?
      :vector == self.media_type
    end

    #
    # Searches for similar media to this medium.
    #
    # Note that this method takes the same options hash as Fotolia::Base#search.
    #
    def similar_media(options = {})
      @fotolia.search(options.merge({:similia_id => self.id}))
    end

    # TODO:: implement function
    #
    # Does not work in Partner and Developer API.
    #
    def buy_and_save_as(license, file_path) #:nodoc:
    end

    #
    # Adds this medium to the logged in user's lightbox or one of his galleries.
    #
    # Requires an authenticated session. Call Fotolia::Base#login on the fotolia
    # client object used to get this medium object first!
    #
    # ==Parameters
    # gallery:: A Fotolia::Gallery object or nil. If the latter, the user's lightbox is used.
    #
    # Does not work in Partner API.
    #
    def add_to_user_gallery(gallery = nil)
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?

      if(gallery)
        # add to gallery
        @fotolia.remote_call('addToUserGallery', @fotolia.session_id, self.id, gallery.id)
      else
        # add to lightbox
        @fotolia.remote_call('addToUserGallery', @fotolia.session_id, self.id)
      end
    end

    #
    # Removes this medium from the logged in user's gallery or lightbox.
    #
    # Requires an authenticated session. Call Fotolia::Base#login first!
    #
    # ==Parameters
    # gallery:: A Fotolia::Gallery object or nil. If the latter, the user's lightbox is used.
    #
    # Does not work in Partner API.
    #
    def remove_from_user_gallery(gallery = nil)
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?

      if(gallery)
        @fotolia.remote_call('removeFromUserGallery', @fotolia.session_id, self.id, gallery.id)
      else
        @fotolia.remote_call('removeFromUserGallery', @fotolia.session_id, self.id)
      end
    end
  end
end
