import SwiftUI
import AppKit

extension Notification.Name {
    static let toggleSidebar = Notification.Name("toggleSidebar")
}

struct ContentView: View {
    @StateObject var noteManager = NoteManager()
    private let selectedTabKey = "selectedNoteID"
    @State private var selectedNoteID: UUID? = UserDefaults.standard
        .string(forKey: "selectedNoteID")
        .flatMap(UUID.init)
    @State private var showingDeleteConfirmation = false
    private let openTabsKey = "openTabIDs"
    @State private var openTabIDs: [UUID] = UserDefaults.standard
        .array(forKey: "openTabIDs")?
        .compactMap { ($0 as? String).flatMap(UUID.init) } ?? []
    @State private var isSidebarVisible = true

    @State private var teleprompterText: String = ""
    @State private var teleprompterOpacity: Double = 0.8
    @State private var isDarkMode: Bool = true

    var body: some View {
        mainView
            .environmentObject(noteManager)
            .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in
                isSidebarVisible.toggle()
            }
            .onChange(of: openTabIDs) { _, newValue in
                let idStrings = newValue.map { $0.uuidString }
                UserDefaults.standard.set(idStrings, forKey: openTabsKey)
            }
            .onChange(of: selectedNoteID) { _, newValue in
                UserDefaults.standard.set(newValue?.uuidString, forKey: selectedTabKey)
            }
    }

    private var mainView: some View {
        NavigationView {
            if isSidebarVisible {
                VStack(alignment: .leading) {
                    Text("Speaker’s note")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 4)

                    Text("Start writing and improve your delivery.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)

                    List(selection: $selectedNoteID) {
                        ForEach(noteManager.notes) { note in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.title)
                                    .font(.headline)
                                Text(String(note.body.prefix(100)) + (note.body.count > 100 ? "…" : ""))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .tag(note.id)
                        }
                    }
                    .listStyle(SidebarListStyle())

                    Spacer()

                    Button(action: {
                        let newNote = noteManager.createNewNote()
                        selectedNoteID = newNote.id
                        if !openTabIDs.contains(newNote.id) {
                            openTabIDs.append(newNote.id)
                        }
                    }) {
                        Text("Start writing")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
                .padding()
                .frame(minWidth: 220, maxWidth: 300)
                .background(Color(.windowBackgroundColor))
            }

            if let id = selectedNoteID,
               let index = noteManager.notes.firstIndex(where: { $0.id == id }) {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(openTabIDs, id: \.self) { tabID in
                                if let note = noteManager.notes.first(where: { $0.id == tabID }) {
                                    Button(action: {
                                        selectedNoteID = tabID
                                    }) {
                                        Text(note.title)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                            .background(selectedNoteID == tabID ? Color.accentColor.opacity(0.2) : Color.clear)
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(selectedNoteID == tabID ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }

                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(spacing: 12) {
                            Spacer()

                            Button {
                                FloatingTeleprompterWindow.shared.show(
                                    text: noteManager.notes[index].body,
                                    opacity: teleprompterOpacity,
                                    isDarkMode: isDarkMode
                                )
                            } label: {
                                Label("Open Teleprompter", systemImage: "rectangle.inset.filled.and.person.filled")
                            }
                            .buttonStyle(.bordered)

                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Note", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 16)
                        .padding(.trailing)

                        NoteEditorView(note: $noteManager.notes[index], onUpdate: { note in
                            noteManager.save(note: note)
                        })
                    }
                    .confirmationDialog(
                        "Delete this note?",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            let noteToDelete = noteManager.notes[index]
                            noteManager.delete(note: noteToDelete)
                            selectedNoteID = nil
                            openTabIDs.removeAll { $0 == noteToDelete.id }
                        }

                        Button("Cancel", role: .cancel) { }
                    }
                }
            } else {
                Text("Select or create a note")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Speaker’s Note")
    }
}
