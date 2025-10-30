require "rails_helper"

RSpec.describe PartiesTaxIdsController, type: :routing do
  include Devise::Test::IntegrationHelpers
  let(:user) { create(:user, :system_admin) }
  before { sign_in user }


  describe "routing" do
    it "routes to #index" do
      expect(get: "/parties_tax_ids").to route_to("parties_tax_ids#index")
    end

    it "routes to #new" do
      expect(get: "/parties_tax_ids/new").to route_to("parties_tax_ids#new")
    end

    it "routes to #show" do
      expect(get: "/parties_tax_ids/1").to route_to("parties_tax_ids#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/parties_tax_ids/1/edit").to route_to("parties_tax_ids#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/parties_tax_ids").to route_to("parties_tax_ids#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/parties_tax_ids/1").to route_to("parties_tax_ids#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/parties_tax_ids/1").to route_to("parties_tax_ids#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/parties_tax_ids/1").to route_to("parties_tax_ids#destroy", id: "1")
    end
  end
end
