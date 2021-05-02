class CreateMemeTags < ActiveRecord::Migration[6.1]
  def change
    create_table :meme_tags do |t|
      t.references :meme, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
