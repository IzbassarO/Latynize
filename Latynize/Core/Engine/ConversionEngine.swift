//
//  ConversionEngine.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

/// Central conversion engine. Thread-safe, stateless per conversion call.
/// Holds a registry of available alphabet mappings and performs conversion.
final class ConversionEngine: @unchecked Sendable {
    
    static let shared = ConversionEngine()
    
    // MARK: - Registry
    
    private let mappings: [String: any AlphabetMapping]
    private let defaultMappingID = "2021"
    
    init() {
        let m2021 = Alphabet2021()
        let m2018 = Alphabet2018()
        self.mappings = [
            m2021.id: m2021,
            m2018.id: m2018,
        ]
    }
    
    var availableMappings: [any AlphabetMapping] {
        mappings.values
            .sorted { $0.id > $1.id } // newest first
    }
    
    func mapping(for id: String) -> (any AlphabetMapping)? {
        mappings[id]
    }
    
    // MARK: - Conversion
    
    struct ConversionResult {
        let output: String
        let direction: ConversionDirection
        let mappingID: String
        let inputCharCount: Int
        let outputCharCount: Int
    }
    
    /// Primary conversion method.
    /// - Parameters:
    ///   - input: Source text to convert
    ///   - direction: Conversion direction
    ///   - mappingID: Which alphabet standard to use (defaults to "2021")
    /// - Returns: Conversion result with metadata
    func convert(
        _ input: String,
        direction: ConversionDirection,
        mappingID: String? = nil
    ) -> ConversionResult {
        let resolvedID = mappingID ?? defaultMappingID
        
        guard let mapping = mappings[resolvedID] else {
            // Fallback: return input unchanged if mapping not found
            return ConversionResult(
                output: input,
                direction: direction,
                mappingID: resolvedID,
                inputCharCount: input.count,
                outputCharCount: input.count
            )
        }
        
        let table: [String: String]
        let multiCharKeys: [String]
        
        switch direction {
        case .cyrillicToLatin:
            table = mapping.cyrillicToLatin
            multiCharKeys = mapping.cyrillicMultiCharKeys
        case .latinToCyrillic:
            table = mapping.latinToCyrillic
            multiCharKeys = mapping.latinMultiCharKeys
        }
        
        let output = performConversion(input: input, table: table, multiCharKeys: multiCharKeys)
        
        return ConversionResult(
            output: output,
            direction: direction,
            mappingID: resolvedID,
            inputCharCount: input.count,
            outputCharCount: output.count
        )
    }
    
    /// Convenience: convert with auto-detected direction.
    /// Falls back to cyrillicToLatin if detection is ambiguous.
    func convertAutoDetect(
        _ input: String,
        mappingID: String? = nil
    ) -> ConversionResult {
        let direction = ScriptDetector.suggestedDirection(for: input) ?? .cyrillicToLatin
        return convert(input, direction: direction, mappingID: mappingID)
    }
    
    // MARK: - Core Algorithm
    
    /// Greedy left-to-right matching: try multi-char keys first, then single char.
    /// Characters not in the mapping table are passed through unchanged
    /// (digits, punctuation, spaces, emoji, etc.)
    private func performConversion(
        input: String,
        table: [String: String],
        multiCharKeys: [String]
    ) -> String {
        var result = ""
        result.reserveCapacity(input.count)
        
        let chars = Array(input)
        var i = 0
        
        while i < chars.count {
            var matched = false
            
            // Try multi-character sequences first (longest match)
            for key in multiCharKeys {
                let keyLen = key.count
                if i + keyLen <= chars.count {
                    let substring = String(chars[i..<(i + keyLen)])
                    if let replacement = table[substring] {
                        result.append(replacement)
                        i += keyLen
                        matched = true
                        break
                    }
                }
            }
            
            if !matched {
                let char = String(chars[i])
                if let replacement = table[char] {
                    result.append(replacement)
                } else {
                    // Pass through unchanged (digits, spaces, punctuation, etc.)
                    result.append(char)
                }
                i += 1
            }
        }
        
        return result
    }
}
