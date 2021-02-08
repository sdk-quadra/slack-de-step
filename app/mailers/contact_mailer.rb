# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact_mail(contact)
    @contact = contact
    mail to: ENV["GMAIL_USERNAME"], from: "slackdestep@example.com", subject: "Slack De Stepへのお問い合わせ"
  end
end
