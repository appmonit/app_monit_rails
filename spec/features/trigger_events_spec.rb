require 'spec_helper'

feature 'Triggered events' do
  scenario 'User creates a new Post' do
    AppMonit::Config.end_point      = 'http://test.local'
    AppMonit::Config.api_key        = 'api_key'
    AppMonit::Config.env            = 'test'
    AppMonit::Rails::Config.skipped_endpoints = %w(PostsController#skipped)

    10.times do
      visit '/posts/'
      visit '/posts/new'

      fill_in 'Title', :with => 'Title'
      fill_in 'Body', :with => 'Body'
      click_button 'Create Post'

      expect(page).to have_text('Post was successfully created.')

      click_link 'Edit'
      fill_in 'Title', :with => 'Title 2'
      fill_in 'Body', :with => 'Body2'
      click_button 'Update Post'

      expect(page).to have_text('Post was successfully updated.')

      visit '/posts/'
      click_link 'Destroy'

      expect {
        visit '/not_found'
      }.to raise_error(ActionController::RoutingError)

      expect {
        visit '/posts/with_exception'
      }.to raise_error(RuntimeError)

      visit '/posts/skipped'

      @worker = AppMonit::Rails::Worker.instance
      @worker.push(:flush)
    end

    puts AppMonit::Rails::Worker.instance.events.inspect
  end
end
