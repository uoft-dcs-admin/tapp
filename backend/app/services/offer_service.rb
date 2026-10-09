# frozen_string_literal: true

class OfferService
    attr_reader :offer

    def initialize(offer: nil, position: nil)
        @offer = offer
        @position = position
    end

    # return a summary of offer activity for the position within the specified time period,
    # specifically the names of applicants that received a new offer, had their offer withdrawn,
    # or either accepted or rejected their offer
    def activity_summary(
        lookback: 24.hours,
        since_time: nil,
        to_time: Time.zone.now
    )
        since_time ||= to_time - lookback
        offers =
            Offer.joins(:assignment)
                .where(assignments: { position_id: @position.id })
                .includes(assignment: :applicant)
                .order(:id)
        activity_range = since_time..to_time

        {
            new_offers:
                applicant_names(offers.where(created_at: activity_range)),
            accepted_offers:
                applicant_names(offers.where(accepted_date: activity_range)),
            rejected_offers:
                applicant_names(offers.where(rejected_date: activity_range)),
            withdrawn_offers:
                applicant_names(offers.where(withdrawn_date: activity_range))
        }
    end

    # generate subsitutions needed for the email templates
    def subs
        {
            first_name: @offer.first_name,
            last_name: @offer.last_name,
            # It is possible that the email from when the offer was created is stale,
            # so send the offer to the applicant's current email.
            email: @offer.assignment.applicant.email,
            session_name: @offer.assignment.position.session.name,
            position_code: @offer.position_code,
            hours: @offer.hours,
            position_title: @offer.position_title,
            ta_coordinator_email: @offer.ta_coordinator_email,
            rejected_date: @offer.rejected_date&.strftime('%B %d, %Y'),
            # TODO:  This seems too hard-coded.  Is there another way to get the route?
            # Note, we are using the `/hash` route proxying (instead of `#` hash)
            # to avoid issues with Shibboleth authentication
            # See details in routes.rb
            url:
                "#{Rails.application.config.base_url}/hash/external/contracts/#{
                    @offer.url_token
                }",
            nag_count: @offer.nag_count,
            status_message: status_message,
            changes_summary: changes_from_previous
        }
    end

    # Get the differences between this offer and the immediately preceeding
    # offer (in terms of creation_date). If no prior offer exists, nil
    # is returned.
    def changes_from_previous
        previous =
            Offer.where(assignment_id: @offer.assignment_id).where(
                'created_at < ?',
                @offer.created_at
            ).order(withdrawn_date: :desc).first
        return nil if previous.nil?

        ret = []
        if @offer.hours != previous.hours
            ret.push "The hours have changed from #{previous.hours} to #{
                         @offer.hours
                     }"
        end
        if @offer.position_start_date != previous.position_start_date
            ret.push "The position start date has changed from #{
                         previous.position_start_date
                     } to #{@offer.position_start_date}"
        end
        if @offer.position_end_date != previous.position_end_date
            ret.push "The position end date has changed from #{
                         previous.position_end_date
                     } to #{@offer.position_end_date}"
        end

        ret
    end

    private

    def applicant_names(offers)
        offers.each_with_object([]) do |offer, names|
            applicant = offer.assignment.applicant
            names << "#{applicant.first_name} #{applicant.last_name}".strip
        end
    end

    def status_message
        case @offer.status.to_sym
        when :withdrawn
            'Withdrawn'
        when :accepted
            "Accepted on #{@offer.accepted_date.strftime('%b %d, %Y')}"
        when :rejected
            "Rejected on #{@offer.rejected_date.strftime('%b %d, %Y')}"
        end
    end
end
