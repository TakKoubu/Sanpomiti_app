class WalkcoursesController < ApplicationController
  def index; end

  def new
    @walkcourse = Walkcourse.new
    5.times do
      @walkcourse.spots.build
    end
  end

  def create
    @walkcourse = current_user.walkcourses.build(course_params)
    if @walkcourse.save
      flash[:success] = 'コースが登録されました。'
      redirect_to edit_walkcourse_path(@walkcourse)
    else
      flash.now[:danger] = 'コースの登録に失敗しました。'
      render 'new'
    end
  end

  def show
    @walkcourse = Walkcourse.find(params[:id])
    @spots = @walkcourse.spots
    @total_time = @walkcourse.spots.sum(:transit_time) + @walkcourse.spots.sum(:time_required) + @walkcourse.time_to_first_spot
  end

  def edit
    @walkcourse = Walkcourse.find(params[:id])
  end

  def update
    @walkcourse = Walkcourse.find(params[:id])
    if @walkcourse.update_attributes(course_params)
      # 更新に成功したときの処理
      flash[:success] = 'コース情報の更新に成功しました。'
      redirect_to walkcourse_path(@walkcourse)
    else
      flash.now[:danger] = 'コース情報の更新に失敗しました。'
      render 'edit'
    end
  end

  def destroy
    @walkcourse = Walkcourse.find(params[:id])
    @walkcourse.destroy
    flash[:success] = 'メッセージを削除しました。'
    redirect_back(fallback_location: root_path)
  end

  private

  def course_params
    params.require(:walkcourse).permit(:title, :description, :coursepic, :start_station, :time_to_first_spot,
                                       :goal_station, spots_attributes: [:id, :name, :transit_time, :time_required, :address, :description, :spotpic, :longitude, :latitude])
  end
end
