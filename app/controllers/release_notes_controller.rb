class ReleaseNotesController < ApplicationController
  before_action :authenticate_admin!
  before_action :find_note, only: %i(edit update destroy)

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

  def edit; end

  def update
    @release_note.update(allowed_params)
    redirect_to release_notes_path, notice: "Note edited"
  end

  def destroy
    @release_note.destroy
    redirect_to release_notes_path, notice: "Note deleted"
  end

  private

  def find_note
    @release_note ||= ReleaseNote.find(params[:id])
  end

  def allowed_params
    params.require(:release_note).permit(%i(version application content))
  end
end
