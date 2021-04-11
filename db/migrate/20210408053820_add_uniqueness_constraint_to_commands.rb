class AddUniquenessConstraintToCommands < ActiveRecord::Migration[6.1]
  def change
    add_index(:commands, [:name], unique: true)
  end
end
