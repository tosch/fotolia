module Fotolia
  class SearchResultSet
    class Pages
      include Enumerable

      def initialize(fotolia_client, options, pages, result_set)
        @fotolia = fotolia_client
        @options = options
        @pages = pages
        @result_sets = Array.new
        @result_sets[result_set.page - 1] = result_set
      end

      def [] (n)
        @result_sets[n] ||= Fotolia::SearchResultSet.new(@fotolia, @options.merge({:page => (n + 1)}), self)
      end

      def each
        (0...@pages).each do |i|
          yield @result_sets[i] ||= Fotolia::SearchResultSet.new(@fotolia, @options.merge({:page => (i + 1)}), self)
        end
        self
      end

      def length
        @pages
      end

      alias :count :length
      
    end

    attr_reader :page, :pages, :per_page, :total

    def initialize(fotolia_client, options, pages_obj = nil)
      @fotolia = fotolia_client
      @options = options
      @pages = pages_obj if(pages_obj.kind_of?(Pages))
      search
    end

    def previous_page
      return nil unless(@media)
      self.pages[@page - 2] if(@page > 1)
    end

    def next_page
      return nil unless(@media)
      self.pages[@page + 2] if(@page < @total)
    end

    def method_missing(method, *args, &block)
      @media.respond_to?(method) ? @media.send(method, *args, &block) : super
    end

    protected

    def search
      #
      # Other arguments (besides language_id and api_key) accepted by Fotolia API:
      #
      # *Argument*     | *Type* | *Element (array)*         | *Valid Values*     | *Default* | *Details*
      # ===============|========|===========================|====================|===========|=================================================================================================
      # words          | string |                           | list of words      | none      | keyword search. Words can also be media_id using # to search for some media ( ex : #20 #21 #22)
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # creator_id     | int    |                           | valid creator id   | none      | Search by creator
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # cat1_id        | int    |                           | valid category1 id | none      | Search by representative category. Get valid categories1 ids width getCategories1
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # cat2_id        | int    |                           | valid category2 id | none      | Search by conceptual category. Get valid valid category2 id's width getCategories2
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # gallery_id     | int    |                           | valid gallery id   | none      | Search by gallery. Get valid galleries id's with getGalleries
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # color_name     | string |                           | valid color name   | none      | Search by color. Get valid color names with getColors
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # country_id     | int    |                           | valid country id   | none      | Search by country. Get valid country id's with getCountries
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # media_id       | int    |                           | existing media id  | none      | Search by media id
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # model_id       | int    |                           | existing media id  | none      | Search by same model
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # serie_id       | int    |                           | existing media id  | none      | Search by same serie
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # similia_id     | int    |                           | existing media id  | none      | Search by similar media (similia)
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # filters        | array  | content_type:photo        | 0 - 1              | 0         | Search for photos
      #                |        | content_type:illustration | 0 - 1              | 0         | Search for illustration (jpg)
      #                |        | content_type:vector       | 0 - 1              | 0         | Search for illustration (svg)
      #                |        | content_type:all          | 0 - 1              | 1         | Search for all (default)
      #                |        | offensive:2               | 0 - 1              | 0         | Explicit/Charm/Nudity/Violence excluded
      #                |        | isolated:on               | 0 - 1              | 0         | Isolated contents
      #                |        | panoramic:on              | 0 - 1              | 0         | Panoramic images
      #                |        | license_L:on              | 0 - 1              | 0         | L size available
      #                |        | license_XL:on             | 0 - 1              | 0         | XL size available
      #                |        | license_XXL:on            | 0 - 1              | 0         | XXL size available
      #                |        | license_X:on              | 0 - 1              | 0         | Extended licence availble
      #                |        | licence_E:on              | 0 - 1              | 0         | Exclusive buy out available
      #                |        | orientation               | horizontal         | all       | only horizontal image
      #                |        |                           | vertical           |           | only vertical image
      #                |        |                           | all                |           | all images (default)
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # order          | string |                           | relevance          | relevance | Relevance
      #                |        |                           | price_1            |           | price ASC
      #                |        |                           | creation           |           | creation date DESC
      #                |        |                           | nb_views           |           | number of views DESC
      #                |        |                           | nb_downloads       |           | number of downloads DESC
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # limit          | int    |                           | 1 to 64            | 32        | maximum number of media returned
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # offset         | int    |                           | 0 to max results   | 0         | Start position in query
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # thumbnail_size | int    |                           | 30                 | 110       | Small (30px)
      #                |        |                           | 110                |           | Medium (110px)
      #                |        |                           | 400                |           | Large (400px - watermarked)
      # ---------------+--------+---------------------------+--------------------+-----------+-------------------------------------------------------------------------------------------------
      # detail_level   | int    |                           | 1                  | none      | When this parameter is sent and set to 1, the method will return for each content :
      #                |        |                           |                    |           | * nb_downloads
      #                |        |                           |                    |           | * nb_views
      #                |        |                           |                    |           | * keywords (comma separated string, depends on the language_id)

      @options = {
        :per_page => 50,
        :page => 1,
        :detailed_results => true,
        :language => @fotolia.language,
        :content_types => [:all],
        :only_licenses => []
      }.merge(@options)

      remote_opts = Hash.new

      remote_opts['language_id'] = @options[:language].id
      remote_opts['words'] = @options[:words] if(@options[:words])
      remote_opts['creator_id'] = @options[:creator_id] if(@options[:creator_id])
      remote_opts['cat1_id'] = @options[:representative_category].id if(@options[:representative_category].kind_of?(Fotolia::Category))
      remote_opts['cat2_id'] = @options[:conceptual_category].id if(@options[:conceptual_category].kind_of?(Fotolia::Category))
      remote_opts['gallery_id'] = @options[:gallery].id if(@options[:gallery].kind_of?(Fotolia::Galery))
      remote_opts['color_name'] = @options[:color].name if(@options[:color].kind_of?(Fotolia::Color))
      remote_opts['country_id'] = @options[:country].id if(@options[:country].kind_of?(Fotolia::Country))
      remote_opts['media_id'] = @options[:media_id] if(@options[:media_id])
      remote_opts['model_id'] = @options[:model_id] if(@options[:model_id])
      remote_opts['serie_id'] = @options[:serie_id] if(@options[:serie_id])
      remote_opts['similia_id'] = @options[:similia_id] if(@options[:similia_id])
      remote_opts['filters'] = {
        'content_type:photo' => @options[:content_types].include?(:photo) ? 1 : 0,
        'content_type:illustration' => @options[:content_types].include?(:illustration) ? 1 : 0,
        'content_type:vector' => @options[:content_types].include?(:vector) ? 1 : 0,
        'content_type:all' => @options[:content_types].include?(:all) ? 1 : 0,
        'offensive:2' => @options[:offensive] ? 1 : 0,
        'isolated:on' => @options[:isolated] ? 1 : 0,
        'panoramic:on' => @options[:panoramic] ? 1 : 0,
        'license_L:on' => @options[:only_licenses].include?('L') ? 1 : 0,
        'license_XL:on' => @options[:only_licenses].include?('XL') ? 1 : 0,
        'license_XXL:on' => @options[:only_licenses].include?('XXL') ? 1 : 0,
        'license_X:on' => @options[:only_licenses].include?('X') ? 1 : 0,
        'license_E:on' => @options[:only_licenses].include?('E') ? 1 : 0,
        'orientation' => @options[:orientation] || 'all'
      }
      remote_opts['order'] = @options[:order] if(@options[:order])
      remote_opts['limit'] = @options[:per_page]
      remote_opts['offset'] = ((@options[:page] - 1) * @options[:per_page]) + 1
      remote_opts['thumbnail_size'] = @options[:thumbnail_size] if(@options[:thumbnail_size])
      remote_opts['detail_level'] = 1 if(@options[:detailed_results])

      parse_results(@fotolia.remote_call('getSearchResults', remote_opts))
    end

    def parse_results(api_response)
      @page = @options[:page]
      @per_page = @options[:per_page]

      @total = api_response['nb_results']

      @media = Array.new

      api_response.each{|k, v| @media << Fotolia::Medium.new(@fotolia, v) unless(k == 'nb_results')}

      @pages = Pages.new(@fotolia, @options, (@total.to_f / @per_page.to_f).ceil, self) unless(@pages)

      self
    end
  end
end