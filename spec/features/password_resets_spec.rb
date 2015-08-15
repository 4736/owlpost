require 'rails_helper'

RSpec.describe "PasswordResets", type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  it "Sends user password reset email upon request." do
    visit new_user_session_path
    click_link "Forgot your password?"
    fill_in "Email", :with => user.email
    click_button "Send me reset password instructions"
    current_path.should eq(new_user_session_path)
    page.should have_content("You will receive an email with instructions on how to reset your password in a few minutes.")
    ActionMailer::Base.deliveries.last.to[0].should include(user.email)
  end
end
