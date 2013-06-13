class SetupSimpleMedals < ActiveRecord::Migration
  def change
    create_table :user_medals do |t|
      t.integer :user_id
      t.string :medal_name

      t.timestamps
    end
  end
end
