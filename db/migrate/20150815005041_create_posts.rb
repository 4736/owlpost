class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
    	t.integer  :user_id, null: false

    	t.datetime :eta
    	t.text		 :recipients, array: true, default: []
    	t.string   :subject
    	t.text   	 :body

    	t.timestamps
    end
  end
end
