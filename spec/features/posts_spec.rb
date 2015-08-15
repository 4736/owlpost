require 'rails_helper'

RSpec.describe "Posts", type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  it "Creates a post on the users request." do
    login_as(user, :scope => :user)
    visit posts_path
    click_link "Schedule A Post"
    current_path.should eq(new_post_path)
    fill_in "post_eta", :with => "2012-07-12 8:30:14"
    fill_in "post_recipients", :with => user.email
    fill_in "post_subject", :with => "Test Post, Please Ignore."
    fill_in "post_body", :with => "This is a test Post."
    click_button "Create Post"
    current_path.should eq(posts_path)
    user.posts.count.should eq(1)
  end

  it "Deletes a post on the users request." do
    post = user.posts.create(eta: 1.month.from_now, recipients: Faker::Internet.email, subject: "Test Post, Please Ignore.", body: "This is a test Post.")
    user.posts.count.should eq(1)
    login_as(user, :scope => :user)
    visit "/posts/#{post.id}/edit"
    click_link "Destroy"
    current_path.should eq(posts_path)
    user.posts.count.should eq(0)
  end

  it "Edits a post on the users request." do
    post = user.posts.create(eta: 1.month.from_now, recipients: Faker::Internet.email, subject: "Test Post, Please Ignore.", body: "This is a test Post.")
    user.posts.count.should eq(1)
    login_as(user, :scope => :user)
    visit "/posts/#{post.id}/edit"
    fill_in "post_body", :with => "wubalubadubdub"
    click_button "Update Post"
    current_path.should eq(posts_path)
    visit "/posts/#{post.id}/edit"
    find_field("post_body").value.should eq("wubalubadubdub")
  end

  it "Does not allow a user to view posts not owned by the user." do
    not_us = FactoryGirl.create(:user)
    foreign_post = not_us.posts.create(eta: 1.month.from_now, recipients: Faker::Internet.email, subject: "Test Post, Please Ignore.", body: "This is a test Post.")

    login_as(user, :scope => :user)
    visit post_path(foreign_post)
    current_path.should eq(posts_path)
    page.should have_selector ".alert", text: "Record not found."
  end
end
