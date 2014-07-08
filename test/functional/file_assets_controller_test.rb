require 'test_helper'

class FileAssetsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:file_assets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_file_asset
    assert_difference('FileAsset.count') do
      post :create, :file_asset => { }
    end

    assert_redirected_to file_asset_path(assigns(:file_asset))
  end

  def test_should_show_file_asset
    get :show, :id => file_assets(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => file_assets(:one).id
    assert_response :success
  end

  def test_should_update_file_asset
    put :update, :id => file_assets(:one).id, :file_asset => { }
    assert_redirected_to file_asset_path(assigns(:file_asset))
  end

  def test_should_destroy_file_asset
    assert_difference('FileAsset.count', -1) do
      delete :destroy, :id => file_assets(:one).id
    end

    assert_redirected_to file_assets_path
  end
end
