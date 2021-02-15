class CreateMemes < ActiveRecord::Migration[6.1]
  def change
    create_table :memes do |t|
      t.string :name
      t.string :source_url
      t.string :start
      t.string :end
      t.boolean :private
      t.integer :duration
      t.float :loudness_i
      t.float :loudness_lra
      t.float :loudness_tp
      t.float :loudness_thresh

      t.timestamps
    end
  end
end
