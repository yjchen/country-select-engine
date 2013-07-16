class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :currency
      t.string :country
      t.string :language
      t.string :timezone

      t.timestamps
    end
  end
end
