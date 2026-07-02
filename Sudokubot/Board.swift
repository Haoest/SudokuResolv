//
//  Board.swift
//  Sudokubot
//
//  Board <-> string conversion in the legacy archive format: nine groups of
//  nine digits, each group followed by a single space.

import Foundation

enum Board {

    static func serialize(_ board: [[Int]]) -> String {
        var rv = ""
        for row in board {
            for value in row {
                rv += String(value)
            }
            rv += " "
        }
        return rv
    }

    /// Returns nil unless the string holds nine 9-digit groups of values 0...9.
    static func deserialize(_ string: String) -> [[Int]]? {
        let groups = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
        guard groups.count == 9 else { return nil }
        var board = [[Int]]()
        for group in groups {
            guard group.count == 9 else { return nil }
            var row = [Int]()
            for ch in group {
                guard let digit = ch.wholeNumberValue, (0...9).contains(digit) else { return nil }
                row.append(digit)
            }
            board.append(row)
        }
        return board
    }
}
