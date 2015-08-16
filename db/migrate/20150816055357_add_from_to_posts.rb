class AddFromToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :sender, :string
  end
end
