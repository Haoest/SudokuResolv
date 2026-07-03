//
//  ArchiveManager.swift
//  Sudokubot
//
//  Swift port of ArchiveManager.m. The archive remains a plist dictionary of
//  entryId -> tab-separated archive string, so existing archives still load.

import Foundation

final class ArchiveManager {

    private var allEntries: [String: String]

    init() {
        if let dict = NSDictionary(contentsOf: AppConfig.archiveFileURL) as? [String: String] {
            allEntries = dict
        } else {
            allEntries = [:]
        }
    }

    func entry(byId entryId: Int) -> ArchiveEntry? {
        guard let raw = allEntries[String(entryId)] else { return nil }
        return ArchiveEntry(archiveString: raw)
    }

    /// Assigns the next free id to entries created with entryId == -1 and
    /// returns it; entries that already carry an id are rejected with -1.
    @discardableResult
    func add(_ entry: inout ArchiveEntry) -> Int {
        guard entry.entryId == -1 else { return -1 }
        entry.entryId = nextEntryId()
        allEntries[String(entry.entryId)] = entry.archiveString
        return entry.entryId
    }

    func update(_ entry: ArchiveEntry) {
        guard entry.entryId >= 0 else { return }
        allEntries[String(entry.entryId)] = entry.archiveString
    }

    func remove(entryId: Int) {
        allEntries.removeValue(forKey: String(entryId))
    }

    @discardableResult
    func save() -> Bool {
        (allEntries as NSDictionary).write(to: AppConfig.archiveFileURL, atomically: false)
    }

    /// All entries sorted by creation date, newest first.
    func allEntriesSorted() -> [ArchiveEntry] {
        allEntries.values
            .compactMap { ArchiveEntry(archiveString: $0) }
            .sorted { $0.secondsSince1970 > $1.secondsSince1970 }
    }

    private func nextEntryId() -> Int {
        (allEntries.keys.compactMap { Int($0) }.max() ?? 0) + 1
    }
}
