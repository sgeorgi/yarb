require_relative '../spec_helper'

describe ApplicationController do

  render_views

  context 'on the root_path' do
    before :each do
      visit root_path
    end

    it 'initialize session' do
      ApplicationController.any_instance.should_receive(:init_session)
      visit root_path
    end

    it 'should switch locales' do
      within '#container.container' do
        page.should have_css('h1', :text => 'Welcome', match: :prefer_exact)
      end
      within 'footer .locales' do
        click_link 'Deutsch'
      end
      within '#container.container' do
        page.should have_css('h1', :text => 'Willkommen', match: :prefer_exact)
      end
    end
  end

  context 'on any pages' do
    it 'stays on the same page when switching locales' do
      I18n.locale = :en
      visit pages_path
      page.should have_content 'Available Pages'
      within '.locales' do
        click_link 'Deutsch'
      end
      page.should have_content 'Alle Seiten'
    end
  end

end
