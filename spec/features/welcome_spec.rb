require 'rails_helper'

RSpec.describe 'Welcome page', type: :feature do
  it 'displays a simple welcome message' do
    visit root_path

    expect(page).to have_content('Little Shop of Orders')

    ['Brian Zanti', 'Megan McMahon', 'Ian Douglas'].each do |staff|
      expect(page).to have_link staff
    end

  end
end
