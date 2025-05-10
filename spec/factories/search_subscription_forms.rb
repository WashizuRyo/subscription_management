FactoryBot.define do
  factory :search_subscription_form do
    filter_column { "" }
    text_filter_value { "" }
    text_filter_pattern { "" }
    date_filter_start { nil }
    date_filter_end { nil }
    date_filter_pattern { "" }
    first_column { "" }
    first_direction { "" }
    second_column { "" }
    second_direction { "" }
    page { "" }

    transient do
      current_user { nil }
    end

    initialize_with {
      new(attributes, current_user: current_user)
    }
  end
end
