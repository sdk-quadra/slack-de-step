# frozen_string_literal: true

class ContactsController < ApplicationController
  skip_before_action :check_logged_in
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.contact_mail(@contact).deliver
      redirect_to new_contact_path, flash: { commit_contact: "送信しました" }
    else
      render action: "new"
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:email, :message)
    end
end
