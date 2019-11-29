# frozen_string_literal: true

# A class representing an assignment. This class has many offers and belongs to
# applicant and position.
class Assignment < ApplicationRecord
    has_many :offers
    belongs_to :applicant
    belongs_to :position
    has_many :wage_chunks



    after_update :reset_active_offer

    def active_offer
        active_offer_id ? Offer.find(active_offer_id) : nil
    end

    def offer_params
        return if active_offer.present?

        session = position.session
        # FIXME: Refactor this out?
        applicant_data = applicant.applicant_data_for_matchings
                                  .joins(:application)
                                  .find_by(applications: { session: session })
        start_date = position.est_start_date
        end_date = position.est_end_date
        installments = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
        offer_template = session.position_templates.find_by(position_type: position.position_type)&.offer_template
        {
            email: applicant.email,
            first_name: applicant.first_name,
            last_name: applicant.last_name,
            first_time_ta: applicant_data.previous_uoft_ta_experience,
            installments: installments,
            instructor_contact_desc: instructor_contact_desc,
            nag_count: 0,
            offer_override_pdf: offer_override_pdf,
            offer_template: offer_template,
            pay_period_desc: pay_period_desc,
            position_code: position.position_code,
            position_end_date: end_date,
            position_start_date: start_date,
            position_title: position.position_title,
            assignment: self
        }
    end

    private

    def reset_active_offer
        # update_column skips callbacks
        update_column(:active_offer_id, nil)
    end

    # FIXME: This should be a decorator...
    def instructor_contact_desc
        contact_info = position.instructors.map do |instructor|
            "#{instructor.first_name.capitalize} #{instructor.last_name.capitalize}: #{instructor.email}"
        end
        contact_info.join(', ')
    end

    # FIXME: This should be a decorator...
    def pay_period_desc
        pay_period_info = wage_chunks.map do |wage_chunk|
            "#{wage_chunk.hours} hours at #{wage_chunk.rate} per hour"
        end
        pay_period_info.join(', ')
    end
end

# == Schema Information
#
# Table name: assignments
#
#  id                 :bigint(8)        not null, primary key
#  contract_end       :datetime
#  contract_start     :datetime
#  note               :text
#  offer_override_pdf :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  active_offer_id    :bigint(8)
#  applicant_id       :bigint(8)
#  position_id        :bigint(8)
#
# Indexes
#
#  index_assignments_on_active_offer_id               (active_offer_id)
#  index_assignments_on_applicant_id                  (applicant_id)
#  index_assignments_on_position_id                   (position_id)
#  index_assignments_on_position_id_and_applicant_id  (position_id,applicant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (active_offer_id => offers.id)
#
