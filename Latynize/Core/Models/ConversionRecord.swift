//
//  ConversionRecord.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftData

@Model
final class ConversionRecord {
    
    var id: UUID
    var inputText: String
    var outputText: String
    
    /// Stored as raw string for SwiftData compatibility
    private var directionRaw: String
    private var sourceRaw: String
    
    var alphabetVersion: String
    var createdAt: Date
    var isFavorite: Bool
    
    // MARK: - Computed Properties
    
    var direction: ConversionDirection {
        get { ConversionDirection(rawValue: directionRaw) ?? .cyrillicToLatin }
        set { directionRaw = newValue.rawValue }
    }
    
    var source: ConversionSource {
        get { ConversionSource(rawValue: sourceRaw) ?? .text }
        set { sourceRaw = newValue.rawValue }
    }
    
    var inputPreview: String {
        if inputText.count <= 60 { return inputText }
        return String(inputText.prefix(57)) + "..."
    }
    
    var outputPreview: String {
        if outputText.count <= 60 { return outputText }
        return String(outputText.prefix(57)) + "..."
    }
    
    // MARK: - Init
    
    init(
        inputText: String,
        outputText: String,
        direction: ConversionDirection,
        source: ConversionSource = .text,
        alphabetVersion: String = "2021",
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.inputText = inputText
        self.outputText = outputText
        self.directionRaw = direction.rawValue
        self.sourceRaw = source.rawValue
        self.alphabetVersion = alphabetVersion
        self.createdAt = Date()
        self.isFavorite = isFavorite
    }
}
