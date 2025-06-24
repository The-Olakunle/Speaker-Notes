import Foundation

class NoteManager: ObservableObject {
    @Published var notes: [Note] = []
    let folderName = "Notes"

    private var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(folderName)
    }

    init() {
        loadNotes()
    }

    func loadNotes() {
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            notes = try files.map { file in
                let data = try Data(contentsOf: file)
                return try JSONDecoder().decode(Note.self, from: data)
            }.sorted(by: { $0.createdAt < $1.createdAt })
        } catch {
            print("Error loading notes:", error)
        }
    }

    func save(note: Note) {
        let fileURL = folderURL.appendingPathComponent("\(note.id).json")
        do {
            let data = try JSONEncoder().encode(note)
            try data.write(to: fileURL)
        } catch {
            print("Error saving note:", error)
        }
    }

    func delete(note: Note) {
        let fileURL = folderURL.appendingPathComponent("\(note.id).json")
        try? FileManager.default.removeItem(at: fileURL)
        notes.removeAll { $0.id == note.id }
    }

    func createNewNote() -> Note {
        let newNote = Note(title: "Untitled", body: "")
        notes.append(newNote)
        save(note: newNote)
        return newNote
    }
}
