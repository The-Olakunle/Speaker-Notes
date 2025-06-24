import SwiftUI

struct NoteEditorView: View {
    @Binding var note: Note
    var onUpdate: (Note) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $note.title)
                .font(.title2)
                .padding(.bottom, 8)

            Divider()

            TextEditor(text: $note.body)
                .font(.body)
                .padding(.top, 4)

            Spacer()
        }
        .padding()
        // Monitor changes separately
        .onChange(of: note.title) {
            onUpdate(note)
        }
        .onChange(of: note.body) {
            onUpdate(note)
        }
    }
}
