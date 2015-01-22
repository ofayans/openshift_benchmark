require 'test_helper'

class GearProfilesControllerTest < ActionController::TestCase
  setup do
    @gear_profile = gear_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gear_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gear_profile" do
    assert_difference('GearProfile.count') do
      post :create, gear_profile: { name: @gear_profile.name }
    end

    assert_redirected_to gear_profile_path(assigns(:gear_profile))
  end

  test "should show gear_profile" do
    get :show, id: @gear_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gear_profile
    assert_response :success
  end

  test "should update gear_profile" do
    patch :update, id: @gear_profile, gear_profile: { name: @gear_profile.name }
    assert_redirected_to gear_profile_path(assigns(:gear_profile))
  end

  test "should destroy gear_profile" do
    assert_difference('GearProfile.count', -1) do
      delete :destroy, id: @gear_profile
    end

    assert_redirected_to gear_profiles_path
  end
end
