class ChangeStringsToText < ActiveRecord::Migration[8.1]
  def change
    change_column :messages, :content, :text
    change_column :results, :roadmap, :text
  end
end
