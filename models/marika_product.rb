require './modules/fam_product'

class MarikaProduct < ActiveRecord::Base
  extend FamProduct

  enum status: { not_updated: 0, updated: 1, skipped: 2 }
end
