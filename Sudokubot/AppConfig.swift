//
//  AppConfig.swift
//  Sudokubot
//
//  Swift port of AppConfig.m; only the values the SwiftUI app still uses.

import Foundation

enum AppConfig {

    static var archiveFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("archive")
    }

    static let archiveDateFormat = "yyyy-MM-dd HH:mm"
}
