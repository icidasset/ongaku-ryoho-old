FactoryGirl.define do

  factory :user do
    email "test_user@domain.com"
    password "secret"
    salt "meUiKDUzMFPWc7KFJopjacbwnQ7GVvTF"
    crypted_password { Sorcery::CryptoProviders::BCrypt.encrypt("secret", salt) }
  end

end