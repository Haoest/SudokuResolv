import SwiftUI

struct ArchiveView: View {
    @State private var entries: [ArchiveEntry] = []
    @State private var selectedEntry: ArchiveEntry? = nil
    @State private var navigateToBoard = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.2, blue: 0.2),
                         Color(red: 0.0, green: 0.0, blue: 0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if entries.isEmpty {
                Text("No saved puzzles yet.")
                    .foregroundStyle(.white)
            } else {
                List {
                    ForEach(entries) { entry in
                        Button {
                            selectedEntry = entry
                            navigateToBoard = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text(formattedDate(entry.creationDateGMT))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !entry.comments.isEmpty {
                                    Text(entry.comments)
                                        .font(.body)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
        .navigationDestination(isPresented: $navigateToBoard) {
            if let entry = selectedEntry,
               let hints = Board.deserialize(entry.sudokuHints) {
                BoardView(hints: hints)
            }
        }
        .onAppear { loadEntries() }
    }

    private func loadEntries() {
        entries = ArchiveManager().allEntriesSorted()
    }

    private func deleteEntries(at offsets: IndexSet) {
        let manager = ArchiveManager()
        for idx in offsets {
            manager.remove(entryId: entries[idx].entryId)
        }
        manager.save()
        entries.remove(atOffsets: offsets)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = AppConfig.archiveDateFormat
        return f.string(from: date)
    }
}
