module ApplicationHelper
  def title_helper(page_title=nil)
    base_title = "Gem of True Sight"

    if page_title.present?
      [page_title, base_title].join(" | ")
    else
      base_title
    end
  end
end
