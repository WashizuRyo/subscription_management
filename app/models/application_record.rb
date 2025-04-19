class ApplicationRecord < ActiveRecord::Base
  ALLOWED_COLUMNS = %w[subscription_name price start_date end_date billing_date]
  primary_abstract_class
end
