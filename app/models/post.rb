class Post < ActiveRecord::Base
	belongs_to :user

	def deliver
		self.recipients.each do |recipient|
			UserMailer.user_post(recipient, self.sender, self.subject, self.body).deliver
		end
		self.destroy
	end
end
