//
//  ArchiveEntry.swift
//  Sudokubot
//
//  Swift port of ArchiveEntry.mm. The tab-separated archive string format is
//  unchanged so archives written by the original app still load.

import Foundation

struct ArchiveEntry: Identifiable {
    var entryId: Int
    var comments: String
    var sudokuSolution: String
    var sudokuHints: String
    var secondsSince1970: Double

    var id: Int { entryId }

    init(entryId: Int, solution: String, hints: String, secondsSince1970: Double, comments: String) {
        self.entryId = entryId
        self.sudokuSolution = solution
        self.sudokuHints = hints
        self.secondsSince1970 = secondsSince1970
        self.comments = comments
    }

    init?(archiveString: String) {
        let segments = archiveString.components(separatedBy: "\t")
        guard segments.count >= 5, let entryId = Int(segments[0]), let seconds = Double(segments[3]) else {
            return nil
        }
        self.init(entryId: entryId,
                  solution: segments[1],
                  hints: segments[2],
                  secondsSince1970: seconds,
                  comments: segments[4])
    }

    var archiveString: String {
        "\(entryId)\t\(sudokuSolution)\t\(sudokuHints)\t\(String(format: "%.0f", secondsSince1970))\t\(comments)"
    }

    var creationDateGMT: Date {
        Date(timeIntervalSince1970: secondsSince1970)
    }
}
