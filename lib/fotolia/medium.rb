module Fotolia
  class Medium
    class Thumbnail
      attr_reader :url, :html_tag, :width, :height

      def initialize(attributes)
        @url = attributes['thumbnail_url']
        @html_tag = attributes['thumbnail_html_tag']
        @width = attributes['thumbnail_width']
        @height = attributes['thumbnail_height']
      end
    end

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
    
    MEDIA_TYPES = {1 => :photo, 2 => :illustration, 3 => :vector}

    attr_reader :id
    attr_reader :thumbnail
    attr_reader :licenses
    attr_reader :fotolia

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

    def comp_image
      @comp_image ||= CompImage.find(self)
    end

    def details
      @details ||= @fotolia.remote_call('getMediaData', self.id, 400, @fotolia.language.id)
    end

    def nb_views
      @nb_views ||= self.details['nb_views']
    end

    def nb_downloads
      @nb_downloads ||= self.details['nb_downloads']
    end

    def keywords
      unless(@keywords)
        @keywords = []
        @keywords = self.details['keywords'].collect{|k| k['name']} if(self.details['keywords'])
      end
      @keywords
    end

    def country
      @country ||= Fotolia::Country.new({'id' => self.details['country_id'], 'name' => self.details['country_name']})
    end

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

    def media_type_id
      @media_type_id ||= self.details['media_type_id']
    end

    def media_type
      MEDIA_TYPES[self.media_type_id] || :unknown
    end

    def title
      @title ||= self.details['title']
    end

    def creator_id
      @creator_id ||= self.details['creator_id']
    end

    def creator_name
      @creator_name ||= self.details['creator_name']
    end

    def licenses
      @licenses ||= self.details['licenses'].collect{|l| License.new(self, l)}
    end

    def thumbnail
      @thumbnail ||= Thumbnail.new(self.details)
    end

    def is_photo?
      :photo == self.media_type
    end

    def is_illustration?
      :illustration == self.media_type
    end

    def is_vector?
      :vector == self.media_type
    end

    def similar_media(options = {})
      @fotolia.search(options.merge({:similia_id => self.id}))
    end

    # TODO:: implement function
    #
    # Does not work in Partner and Developer API.
    #
    def buy_and_save_as(license, file_path)
    end

    #
    # Adds this medium to the logged in user's lightbox or one of his galleries.
    #
    # Requires an authenticated session. Call Fotolia::Base#login first!
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
