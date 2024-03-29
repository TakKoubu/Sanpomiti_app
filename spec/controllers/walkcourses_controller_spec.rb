require 'rails_helper'

RSpec.describe WalkcoursesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:anotheruser) { create(:anotheruser) }
  let!(:walkcourse) { create(:walkcourse, user: user) }
  let!(:spot) { create(:spot, walkcourse: walkcourse, name: 'スポット1') }
  let(:spot_params) do
    { spots_attributes: { "0": FactoryBot.attributes_for(:spot) } }
  end
  let(:params_nested) do
    { walkcourse: FactoryBot.attributes_for(:walkcourse).merge(spot_params) }
  end

  describe '#index' do
    subject { get :index; response }
    context '正常なレスポンスであること' do
      it { is_expected.to be_successful }
    end
    context '200レスポンスを返すこと' do
      it { is_expected.to have_http_status '200' }
    end
  end

  describe '#new' do
    subject { get :new; response }
    context 'loginしている場合' do
      before do
        sign_in user
      end
      context '正常なレスポンスであること' do
        it { is_expected.to be_successful }
      end
      context '200レスポンスを返すこと' do
        it { is_expected.to have_http_status '200' }
      end
    end

    context 'loginしていない場合' do
      context '正常なレスポンスではないこと' do
        it { is_expected.not_to be_successful }
      end
      context '302レスポンスを返すこと' do
        it { is_expected.to have_http_status '302' }
      end
      context 'ログイン画面にリダイレクトされること' do
        it { is_expected.to redirect_to '/login' }
      end
    end
  end

  describe '#create' do
    context 'loginしている場合' do
      before do
        sign_in user
      end
      context '正常なデータのWalkcourseの場合' do
        it '正常にWalkcourseを作成できること' do
          expect do
            post :create, params: { walkcourse: attributes_for(:walkcourse) }
          end.to change(Walkcourse, :count).by(1)
        end
        it 'Walkcourse作成後、editページに遷移すること' do
          post :create, params: { walkcourse: attributes_for(:walkcourse) }
          expect(response).to redirect_to edit_walkcourse_path(Walkcourse.last)
        end
      end

      context '不正なデータを含むWalkcourseの場合' do
        it '不正なデータを含むWalkcourseは作成できなくなっていること' do
          expect do
            post :create, params: { walkcourse: attributes_for(:walkcourse, title: nil) }
          end.not_to change(Walkcourse, :count)
        end
        it '不正なWalkcourseを作成しようとすると、再度作成ページへレンダリングされること' do
          post :create, params: { walkcourse: attributes_for(:walkcourse, title: nil) }
          expect(response).to render_template :new
        end
      end

      context 'nestしているspotの挙動' do
        context '正常なデータのSpotの場合' do
          it '正常にWalkcourseとSpotが作成できること' do
            expect do
              post :create, params: params_nested
            end.to change(Walkcourse, :count).by(1) and change(Spot, :count).by(5)
          end
          it 'WalkcourseとSpot作成後、editページに遷移すること' do
            post :create, params: params_nested
            expect(response).to redirect_to edit_walkcourse_path(Walkcourse.last)
          end
        end

        context '不正なデータを含むSpotの場合' do
          let(:spot_params) do
            { spots_attributes: { "0": FactoryBot.attributes_for(:spot, name: 'a' * 21) } }
          end
          let(:params_nested) do
            { walkcourse: FactoryBot.attributes_for(:walkcourse).merge(spot_params) }
          end
          it '不正なデータを含むSpotは作成できなくなっていること' do
            expect do
              post :create, params: params_nested
            end.not_to change(Walkcourse, :count)
          end
          it '不正なWalkcourseを作成しようとすると、再度作成ページへレンダリングされること' do
            post :create, params: params_nested
            expect(response).to render_template :new
          end
        end
      end
    end

    context 'loginしていない場合' do
      context 'Walkcourseの挙動を確認する' do
        it '正常なレスポンスではないこと' do
          post :create, params: { walkcourse: attributes_for(:walkcourse) }
          expect(response).to_not be_successful
        end
        it '302レスポンスを返すこと' do
          post :create, params: { walkcourse: attributes_for(:walkcourse) }
          expect(response).to have_http_status '302'
        end
        it 'ログイン画面にリダイレクトされること' do
          post :create, params: { walkcourse: attributes_for(:walkcourse) }
          expect(response).to redirect_to '/login'
        end
      end

      context 'nestしているspotの挙動' do
        it '正常なレスポンスではないこと' do
          post :create, params: params_nested
          expect(response).to_not be_successful
        end
        it '302レスポンスを返すこと' do
          post :create, params: params_nested
          expect(response).to have_http_status '302'
        end
        it 'ログイン画面にリダイレクトされること' do
          post :create, params: params_nested
          expect(response).to redirect_to '/login'
        end
      end
    end
  end

  describe '#show' do
    subject { get :show, params: { id: walkcourse.id }; response }
    context '正常なレスポンスであること' do
      it { is_expected.to be_successful }
    end
    context '200レスポンスを返すこと' do
      it { is_expected.to have_http_status '200' }
    end
  end

  describe '#edit' do
    context 'loginしている場合' do
      before do
        sign_in user
      end
      it '正常なレスポンスであること' do
        get :edit, params: { id: walkcourse.id }
        expect(response).to be_successful
      end
      it '200レスポンスを返すこと' do
        get :edit, params: { id: walkcourse.id }
        expect(response).to have_http_status '200'
      end
    end

    context 'loginしていない場合' do
      context 'クライアントの挙動' do
        it '正常なレスポンスではないこと' do
          get :edit, params: { id: walkcourse.id }
          expect(response).to_not be_successful
        end
        it '302レスポンスを返すこと' do
          get :edit, params: { id: walkcourse.id }
          expect(response).to have_http_status '302'
        end
        it 'ログイン画面にリダイレクトされること' do
          get :edit, params: { id: walkcourse.id }
          expect(response).to redirect_to '/login'
        end
      end

      context '他のユーザーのWalkcourseを編集しようとした時' do
        before do
          sign_in anotheruser
        end
        it '正常なレスポンスが返らないこと' do
          get :edit, params: { id: walkcourse.id }
          expect(response).to_not be_successful
        end
        it '他のユーザーのWalkcourseを編集しようとするとルートページにリダイレクトすること' do
          get :edit, params: { id: walkcourse.id }
          expect(response).to redirect_to root_url
        end
      end
    end
  end

  describe '#update' do
    context 'ログインしている場合' do
      before do
        sign_in user
      end

      context '正常なWalkcourseデータの場合' do
        subject { patch :update, params: { id: walkcourse.id, walkcourse: attributes_for(:walkcourse, title: 'hogehoge') }; response }
        it '正常に更新できること' do
          expect { subject }.to change { walkcourse.reload.title }.to 'hogehoge'
        end
        it '更新した後Walkcourseの編集ページにリダイレクトすること' do
          expect(subject).to redirect_to edit_walkcourse_path(walkcourse)
        end
      end

      context '不正なデータを含むWalkcourseの場合' do
        before do
          patch :update, params: { id: walkcourse.id, walkcourse: attributes_for(:walkcourse, title: 'a' * 51) }
        end
        it '不正なデータを含むWalkcourseを更新できなくなっていること' do
          expect(walkcourse.reload.title).not_to eq 'a' * 51
        end
        it '不正なWalkcourseを作成しようとすると、編集ページへリダイレクトすること' do
          expect(response).to render_template :edit
        end
      end

      context '他のユーザーのWalkcourseを更新しようとした時' do
        before do
          another_walkcourse = create(:walkcourse)
          patch :update, params: { id: another_walkcourse.id, walkcourse: attributes_for(:walkcourse, title: 'hogehoge') }
        end
        it '正常なレスポンスが返らないこと' do
          expect(response).not_to be_successful
        end
        it '他のユーザーのWalkcourseを編集しようとするとルートページにリダイレクトされること' do
          expect(response).to redirect_to root_url
        end
      end

      context 'nestしているspotの挙動' do
        context '正常なSpotデータの場合' do
          # 更新内容
          let(:walkcourse_params) { { walkcourse: FactoryBot.attributes_for(:walkcourse) } }
          let(:spots_attributes) { { spots_attributes: { "0": FactoryBot.attributes_for(:spot, id: spot.id, name: 'スポット2') } } }

          before do
            patch :update, params: { id: walkcourse.id, walkcourse: walkcourse_params.merge(spots_attributes) }
          end
          it '正常に更新できること' do
            expect(spot.reload.name).to eq 'スポット2'
          end
          it '更新した後Walkcourseの編集ページにリダイレクトすること' do
            expect(response).to redirect_to edit_walkcourse_path(walkcourse)
          end
        end

        context '不正なデータを含むSpotの場合' do
          let(:walkcourse_params) { { walkcourse: FactoryBot.attributes_for(:walkcourse) } }
          let(:spots_attributes) { { spots_attributes: { "0": FactoryBot.attributes_for(:spot, id: spot.id, name: 'a' * 21) } } }
          before do
            patch :update, params: { id: walkcourse.id, walkcourse: walkcourse_params.merge(spots_attributes) }
          end
          it '不正なデータを含むWalkcourseを更新できなくなっていること' do
            expect(spot.reload.name).not_to eq 'a' * 21
          end
          it '不正なWalkcourseを作成しようとすると、編集ページへリダイレクトすること' do
            expect(response).to render_template :edit
          end
        end

        context '他のユーザーのSpotを更新しようとした時' do
          let(:walkcourse_params) { { walkcourse: FactoryBot.attributes_for(:walkcourse) } }
          let(:spots_attributes) { { spots_attributes: { "0": FactoryBot.attributes_for(:spot, id: spot.id, name: 'スポット2') } } }
          before do
            sign_in anotheruser
            patch :update, params: { id: walkcourse.id, walkcourse: attributes_for(:walkcourse, title: 'hogehoge') }
          end
          it '正常なレスポンスが返らないこと' do
            expect(response).not_to be_successful
          end
          it '他のユーザーのSpotを編集しようとするとルートページにリダイレクトされること' do
            expect(response).to redirect_to root_url
          end
        end
      end
    end

    context 'loginしていない場合' do
      context 'Walkcourseに関する挙動の確認' do
        before do
          patch :update, params: { id: walkcourse.id, walkcourse: attributes_for(:walkcourse, title: 'hogehoge') }
        end
        it '正常なレスポンスではないこと' do
          expect(response).to_not be_successful
        end
        it '302レスポンスを返すこと' do
          expect(response).to have_http_status '302'
        end
        it 'ログイン画面にリダイレクトされること' do
          expect(response).to redirect_to '/login'
        end
      end

      context 'nestしているspotの挙動' do
        let(:walkcourse_params) { { walkcourse: FactoryBot.attributes_for(:walkcourse) } }
        let(:spots_attributes) { { spots_attributes: { "0": FactoryBot.attributes_for(:spot, id: spot.id, name: 'スポット2') } } }

        before do
          patch :update, params: { id: walkcourse.id, walkcourse: walkcourse_params.merge(spots_attributes) }
        end
        it '正常なレスポンスではないこと' do
          expect(response).to_not be_successful
        end
        it '302レスポンスを返すこと' do
          expect(response).to have_http_status '302'
        end
        it 'ログイン画面にリダイレクトされること' do
          expect(response).to redirect_to '/login'
        end
      end
    end
  end

  describe '#destroy' do
    context 'loginしている場合' do
      context 'Walkcourseのみの挙動を確認' do
        before do
          sign_in user
          request.env['HTTP_REFERER'] = 'where_i_came_from'
        end
        it '正常に削除できること' do
          expect { walkcourse.destroy }.to change(Walkcourse, :count).by(-1)
        end
        it '削除した後、リファラーページもしくはルートページにリダイレクトすること' do
          delete :destroy, params: { id: walkcourse.id }
          expect(response).to redirect_to 'where_i_came_from' || root_url
        end
      end
      context 'nestしているspotの挙動' do
        it '正常に削除できること' do
          expect { walkcourse.destroy }.to change(Walkcourse, :count).by(-1) and change(Spot, :count).by(-5)
        end
      end
    end

    context 'loginしていない場合' do
      it '302レスポンスを返すこと' do
        delete :destroy, params: { id: walkcourse.id }
        expect(response).to have_http_status '302'
      end
      it 'ログイン画面にリダイレクトされること' do
        delete :destroy, params: { id: walkcourse.id }
        expect(response).to redirect_to '/login'
      end
    end

    context '他のユーザーのWalkcourseを削除しようとした時' do
      before do
        sign_in anotheruser
        delete :destroy, params: { id: walkcourse.id }
      end
      it '他のユーザーのWalkcourseを削除しようとしても削除できないこと' do
        expect { walkcourse }.to_not change(Walkcourse, :count) and change(Spot, :count)
      end
      it '他のユーザーのWalkcourseを削除するとrootページにリダイレクトされること' do
        expect(response).to redirect_to root_url
      end
    end
  end
end
