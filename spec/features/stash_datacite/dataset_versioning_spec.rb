require 'rails_helper'
RSpec.feature 'DatasetVersioning', type: :feature do

  include MerrittHelper
  include DatasetHelper
  include Mocks::CurationActivity
  include Mocks::Datacite
  include Mocks::Repository
  include Mocks::RSolr
  include Mocks::Salesforce
  include Mocks::Stripe
  include Mocks::Tenant

  before(:each) do
    mock_repository!
    mock_salesforce!
    mock_solr!
    mock_datacite_and_idgen!
    mock_stripe!
    mock_tenant!
    ignore_zenodo!
    neuter_curation_callbacks!
    @curator = create(:user, role: 'curator')
    @author = create(:user)
    @document_list = []
  end

  describe :initial_version do

    before(:each, js: true) do
      ActionMailer::Base.deliveries = []
      # Sign in and create a new dataset
      sign_in(@author)
      visit root_path
      click_link 'My Datasets'
      start_new_dataset
      fill_required_fields
      navigate_to_review
      agree_to_everything
      submit_form
    end

    describe :pre_submit do
      it 'should display the proper info on the My Datasets page', js: true do
        click_link 'My Datasets'

        expect(page).to have_text(@resource.title)
        expect(page).to have_text('In Progress')
      end

      it 'did not send out an email to the author', js: true do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    describe :merritt_submission_error do
      it 'displays the proper information on the My Datasets page', js: true do
        mock_unsuccessfull_merritt_submission!(@resource)
        click_link 'My Datasets'
        within(:css, '#user_submitted tbody tr:first-child') do
          expect(page).to have_text(@resource.title)
          expect(page).to have_text('Processing')
          # Capybara matcher returns nil for the 'Update' link since it is disabled
          expect(page).not_to have_link('Update')
        end
      end
    end

    describe :merritt_submission_success do
      before(:each) do
        ActionMailer::Base.deliveries = []
        mock_successfull_merritt_submission!(@resource)
      end

      it 'has a resource_state (Merritt status) of "submitted"', js: true do
        expect(@resource.submitted?).to eql(true)
      end

      it 'has a curation status of "submitted"', js: true do
        expect(@resource.current_curation_status).to eql('submitted')
      end

      it 'displays the proper information on the My Datasets page', js: true do
        click_link 'My Datasets'
        within(:css, '#user_submitted tbody tr:first-child') do
          expect(page).to have_text(@resource.title)
          expect(page).to have_text('Submitted')
          expect(page).to have_button('Update')
        end
      end

      describe :when_viewed_by_curator do
        before(:each, js: true) do
          sign_in(@curator)
          find('summary', text: 'Admin').click
          visit stash_url_helpers.ds_admin_path
        end

        it 'displays the proper information on the Admin page', js: true do
          within(:css, '.c-lined-table__row') do
            # Make sure the appropriate buttons are available
            # Curators want to edit everything unless it's in progress, so enjoy
            expect(page).to have_css('button[title="Edit Dataset"]')
            expect(page).to have_css('button[aria-label="Update status"]')

            # Make sure the right text is shown
            expect(page).to have_link(@resource.title)
            within(:css, "#js-curation-state-#{@resource.id}") do
              expect(page).to have_text('Submitted')
            end
            expect(page).to have_text(@resource.authors.collect(&:author_last_name).join('; '))
            expect(page).not_to have_text(@curator.name_last_first)
            expect(page).to have_text(@resource.identifier.identifier)
          end
        end

        it 'displays the proper information on the Activity Log page', js: true do
          within(:css, '.c-lined-table__row') do
            find('button[aria-label="View Activity Log"]').click
          end

          expect(page).to have_text(@resource.identifier)
          expect(page).to have_text('Submitted')
          expect(page).to have_text(@author.name)
        end
      end
    end
  end

  describe :new_version do
    before(:each) do
      ActionMailer::Base.deliveries = []
      @identifier = create(:identifier)
      @resource = create(:resource, :submitted, identifier: @identifier, user_id: @author.id,
                                                tenant_id: @author.tenant_id, current_editor_id: @curator.id)
    end

    context :by_curator do
      before(:each, js: true) do
        # needed to set the user to system user.  Not migrated as part of tests for some reason
        StashEngine::User.create(id: 0, first_name: 'Dryad', last_name: 'System', role: 'user') unless StashEngine::User.where(id: 0).first

        create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'curation')
        create(:data_file, file_state: 'copied', resource: @resource, upload_file_name: 'README.txt')
        create(:data_file, file_state: 'copied', resource: @resource)
        @resource.reload

        sign_in(@curator)
        find('summary', text: 'Admin').click
        visit stash_url_helpers.ds_admin_path

        # Edit the Dataset as an admin
        find('button[title="Edit Dataset"]').click
        expect(page).to have_text("You are editing #{@author.name}'s dataset.")
        update_dataset(curator: true)
        @resource.reload

        visit stash_url_helpers.ds_admin_path
      end

      it 'has a resource_state (Merritt status) of "submitted"', js: true do
        expect(@resource.submitted?).to eql(true)
      end

      it 'has a curation status of "curation"', js: true do
        expect(@resource.current_curation_status).to eql('curation')
      end

      it 'added a curation note to the record', js: true do
        expect(@resource.curation_activities.where(status: 'in_progress').last.note).to include(@resource.edit_histories.last.user_comment)
      end

      it 'displays the proper information on the Admin page', js: true do
        within(:css, '.c-lined-table__row') do
          # Make sure the appropriate buttons are available
          expect(page).to have_css('button[title="Edit Dataset"]')
          expect(page).to have_css('button[aria-label="Update status"]')

          # Make sure the right text is shown
          expect(page).to have_link(@resource.title)
          expect(page).to have_text('Curation')
          @resource.authors.each do |author|
            expect(page).to have_text(author.author_last_name)
          end
          expect(page).to have_text(@curator.name.to_s)
          expect(page).to have_text(@resource.identifier.identifier)
        end
      end

      it 'displays the proper information on the Activity Log page', js: true do
        within(:css, '.c-lined-table__row') do
          find('button[aria-label="View Activity Log"]').click
        end

        expect(page).to have_text(@resource.identifier)

        # it has the user comment when they clicked to submit and end in-progress edit
        expect(page).to have_text(@resource.edit_histories.last.user_comment)

        expect(page).to have_text('Curation')
        expect(page).to have_text('Dryad System')
        expect(page).to have_text('System set back to curation')
      end
    end

    context :by_author do
      before(:each, js: true) do
        ActionMailer::Base.deliveries = []
        sign_in(@author)
        click_link 'My Datasets'
        within(:css, '#user_submitted') do
          click_button 'Update'
        end
        update_dataset
        @resource.reload
      end

      it 'has a resource_state (Merritt status) of "submitted"', js: true do
        expect(@resource.submitted?).to eql(true)
      end

      it 'has a curation status of "submitted"', js: true do
        expect(@resource.current_curation_status).to eql('submitted')
      end

      it 'does not have an automatically-assigned curator', js: true do
        expect(@resource.current_editor_id).to eq(@author.id)
      end

      # TODO: This is no longer tested the same way... may need to install capybara-email
      xit 'sends out a "submitted" email to the author', js: true do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

      it 'displays the proper information on the Admin page', js: true do
        sign_in(@curator)
        find('summary', text: 'Admin').click

        visit stash_url_helpers.ds_admin_path

        within(:css, '.c-lined-table__row') do
          # Make sure the appropriate buttons are available
          # Make sure the right text is shown
          expect(page).to have_link(@resource.title)
          expect(page).to have_text('Submitted')
          @resource.authors.each do |author|
            expect(page).to have_text(author.author_last_name)
          end
          expect(page).not_to have_text(@curator.name_last_first)
          expect(page).to have_text(@resource.identifier.identifier)
        end
      end

      it 'displays the proper information on the Activity Log page', js: true do
        sign_in(@curator)
        find('summary', text: 'Admin').click
        visit stash_url_helpers.ds_admin_path

        within(:css, '.c-lined-table__row') do
          find('button[aria-label="View Activity Log"]').click
        end

        expect(page).to have_text(@resource.identifier.identifier)

        expect(page).to have_text('Submitted')
        expect(page).to have_text(@author.name)
      end

    end

    context :by_author_after_curation do

      before(:each) do
        # needed to set the user to system user.  Not migrated as part of tests for some reason
        StashEngine::User.create(id: 0, first_name: 'Dryad', last_name: 'System', role: 'user') unless StashEngine::User.where(id: 0).first

        create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'curation')
        @resource.reload
      end

      it "has a curation status of 'curation' when prior version was :action_required", js: true do
        create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'action_required')
        @resource.reload

        sign_in(@author)
        click_link 'My Datasets'
        within(:css, '#user_submitted') do
          click_button 'Update'
        end
        update_dataset
        @resource.reload

        expect(@resource.current_curation_status).to eql('curation')
        expect(@resource.current_editor_id).to eql(@curator.id)
      end

      it "has a curation status of 'curation' when prior version was :withdrawn", js: true do
        create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'withdrawn')
        @resource.reload

        sign_in(@author)
        click_link 'My Datasets'
        within(:css, '#user_submitted') do
          click_button 'Update'
        end
        update_dataset
        @resource.reload

        expect(@resource.current_curation_status).to eql('curation')
        expect(@resource.current_editor_id).to eql(@curator.id)
      end

      context :curator_workflow do

        before(:each) do
          ActionMailer::Base.deliveries = []
          mock_datacite!
          mock_stripe!
        end

        it 'has a backup curator when the previous curator is no longer available', js: true do
          curator2 = create(:user, role: 'curator')
          create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'published')
          @resource.reload

          # demote the original curator
          @curator.update(role: 'user')

          sign_in(@author)
          click_link 'My Datasets'
          within(:css, '#user_submitted') do
            click_button 'Update'
          end
          update_dataset
          @resource.reload

          expect(@resource.current_curation_status).to eql('submitted')
          expect(@resource.current_editor_id).to eql(curator2.id)
        end

        it 'does not use the backup curator when the previous curator is a tenant_curator', js: true do
          @curator.update(role: 'tenant_curator')
          create(:user, role: 'curator') # backup curator
          create(:curation_activity, user_id: @curator.id, resource_id: @resource.id, status: 'published')
          @resource.reload

          sign_in(@author)
          click_link 'My Datasets'
          within(:css, '#user_submitted') do
            click_button 'Update'
          end
          update_dataset
          @resource.reload

          expect(@resource.current_curation_status).to eql('submitted')
          expect(@resource.current_editor_id).to eql(@curator.id)
        end

      end

    end

  end

  def update_dataset(curator: false)
    # Add a value to the dataset, submit it and then mock a successful submission
    navigate_to_metadata
    all('[id^=instit_affil_]').last.set('test institution')
    description_divider = find('h2', text: 'Data Description')
    description_divider.click
    doi = 'https://doi.org/10.5061/dryad.888gm50'
    mock_good_doi_resolution(doi: doi)
    fill_in 'Identifier or external url', with: doi
    add_required_data_files
    # Submit the changes
    navigate_to_review
    agree_to_everything
    fill_in('user_comment', with: Faker::Lorem.sentence) if curator
    click_button 'Submit'
    @resource = StashEngine::Resource.last
    mock_successfull_merritt_submission!(@resource)
  end

end
