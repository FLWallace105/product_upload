module RouteHelper
  def csv_flash(result)
    "#{result[:updated]} products updated and
    #{result[:not_updated]} did not update.
    #{result[:handles_not_found].empty? ? nil : "Handles not found: #{result[:handles_not_found].to_sentence}"}
    #{result[:products_not_updated].empty? ? nil : "Products not updated: #{result[:products_not_updated].to_sentence}"}"
  end
end
