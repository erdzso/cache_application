# frozen_string_literal: true

# :nodoc:
class SearchWrapper
  autoload :Movie, 'search_wrapper/movie'

  def initialize(raw_data)
    @raw_data = raw_data
  end

  class << self
    def human_attribute_name(attribute)
      translation = I18n.t("search_wrapper.attributes.#{name.underscore}.#{attribute}")
      if translation.match(/translation missing:/) && superclass.respond_to?(:human_attribute_name)
        translation = superclass.human_attribute_name(attribute)
      end
      translation
    end

    def human_model_name
      I18n.t("search_wrapper.models.#{name.underscore}.one")
    end
  end

  def id
    "#{send(:class).name.split('::').last.downcase}#{send(:[], 'id')}"
  end

  def image_path
    send(:[], image_path_key)
  end

  def image_url
    image_path ? "https://image.tmdb.org/t/p/w500#{image_path}" : nil
  end

  def primary_name
    send(:[], primary_name_key)
  end

  def [](key)
    @raw_data[key]
  end

  def human_attribute_name(attribute)
    send(:class).human_attribute_name(attribute)
  end

  def human_model_name
    send(:class).human_model_name
  end
end
