# spec/policies/party_policy_spec.rb
require "rails_helper"

RSpec.describe Parties::PartyPolicy do
  let(:user)   { create(:user, :system_admin) }     # persists role/perm
  let(:record) { Parties::Party.new }
  subject(:policy) { described_class.new(user, record) }

  it { expect(user.system_admin?).to be true }      # guard
  it { expect(policy).to permit_action(:show) }
  end

  def show?
  Rails.logger.debug("PPOL admin?=#{admin?} user=#{user.inspect}")
  admin?
  end
