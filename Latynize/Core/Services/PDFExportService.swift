//
//  PDFExportService.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 22.04.2026.
//

import Foundation
import SwiftUI
import UIKit
import PDFKit

@MainActor
final class PDFExportService {
    
    static let shared = PDFExportService()
    private init() {}
    
    // MARK: - Page config (A4 for international standard)
    
    private let pageWidth: CGFloat = 595   // A4 width in pt
    private let pageHeight: CGFloat = 842  // A4 height in pt
    private let marginH: CGFloat = 56
    private let marginV: CGFloat = 56
    private let footerHeight: CGFloat = 40
    
    // MARK: - Professional color palette
    
    private let brandColor = UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 1)
    private let textPrimary = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)      // near-black, readable
    private let textSecondary = UIColor(red: 0.35, green: 0.35, blue: 0.37, alpha: 1)    // dark gray
    private let textMuted = UIColor(red: 0.55, green: 0.55, blue: 0.57, alpha: 1)        // medium gray (still readable)
    private let dividerColor = UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1)
    private let accentBgColor = UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 0.08)
    
    // MARK: - Public API
    
    func exportSingle(_ record: ConversionRecord) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let url = fileURL(for: "Latynize-Export")
        
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                drawSinglePage(record: record)
            }
            return url
        } catch {
            print("PDF generation failed: \(error)")
            return nil
        }
    }
    
    func exportBulk(_ records: [ConversionRecord], title: String) -> URL? {
        guard !records.isEmpty else { return nil }
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let url = fileURL(for: "Latynize-Export")
        
        do {
            try renderer.writePDF(to: url) { context in
                drawBulkDocument(records: records, title: title, in: context)
            }
            return url
        } catch {
            print("PDF generation failed: \(error)")
            return nil
        }
    }
    
    private func fileURL(for name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")
    }
    
    // MARK: - Single Page
    
    private func drawSinglePage(record: ConversionRecord) {
        var y = marginV
        
        // Header block
        y = drawHeader(y: y, rightText: record.createdAt.formatted(date: .abbreviated, time: .shortened))
        y += 8
        
        // Document title
        y = drawText(
            "Conversion Report",
            at: CGPoint(x: marginH, y: y),
            font: .systemFont(ofSize: 24, weight: .bold),
            color: textPrimary
        )
        y += 6
        
        let subtitleText = "\(record.direction.label) · \(record.alphabetVersion == "2021" ? "Standard 2021" : "Legacy 2018")"
        y = drawText(
            subtitleText,
            at: CGPoint(x: marginH, y: y),
            font: .systemFont(ofSize: 12, weight: .medium),
            color: textSecondary
        )
        y += 20
        
        drawDivider(y: y)
        y += 20
        
        // Original block
        y = drawLabel("ORIGINAL", y: y, color: textSecondary)
        y += 8
        y = drawBlockText(record.inputText, y: y, isAccent: false)
        y += 18
        
        // Converted block (accented)
        y = drawLabel("CONVERTED", y: y, color: brandColor)
        y += 8
        y = drawBlockText(record.outputText, y: y, isAccent: true)
        y += 24
        
        drawDivider(y: y)
        y += 16
        
        // Metadata — compact 2-column
        y = drawMetadataRow(left: ("Direction", record.direction.label),
                            right: ("Standard", record.alphabetVersion == "2021" ? "Standard 2021" : "Legacy 2018"),
                            y: y)
        y += 8
        y = drawMetadataRow(left: ("Source", record.source.rawValue.capitalized),
                            right: ("Created", record.createdAt.formatted(date: .abbreviated, time: .shortened)),
                            y: y)
        
        drawFooter(pageNumber: 1, totalPages: 1)
    }
    
    // MARK: - Bulk Document
    
    private func drawBulkDocument(records: [ConversionRecord], title: String, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = marginV
        var currentPage = 1
        
        // Header
        y = drawHeader(y: y, rightText: "\(records.count) records")
        y += 8
        
        // Document title
        y = drawText(
            title,
            at: CGPoint(x: marginH, y: y),
            font: .systemFont(ofSize: 24, weight: .bold),
            color: textPrimary
        )
        y += 6
        
        y = drawText(
            "Export · \(Date.now.formatted(date: .long, time: .shortened))",
            at: CGPoint(x: marginH, y: y),
            font: .systemFont(ofSize: 11, weight: .regular),
            color: textMuted
        )
        y += 24
        
        drawDivider(y: y)
        y += 16
        
        // Records (compact)
        for (index, record) in records.enumerated() {
            let estimatedHeight = estimatedCompactRecordHeight(record)
            
            if y + estimatedHeight > pageHeight - marginV - footerHeight {
                drawFooter(pageNumber: currentPage, totalPages: nil)
                context.beginPage()
                currentPage += 1
                y = marginV
                y = drawHeader(y: y, rightText: "Page \(currentPage)")
                y += 20
            }
            
            y = drawCompactRecord(record, index: index + 1, y: y)
            y += 14  // tight spacing between records
        }
        
        drawFooter(pageNumber: currentPage, totalPages: currentPage)
    }
    
    // MARK: - Header
    
    private func drawHeader(y: CGFloat, rightText: String) -> CGFloat {
        let startY = y
        
        // Latynize wordmark (left)
        drawText(
            "Latynize",
            at: CGPoint(x: marginH, y: startY),
            font: .systemFont(ofSize: 18, weight: .bold),
            color: textPrimary
        )
        
        // Right text
        let rightAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: textMuted
        ]
        let rightSize = rightText.size(withAttributes: rightAttrs)
        rightText.draw(
            at: CGPoint(x: pageWidth - marginH - rightSize.width, y: startY + 6),
            withAttributes: rightAttrs
        )
        
        // Brand accent line
        let lineRect = CGRect(x: marginH, y: startY + 28, width: 32, height: 2)
        brandColor.setFill()
        UIBezierPath(rect: lineRect).fill()
        
        return startY + 40
    }
    
    // MARK: - Footer
    
    private func drawFooter(pageNumber: Int, totalPages: Int?) {
        let footerY = pageHeight - marginV + 8
        
        // Divider
        let dividerRect = CGRect(x: marginH, y: footerY, width: pageWidth - marginH * 2, height: 0.5)
        dividerColor.setFill()
        UIBezierPath(rect: dividerRect).fill()
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textMuted
        ]
        
        // Left — Generated by Latynize
        let leftText = "Generated by Latynize"
        leftText.draw(at: CGPoint(x: marginH, y: footerY + 10), withAttributes: attrs)
        
        // Right — page number
        if let total = totalPages {
            let pageText = total > 1 ? "Page \(pageNumber) of \(total)" : ""
            if !pageText.isEmpty {
                let size = pageText.size(withAttributes: attrs)
                pageText.draw(
                    at: CGPoint(x: pageWidth - marginH - size.width, y: footerY + 10),
                    withAttributes: attrs
                )
            }
        }
    }
    
    // MARK: - Content helpers
    
    private func drawText(
        _ text: String,
        at point: CGPoint,
        font: UIFont,
        color: UIColor
    ) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        text.draw(at: point, withAttributes: attrs)
        return point.y + font.lineHeight
    }
    
    private func drawLabel(_ text: String, y: CGFloat, color: UIColor) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: color,
            .kern: 1.4
        ]
        text.draw(at: CGPoint(x: marginH, y: y), withAttributes: attrs)
        return y + 14
    }
    
    private func drawBlockText(_ text: String, y: CGFloat, isAccent: Bool) -> CGFloat {
        let availableWidth = pageWidth - marginH * 2
        let font = UIFont.systemFont(ofSize: 15, weight: isAccent ? .medium : .regular)
        let color = isAccent ? textPrimary : textPrimary
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 0
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attrs)
        let textRect = attributedString.boundingRect(
            with: CGSize(width: availableWidth - 24, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // Background box for accented block
        if isAccent {
            let bgRect = CGRect(
                x: marginH,
                y: y - 2,
                width: availableWidth,
                height: textRect.height + 16
            )
            let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 8)
            accentBgColor.setFill()
            bgPath.fill()
            
            // Left accent bar
            let barRect = CGRect(x: marginH, y: y - 2, width: 3, height: textRect.height + 16)
            brandColor.setFill()
            UIBezierPath(rect: barRect).fill()
            
            // Draw text with padding
            attributedString.draw(in: CGRect(
                x: marginH + 12,
                y: y + 6,
                width: availableWidth - 24,
                height: textRect.height
            ))
            
            return y + textRect.height + 14
        } else {
            // Simple text, no background
            attributedString.draw(in: CGRect(
                x: marginH,
                y: y,
                width: availableWidth,
                height: textRect.height
            ))
            return y + textRect.height
        }
    }
    
    private func drawMetadataRow(
        left: (label: String, value: String),
        right: (label: String, value: String),
        y: CGFloat
    ) -> CGFloat {
        let columnWidth = (pageWidth - marginH * 2) / 2
        
        drawMetadataCell(label: left.label, value: left.value, x: marginH, y: y, width: columnWidth)
        drawMetadataCell(label: right.label, value: right.value, x: marginH + columnWidth, y: y, width: columnWidth)
        
        return y + 32
    }
    
    private func drawMetadataCell(label: String, value: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: textMuted,
            .kern: 1.2
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: textPrimary
        ]
        
        label.uppercased().draw(at: CGPoint(x: x, y: y), withAttributes: labelAttrs)
        value.draw(at: CGPoint(x: x, y: y + 14), withAttributes: valueAttrs)
    }
    
    private func drawDivider(y: CGFloat) {
        let rect = CGRect(x: marginH, y: y, width: pageWidth - marginH * 2, height: 0.5)
        dividerColor.setFill()
        UIBezierPath(rect: rect).fill()
    }
    
    // MARK: - Compact bulk record
    
    private func drawCompactRecord(_ record: ConversionRecord, index: Int, y: CGFloat) -> CGFloat {
        var currentY = y
        let availableWidth = pageWidth - marginH * 2
        
        // Index chip + date
        let indexText = "#\(index)"
        let indexAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: brandColor,
            .kern: 0.6
        ]
        indexText.draw(at: CGPoint(x: marginH, y: currentY), withAttributes: indexAttrs)
        
        let dateText = record.createdAt.formatted(date: .abbreviated, time: .shortened)
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textMuted
        ]
        let dateSize = dateText.size(withAttributes: dateAttrs)
        dateText.draw(
            at: CGPoint(x: pageWidth - marginH - dateSize.width, y: currentY + 1),
            withAttributes: dateAttrs
        )
        currentY += 16
        
        // Original text
        let inputAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: textPrimary
        ]
        let inputString = NSAttributedString(string: record.inputText, attributes: inputAttrs)
        let inputRect = inputString.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )
        inputString.draw(in: CGRect(x: marginH, y: currentY, width: availableWidth, height: inputRect.height))
        currentY += inputRect.height + 2
        
        // Converted text with arrow prefix
        let arrowAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: brandColor
        ]
        "→".draw(at: CGPoint(x: marginH, y: currentY + 2), withAttributes: arrowAttrs)
        
        let outputAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: textPrimary
        ]
        let outputString = NSAttributedString(string: record.outputText, attributes: outputAttrs)
        let outputRect = outputString.boundingRect(
            with: CGSize(width: availableWidth - 16, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )
        outputString.draw(in: CGRect(x: marginH + 16, y: currentY, width: availableWidth - 16, height: outputRect.height))
        currentY += outputRect.height + 8
        
        // Subtle divider
        let dividerRect = CGRect(x: marginH, y: currentY, width: availableWidth, height: 0.25)
        dividerColor.setFill()
        UIBezierPath(rect: dividerRect).fill()
        
        return currentY
    }
    
    private func estimatedCompactRecordHeight(_ record: ConversionRecord) -> CGFloat {
        // Index row (16) + input (~18) + output (~18) + spacing (10) = ~62
        // Add more for long text
        let charCount = record.inputText.count + record.outputText.count
        let linesEstimate = max(2, (charCount / 60) + 2)
        return CGFloat(16 + linesEstimate * 17)
    }
}
