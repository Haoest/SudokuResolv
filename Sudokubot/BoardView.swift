import SwiftUI

struct BoardView: View {
    let hints: [[Int]]

    @State private var solution: [[Int]]? = nil
    @State private var isSolving = true
    @State private var comment = ""
    @State private var savedEntryId: Int32 = -1
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
        let hintsNS = hints.map { $0.map { NSNumber(value: $0) } }
        let result = await Task.detached(priority: .userInitiated) {
            SudokuBridge.solve(hintsNS)
        }.value

        isSolving = false
        if let nsResult = result as? [[NSNumber]] {
            solution = nsResult.map { $0.map { $0.intValue } }
        } else {
            errorMessage = "This puzzle has no solution or something went wrong."
        }
    }

    private func saveOrUpdate(_ sol: [[Int]]) {
        let solNS = sol.map { $0.map { NSNumber(value: $0) } }
        let hintsNS = hints.map { $0.map { NSNumber(value: $0) } }
        if savedEntryId < 0 {
            let newId = SudokuBridge.save(toArchive: solNS, hints: hintsNS, comment: comment)
            if newId >= 0 { savedEntryId = Int32(newId) }
        } else {
            SudokuBridge.updateArchiveEntry(Int32(savedEntryId), comment: comment)
        }
        showSaveConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSaveConfirmation = false }
    }
}
