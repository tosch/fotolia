module Fotolia
  #
  # See Fotolia::Base#new.
  #
  def self.new(*params)
    Fotolia::Base.new(*params)
  end

  #
  # This error is raised if Fotolia's Api returns an error
  #
  class CommunicationError < StandardError; end

  #
  # Raised if no api key is given to the initializer
  #
  class ApiKeyRequiredError < StandardError; end

  #
  # Raised if an user login via Fotolia's API fails
  #
  class UserLoginError < StandardError; end

  #
  # Raised if a function is called which requires a user login
  #
  class LoginRequiredError < StandardError; end

  #
  # == Example Usage
  #
  # 0. Require the lib:
  #    <tt>require 'fotolia'</tt>
  #
  # 1. Get a new instance of the base class:
  #    <tt>fotolia = Fotolia::Base.new :api_key => 'AAAAA'</tt>
  #
  #    Note: You may also use the shortcut <tt>Fotolia.new</tt>.
  #
  # 2. Search for some media:
  #    <tt>search_results = fotolia.search :words => 'nitpick'</tt>
  #
  #    +search_result+ now contains an array of Fotolia media containing the
  #    word 'nitpick' somewhere. Note that the array won't have more than 50
  #    items per default as Fotolia limits the number of media returned (the max
  #    is 64). However, the array is extended in some ways as it is not a plain
  #    Array object, but a SearchResultSet instead. So you can call
  #    <tt>search_results.total</tt> to get the total number of all results or
  #    <tt>search_results.next_page</tt> to get the next set of results. See
  #    SearchResultSet for more information.
  #
  #    Each medium is represented by the class Fotolia::Medium, so check its
  #    documentation for further info.
  #
  # 3. Get all representative categories in root level (Fotolia has two types of
  #    categories, representative and conceptual ones. Each root category may
  #    have children and grand-children):
  #    <tt>r_cats = fotolia.representative_categories</tt>
  #
  #    This gives you an array of all root-level representative categories. You
  #    may get the children of the first cat by calling
  #    <tt>r_cats.first.children</tt>
  #
  #    You can fetch a category's media by calling
  #    <tt>r_cats.first.media</tt>
  #    Note that this method takes the same options hash as parameter as
  #    Base#search.
  #
  # 4. You may change the language used in all returns of Fotolia's API. Default
  #    is <tt>:en_us</tt>. Also available are <tt>:en_uk</tt>, <tt>:fr</tt>,
  #    <tt>:de</tt>, <tt>:es</tt>, <tt>:it</tt>, <tt>:pt_pt</tt>,
  #    <tt>:pt_br</tt>, <tt>:jp</tt> and <tt>:pl</tt>. To use one of them, pass
  #    the initializer of Base an Fotolia::Language instance:
  #
  #    <tt>fotolia = Fotolia.new :api_key => 'A...', :language => Fotolia::Language.new(:de)</tt>
  #
  #    Category names, tags and some other items will be returned in German now.
  #    If it's not translated, it's Fotolia's fault, not this gem's ;-)
  #
  # 5. Get a Fotolia medium by its ID
  #
  #    You may use the :media_id option of Base#search, but calling
  #
  #    <tt>medium = Fotolia::Medium.new fotolia, :id => 12334567</tt>
  #
  #    is just more intuitive. The class will try to fetch all missing data from
  #    Fotolia. You should catch CommunicationErrors when using any medium
  #    object generated this way as an of those will be raised if the given
  #    media id is unknown to Fotolia.
  #
  # 6. Login a user and get its galleries and add a medium to the first.
  #
  #   <tt>fotolia.login 'username', 'password'</tt>
  #   <tt>galleries = fotolia.logged_in_user.galleries</tt>
  #   <tt>medium = Fotolia::Medium.new fotolia, :id => 12345678</tt>
  #   <tt>medium.add_to_user_gallery galleries.first</tt>
  #   <tt>fotolia.logout</tt>
  #
  #
  class Base
    DEFAULT_API_URI = 'http://api.fotolia.com/Xmlrpc/rpc'
    DEFAULT_LANGUAGE = :en_us

    # <String> The API key the client is set to.
    attr_reader :api_key
    # <Fotolia::Language> The language for all requests which return i18n'd results.
    attr_reader :language
    # <String> The URI of the API.
    attr_reader :api_uri
    # <mixed> A string containing the user session id or nil if any.
    attr_reader :session_id
    # <mixed> A Fotolia::User object if there is a user session or nil.
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

    def general_data #:nodoc:
      @general_data ||= self.remote_call('getData')
    end
  end
end
