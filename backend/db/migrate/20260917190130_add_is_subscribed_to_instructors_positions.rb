class AddIsSubscribedToInstructorsPositions < ActiveRecord::Migration[6.1]
    def change
        add_column :instructors_positions, :is_subscribed, :boolean, default: false, null: false
    end
end
