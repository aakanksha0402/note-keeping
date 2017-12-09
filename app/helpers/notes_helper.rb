module NotesHelper
  def formatted_body(note)
    truncate(note.body, length: 40)
  end
end
