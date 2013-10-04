# -*- encoding : utf-8 -*-
#
# Settings Hash for test-environment
module Settings

  def self.settings
    {
      mailers: {
        user_mailer: {
          default_from: "noreply@example.com",
        }
      },
    }
  end

end
