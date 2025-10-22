# spec/requests/routes_hygiene_spec.rb
require "rails_helper"

RSpec.describe "Route hygiene", type: :request do
  it "has no write routes outside /admin" do
    offenders = Rails.application.routes.routes.filter_map do |r|
      verb_src = r.verb.respond_to?(:source) ? r.verb.source : r.verb.to_s
      path     = r.path.spec.to_s

      next if path.start_with?("/admin", "/rails", "/users")
      next unless verb_src.match?(/\b(POST|PUT|PATCH|DELETE)\b/)

      ctrl = r.defaults[:controller].to_s
      act  = r.defaults[:action].to_s
      "#{verb_src}\t#{path}\t#{ctrl}##{act}"
    end

    expect(offenders).to be_empty, "\n#{offenders.join("\n")}"
  end

  it "limits public Payments::ACH to index/show" do
    post payments_ach_routings_path
    expect(response).to have_http_status(:not_found)

    get payments_ach_routings_path
    expect(response).to have_http_status(:ok)
  end

  it "limits public System to index/show" do
    post system_reference_lists_path
    expect(response).to have_http_status(:not_found)
  end
end
