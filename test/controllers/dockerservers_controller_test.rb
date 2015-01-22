require 'test_helper'

class DockerserversControllerTest < ActionController::TestCase
  setup do
    @dockerserver = dockerservers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dockerservers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dockerserver" do
    assert_difference('Dockerserver.count') do
      post :create, dockerserver: { name: @dockerserver.name, url: @dockerserver.url }
    end

    assert_redirected_to dockerserver_path(assigns(:dockerserver))
  end

  test "should show dockerserver" do
    get :show, id: @dockerserver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dockerserver
    assert_response :success
  end

  test "should update dockerserver" do
    patch :update, id: @dockerserver, dockerserver: { name: @dockerserver.name, url: @dockerserver.url }
    assert_redirected_to dockerserver_path(assigns(:dockerserver))
  end

  test "should destroy dockerserver" do
    assert_difference('Dockerserver.count', -1) do
      delete :destroy, id: @dockerserver
    end

    assert_redirected_to dockerservers_path
  end
end
