import SwiftUI

struct BoardView: View {
    let hints: [[Int]]

    @State private var solution: [[Int]]? = nil
    @State private var isSolving = true
    @State private var comment = ""
    @State private var savedEntryId: Int = -1
    @State private var showSaveConfirmation = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.2, blue: 0.2),
                         Color(red: 0.0, green: 0.0, blue: 0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                if isSolving {
                    ProgressView("Solving...")
                        .tint(.white)
                        .foregroundStyle(.white)
                } else if let sol = solution {
                    solvedGrid(sol)

                    TextField("Add a comment...", text: $comment)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button(savedEntryId >= 0 ? "Update Comment" : "Save to Archive") {
                        saveOrUpdate(sol)
                    }
                    .buttonStyle(.borderedProminent)

                    if showSaveConfirmation {
                        Text("Saved!")
                            .foregroundStyle(.green)
                    }
                } else {
                    Text("No solution found for this puzzle.")
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Solution")
        .navigationBarTitleDisplayMode(.inline)
        .alert(errorMessage ?? "", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
        .task { await solve() }
    }

    private func solvedGrid(_ sol: [[Int]]) -> some View {
        VStack(spacing: 1) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<9, id: \.self) { col in
                        ZStack {
                            Rectangle().fill(Color.black.opacity(0.3))
                            Text("\(sol[row][col])")
                                .foregroundStyle(hints[row][col] != 0 ? Color.red : Color.white)
                                .font(.system(size: 14, weight: hints[row][col] != 0 ? .bold : .regular))
                        }
                        .frame(width: 34, height: 34)
                        .border(col % 3 == 2 ? Color.black : Color.gray.opacity(0.5),
                                width: col % 3 == 2 ? 1.5 : 0.5)
                    }
                }
            }
        }
        .border(Color.black, width: 2)
    }

    @MainActor
    private func solve() async {
        let hints = self.hints
        let result = await Task.detached(priority: .userInitiated) {
            Solver.solve(hints)
        }.value

        isSolving = false
        if let result {
            solution = result
        } else {
            errorMessage = "This puzzle has no solution or something went wrong."
        }
    }

    private func saveOrUpdate(_ sol: [[Int]]) {
        let manager = ArchiveManager()
        if savedEntryId < 0 {
            var entry = ArchiveEntry(entryId: -1,
                                     solution: Board.serialize(sol),
                                     hints: Board.serialize(hints),
                                     secondsSince1970: Date().timeIntervalSince1970,
                                     comments: comment)
            let newId = manager.add(&entry)
            if manager.save() && newId >= 0 { savedEntryId = newId }
        } else if var entry = manager.entry(byId: savedEntryId) {
            entry.comments = comment
            manager.update(entry)
            manager.save()
        }
        showSaveConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSaveConfirmation = false }
    }
}
