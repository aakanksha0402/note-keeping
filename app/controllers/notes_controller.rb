class NotesController < ApplicationController

  before_action :authenticate_user!, except: [:index]

  before_action :check_request_type, except: [:index] #Except for index, if request type is html, redirect to root_path. Block HTML request throughout

  before_action :set_note, only: [:show, :edit, :update, :destroy, :share, :add_tags, :remove_tag, :remove_user]

  before_action :note_permission, only: [:show, :edit, :update, :destroy, :share, :add_tags]

  before_action :set_note_user, only: [:edit_permission, :save_permission] # Find user note for permission changing

  def index
     if user_signed_in?
      get_created_and_shared_notes
      @note = current_user.created_notes.new
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
    redirect_to notes_path unless @permissions.has_key?("2")
  end

  def create
    @note = current_user.created_notes.new(note_params)
    if @note.save
      @created_notes = current_user.created_notes.all
      note_permission
      get_users
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    @note.update(note_params)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @note.destroy
    @note = current_user.created_notes.new
    respond_to do |format|
      format.js
    end
  end

  def share
    unless @permissions.has_key?("3")
      @error = "You're not allowed to perform this action"
    end
    user_ids = params[:user][:ids].reject { |p| p.empty? } if params[:user][:ids].present?
    permission_ids = params[:permission][:ids].reject { |p| p.empty? } if params[:permission][:ids].present?
    if user_ids.empty?
      @error = "Please select users to share notes"
    elsif permission_ids.empty?
      @error = "Please select atleast one permission"
    else
      permission_hash = {}
      permission_ids.map {|p| permission_hash["#{p}"] = true}
      user_ids.map do |user_id|
        n = current_user.shared_notes.new(user_id: user_id, note: @note, permissions: permission_hash )
        n.save
      end
      get_users
      @success = "Note shared successfully!"
    end
    respond_to do |format|
      format.js { render :file => "notes/all_users.js.erb" }
    end
  end

  def add_tags
    tags = params[:tags].split(",").reject { |tag| tag.empty? } if params[:tags].present?

    if tags.nil? || tags.empty?
      @error = "Please add a tag"
    else
      tags.map do |tag|
        @existing_tag = Tag.find_or_create_by(name: tag.downcase.strip)
        tag = @note.note_tags.new(added_by: current_user, tag: @existing_tag)
        tag.save
        @count = @note.note_tags.count
      end
      @success = "Tags added successfully!"
    end
    respond_to do |format|
      format.js { render :file => "notes/all_tags.js.erb" }
    end
  end

  def remove_tag
    tag = @note.note_tags.find_by(tag_id: params[:tag_id])
    if tag.present? &&  tag.destroy
      @success = "Tag destroyed successfully!"
      @count = @note.note_tags.count
    else
      @error = "There seems to be an issue. Please select the note and try again"
    end
    respond_to do |format|
        format.js { render :file => "notes/all_tags.js.erb" }
    end
  end

  def remove_user
    note = @note.note_users.find_by(user_id: params[:user_id])
    if note.present? && note.destroy
      get_users
      @success = "All permissions revoked from this user successfully!"
    else
      @error = "There seems to be an issue. Please try again"
    end
    # @users = User.where.not(id: [current_user.id, @note.created_by.id])
    respond_to do |format|
        format.js { render :file => "notes/all_users.js.erb" }
    end
  end

  def edit_permission
    @permissions = Permission.all.order(:id)
  end

  def save_permission
    permission_ids = params[:permissions].reject { |p| p.empty? } if params[:permissions].present?
    if permission_ids.empty?
      @error = "Please select atleast one permission"
    else
      permission_hash = {}
      permission_ids.map {|p| permission_hash["#{p}"] = true}

       if @note_user.update(permissions: permission_hash)
         @note = @note_user.note
         get_users
         @success = "Permissions changed successfully!"
       else
         @error = "The permission couldn't be saved. Please try again"
       end
    end

    respond_to do |format|
        format.js { render :file => "notes/all_users.js.erb" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = current_user.created_notes.find_by(id: params[:id])
      @note = current_user.notes.find_by(id: params[:id]) unless @note
      if @note.nil?
        respond_to do |format|
          format.js { render :file => "layouts/shared/error.js.erb" }
        end
      end
    end

    def set_note_user
      @note_user = NoteUser.find(params[:note_user_id])
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

    def check_request_type
      redirect_to root_path if request.format.html?
    end

    def get_created_and_shared_notes
      @created_notes = current_user.created_notes.all.order(updated_at: :desc)
      @shared_with_notes = current_user.note_users.all.order(updated_at: :desc)
    end
end
