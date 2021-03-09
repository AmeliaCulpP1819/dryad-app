module StashEngine
  class CurationStats < ApplicationRecord
    validates :date, presence: true, uniqueness: true

    after_create :populate_values

    def complete?
      datasets_curated.present? &&
        new_datasets_to_submitted.present? &&
        new_datasets_to_peer_review.present? &&
        datasets_to_aar.present? &&
        datasets_to_published.present? &&
        datasets_to_embargoed.present? &&
        author_revised.present? &&
        author_versioned.present?
    end

    def recalculate
      populate_values
    end

    private

    def populate_values
      populate_datasets_curated
      populate_new_datasets_to_submitted
      populate_new_datasets_to_peer_review
      populate_datasets_to_aar
      populate_datasets_to_published
      populate_datasets_to_embargoed
      populate_author_revised
      populate_author_versioned
    end

    # The number processed (meaning the status changed from 'curation' to 'action_required', 'embargoed' or 'published')
    def populate_datasets_curated
      datasets_found = Set.new
      # for each dataset that received the target status on the given day
      cas = CurationActivity.where(created_at: date..(date + 1.day), status: %w[action_required embargoed published])
      cas.each do |ca|
        # if the previous ca was `curation`, add the identifier to datasets_found
        prev_ca = CurationActivity.where(resource_id: ca.resource_id, id: 0..ca.id - 1).last
        datasets_found.add(ca.resource.identifier) if prev_ca.curation?
      end
      update(datasets_curated: datasets_found.size)
    end

    # The number of new submissions that day (so the first time we see them as 'submitted' in the system)
    def populate_new_datasets_to_submitted
      datasets_found = Set.new
      # for each dataset that received the target status on the given day
      cas = CurationActivity.where(created_at: date..(date + 1.day), status: %w[submitted])
      cas.each do |ca|
        # include this this dataset unless it has a previous resource that had been submitted
        this_resource = ca.resource
        found_dataset = this_resource.identifier
        prev_resources = this_resource.identifier.resources.where(id: 0..this_resource.id - 1)
        prev_resources.each do |pr|
          found_dataset = nil if pr.submitted_date
        end

        datasets_found.add(found_dataset) if found_dataset
      end
      update(new_datasets_to_submitted: datasets_found.size)
    end

    # The number of new PPR that day (so the first time we see them as 'peer_review' in the system)
    def populate_new_datasets_to_peer_review
      datasets_found = Set.new
      # for each dataset that received the target status on the given day
      cas = CurationActivity.where(created_at: date..(date + 1.day), status: %w[peer_review])
      cas.each do |ca|
        # include this this dataset unless it has a previous resource that had been submitted
        this_resource = ca.resource
        found_dataset = this_resource.identifier
        prev_resources = this_resource.identifier.resources.where(id: 0..this_resource.id - 1)
        prev_resources.each do |pr|
          found_dataset = nil if pr.submitted_date
        end

        datasets_found.add(found_dataset) if found_dataset
      end
      update(new_datasets_to_peer_review: datasets_found.size)
    end

    # Number that were transitioned directly from one status to another on the target day
    def datasets_transitioned(from_status: nil, to_status: nil)
      return 0 unless from_status && to_status

      datasets_found = Set.new
      # for each dataset that received the target status on the given day
      cas = CurationActivity.where(created_at: date..(date + 1.day), status: to_status)
      cas.each do |ca|
        # if the previous ca was from_status, add the identifier to datasets_found
        prev_ca = CurationActivity.where(resource_id: ca.resource_id, id: 0..ca.id - 1).last
        datasets_found.add(ca.resource.identifier) if prev_ca.status == from_status
      end
      datasets_found.size
    end

    # The number AAR'd that day (status change from 'curation' to 'action_required')
    def populate_datasets_to_aar
      update(datasets_to_aar: datasets_transitioned(from_status: 'curation', to_status: 'action_required'))
    end

    # The number published by a curator that day (status change from 'curation' to 'published' by a curator and not the system)
    def populate_datasets_to_published
      update(datasets_to_published: datasets_transitioned(from_status: 'curation', to_status: 'published'))
    end

    # The number embargoed that day (status change from 'curation' to 'embargoed' per day)
    def populate_datasets_to_embargoed
      update(datasets_to_embargoed: datasets_transitioned(from_status: 'curation', to_status: 'embargoed'))
    end

    # The number that come back to us after an Author Action Required
    # (so they change status from 'action_required' to 'curation')
    def populate_author_revised
      datasets_found = Set.new
      # for each dataset that received the target status on the given day
      cas = CurationActivity.where(created_at: date..(date + 1.day), status: 'curation')
      cas.each do |ca|
        # action_required is either a previous status in this version, or the last status of the previous version
        this_ver_aar = CurationActivity.where(resource_id: ca.resource_id, id: 0..ca.id - 1, status: 'action_required').present?
        prev_resource = ca.resource.identifier.resources.where(id: 0..ca.resource_id - 1).last
        prev_ver_aar = prev_resource&.current_curation_status == 'action_required'

        datasets_found.add(ca.resource.identifier) if this_ver_aar || prev_ver_aar
      end
      datasets_found.size

      update(author_revised: datasets_found.size)
    end

    # The number resubmitted that day (were 'published' or 'embargoed' before, and changed status to 'submitted')
    def populate_author_versioned; end

  end
end
