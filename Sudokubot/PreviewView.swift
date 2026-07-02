import SwiftUI

struct PreviewView: View {
    let image: UIImage

    @State private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    @State private var isRecognizing = true
    @State private var recognitionFailed = false
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var navigateToBoard = false
    @State private var errorMessage: String? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.2, blue: 0.2),
                         Color(red: 0.0, green: 0.0, blue: 0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .border(Color.white, width: 1)

                if isRecognizing {
                    ProgressView("Recognizing board...")
                        .tint(.white)
                        .foregroundStyle(.white)
                } else if recognitionFailed {
                    Text("Could not find a Sudoku board in this photo. Try a clearer, well-lit shot.")
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    boardGrid
                    numpad
                    HStack {
                        Button("Solve") {
                            navigateToBoard = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(board.flatMap { $0 }.allSatisfy { $0 == 0 })

                        Button("Cancel") { dismiss() }
                            .buttonStyle(.bordered)
                            .tint(.white)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToBoard) {
            BoardView(hints: board)
        }
        .alert(errorMessage ?? "", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
        .task {
            await recognizeBoard()
        }
    }

    private var boardGrid: some View {
        VStack(spacing: 1) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<9, id: \.self) { col in
                        let val = board[row][col]
                        let isSelected = selectedCell?.row == row && selectedCell?.col == col
                        ZStack {
                            Rectangle()
                                .fill(isSelected ? Color.green.opacity(0.5) : Color.black.opacity(0.3))
                            if val > 0 {
                                Text("\(val)")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .frame(width: 34, height: 34)
                        .border(boxBorderColor(row: row, col: col), width: boxBorderWidth(row: row, col: col))
                        .onTapGesture {
                            selectedCell = (row, col)
                        }
                    }
                }
            }
        }
        .border(Color.black, width: 2)
    }

    private var numpad: some View {
        HStack(spacing: 8) {
            ForEach(0..<10, id: \.self) { n in
                Button(n == 0 ? "✕" : "\(n)") {
                    if let cell = selectedCell {
                        board[cell.row][cell.col] = n
                        selectedCell = nil
                    }
                }
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.2))
                .foregroundStyle(.white)
                .cornerRadius(4)
                .disabled(selectedCell == nil)
            }
        }
    }

    private func boxBorderColor(row: Int, col: Int) -> Color {
        (row % 3 == 2 || col % 3 == 2) ? Color.black : Color.gray.opacity(0.5)
    }

    private func boxBorderWidth(row: Int, col: Int) -> CGFloat {
        (row % 3 == 2 || col % 3 == 2) ? 1.5 : 0.5
    }

    @MainActor
    private func recognizeBoard() async {
        let result = await Task.detached(priority: .userInitiated) {
            SudokuBridge.recognizeBoard(self.image)
        }.value

        isRecognizing = false
        if let result, result.success, let nsBoard = result.board as? [[NSNumber]] {
            board = nsBoard.map { $0.map { $0.intValue } }
        } else {
            recognitionFailed = true
        }
    }
}
