require 'spec_helper'

feature 'single page modal' do
  describe 'without javascript' do
    it 'loads page manually' do
      visit '/'
      page.should have_content "Your posts"
      click_on "New post"
      expect { find(".bbm-modal") }.to raise_error Capybara::ElementNotFound # not found
    end
  end

  describe 'with javascript', js: true do
    it 'loads page into modal and renders modal' do
      visit '/'
      sleep 5
      click_on "New post"
      within ".bbm-modal__topbar" do
        page.should have_content "Create a new post"
      end
    end
  end
end
