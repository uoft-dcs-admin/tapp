# frozen_string_literal: true

class InstructorPosition < ApplicationRecord
    self.table_name = 'instructors_positions'

    belongs_to :instructor
    belongs_to :position

    validates :is_subscribed, inclusion: { in: [true, false] }
end
