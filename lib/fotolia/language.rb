module Fotolia
  class LanguageNotDefinedError < StandardError; end
  class Language

    LANGUAGE_IDS = {
      :fr => 1,
      :en_us => 2,
      :en_uk => 3,
      :de => 4,
      :es => 5,
      :it => 6,
      :pt_pt => 7,
      :pt_br => 8,
      :jp => 9,
      :pl => 11
    }

    def initialize(id_or_lang_sym)
      if(id_or_lang_sym.is_a?(Symbol))
        raise Fotolia::LanguageNotDefinedError and return nil unless(LANGUAGE_IDS.has_key?(id_or_lang_sym))
        @language_sym = id_or_lang_sym
      else
        raise Fotolia::LanguageNotDefinedError and return nil unless(LANGUAGE_IDS.has_value?(id_or_lang_sym))
        @language_sym = LANGUAGE_IDS.invert[id_or_lang_sym]
      end

      self
    end

    def to_s
      @language_sym.to_s
    end
    
    alias to_code to_s

    def to_sym
      @language_sym
    end

    def id
      LANGUAGE_IDS[@language_sym]
    end
  end
end
