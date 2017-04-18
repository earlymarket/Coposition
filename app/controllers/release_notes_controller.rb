class ReleaseNotesController < ApplicationController
  def new
    @release_note = ReleaseNote.new
  end

  def create
    ReleaseNote.create(allowed_params)
    redirect_to release_notes_path
  end

  def index
    @release_notes = ReleaseNote.all.paginate(per_page: 10, page: params[:page])
  end

  def edit
    @release_note = ReleaseNote.find(params[:id])
  end

  def update
    @release_note = ReleaseNote.find(params[:id])
    @release_note.update(params)
  end

  private

  def allowed_params
    params.require(:release_note).permit(%i(version application content))
  end
end
