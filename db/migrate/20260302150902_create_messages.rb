class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.string :content
      t.string :role

      t.timestamps
    end
  end
end

