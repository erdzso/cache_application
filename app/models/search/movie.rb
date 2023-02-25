# frozen_string_literal: true

# == Schema Information
#
# Table name: searches
#
#  id         :bigint           not null, primary key
#  type       :string(255)      not null
#  query      :string(255)      not null
#  page       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Search
  # :nodoc:
  class Movie < Search
    #
    ### CLASS METHODS

    class << self
      def wrapper_class
        SearchWrapper::Movie
      end
    end

    #
    ### INSTANCE METHODS

    def client
      MoviesClient.new(:Movie, query:, page:)
    end
  end
end
