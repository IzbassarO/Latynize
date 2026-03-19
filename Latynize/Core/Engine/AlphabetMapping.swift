//
//  AlphabetMapping.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

// MARK: - Direction

enum ConversionDirection: String, Codable, CaseIterable {
    case cyrillicToLatin = "cyr_to_lat"
    case latinToCyrillic = "lat_to_cyr"
    
    var label: String {
        switch self {
        case .cyrillicToLatin: return "Кириллица → Латын"
        case .latinToCyrillic: return "Латын → Кириллица"
        }
    }
    
    var toggled: ConversionDirection {
        switch self {
        case .cyrillicToLatin: return .latinToCyrillic
        case .latinToCyrillic: return .cyrillicToLatin
        }
    }
}

// MARK: - Source

enum ConversionSource: String, Codable {
    case text
    case camera
    case shareExtension
    
    var icon: String {
        switch self {
        case .text: return "text.alignleft"
        case .camera: return "camera"
        case .shareExtension: return "square.and.arrow.up"
        }
    }
}

// MARK: - Alphabet Mapping Protocol

protocol AlphabetMapping: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var version: String { get }
    var yearLabel: String { get }
    var letterCount: Int { get }
    var isRecommended: Bool { get }
    
    /// Core mapping tables
    var cyrillicToLatin: [String: String] { get }
    var latinToCyrillic: [String: String] { get }
    
    /// Multi-character sequences that must be checked before single chars.
    /// Example: "Щ" → "ŞŞ" must be handled before "Ш" → "Ş"
    var cyrillicMultiCharKeys: [String] { get }
    var latinMultiCharKeys: [String] { get }
}

extension AlphabetMapping {
    
    /// Default implementation: multi-char keys sorted by length descending
    var cyrillicMultiCharKeys: [String] {
        cyrillicToLatin.keys
            .filter { $0.count > 1 }
            .sorted { $0.count > $1.count }
    }
    
    var latinMultiCharKeys: [String] {
        latinToCyrillic.keys
            .filter { $0.count > 1 }
            .sorted { $0.count > $1.count }
    }
}
