class ChangeDurationTypeOnMemes < ActiveRecord::Migration[6.1]
  def up
    change_column :memes, :duration, :float
  end
  def down
    change_column :memes, :duration, :integer
  end
end