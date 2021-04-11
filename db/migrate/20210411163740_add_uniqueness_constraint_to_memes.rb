class AddUniquenessConstraintToMemes < ActiveRecord::Migration[6.1]
  def change
    add_index(:memes, [:name], unique: true)
  end
end
