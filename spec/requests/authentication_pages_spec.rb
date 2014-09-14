require 'spec_helper'

describe "AuthenticationPages" do
 subject { page }

 describe "signin page" do
  before {visit signin_path}

  it { should have_title ('Sign in') }
  it { should have_content('Sign in') }
 end

 describe "signin" do
 before { visit signin_path }

 describe "with invalid information" do
  before { click_button "Sign in" }

  it {should have_title('Sign in') }
  it {should have_error_message('Invalid') }

  describe "after visiting another page" do
   before { click_link "Home" }
   it { should_not have_error_message('Invalid') }
   end
  end

 describe "with valid information" do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it { should have_title(user.name) }
  it { should have_link('Profile',     href: user_path(user)) }
  it { should have_link('Users',       href: users_path) }
  it { should have_link('Settings',    href: edit_user_path(user)) }
  it { should have_link('Sign out',    href: signout_path) }
  it { should_not have_link('Sign in', href: signin_path) }

   describe "followed by signout" do
    before { click_link "Sign out" }
    it { should have_link('Sign in') }
   end
  end
 end

 describe "authorization" do

  describe "for signed-in users" do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user, no_capybara: true }

  describe "cannot access #new action" do
   before { get new_user_path }
   specify { expect(response).to redirect_to(root_path) }
  end

  describe "cannot access #create action" do
   before { post users_path(user) }
   specify { expect(response).to redirect_to(root_path) }
  end
 end

  describe "for non-signed-in users" do
  let(:user) { FactoryGirl.create(:user) }

   describe "when visiting a non-protected page" do
    before {visit user_path(user)}
    it { should have_link('Sign in',         href: signin_path)}
    it { should_not have_link('Users',       href: users_path) }
    it { should_not have_link('Settings',    href: edit_user_path(user)) }
    it { should_not have_link('Sign out',    href: signout_path) }
    it { should_not have_link('Profile',     href: user_path(user)) }
   end

   describe "when attempting to visit a protected page" do
    before do
    visit edit_user_path(user)
    sign_in user
   end

   describe "after signing in" do

    it "should render the desired protected page" do
     expect(page).to have_title('Edit user')
    end
   end
  end

   describe "in the Users controller" do

    describe "visiting the edit page" do
     before { visit edit_user_path(user) }
     it {should have_title('Sign in') }
    end

    describe "submitting to the update action" do
     before { patch user_path(user) }
     specify { expect(response).to redirect_to(signin_path) }
    end
   end

   describe "in the Microposts controller" do

    describe "submitting to the create action" do
     before { post microposts_path }
     specify { expect(response).to redirect_to(signin_path) }
    end

    describe "submitting to the destroy action" do
     before { delete micropost_path(FactoryGirl.create(:micropost)) }
     specify { expect(response).to redirect_to(signin_path) }
    end
   end

    describe "visiting the user index" do
     before { visit users_path }
     it {should have_title('Sign in') }
    end

    describe "when attempting to visit a protected page" do
     before do
      visit edit_user_path(user)
      sign_in user
     end

     describe "after signing in" do
      it "should render desired protected page" do
       expect(page).to have_title('Edit user')
      end

      describe "when signing in again" do
       before do
        click_link "Sign out"
       	visit signin_path
       	sign_in user
       end

       it "should render the (deafult) profile page" do
       	expect(page).to have_title(user.name)
       end
      end
     end
    end
   end

  describe "as wrong user" do
   let(:user) { FactoryGirl.create(:user) }
   let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
   before { sign_in user, no_capybara: true }

   describe "submitting GET request to the User#edit action" do
    before { get edit_user_path(wrong_user) }
    specify{ expect(response.body).not_to match(full_title('Edit user')) }
    specify{ expect(response).to redirect_to(root_url) }
   end

   describe "submitting PATCH request to the User#UPDATE action" do
    before { patch user_path(wrong_user) }
    specify{ expect(response).to redirect_to(root_url) }
   end
  end

   describe "as non-admin user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:non_admin) { FactoryGirl.create(:user) }

    before { sign_in non_admin, no_capybara: true }

    describe "submitting a DELETE request to the User#destroy action" do
     before { delete user_path(user) }
     specify { expect(response).to redirect_to(root_url) }
    end
   end

   describe "as an admin user" do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin, no_capybara: true }

    describe "should not be able do delete himself via #destroy action" do
     specify do
      expect { delete user_path(admin) }.not_to change(User, :count).by(-1)
     end
    end
   end
 end
end