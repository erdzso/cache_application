# frozen_string_literal: true

# :nodoc:
class SearchWrapper
  # :nodoc:
  class Movie < SearchWrapper
    def image_path_key
      'poster_path'
    end

    def primary_name_key
      'title'
    end

    def special_attribute_keys
      %w[
        title
        overview
        original_title
        original_language
        popularity
        release_date
        vote_average
        vote_count
      ]
    end
  end
end
