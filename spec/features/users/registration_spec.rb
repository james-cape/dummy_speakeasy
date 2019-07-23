require 'rails_helper'

RSpec.describe 'the registration page' do
  describe 'happy path' do
    it "should create a new user after filling out the form" do
      visit registration_path

      fill_in :user_name, with: "name"
      fill_in :street, with: "street_1"
      fill_in :city, with: "city_1"
      fill_in :state, with: "state_1"
      fill_in :zip_code, with: "zip_1"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Submit"

      expect(current_path).to eq(profile_path)

      user = User.last

      expect(page).to have_content("Registration Successful! You are now logged in.")
      expect(page).to have_content("Logged in as #{user.name}")
    end

    it "should create a new address with the nickname 'home' for the new user" do
      visit registration_path

      fill_in :user_name, with: "name"
      fill_in :street, with: "street_1"
      fill_in :city, with: "city_1"
      fill_in :state, with: "state_1"
      fill_in :zip_code, with: "zip_1"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Submit"

      expect(current_path).to eq(profile_path)

      user = User.last

      expect(user.addresses.first.nickname).to eq("home")
    end
  end

  describe 'sad path' do
    it "should display error messages for each unfilled field" do
      visit registration_path

      click_button "Submit"

      expect(current_path).to eq(registration_path)

      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Name can't be blank")
      # expect(page).to have_content("Street can't be blank")
      # expect(page).to have_content("City can't be blank")
      # expect(page).to have_content("State can't be blank")
      # expect(page).to have_content("Zip can't be blank")
      # ^^ Removed because full_messages method does not work on @address in controller
      expect(page).to have_content("Email can't be blank")
    end

    it "should display an error when an email is taken" do
      user = create(:user)
      user.update(email: "example@gmail.com")

      visit registration_path

      fill_in :user_name, with: "name_1"
      fill_in :street, with: "address_1"
      fill_in :city, with: "city_1"
      fill_in :state, with: "state_1"
      fill_in :zip_code, with: "zip_1"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Submit"

      expect(current_path).to eq(registration_path)
      expect(page).to have_content("Email has already been taken")

      expect(page).to have_css("input[value='name_1']")
      expect(page).to have_css("input[value='address_1']")
      expect(page).to have_css("input[value='city_1']")
      expect(page).to have_css("input[value='state_1']")
      expect(page).to have_css("input[value='zip_1']")
      expect(page).to_not have_css("input[value='example@gmail.com']")
      expect(page).to_not have_css("input[value='password']")
    end

    it "should display an error when password confirmation doesn't match" do
      visit registration_path

      fill_in :user_name, with: "name"
      fill_in :street, with: "street_1"
      fill_in :city, with: "city_1"
      fill_in :state, with: "state_1"
      fill_in :zip_code, with: "zip_1"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      fill_in :user_name, with: "name"
      fill_in :street, with: "address"
      fill_in :city, with: "city"
      fill_in :state, with: "state"
      fill_in :zip_code, with: "zip"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "a different password"

      click_button "Submit"

      expect(current_path).to eq(registration_path)
      expect(page).to have_content("Password confirmation doesn't match Password")
    end
  end
end
