module ViewHelper
  def css_file_names
    [
      'flash.css'
    ]
  end

  def stylesheets
    tags = []
    create_tag_in_tags_array = proc do |filename, media|
      tags << "<link rel='stylesheet' media=\"#{media if media}\" href=\"/stylesheets/#{filename}\">"
    end

    css_file_names.each(&create_tag_in_tags_array)

    tags.join
  end

  def unordered_list_errors(object)
    ul = "<ul>"
    object.errors.each do |attribute, error|
      li = '<li>' + attribute.to_s + ' ' + error.to_s + '</li>'
      ul << li
    end

    ul << '</ul>'
  end
end
