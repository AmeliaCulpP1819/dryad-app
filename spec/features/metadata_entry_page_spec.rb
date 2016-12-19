require 'rails_helper'

# RSpec.configure do |config|
#   config.include FeatureHelper, :type => :feature
# end

feature "User lands on metadata entry page and navigates through it" do

  background do
    @tenant = ::StashEngine::Tenant.find(tenant_id = "dataone")
    @user = ::StashEngine::User.create(first_name: 'test', last_name: 'user', email: 'testuser.ucop@gmail.com', tenant_id: @tenant.tenant_id)
  end

  it "Logged in user fills metadata entry page", js: true do
    visit "localhost:3000/stash"
    visit "http://#{@tenant.full_domain}/stash/auth/developer"

    within('form') do
      fill_in 'Name', with: 'testuser'
      fill_in 'Email', with: 'testuser.ucop@gmail.com'
      fill_in 'test_domain', with: 'testuser@ucop.edu'
      click_button 'Sign In'
    end
    if page.has_content?('My Datasets: Getting Started') == true
      click_button 'Start New Dataset'
    else
      click_button 'Resume'
    end
    expect(page).to have_content 'Describe Your Datasets'

    #Data Type
    select 'Image', from: 'Type of Data'

    #Title
    fill_in 'Title', with: 'Test Dataset - In Identification Information Section'

    #Author
    fill_in 'First Name', with: 'Test'
    fill_in 'Last Name', with: 'User'
    fill_in 'Institutional Affiliation', with: 'UCOP'
    click_link 'Add Author'

    #Abstract
    fill_in 'Abstract', with: "Lorem ipsum dolor sit amet, consectetur"\
    "adipiscing elit. Maecenas posuere quis ligula eu luctus."\
    "Donec laoreet sit amet lacus ut efficitur. Donec mauris erat,"\
    "aliquet eu finibus id, lobortis at ligula. Donec iaculis orci nisl,"\
    "quis vulputate orci efficitur nec. Proin imperdiet in lorem eget sodales."\
    "Etiam blandit eget quam nec tristique. In hac habitasse platea dictumst."\
    "Integer id nunc in purus sagittis dapibus sed ac augue. Aenean eu lobortis turpis."\

    find('summary', text: "Data Description (optional)").click

    #Funding
    # fill_autocomplete('contributor_name', with: 'Royal Norwegian Embassy in London')
    # ## This is an example of something that should be on your screen after you make the selection
    # page.should have_content("Royal Norwegian Embassy in London")
    fill_in 'Award Number', with: '21-10-513021'

    #Keywords
    fill_in 'Keywords', with: 'testing all, possible options'

    #Methods
    fill_in 'Methods', with: "Lorem ipsum dolor sit amet, consectetur"\
    "adipiscing elit. Maecenas posuere quis ligula eu luctus."\
    "Donec laoreet sit amet lacus ut efficitur. Donec mauris erat,"\
    "aliquet eu finibus id, lobortis at ligula. Donec iaculis orci nisl,"\
    "quis vulputate orci efficitur nec. Proin imperdiet in lorem eget sodales."\
    "Etiam blandit eget quam nec tristique. In hac habitasse platea dictumst."\
    "Integer id nunc in purus sagittis dapibus sed ac augue. Aenean eu lobortis turpis."\

    #Usage Notes
    fill_in 'Usage Notes', with: "Lorem ipsum dolor sit amet, consectetur"\
    "adipiscing elit. Maecenas posuere quis ligula eu luctus."\
    "Donec laoreet sit amet lacus ut efficitur. Donec mauris erat,"\
    "aliquet eu finibus id, lobortis at ligula. Donec iaculis orci nisl,"\
    "quis vulputate orci efficitur nec. Proin imperdiet in lorem eget sodales."\
    "Etiam blandit eget quam nec tristique. In hac habitasse platea dictumst."\
    "Integer id nunc in purus sagittis dapibus sed ac augue. Aenean eu lobortis turpis."\

    #Related work(s)
    select 'is cited by', from: 'related_identifier[relation_type]'
    select 'DOI', from: 'related_identifier[related_identifier_type]'
    fill_in 'Identifier', with: 'gov.noaa.class:AVHRR'
    click_link 'add another related work'

    click_link 'Proceed to Upload'

  end
end