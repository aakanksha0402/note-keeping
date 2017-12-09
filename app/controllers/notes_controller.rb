class NotesController < ApplicationController

  before_action :authenticate_user!, except: [:index]

  before_action :set_note, only: [:show, :edit, :update, :destroy, :share, :add_tags, :remove_tag, :remove_user]
  before_action :note_permission, only: [:show, :edit, :update, :destroy, :share, :add_tags]

  def index
     if user_signed_in?
      @created_notes = current_user.created_notes.all.order(updated_at: :desc)
      @shared_with_notes = current_user.note_users.all.order(updated_at: :desc)
    else
      redirect_to user_session_path
    end
  end

  def show
    get_users
    # @users = User.where.not(id: [current_user.id, @note.created_by.id])
  end

  def new
    @note = current_user.created_notes.new
  end

  def edit
    redirect_to notes_path unless @permissions["2"] == "true"
  end

  def create
    @note = current_user.created_notes.new(note_params)

    respond_to do |format|
      if @note.save
        @created_notes = current_user.created_notes.all
        note_permission
        get_users
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def share
    redirect_to notes_path unless @permissions["3"] == "true"
    @user_ids = params[:user][:ids].reject { |u| u.empty? }
    permission = params[:permission][:ids].reject { |p| p.empty? }
    permission_hash = {}
    permission.map {|p| permission_hash["#{p}"] = true}
    @user_ids.map do |user_id|
      n = current_user.shared_notes.new(user_id: user_id, note: @note, permissions: permission_hash )
      n.save
      puts n.errors.as_json
    end
    get_users
    # @users = User.where.not(id: [current_user.id, @note.created_by.id])
    respond_to do |format|
        format.js { render :file => "notes/all_users.js.erb" }
    end
  end

  def add_tags
    tags = params[:tags].split(",").reject { |tag| tag.empty? }
    tags.map do |tag|
      @tag = Tag.find_or_create_by(name: tag.downcase.strip)
      tag = @note.note_tags.new(added_by: current_user, tag: @tag)
      tag.save
    end
    respond_to do |format|
        format.js { render :file => "notes/all_tags.js.erb" }
    end
  end

  def remove_tag
    @note.note_tags.find_by(tag_id: params[:tag_id]).destroy
    respond_to do |format|
        format.js { render :file => "notes/all_tags.js.erb" }
    end
  end

  def remove_user
    @note.note_users.find_by(user_id: params[:user_id]).destroy
    get_users
    # @users = User.where.not(id: [current_user.id, @note.created_by.id])
    respond_to do |format|
        format.js { render :file => "notes/all_users.js.erb" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = current_user.created_notes.find_by(id: params[:id])
      @note = current_user.notes.find(params[:id]) unless @note
    end

    def note_permission
      if @note.created_by == current_user
        @permissions = ActiveSupport::HashWithIndifferentAccess.new("1": "true", "2": "true", "3": "true")
      else
        @permissions = @note.note_users.find_by(user: current_user).permissions.with_indifferent_access
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def note_params
      params.require(:note).permit(:body, :title)
    end

    def get_users
      # @users = User.where.not(id: [current_user.id, @note.created_by.id])
      @users = @note.all_users_without_this_note
    end
end