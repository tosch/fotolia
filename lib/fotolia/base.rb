module Fotolia
  def self.new(*params)
    Fotolia::Base.new(*params)
  end

  class CommunicationError < StandardError; end
  class ApiKeyRequiredError < StandardError; end

  class Base
    DEFAULT_API_URI = 'http://api.fotolia.com/Xmlrpc/rpc'
    DEFAULT_LANGUAGE = :en_us

    attr_reader :api_key
    attr_reader :language
    attr_reader :api_uri

    def initialize(options = {})
      @api_key = options[:api_key]
      @language = options[:language] || Fotolia::Language.new(DEFAULT_LANGUAGE)
      @api_uri = options[:api_uri] || DEFAULT_API_URI

      raise ApiKeyRequiredError unless(@api_key)
    end

    def colors
      @colors ||= Fotolia::Colors.new(self)
    end

    def conceptual_categories
      @conceptual_categories ||= Fotolia::ConceptualCategories.new(self)
    end

    def representative_categories
      @representative_categories ||= Fotolia::RepresentativeCategories.new(self)
    end

    def countries
      @countries ||= Fotolia::Countries.new(self)
    end

    def galleries
      @galleries ||= Fotolia::Galeries.new(self)
    end
    
    def tags
      @tags ||= Fotolia::Tags.new(self)
    end

    #
    # Searches for media in Fotolia's DB.
    #
    # ==options hash
    # :language <Fotolia::Language>:: Return results in this language. Defaults to language set in Fotolia::Base#new.
    # :per_page <Fixnum>:: Number of results per page. Defaults to 50. Fotolia API limits this to values from 1 to 64.
    # :page <Fixnum>:: Page to show. Defaults to 1.
    # :detailed_results <Boolean>:: Whether to fetch keywords, number of views and downloads of the media in the result set. Defaults to true.
    # :content_types <Array>:: Limit search to certain content types. Valid values are :photo, :illustration, :vector and :all. These types may be mixed together.
    # :only_licenses <Array>:: Only return media offering the listed licenses. Valid values may be 'L', 'XL', 'XXL', 'X' and 'E'. Values may be mixed, but unsure if Fotolia API combines them by AND or OR.
    # :words <String>:: Keyword search. Words can also be media_id using # to search for some media ( ex : #20 #21 #22)
    # :creator_id <Fixnum>:: Search by creator.
    # :representative_category <Fotolia::RepresentativeCategory>:: Search by representative category.
    # :conceptual_category <Fotolia::ConceptualCategory>:: Search by conceptual category.
    # :gallery <Fotolia::Galery>:: Search by gallery.
    # :color <Fotolia::Color>:: Search by color.
    # :country <Fotolia::Country>:: Search by country.
    # :media_id <Fixnum>:: Search by media id -- fetch a medium by its known media id.
    # :model_id <Fixnum>:: Search by same model. Value must be a valid media id.
    # :serie_id <Fixnum>:: Search by same serie. Value must be a valid media id.
    # :similia_id <Fixnum>:: Search similar media. Value must be a valid media id.
    # :offensive <Boolean>:: Include Explicit/Charm/Nudity/Violence media. Defaults to false.
    # :panoramic <Boolean>:: Only fetch panoramic media. Defaults to false.
    # :isolated <Boolean>:: Only fetch isolated media. Defaults to false.
    # :orientation <String>:: Only fetch media in given orientation. Valid values are 'horizontal', 'vertical' and 'all'. Defaults to the latter.
    # :order <String>:: Order the result set. Valid values are 'relevance', 'price_1', 'creation', 'nb_views' and 'nb_downloads'. Defaults to 'relevance'.
    # :thumbnail_size <Fixnum>:: The size of the thumbnail images included in the result set. Valid values are 30, 110 and 400. Defaults to 110. Thumbs in 400px size are watermarked by Fotolia.
    #
    def search(options)
      Fotolia::SearchResultSet.new(self, options)
    end

    def remote_call(method, *args)
      begin
        client = XMLRPC::Client.new2(@api_uri)
        client.call('xmlrpc.' + method.to_s, @api_key, *args)
      rescue XMLRPC::FaultException => e
        raise Fotolia::CommunicationError, e.message
      end
    end
  end
end
