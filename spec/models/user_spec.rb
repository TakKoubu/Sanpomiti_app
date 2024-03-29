require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create(:user) }
  let!(:walkcourse) { create(:walkcourse, user: user) }
  let!(:otherwalkcourse) { create(:otherwalkcourse, user: user) }
  let(:favorite) { user.favorites.build(like_id: walkcourse.id) }
  let(:otherfavorite) { user.otherfavorites.build(like_id: otherwalkcourse.id) }

  describe 'signup,login画面における　user.name user.emailの検証' do
    it '規定文字数のnameとemailがあれば有効' do
      expect(user).to be_valid
    end

    context '一部入力がない状態でデータの送信が行われた場合' do
      it 'usernameの入力がないとエラー表示' do
        user = build(:user, name: '')
        user.valid?
        expect(user.errors[:name]).to include('を入力してください')
      end

      it 'emailの入力がないとエラー表示' do
        user = build(:user, email: '')
        user.valid?
        expect(user.errors[:email]).to include('を入力してください')
      end

      it 'passwordの入力がないとエラー表示' do
        user = build(:user, password: '')
        user.valid?
        expect(user.errors[:password]).to include('を入力してください')
      end

      it 'password_confirmationの入力がないとエラー表示' do
        user = build(:user, password_confirmation: '')
        user.valid?
        expect(user.errors[:password_confirmation]).to include('とパスワードの入力が一致しません')
      end

      it 'prefectureの入力がないとエラー表示' do
        user = build(:user, prefecture_id: '')
        user.valid?
        expect(user.errors[:prefecture]).to include('を入力してください')
      end
    end

    describe 'name email 入力文字数に関する検証' do
      it 'usernameが規定文字数を超えた場合はエラー表示' do
        user = build(:user, name: 'a' * 51)
        user.valid?
        expect(user.errors[:name]).to include('は50文字以内で入力してください')
      end

      it 'emailが規定文字数を超えた場合はエラー表示' do
        user = build(:user, email: 'a' * 256)
        user.valid?
        expect(user.errors[:email]).to include('は255文字以内で入力してください', 'は不正な値です')
      end
    end

    describe 'password password_confirmation 入力文字数に関する検証' do
      it 'passwordが規定文字数を超えた場合はエラー表示' do
        user = build(:user, password: 'a' * 17)
        user.valid?
        expect(user.errors[:password]).to include('は16文字以内で入力してください')
      end

      it 'password_confirmationが規定文字数を超えた場合はエラー表示' do
        user = build(:user, password_confirmation: 'a' * 17)
        user.valid?
        expect(user.errors[:password_confirmation]).to include('とパスワードの入力が一致しません')
      end

      it 'passwordが規定文字数以下の場合はエラー表示' do
        user = build(:user, password: 'a' * 5)
        user.valid?
        expect(user.errors[:password]).to include('は6文字以上で入力してください')
      end

      it 'password_confirmationが規定文字数以下の場合はエラー表示' do
        user = build(:user, password_confirmation: 'a' * 5)
        user.valid?
        expect(user.errors[:password_confirmation]).to include('とパスワードの入力が一致しません')
      end
    end

    describe 'emailの一意性、及びemailが保存前に小文字化されているか検証' do
      it '同じemailの入力は無効' do
        dup_user = user.dup
        dup_user.email = user.email.upcase
        expect(dup_user).to be_invalid
      end

      it '大文字のemailは入力されたら、小文字で保存される' do
        user = create(:user, email: 'Test@samplE.coM')
        expect(user.reload.email).to eq 'test@sample.com'
      end
    end
  end

  describe 'メソッドの確認' do
    before do
      user.like(walkcourse)
      user.like(otherwalkcourse)
    end

    it 'テストデータが有効であること' do
      expect(favorite).to be_valid
    end
    it 'likeメソッドが正常に機能している' do
      expect(user.liking?(walkcourse)).to be_truthy
    end
    it 'unlikeメソッドが正常に機能している' do
      user.unlike(walkcourse)
      expect(user.liking?(walkcourse)).to be_falsy
    end
    it 'feed_favoritesメソッドによって、likeしたwalkcourseが正常に表示される' do
      expect(user.feed_favorites).to include walkcourse, otherwalkcourse
    end
  end
end
