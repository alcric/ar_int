module ApplicationHelper
  def full_title(page_title)
    base_title = "Always Resolve"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def h1_title(page_title)
    base_title = "Always Resolve"
    if page_title.empty?
      base_title
    else
      page_title
    end
  end

end
