# frozen_string_literal: true

# :nodoc:
module SearchesHelper
  def error_alert(error)
    content_tag(:div, error, class: %w[alert alert-danger])
  end

  def api_calling_alert(hit_count)
    source = hit_count.zero? ? t('views.searches.an_api_request') : t('views.searches.cache', hit_count:)
    content_tag(:div, t('views.searches.results_were_provided_from', source:), class: %w[alert alert-primary])
  end

  def list(raw_data_collection, wrapper_class)
    raw_data_collection.each_slice(4).inject(''.html_safe) do |result, raw_data_slice|
      result + row(raw_data_slice, wrapper_class) + content_tag(:br)
    end
  end

  def row(raw_data_collection, wrapper_class)
    content_tag(:div, nil, class: 'row') do
      raw_data_collection.inject(''.html_safe) do |result, raw_data|
        result + card(wrapper_class.new(raw_data))
      end
    end
  end

  def card(instance)
    content_tag(:div, nil, class: %w[col col-3]) do
      content_tag(:div, nil, class: 'card') do
        image(instance.image_url) +
          content_tag(:div, nil, class: 'card-body') do
            content_tag(:h5, instance.primary_name, class: 'card-title') +
              modal_button_with_modal(instance)
          end
      end
    end
  end

  def image(url)
    if url
      content_tag(:img, nil, src: url, class: 'card-img-top')
    else
      content_tag(:svg, nil, xmlns: 'http://www.w3.org/2000/svg', role: 'img') do
        content_tag(:rect, nil, width: '100%', height: '100%', fill: '#868e96') +
          content_tag(:text, nil, x: '50%', y: '50%', fill: '#dee2e6', 'text-anchor': 'middle') do
            t('views.searches.unavailable')
          end
      end
    end
  end

  def modal_button_with_modal(instance)
    modal_button(instance) + modal(instance)
  end

  def modal_button(instance)
    options = {
      class: %w[btn btn-primary],
      href: '#',
      data: {
        bs_toggle: 'modal',
        bs_target: "##{instance.id}Modal"
      }
    }
    content_tag(:a, t('views.searches.more_info'), options)
  end

  def modal(instance)
    content_tag(:div, nil, class: %w[modal fade], id: "#{instance.id}Modal", tabindex: -1) do
      content_tag(:div, nil, class: 'modal-dialog') do
        content_tag(:div, nil, class: 'modal-content') do
          modal_header(instance) + modal_body(instance)
        end
      end
    end
  end

  def modal_header(instance)
    content_tag(:div, nil, class: 'modal-header') do
      content_tag(:h5, "#{instance.primary_name} (#{instance.human_model_name})", class: 'modal-title') +
        content_tag(:button, nil, class: 'btn-close', data: { bs_dismiss: 'modal', aria_label: 'Close' })
    end
  end

  def modal_body(instance)
    content_tag(:div, nil, class: 'modal-body') do
      details(instance)
    end
  end

  def details(instance)
    content_tag(:table, nil, class: 'table') do
      content_tag(:tbody) do
        instance.special_attribute_keys.inject(''.html_safe) do |result, attribute_name|
          result + content_tag(:tr) do
            content_tag(:th, instance.human_attribute_name(attribute_name), scope: 'row') +
              content_tag(:td, instance[attribute_name])
          end
        end
      end
    end
  end
end
