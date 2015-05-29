require "spec_helper"
require "active_support/testing/assertions"

describe OrganizationsController do
  render_views
  include ActiveSupport::Testing::Assertions
  before do
    @request.session[:user_id] = 1
  end

  it "should get index" do
    get :index
    response.should be_success
    assert_not_nil assigns(:organizations)
  end

  it "should get new" do
    get :new
    response.should be_success
  end

  it "should create organization" do
    assert_difference('Organization.count') do
      post :create, organization: { name: "orga-A" }
    end

    response.should redirect_to(organization_path(assigns(:organization)))
  end

  it "should show organization" do
    get :show, :id => Organization.find(1).to_param
    response.should be_success
  end

  it "should get edit" do
    get :edit, :id => Organization.find(1).to_param
    response.should be_success
  end

  it "should update organization" do
    put :update, :id => Organization.find(1).to_param, :organization => { }
    response.should redirect_to(organization_path(assigns(:organization)))
  end

  it "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, :id => Organization.find(3).to_param
    end

    response.should redirect_to(organizations_path)
  end

  it "should autocomplete for users" do
    get :autocomplete_for_user, :id => 1, :q => "adm"
    response.should be_success
    assert response.body.include?("Admin")
    assert !response.body.include?("John")
  end

  it "should NOT create organizations with same names and parents" do
    assert_no_difference('Organization.count') do
      post :create, organization: {name: "Team A", parent_id: 1}
    end
  end

  it "should create organizations with same names but different parents" do
    assert_difference('Organization.count') do
      post :create, organization: {name: "Team A", parent_id: 3}
    end
  end

  describe "memberships methods" do

    before do
      @request.session[:user_id] = 1
      members = Member.where("project_id = ?", 2)
      members.each do |m|
        if m.user.present?
          m.user.organization_id = 1
          m.user.save!
        end
      end
    end

    it "shoud display a new organization in a project" do
      assert_no_difference 'Organization.find(1).projects.count' do
        post :create_membership_in_project, 'membership' => {:organization_id => 1}, :project_id => 3, :format => :js
      end
      response.content_type.should == Mime::JS
    end

    it "shoud update members roles in a project" do
      users_ids = Project.find(2).members.map(&:user_id)
      users_ids << 1
      assert_difference 'Project.find(2).members.count', +1 do
        put :update_roles, 'membership' => {user_ids: users_ids, role_ids: [2]}, :project_id => 2, organization_id: 1
      end
      response.should redirect_to('/projects/2/settings/members')
    end

    it "should destroy membership inside a project" do
      assert_difference 'Organization.find(1).projects.count', -1 do
        delete :destroy_membership_in_project, :project_id => 2, :organization_id => 1
      end
      response.should redirect_to('/projects/2/settings/members')
    end

  end

end