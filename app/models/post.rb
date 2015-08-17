class Post < ActiveRecord::Base
	belongs_to :user
	validate :valid_datetime, :valid_recipients
	validates :sender, presence: { message: "Post sender is required." }
	validates :subject, presence: { message: "Post subject is required." }
	validates :body, presence: { message: "Post body is required." }

	private

	def valid_datetime
		self.eta = self.eta? ? self.eta.to_datetime : errors.add(:eta, "Must be a valid DateTime.")
	end

	def valid_recipients
		if self.recipients.count == 0
			errors.add(:recipients, "Post recipient is required.")
		end

		self.recipients.each do |recipient|
			if recipient =~ /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
				result = Net::HTTP.get(URI.parse("http://api.quickemailverification.com/v1/verify?email=#{recipient}&apikey=#{ENV['QUICK_EMAIL_VERIFICATION_KEY']}"))

				if JSON.parse(result)["result"] != "valid"
					errors.add(:recipients, "#{recipient} is not a valid email.")
				end
			else
				errors.add(:recipients, "#{recipient} is not a valid email.")
			end
		end
	end

	def deliver
		self.recipients.each do |recipient|
			UserMailer.user_post(recipient, self.sender, self.subject, self.body).deliver
		end
		self.destroy
	end
end
