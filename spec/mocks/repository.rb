require 'stash/repo'

module Mocks

  module Repository

    def mint_id
      "doi:#{Faker::Number.number(5)}/#{Faker::Number.number(5)}"
    end

    def mock_repository!
      allow_any_instance_of(Stash::Repo::Repository).to receive(:create_submission_job).and_return('doi:12234/38575')
      allow_any_instance_of(Stash::Repo::Repository).to receive(:download_uri_for).and_return('doi:12234/38575')
      allow_any_instance_of(Stash::Repo::Repository).to receive(:update_uri_for).and_return('doi:12234/38575')
      allow_any_instance_of(Stash::Repo::Repository).to receive(:submit).and_return(mint_id)
    end

    class Repository < Stash::Repo::Repository

    end

  end

end
