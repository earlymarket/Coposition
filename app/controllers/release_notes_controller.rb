class ReleaseNotesController < ApplicationController
  before_action :authenticate_admin!, except: :index

  def new
    @release_note = ReleaseNote.new
  end

  def create
    ReleaseNote.create(allowed_params)
    redirect_to release_notes_path, notice: "Note created"
  end

  def index
    release_notes = ReleaseNote.all
    release_notes = release_notes.where(application: params[:application]) if params[:application]
    @release_notes = release_notes.paginate(per_page: 10, page: params[:page])
  end

  def edit
    release_note
  end

  def notify
    Firebase::Push.call(
      topic: release_note.application,
      notification: {
        body: "Version: #{release_note.version} released",
        title: "New version available"
      }
    )
    redirect_to release_notes_path, notice: "Release notification sent"
  end

  def update
    release_note.update(allowed_params)
    redirect_to release_notes_path, notice: "Note edited"
  end

  def destroy
    release_note.destroy
    redirect_to release_notes_path, notice: "Note deleted"
  end

  private

  def release_note
    @release_note ||= ReleaseNote.find(params[:id])
  end

  def allowed_params
    params.require(:release_note).permit(%i(created_at version application content))
  end
end
