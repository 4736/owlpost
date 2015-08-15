require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "user_post" do
    mail = UserMailer.user_post
    assert_equal "User post", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
