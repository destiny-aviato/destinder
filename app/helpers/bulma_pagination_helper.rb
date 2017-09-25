module BulmaPaginationHelper
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag(:nav, tag(:ul, html, class: 'pagination-list'), class: 'pagination is-centered')
    end

    def previous_or_next_page(page, text, _classname)
      if page
        tag(:li, link(text, page, class: 'pagination-link'))
      else
        tag(:li, tag(:a, text, class: 'pagination-link'), class: 'is-disabled')
      end
    end

    def page_number(page)
      if page == current_page
        tag(:li, tag(:a, page, class: 'pagination-link is-current'))
      else
        tag(:li, link(page, page, class: 'pagination-link'))
      end
    end

    def gap
      tag(:li, tag(:span, '&hellip;', class: 'pagination-ellipsis'))
    end
  end

  def bulma_will_paginate(collection = nil, options = {})
    if collection.is_a? Hash
      options = collection
      collection = nil
    end
    options = options.merge(
      renderer: BulmaPaginationHelper::LinkRenderer
    )
    will_paginate(collection, options)
  end
end
