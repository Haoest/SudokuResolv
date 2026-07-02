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
                    ForEach(entries, id: \.entryId) { entry in
                        Button {
                            selectedEntry = entry
                            navigateToBoard = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text(formattedDate(entry.getCreationDateGMT()))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let comment = entry.comments, !comment.isEmpty {
                                    Text(comment)
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
               let hintStr = entry.sudokuHints,
               let hintsNS = SudokuBridge.deserializeBoard(hintStr) as? [[NSNumber]] {
                let hints = hintsNS.map { $0.map { $0.intValue } }
                BoardView(hints: hints)
            }
        }
        .onAppear { loadEntries() }
    }

    private func loadEntries() {
        entries = SudokuBridge.loadAllArchiveEntries() as? [ArchiveEntry] ?? []
    }

    private func deleteEntries(at offsets: IndexSet) {
        for idx in offsets {
            SudokuBridge.deleteArchiveEntry(Int32(entries[idx].entryId))
        }
        entries.remove(atOffsets: offsets)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let f = DateFormatter()
        f.dateFormat = AppConfig.archiveDateFormat()
        return f.string(from: date)
    }
}
