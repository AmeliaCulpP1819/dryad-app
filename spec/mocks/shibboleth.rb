module Mocks

  class Shibboleth

    def self.omniauth_response(user)
      {
        uid: user&.email || Faker::Internet.safe_email,
        credentials: {
          token: "#{Faker::Alphanumeric.alphanumeric(4)}.#{Faker::Alphanumeric.alphanumeric(26)}"
        },
        info: {
          email: user&.email || Faker::Internet.safe_email,
          identity_provider: 'localhost'
        }
      }
    end

  end

end
