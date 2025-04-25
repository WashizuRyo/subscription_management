FactoryBot.define do
  factory :search_subscription_form do
    search_column { "" }
    search_value { "" }
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
