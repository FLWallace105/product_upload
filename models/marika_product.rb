class MarikaProduct < ActiveRecord::Base
  enum status: { not_updated: 0, updated: 1, skipped: 2 }
end
