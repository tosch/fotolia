module Fotolia
  #
  # Represents a Fotolia user.
  #
  # Won't yield sensible results in Partner API as the user methods are not
  # available there. Note that Reseller and Business API are limited to the user
  # the API key belongs to.
  #
  class User
    attr_reader :login, :password

    def initialize(fotolia_client, login, password)
      @fotolia = fotolia_client
      @login = login
      @password = password
    end

    #
    # reloads the statistical data when requested next time
    #
    def reload_data
      @user_data = nil
      @user_stats = nil
    end

    #
    # the user's id
    #
    def id
      self.user_data['id']
    end

    #
    # the user's language
    #
    # returns a Fotolia::Language object
    #
    def language
      Fotolia::Language.new(self.user_data['language_id'])
    end

    #
    # the user's credits
    #
    def credits
      user_data['nb_credits']
    end

    #
    # how much is one of the user's credits worth?
    #
    def credit_value
      user_data['credit_value']
    end

    #
    # the name of the currency #credit_value is in
    #
    def currency_name
      user_data['currency_name']
    end

    #
    # the symbol of the currency #credit_value is in
    #
    def currency_symbol
      user_data['currency_symbol']
    end

    #
    # number of uploaded media
    #
    def count_media_uploaded
      user_stats['nb_media_uploaded']
    end

    #
    # number of accepted media
    #
    def count_media_accepted
      user_stats['nb_media_accepted']
    end

    #
    # number of purchased media
    #
    def count_media_purchased
      user_stats['nb_media_purchased']
    end

    #
    # number of sold media
    #
    def count_media_sold
      user_stats['nb_media_sold']
    end

    #
    # absolute ranking ( top sellers ever)
    #
    def absolute_ranking
      user_stats['ranking_absolute']
    end

    #
    # relative ranking ( top seller in 7 days)
    #
    def relative_ranking
      user_stats['ranking_relative']
    end

    #
    # See http://services.fotolia.com/Services/API/Method/getUserAdvancedStats
    #
    # ==Parameters
    # time_range:: Group results by :day, :week, :month, :quarter or :year
    # date_period:: The period for which the value shall be returned. Is optional. May be one of :all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week, :one_month or an array of two Time objects: The first is taken as starting date, the latter as end.
    #
    def count_member_viewed_photos(time_range = :day, date_period = nil)
      advanced_user_stats('member_viewed_photos', time_range, date_period)
    end

    #
    # See http://services.fotolia.com/Services/API/Method/getUserAdvancedStats
    #
    # ==Parameters
    # time_range:: Group results by :day, :week, :month, :quarter or :year
    # date_period:: The period for which the value shall be returned. Is optional. May be one of :all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week, :one_month or an array of two Time objects: The first is taken as starting date, the latter as end.
    #
    def count_member_downloaded_photos(time_range = :day, date_period = nil)
      advanced_user_stats('member_downloaded_photos', time_range, date_period)
    end

    #
    # See http://services.fotolia.com/Services/API/Method/getUserAdvancedStats
    #
    # ==Parameters
    # time_range:: Group results by :day, :week, :month, :quarter or :year
    # date_period:: The period for which the value shall be returned. Is optional. May be one of :all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week, :one_month or an array of two Time objects: The first is taken as starting date, the latter as end.
    #
    def count_member_bought_photos(time_range = :day, date_period = nil)
      advanced_user_stats('member_bought_photos', time_range, date_period)
    end

    #
    # See http://services.fotolia.com/Services/API/Method/getUserAdvancedStats
    #
    # ==Parameters
    # time_range:: Group results by :day, :week, :month, :quarter or :year
    # date_period:: The period for which the value shall be returned. Is optional. May be one of :all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week, :one_month or an array of two Time objects: The first is taken as starting date, the latter as end.
    #
    def count_member_earned_credits(time_range = :day, date_period = nil)
      advanced_user_stats('member_earned_credits', time_range, date_period)
    end

    #
    # Returns an array of galleries the user has created.
    #
    def galleries
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?

      res = @fotolia.remote_call('getUserGalleries', @fotolia.session_id)

      res.collect{|g| Fotolia::Gallery.new(@fotolia, g)}
    end

    protected

    def user_data #:nodoc:
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?
      @user_data ||= @fotolia.remote_call('getUserData', @fotolia.session_id)
    end

    def user_stats #:nodoc:
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?
      @user_stats ||= @fotolia.remote_call('getUserStats', @fotolia.session_id)
    end

    def advanced_user_stats(type, time_range = :year, date_period = nil) #:nodoc:
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?
      raise ArgumentError, 'time_range has to be one of :day, :week, :month, :quarter or :year' unless([:day, :week, :month, :quarter, :year].include?(time_range))

      res = if(date_period.kind_of?(Symbol))
        raise ArgumentError, 'only :all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week or :one_month are allowed as symbols in date_period' unless([:all, :today, :yesterday, :one_day, :two_days, :three_days, :one_week, :one_month].include?(date_period))
        @fotolia.remote_call('getUserAdvancedStats', @fotolia.session_id, type, time_range.to_s, date_period.to_s)
      elsif(date_period.kind_of?(Array))
        raise ArgumentError, 'Array elements have to be Time objects in date_period' unless(date_period[0] && date_period[1] && date_period[0].respond_to?(:strftime) && date_period[1].respond_to?(:strftime))
        @fotolia.remote_call('getUserAdvancedStats', @fotolia.session_id, type, {'start_date' => date_period[0].strftime('%Y-%m-%d'), 'end_date' => date_period[1].strftime('%Y-%m-%d')})
      elsif(date_period.nil?)
        @fotolia.remote_call('getUserAdvancedStats', @fotolia.session_id, type, time_range.to_s)
      else
        raise ArgumentError, 'date_period has to be either Symbol, Array or nil'
      end

      # TODO:: parse response

    end

  end
end