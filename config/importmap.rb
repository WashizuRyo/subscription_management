# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "jquery" # @3.7.1
pin "jquery_ujs"
pin "bootstrap", to: "bootstrap.min.js"
pin "@popperjs/core", to: "popper.js"
pin "payment_method", to: "payment_method.js"
pin "tag", to: "tag.js"
pin "subscription_filter", to: "subscription_filter.js"
