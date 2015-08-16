class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.user_post.subject
  #
  def user_post(to, from, subject, body)
    @body = body

    mail to: to, from: from, subject: subject
  end
end
