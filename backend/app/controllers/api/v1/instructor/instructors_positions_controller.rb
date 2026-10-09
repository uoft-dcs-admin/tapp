# frozen_string_literal: true

class Api::V1::Instructor::InstructorsPositionsController < ApplicationController
    before_action :find_instructor
    before_action :find_instructor_position, only: %i[update]

    # GET /sessions/:session_id/instructors_positions
    def index
        render_success([]) && return unless @active_instructor

        render_success @active_instructor.instructor_positions
                                         .joins(:position)
                                         .where(positions: { session_id: params[:session_id] })
    end

    # PATCH /instructors_positions/:id
    def update
        render_on_condition(
            object: @instructor_position,
            condition: proc do
                @instructor_position.update!(instructor_position_params)
            end
        )
    end

    private

    def find_instructor
        active_user = ActiveUserService.active_user request
        @active_instructor = Instructor.find_by(utorid: active_user.utorid)
    end

    def find_instructor_position
        unless @active_instructor
            render_error(message: 'Not an instructor') && return
        end

        @instructor_position = @active_instructor.instructor_positions.find(params[:id])
    end

    def instructor_position_params
        params.permit(:id, :is_subscribed)
    end
end
