module Fotolia
  #
  # See Fotolia::Base#new.
  #
  def self.new(*params)
    Fotolia::Base.new(*params)
  end

  class CommunicationError < StandardError; end
  class ApiKeyRequiredError < StandardError; end
  class UserLoginError < StandardError; end
  class LoginRequiredError < StandardError; end

  class Base
    DEFAULT_API_URI = 'http://api.fotolia.com/Xmlrpc/rpc'
    DEFAULT_LANGUAGE = :en_us

    attr_reader :api_key
    attr_reader :language
    attr_reader :api_uri
    attr_reader :session_id
    attr_reader :logged_in_user

    #
    # ==options hash
    # :api_key <String>:: Your Fotolia API key (an exception is raised if not included)
    # :language <Fotolia::Language>:: The language the client should submit to the API if applicable. Defaults to Fotolia::Language.new(DEFAULT_LANGUAGE).
    # :api_uri <String>:: The URI of the Fotolia API. Defaults to DEFAULT_API_URI.
    #
    def initialize(options = {})
      @api_key = options[:api_key]
      @language = options[:language] || Fotolia::Language.new(DEFAULT_LANGUAGE)
      @api_uri = options[:api_uri] || DEFAULT_API_URI
      @xmlrpc_client = XMLRPC::Client.new2(@api_uri)

      raise ApiKeyRequiredError unless(@api_key)
    end

    #
    # Returns a Fotolia::Colors object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.colors.find_all
    #
    def colors
      @colors ||= Fotolia::Colors.new(self)
    end

    #
    # Returns a Fotolia::ConceptualCategories object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.conceptual_categories.find
    #
    def conceptual_categories
      @conceptual_categories ||= Fotolia::ConceptualCategories.new(self)
    end

    #
    # Returns a Fotolia::RepresentativeCategories object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.representative_categories.find
    #
    def representative_categories
      @representative_categories ||= Fotolia::RepresentativeCategories.new(self)
    end

    #
    # Returns a Fotolia::Countries object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.countries.find_all
    #
    def countries
      @countries ||= Fotolia::Countries.new(self)
    end

    #
    # Returns a Fotolia::Galleries object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.galleries.find_all
    #
    def galleries
      @galleries ||= Fotolia::Galleries.new(self)
    end

    #
    # Returns a Fotolia::Tags object.
    #
    # ==Example
    # f = Fotolia.new(:api_key => YOUR_API_KEY)
    # f.tags.most_used
    # f.tags.most_searched
    #
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
    # ==returns
    # Fotolia::SearchResultSet
    #
    def search(options)
      Fotolia::SearchResultSet.new(self, options)
    end

    #
    # Start an user authenticated session which is needed for some functions,
    # especially user related ones.
    #
    # Won't work in Fotolia's Partner API! Business and Reseller API are limited
    # to login the user the API key belongs to. Only Developer API allows login
    # of all users.
    #
    def login(login, pass)
      @logged_in_user = Fotolia::User.new(self, login, pass)
      res = self.remote_call('loginUser', login, pass)
      raise UserLoginError unless(res['session_id'])
      @session_id = res['session_id']
    end

    #
    # Ends an user authenticated session.
    #
    def logout
      return false unless self.logged_in?
      self.remote_call('logoutUser', self.session_id)
      @session_id = nil
      @logged_in_user = nil
      true
    end

    #
    # Returns true if there is a valid user authenticated session.
    #
    def logged_in?
      !@session_id.nil?
    end

    # 
    # The number of media objects in Fotolia's DB.
    #
    def count_media
      general_data['nb_media']
    end

    #
    # Does an API call and returns the response. Useful if you like to call
    # methods not implemented by this library.
    #
    def remote_call(method, *args)
      begin
        @xmlrpc_client.call('xmlrpc.' + method.to_s, @api_key, *args)
      rescue XMLRPC::FaultException => e
        raise Fotolia::CommunicationError, e.message
      end
    end

    def inspect #:nodoc:
      "#<#{self.class} api_key=#{@api_key.inspect} language=#{@language.inspect} session_id=#{@session_id.inspect} logged_in_user=#{@logged_in_user.inspect}>"
    end

    protected

    def general_data
      @general_data ||= self.remote_call('getData')
    end
  end
end
