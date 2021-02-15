require "test_helper"

class MemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meme = memes(:one)
  end

  test "should get index" do
    get memes_url
    assert_response :success
  end

  test "should get new" do
    get new_meme_url
    assert_response :success
  end

  test "should create meme" do
    assert_difference('Meme.count') do
      post memes_url, params: { meme: { duration: @meme.duration, end: @meme.end, loudness_i: @meme.loudness_i, loudness_lra: @meme.loudness_lra, loudness_thresh: @meme.loudness_thresh, loudness_tp: @meme.loudness_tp, name: @meme.name, private: @meme.private, source_url: @meme.source_url, start: @meme.start } }
    end

    assert_redirected_to meme_url(Meme.last)
  end

  test "should show meme" do
    get meme_url(@meme)
    assert_response :success
  end

  test "should get edit" do
    get edit_meme_url(@meme)
    assert_response :success
  end

  test "should update meme" do
    patch meme_url(@meme), params: { meme: { duration: @meme.duration, end: @meme.end, loudness_i: @meme.loudness_i, loudness_lra: @meme.loudness_lra, loudness_thresh: @meme.loudness_thresh, loudness_tp: @meme.loudness_tp, name: @meme.name, private: @meme.private, source_url: @meme.source_url, start: @meme.start } }
    assert_redirected_to meme_url(@meme)
  end

  test "should destroy meme" do
    assert_difference('Meme.count', -1) do
      delete meme_url(@meme)
    end

    assert_redirected_to memes_url
  end
end
