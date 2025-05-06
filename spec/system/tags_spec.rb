require 'rails_helper'

RSpec.describe "Tags", type: :system do
  let(:user) { FactoryBot.create(:user, :with_tags) }

  it "displays 'タグを削除しました' when a tag is deleted" do
    login_as user
    tag = user.subscriptions.first.tags.first

    visit user_tags_path(user)

    expect do
      find("#tag_#{tag.id}").click_button

      expect(page).to have_content "タグを削除しました"
      expect(page).to_not have_content tag.name
    end.to change(Tag, :count).by(-1)
  end
end
