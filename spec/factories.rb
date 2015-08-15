FactoryGirl.define do
	factory :user do |f|
		f.email {Faker::Internet.email}
		f.password "super_secure_password"
	end
end