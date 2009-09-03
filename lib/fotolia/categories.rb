module Fotolia
  #
  # Base class for ConceptualCategories and RepresentativeCategories.
  #
  class Categories
    #
    # == Parameters
    # fotolia_client:: A Fotolia::Base object
    #
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    #
    # Returns an array of Category objects. If no category is given, fetches
    # the root level category. Otherwise the child categories of the given cat
    # are returned.
    #
    # Raises a RuntimeError if not called on a ConceptualCategories or
    # RepresentativeCategories object, i. e. <tt>@method</tt> and
    # <tt>@klass</tt> has to be set.
    #
    def find(category = nil)
      raise 'You have to use ConceptualCategories or RepresentativeCategories!' unless(@method && @klass)

      k = if(category) then category.id else :root end

      if(@categories && @categories[k]) # check if categories have been loaded already
        @categories[k] # use cached categories
      else
        # get cats from fotolia
        res = if(category && (category.kind_of?(String) || category.kind_of?(Fixnum)))
          @fotolia.remote_call(@method, @fotolia.language.id, category.to_i)
        elsif(category)
          @fotolia.remote_call(@method, @fotolia.language.id, category.id.to_i)
        else
          @fotolia.remote_call(@method, @fotolia.language.id)
        end

        @categories = Hash.new unless(@categories)

        @categories[k] = res.collect{|c| @klass.new(@fotolia, {'key' => c.first, 'parent_category' => category}.merge(c.last))}
      end
    end

    #
    # Returns an array of all root level Category objects. See #find.
    #
    def root_level
      self.find
    end
  end
end