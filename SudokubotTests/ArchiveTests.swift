//
//  ArchiveTests.swift
//  SudokubotTests
//
//  Swift port of ArchiveTests.m.

import XCTest
@testable import Sudokubot

final class ArchiveTests: XCTestCase {

    let testHints = "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"
    let testSolution = "534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179"
    let testComment = "my comment"
    var now: TimeInterval = 0
    var oneMinuteLater: TimeInterval = 0
    var twoMinutesLater: TimeInterval = 0

    override func setUp() {
        super.setUp()
        now = Date().timeIntervalSince1970
        oneMinuteLater = now + 60
        twoMinutesLater = now + 120
        deleteArchiveFile()
    }

    override func tearDown() {
        deleteArchiveFile()
        super.tearDown()
    }

    private func deleteArchiveFile() {
        let url = AppConfig.archiveFileURL
        try? FileManager.default.removeItem(at: url)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path), "failed to clean archive")
    }

    private func makeEntry(seconds: TimeInterval, comments: String) -> ArchiveEntry {
        ArchiveEntry(entryId: -1, solution: testSolution, hints: testHints,
                     secondsSince1970: seconds, comments: comments)
    }

    func testArchiveEntryDate() {
        let entry = makeEntry(seconds: Date().timeIntervalSince1970, comments: "you noob")
        XCTAssertEqual(entry.creationDateGMT.timeIntervalSince1970, entry.secondsSince1970,
                       "Archive entry dates must be equal after construction")
    }

    func testArchiveStringRoundTrip() throws {
        let entry = ArchiveEntry(entryId: 7, solution: testSolution, hints: testHints,
                                 secondsSince1970: 1_234_567_890, comments: testComment)
        let reloaded = try XCTUnwrap(ArchiveEntry(archiveString: entry.archiveString))
        XCTAssertEqual(reloaded.entryId, entry.entryId)
        XCTAssertEqual(reloaded.sudokuSolution, entry.sudokuSolution)
        XCTAssertEqual(reloaded.sudokuHints, entry.sudokuHints)
        XCTAssertEqual(reloaded.secondsSince1970, entry.secondsSince1970)
        XCTAssertEqual(reloaded.comments, entry.comments)
    }

    func testLegacyArchiveStringStillLoads() throws {
        // exact format written by the original Objective-C app
        let legacy = "1\t\(testSolution)\t\(testHints)\t0\t\(testComment)"
        let entry = try XCTUnwrap(ArchiveEntry(archiveString: legacy))
        XCTAssertEqual(entry.entryId, 1)
        XCTAssertEqual(entry.comments, testComment)
        XCTAssertEqual(entry.secondsSince1970, 0)
    }

    func testRetrieveEntryBeforeSaving() throws {
        let manager = ArchiveManager()
        var entry = makeEntry(seconds: 0, comments: testComment)
        let newId = manager.add(&entry)
        let retrieved = try XCTUnwrap(manager.entry(byId: newId), "entry should exist in dictionary")
        XCTAssertEqual(retrieved.entryId, entry.entryId,
                       "entryIds should be equal before and after retrieval")
    }

    func testSaveArchive() throws {
        let manager = ArchiveManager()
        var entry = makeEntry(seconds: 0, comments: testComment)
        let newEntryId = manager.add(&entry)
        XCTAssertTrue(manager.save(), "archive file not saved")
        XCTAssertTrue(FileManager.default.fileExists(atPath: AppConfig.archiveFileURL.path),
                      "dictionary file should have been saved")

        let manager2 = ArchiveManager()
        let retrieved = try XCTUnwrap(manager2.entry(byId: newEntryId), "archive entry should be saved")
        XCTAssertEqual(retrieved.entryId, newEntryId)
        XCTAssertEqual(retrieved.comments, entry.comments)
        XCTAssertEqual(retrieved.sudokuSolution, entry.sudokuSolution)
        XCTAssertEqual(retrieved.sudokuHints, entry.sudokuHints)
        XCTAssertEqual(retrieved.secondsSince1970, entry.secondsSince1970)
    }

    func testSaveMultipleEntries() throws {
        var entry1 = makeEntry(seconds: now, comments: "entry1")
        var entry2 = makeEntry(seconds: oneMinuteLater, comments: "entry2")
        var entry3 = makeEntry(seconds: twoMinutesLater, comments: "entry3")

        let manager = ArchiveManager()
        let entryId2 = manager.add(&entry2)
        let entryId1 = manager.add(&entry1)
        let entryId3 = manager.add(&entry3)
        XCTAssertTrue(manager.save(), "archive file can not save")

        let manager2 = ArchiveManager()
        XCTAssertEqual(try XCTUnwrap(manager2.entry(byId: entryId1)).comments, "entry1")
        XCTAssertEqual(try XCTUnwrap(manager2.entry(byId: entryId2)).comments, "entry2")
        XCTAssertEqual(try XCTUnwrap(manager2.entry(byId: entryId3)).comments, "entry3")
        let allEntries = manager2.allEntriesSorted()
        XCTAssertEqual(allEntries.count, 3, "retrieval count should be 3")
        XCTAssertEqual(allEntries[0].comments, "entry3", "allEntries should be sorted by date")
        XCTAssertEqual(allEntries[1].comments, "entry2", "allEntries should be sorted by date")
        XCTAssertEqual(allEntries[2].comments, "entry1", "allEntries should be sorted by date")
    }

    func testRemoveEntry() {
        var entry1 = makeEntry(seconds: now, comments: "entry1")
        var entry2 = makeEntry(seconds: oneMinuteLater, comments: "entry2")
        var entry3 = makeEntry(seconds: twoMinutesLater, comments: "entry3")

        let manager = ArchiveManager()
        let entryId2 = manager.add(&entry2)
        let entryId1 = manager.add(&entry1)
        let entryId3 = manager.add(&entry3)
        XCTAssertTrue(manager.save(), "archive file can not save")

        let manager2 = ArchiveManager()
        manager2.remove(entryId: entryId2)
        XCTAssertNil(manager2.entry(byId: entryId2), "entry2 should be removed")
        XCTAssertEqual(manager2.allEntriesSorted().count, 2, "should be only 2 entries after removal")
        manager2.save()

        let manager3 = ArchiveManager()
        XCTAssertEqual(manager3.allEntriesSorted().count, 2, "should only be 2 entries after removal and reload")
        XCTAssertNil(manager3.entry(byId: entryId2), "entry2 should be removed")
        XCTAssertNotNil(manager3.entry(byId: entryId1), "entry1 should remain")
        XCTAssertNotNil(manager3.entry(byId: entryId3), "entry3 should remain")
        manager3.remove(entryId: entryId1)
        manager3.remove(entryId: entryId3)
        manager3.save()

        let manager4 = ArchiveManager()
        XCTAssertEqual(manager4.allEntriesSorted().count, 0, "archive should be empty")
    }

    func testUpdateEntry() throws {
        var entry1 = makeEntry(seconds: now, comments: "entry1")
        var entry2 = makeEntry(seconds: oneMinuteLater, comments: "entry2")

        let manager = ArchiveManager()
        _ = manager.add(&entry2)
        let entryId1 = manager.add(&entry1)
        XCTAssertTrue(manager.save(), "archive file can not save")

        let manager2 = ArchiveManager()
        var retrieved1 = try XCTUnwrap(manager2.entry(byId: entryId1))
        let newComment = "your comment"
        retrieved1.comments = newComment
        manager2.update(retrieved1)
        let retrieved2 = try XCTUnwrap(manager2.entry(byId: entryId1))
        XCTAssertEqual(retrieved2.comments, newComment, "comments should equal after update")
        manager2.save()

        let manager3 = ArchiveManager()
        let retrieved3 = try XCTUnwrap(manager3.entry(byId: entryId1))
        XCTAssertEqual(retrieved3.comments, newComment, "comment should be updated")
    }
}
