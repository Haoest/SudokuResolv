//
//Copyright 2011 Haoest
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

//  Solver.swift
//  Sudokubot
//
//  Swift port of the original Objective-C++ backtracking solver (solver.mm).

import Foundation

enum Solver {

    // 3x3 unit membership expressed as ordinal cell indexes (row * 9 + col),
    // indexed by unit number
    private static let boardUnitIndexes: [[Int]] = [
        [0, 1, 2, 9, 10, 11, 18, 19, 20],
        [3, 4, 5, 12, 13, 14, 21, 22, 23],
        [6, 7, 8, 15, 16, 17, 24, 25, 26],

        [27, 28, 29, 36, 37, 38, 45, 46, 47],
        [30, 31, 32, 39, 40, 41, 48, 49, 50],
        [33, 34, 35, 42, 43, 44, 51, 52, 53],

        [54, 55, 56, 63, 64, 65, 72, 73, 74],
        [57, 58, 59, 66, 67, 68, 75, 76, 77],
        [60, 61, 62, 69, 70, 71, 78, 79, 80],
    ]

    private static func unitSequence(row: Int, column: Int) -> [Int] {
        boardUnitIndexes[(row / 3) * 3 + column / 3]
    }

    /// Returns the solved board, or nil when the hints admit no solution.
    static func solve(_ hints: [[Int]]) -> [[Int]]? {
        var board = hints
        var boxSpace = [[Set<Int>]](repeating: [Set<Int>](repeating: [], count: 9), count: 9)
        for row in 0..<9 {
            for col in 0..<9 {
                boxSpace[row][col] = boxSampleSpace(board, row: row, column: col)
            }
        }
        if trySolveRecursively(&board, boxSpace, 0) {
            return board
        }
        return nil
    }

    // candidate values for an empty cell; empty set for a hinted cell
    private static func boxSampleSpace(_ board: [[Int]], row: Int, column: Int) -> Set<Int> {
        if board[row][column] > 0 {
            return []
        }
        var rv = Set(1...9)
        for i in 0..<9 {
            rv.remove(board[row][i])
            rv.remove(board[i][column])
        }
        for ordinal in unitSequence(row: row, column: column) {
            rv.remove(board[ordinal / 9][ordinal % 9])
        }
        return rv
    }

    private static func isUnique(in board: [[Int]], value: Int, boxIndex: Int) -> Bool {
        let row = boxIndex / 9
        let column = boxIndex % 9
        let unit = unitSequence(row: row, column: column)
        for i in 0..<9 {
            if board[row][i] == value { return false }
            if board[i][column] == value { return false }
            let ordinal = unit[i]
            if board[ordinal / 9][ordinal % 9] == value { return false }
        }
        return true
    }

    private static func trySolveRecursively(_ board: inout [[Int]], _ boxSpace: [[Set<Int>]], _ boxIndex: Int) -> Bool {
        if boxIndex == 9 * 9 {
            return true
        }
        let curBox = boxSpace[boxIndex / 9][boxIndex % 9]
        if curBox.isEmpty { // is hint
            return trySolveRecursively(&board, boxSpace, boxIndex + 1)
        }
        for candidate in curBox.sorted() {
            if isUnique(in: board, value: candidate, boxIndex: boxIndex) {
                board[boxIndex / 9][boxIndex % 9] = candidate
                if trySolveRecursively(&board, boxSpace, boxIndex + 1) {
                    return true
                }
            }
        }
        board[boxIndex / 9][boxIndex % 9] = 0
        return false
    }

    /// A completed board is valid when every row, column, and unit holds nine
    /// distinct values in 1...9.
    static func verifySolution(_ board: [[Int]]) -> Bool {
        for i in 0..<9 {
            let unit = boardUnitIndexes[i]
            for j in 0..<8 {
                for k in (j + 1)..<9 {
                    // horizontal check
                    if board[i][k] == board[i][j] { return false }
                    // vertical
                    if board[k][i] == board[j][i] { return false }
                    // unit
                    let oj = unit[j]
                    let ok = unit[k]
                    if board[oj / 9][oj % 9] == board[ok / 9][ok % 9] { return false }
                }
            }
        }
        for row in board {
            for value in row where value <= 0 || value > 9 {
                return false
            }
        }
        return true
    }

    /// Hints are valid when no filled value repeats within a row, column, or unit.
    static func verifyHints(_ board: [[Int]]) -> Bool {
        for i in 0..<9 {
            let unit = boardUnitIndexes[i]
            for j in 0..<8 {
                for k in (j + 1)..<9 {
                    if board[i][k] == board[i][j] && board[i][j] != 0 { return false }
                    if board[k][i] == board[j][i] && board[j][i] != 0 { return false }
                    let oj = unit[j]
                    let ok = unit[k]
                    if board[oj / 9][oj % 9] != 0 && board[oj / 9][oj % 9] == board[ok / 9][ok % 9] { return false }
                }
            }
        }
        for row in board {
            for value in row where value < 0 || value > 9 {
                return false
            }
        }
        return true
    }
}
