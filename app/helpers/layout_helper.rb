# some useful functions for views
module LayoutHelper

  # Joins all avaiable locales
  # @param [String] concatinator
  # @return [String] joined locale String
  # @yield [Symbol] locale
  def join_all_locales concatinator, &block
    if block_given?
      I18n.available_locales.map { |locale|
        yield(locale)
      }.join(concatinator).html_safe
    else
      I18n.available_locales.map(&:to_s).join(concatinator).html_safe
    end
  end

  # @param [Symbol|String] symbol - the twitter-bootstrap icon-class(es)
  # @return [String] html-safe string representing twitter-bootstrap-code for the icon
  def icon symbol
    "<i class='#{symbol.to_s}'></i>".html_safe
  end

  # @param [Symbol|String] symbol - the twitter-bootstrap icon-class(es)
  # @param [String] text - the text to be displayed after the icon
  # @return [String] html-safe string representing twitter-bootstrap-code for the icon
  def icon_with_text symbol, text
    [icon(symbol),text].join("&nbsp;").html_safe
  end

  # Insert a delete-button with data-confirm
  # @param [String] path
  # @param [String] what - %what Are you sure?
  # @return [String] html
  def delete_link_tag path, what=''
    link_to icon_with_text('icon-trash icon-white', t(:delete)),
      path,
      method: :delete,
      data: { confirm: t(:are_you_sure, what: what) },
      class: 'btn btn-danger'
  end

  # Inserts a mailto-button
  # @param [String] _label link label
  # @param [String] _email email address
  # @return [String] html
  def mail_link_to _label, _email
    link_to icon_with_text('icon-envelope', _label), "mailto:#{_email}"
  end

  # Insert a 'green' button with a +-sign
  # @param [String] label
  # @param [String] path
  # @return [String] html-link
  def new_button_tag label, path
    link_to icon_with_text('icon-plus-sign icon-white',label),
      path,
      class: 'btn btn-success'
  end

  # Insert a 'default' button with a list-sign
  # @param [String] label
  # @param [String] path
  # @return [String] html-link
  def list_button_tag label, path
    link_to icon_with_text('icon-list',label),
      path,
      class: 'btn btn-default'
  end

  # Insert a 'primary' button with an edit-icon
  # @param [String] label
  # @param [String] path
  # @return [String] html-link
  def edit_button_tag label, path
    link_to icon_with_text('icon-edit icon-white',label),
      path,
      class: 'btn btn-primary'
  end

  # Insert a 'default' button with a cancel-sign
  # @param [String] label
  # @param [String] path
  # @return [String] html-link
  def cancel_button_tag label, path, classes="btn btn-default"
    link_to icon_with_text('icon-remove',label), path, class: classes
  end

  # @return [String] html-button
  # NOTE: This method is thought to insert a <i class='ok'></i> infront
  # of the label. But since simple_form.button uses this string in
  # value='...' it will not be rendered through html.
  # TODO: Find a way to prefix with an icon
  def deliver_button label
    label
  end

  # @param [Symbol] locale
  # @return [String] html-link
  def switch_to_locale_path_link locale
    link_to t(locale.to_sym), set_locale_path(locale)
  end

  # Returns active css class when given current url
  # @param [Uri] _path the url
  # @return [String] 'active' if path is current.
  def active_class _path
    current_page?(_path)  ? 'active' : ''
  end

  # @return [String] css-classes for standard forms
  def standard_form_classes
    'form form-vertical'
  end

  # @return [String] css-classes for standard save-buttons
  def save_button_classes
   'btn btn-primary'
  end

  # Returns a String reresenting the Models created_at and updated_at timestamp information
  # @example
  #   model_date_information(User.first) # => "Created at: ... , Updated at: ..."
  # @param [Class] _model the model instance
  # @return [String] create_at and updated_at concatinated
  def model_date_information _model
    c,m = _model.created_at, _model.updated_at
    _str = t(:created_at, time: c.to_s(:short))
    _str << ", " << t(:updated_at, time: m.to_s(:short)) unless c == m
  end

  # insert a right-floating admin-menu box
  # @return [String] html div-tags
  def right_admin_box &block
    content_tag :div, class: "admin-menu pull-right pad-left"  do
      content_tag :div, class: "well gap-left inline"  do
        content_tag :span  do
          "Admin: ".html_safe +
          content_tag(:div, class: "btn-group") do
            yield
          end
        end
      end
    end
  end

end
