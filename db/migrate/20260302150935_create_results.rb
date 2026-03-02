class CreateResults < ActiveRecord::Migration[8.1]
  def change
    create_table :results do |t|
      t.string :roadmap

      t.timestamps
    end
  end
end
