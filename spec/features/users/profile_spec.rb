require 'rails_helper'

RSpec.describe 'user profile', type: :feature do
  before :each do
    @user = create(:user)
    @address_1 = create(:address, user: @user, nickname: "home")
    @address_2 = create(:address, user: @user, nickname: "business")
  end

  describe 'registered user visits their profile' do
    it 'shows user information' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#profile-data' do
        expect(page).to have_content("Role: #{@user.role}")
        expect(page).to have_content("Email: #{@user.email}")
        expect(page).to have_link('Edit Profile Data')
      end
      within "#address-details-#{@address_2.id}" do
        expect(page).to have_content("Street: #{@user.addresses[1].street}")
        expect(page).to have_content("City: #{@user.addresses[1].city}")
        expect(page).to have_content("State: #{@user.addresses[1].state}")
        expect(page).to have_content("Zip Code: #{@user.addresses[1].zip_code}")
      end
    end
  end

  describe 'registered user edits their profile' do
    describe 'edit user form' do
      it 'pre-fills form with all but password information' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path

        click_link 'Edit'

        expect(current_path).to eq('/profile/edit')
        expect(find_field('Name').value).to eq(@user.name)
        expect(find_field('Email').value).to eq(@user.email)
        expect(find_field('Street').value).to eq(@user.addresses.last.street)
        expect(find_field('City').value).to eq(@user.addresses.last.city)
        expect(find_field('State').value).to eq(@user.addresses.last.state)
        expect(find_field('Zip').value).to eq(@user.addresses.last.zip_code)
        expect(find_field('Password').value).to eq(nil)
        expect(find_field('Password confirmation').value).to eq(nil)
      end
    end

    describe 'user information is updated' do
      before :each do
        @updated_name = 'Updated Name'
        @updated_email = 'updated_email@example.com'
        @updated_street = 'newest street'
        @updated_city = 'new new york'
        @updated_state = 'S. California'
        @updated_zip_code = '33333'
        @updated_password = 'newandextrasecure'
      end

      describe 'succeeds with allowable updates' do
        scenario 'all attributes are updated' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email
          fill_in :address_street, with: @updated_street
          fill_in :address_city, with: @updated_city
          fill_in :address_state, with: @updated_state
          fill_in :address_zip_code, with: @updated_zip_code
          fill_in :user_password, with: @updated_password
          fill_in :user_password_confirmation, with: @updated_password

          click_button 'Submit'

          updated_user = User.find(@user.id)
          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")
          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
            within '#address-details' do
              expect(page).to have_content("#{@updated_street}")
              expect(page).to have_content("#{@updated_city}, #{@updated_state} #{@updated_zip_code}")
            end
          end
          expect(updated_user.password_digest).to_not eq(old_digest)
        end
        scenario 'works if no password is given' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email
          fill_in :address_street, with: @updated_street
          fill_in :address_city, with: @updated_city
          fill_in :address_state, with: @updated_state
          fill_in :address_zip_code, with: @updated_zip_code

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")
          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
            within '#address-details' do
              expect(page).to have_content("#{@updated_street}")
              expect(page).to have_content("#{@updated_city}, #{@updated_state} #{@updated_zip_code}")
            end
          end
          expect(updated_user.password_digest).to eq(old_digest)
        end
      end
    end

    it 'fails with non-unique email address change' do
      create(:user, email: 'megan@example.com')
      login_as(@user)

      visit edit_profile_path

      fill_in :user_email, with: 'megan@example.com'

      click_button 'Submit'

      expect(page).to have_content("Email has already been taken")
    end

    it 'shows all user addresses and buttons' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#address-handler' do
        expect(page).to have_content("Addresses on File:")
        within "#address-details-#{@address_1.id}" do
          expect(page).to have_content("Street: #{@user.addresses[0].street}")
          expect(page).to have_content("City: #{@user.addresses[0].city}")
          expect(page).to have_button("Edit This Address")
          expect(page).to have_button("Delete This Address")
        end
        within "#address-details-#{@address_2.id}" do
          expect(page).to have_content("Street: #{@user.addresses[1].street}")
          expect(page).to have_content("City: #{@user.addresses[1].city}")
          expect(page).to have_button("Edit This Address")
          expect(page).to have_button("Delete This Address")
        end
      end
    end

    it 'does not show edit/delete buttons for addresses in completed orders' do

      @admin = create(:admin)

      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @order_1 = create(:order, user: @user, address_id: @address_1.id, status: "shipped")

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#address-handler' do
        expect(page).to have_content("Addresses on File:")
        within "#address-details-#{@address_1.id}" do
          expect(page).to have_content("Street: #{@user.addresses[0].street}")
          expect(page).to have_content("City: #{@user.addresses[0].city}")
          expect(page).to_not have_button("Edit This Address")
          expect(page).to_not have_button("Delete This Address")
        end
      end
    end


  end
end
