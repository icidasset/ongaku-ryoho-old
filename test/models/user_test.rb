require "test_helper"

describe User do
  subject { User.new }
  
  it { must have_many(:sources) }
  it { must have_many(:favourites) }
  
  it { must allow_mass_assignment_of(:email) }
  it { must allow_mass_assignment_of(:password) }
  
  it { wont allow_mass_assignment_of(:crypted_password) }
  it { wont allow_mass_assignment_of(:salt) }
  
  it { must validate_presence_of(:email) }
  
  it "must have a unique e-mail" do
    user_a = FactoryGirl.create(:user)
    user_b = FactoryGirl.build(:user)
    user_b.valid?.must_equal false
  end
  
  it { must validate_format_of(:email).with('test@domain.com') }
  it { must validate_format_of(:email).not_with('test') }
  
  it { must validate_presence_of(:password) }
  it { must validate_confirmation_of(:password) }
end

