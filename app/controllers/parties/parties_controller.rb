# app/controllers/parties/parties_controller.rb
module Parties
  class PartiesController < ApplicationController
    before_action :set_party, only: %i[show edit update]

    def index
      @parties = policy_scope(Parties::Party)
                   .includes(:names, :individual, :organization)
                   .order(created_at: :desc)
                   .limit(100)
    end

    def show
      authorize @party
    end

    def new
      @party = Parties::Party.new
      authorize @party
      @party.names.build(preferred: true, name_type_code: "preferred_display") if @party.names.empty?
      build_defaults_for(@party, person: true)
    end

    def create
      person = params.dig(:party, :profile_kind) == "person"
      @party = Parties::Party.new
      authorize @party

      person ? @party.build_individual : @party.build_organization
      @party.assign_attributes(party_params(person))

      ActiveRecord::Base.transaction do
        @party.save!
        if (pref = @party.names.detect(&:preferred?))
          @party.update!(preferred_party_name_id: pref.id)
        end
      end

      redirect_to @party, notice: "Profile created."
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      @party.build_individual   unless @party.individual   || !person
      @party.build_organization unless @party.organization ||  person
      @party.names.build(preferred: true, name_type_code: "preferred_display") if @party.names.empty?
      render :new, status: :unprocessable_entity
    end

    def edit
      authorize @party
      @party.names.build(preferred: true, name_type_code: "preferred_display") if @party.names.empty?
      @party.build_individual unless @party.individual || @party.organization
    end

    def update
      authorize @party

      # Prefer submitted value; otherwise use the record’s current subtype
      person = if params.dig(:party, :profile_kind).present?
                params[:party][:profile_kind] == "person"
      else
                @party.person?
      end

      # ensure exactly one subtype present for validations
      person ? (@party.build_individual unless @party.individual) :
              (@party.build_organization unless @party.organization)

      if @party.update(party_params(person))
        if (pref = @party.names.detect(&:preferred?))
          @party.update_column(:preferred_party_name_id, pref.id)
        end
        redirect_to @party, notice: "Profile updated."
      else
        flash.now[:alert] = @party.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_party
      @party = Parties::Party.find_by!(public_id: params[:id])
    end

    def build_defaults_for(party, person:)
      party.names.build(preferred: true, name_type_code: "preferred_display") if party.names.empty?
      person ? party.build_individual : party.build_organization
    end

    def party_params(person)
      base = %i[relationship_to_institution_code withholding_option_code profile_kind]
      names = {
        names_attributes: %i[
          id name_type_code full_name
          family_name given_name middle_name
          prefix_code suffix_code
          preferred valid_from valid_to
        ]
      }

      if person
        params.require(:party)
              .permit(*base, names,
                individual_attributes: %i[
                  residence_country birth_date gender_code marital_status_code
                  immigration_status_code education_level_code home_ownership_code
                  race_code employment_type_code occupation_code
                ])
      else
        params.require(:party)
              .permit(*base, names,
                organization_attributes: %i[
                  residence_country established_on organization_type_code
                  system_naics_code_id tax_exempt_code naics_code
                ])
      end
    end
  end
end
