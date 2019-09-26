require "rails_helper"

RSpec.describe "TL2 Agreed Flags" do
  let(:category_3) {
    category = Fabricate(:category)
    category.custom_fields["flags_to_hide_post"] = 3
    category.save
    category
  }

  context "while enabled" do
    before do
      SiteSetting.simple_flags_enabled = true
      SiteSetting.default_flags_required = 5
    end

    it "should not hide posts just because there's a big score" do
      post = create_post(category: category_3)

      PostActionCreator.spam(Fabricate(:admin), post)
      PostActionCreator.spam(Fabricate(:admin), post)

      post.reload

      expect(post.hidden).to eq(false)
    end

    it "should hide once the constant number of flags is reached" do
      post = create_post(category: category_3)

      PostActionCreator.spam(Fabricate(:admin), post)
      PostActionCreator.spam(Fabricate(:admin), post)
      PostActionCreator.spam(Fabricate(:admin), post)

      post.reload

      expect(post.hidden).to eq(true)
    end

    it "should have a default flag count" do
      expect(Fabricate(:category).flags_to_hide_post).to eq(5)
    end
  end

  context "while disabled" do
    before do
      SiteSetting.hide_post_sensitivity = Reviewable.sensitivity[:low]
      SiteSetting.simple_flags_enabled = false
    end

    it "should hide posts with big score" do
      post = create_post(category: category_3)

      PostActionCreator.spam(Fabricate(:admin), post)
      PostActionCreator.spam(Fabricate(:admin), post)

      post.reload

      expect(post.hidden).to eq(true)
    end
  end
end
