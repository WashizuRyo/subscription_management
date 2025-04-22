require 'rails_helper'

RSpec.describe "Tags", type: :system do
  let(:user) { FactoryBot.create(:user, :with_tags) }

  it "displays 'タグを削除しました' when a tag is deleted" do
    login_as user
    tag = user.subscriptions.first.tags.first

    visit user_tags_path(user)

    expect do
      within "#tag_#{tag.id}" do
        click_button "削除"
      end

      expect(page).to have_content "タグを削除しました"
      expect(page).to_not have_content tag.name
    end.to change(Tag, :count).by(-1)
  end

  it "displays 'タグを更新しました' when a tag is updated" do
    login_as user
    tag = user.subscriptions.first.tags.first

    visit user_tags_path(user)

    click_link(href: edit_user_tag_path(user, tag))
    expect(page).to have_field("名前", with: tag.name)
    fill_in "名前", with: "TestTag"
    click_button "送信する"

    expect(page).to have_current_path(user_tags_path(user))
    expect(page).to have_content "タグを更新しました"
    expect(page).to have_content "TestTag"
  end
end
