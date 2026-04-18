import UIKit

final class KeyboardViewController: UIInputViewController {

    private let engine = ConversionEngine.shared
    private let settings = AppSettings.shared

    private var isUppercase = false
    private var isCapsLock = false
    private var lastShiftTap: Date?

    private var lastBuiltWidth: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint?
    
    private let keyboardHeight: CGFloat = 260

    private let teal = UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 1)
    private let gray = UIColor(red: 0.67, green: 0.68, blue: 0.70, alpha: 1)
    private let bg = UIColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1)

    private let containerTag = 999

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bg
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyKeyboardHeight()
        lastBuiltWidth = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width
        guard width > 100 else { return }
        if abs(width - lastBuiltWidth) > 1 {
            lastBuiltWidth = width
            buildKeys()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        applyKeyboardHeight()
    }
    
    // MARK: - Height Fix
    
    private func applyKeyboardHeight() {
        if let existing = heightConstraint {
            if existing.constant != keyboardHeight {
                existing.constant = keyboardHeight
            }
            return
        }
        
        view.constraints.forEach { c in
            if c.firstAttribute == .height && c.secondItem == nil {
                view.removeConstraint(c)
            }
        }
        
        let hc = view.heightAnchor.constraint(equalToConstant: keyboardHeight)
        hc.priority = UILayoutPriority(999)
        hc.isActive = true
        heightConstraint = hc
    }
    
    // MARK: - Build

    private func buildKeys() {
        view.subviews.forEach {
            if $0.tag == containerTag { $0.removeFromSuperview() }
        }

        let width = view.bounds.width
        guard width > 100 else { return }
        
        let height = keyboardHeight
        let sidePadding: CGFloat = 3
        let topPadding: CGFloat = 4
        let bottomPadding: CGFloat = 4
        let horizontalGap: CGFloat = 5
        let verticalGap: CGFloat = 6

        let rows = kazakhLayout
        let usableWidth = width - sidePadding * 2
        let usableHeight = height - topPadding - bottomPadding
        let rowCount = CGFloat(rows.count)
        let keyHeight = (usableHeight - (rowCount - 1) * verticalGap) / rowCount

        let container = UIView(frame: CGRect(x: sidePadding, y: topPadding, width: usableWidth, height: usableHeight))
        container.tag = containerTag
        container.backgroundColor = .clear
        view.addSubview(container)

        let maxKeysInRow = 11
        let singleKeyW = (usableWidth - CGFloat(maxKeysInRow - 1) * horizontalGap) / CGFloat(maxKeysInRow)

        for (rowIndex, row) in rows.enumerated() {
            let y = CGFloat(rowIndex) * (keyHeight + verticalGap)
            let isBottom = rowIndex == rows.count - 1

            if isBottom {
                drawBottomRow(row, in: container, y: y, keyHeight: keyHeight,
                              totalWidth: usableWidth, gap: horizontalGap)
            } else {
                drawStandardRow(row, in: container, y: y, keyHeight: keyHeight,
                                singleKeyW: singleKeyW, totalWidth: usableWidth,
                                gap: horizontalGap)
            }
        }
    }
    
    private func drawStandardRow(
        _ row: [KeyModel], in container: UIView, y: CGFloat,
        keyHeight: CGFloat, singleKeyW: CGFloat, totalWidth: CGFloat, gap: CGFloat
    ) {
        let keyCount = CGFloat(row.count)
        let rowWidth = keyCount * singleKeyW + (keyCount - 1) * gap
        var x = max((totalWidth - rowWidth) / 2, 0)

        for key in row {
            let button = makeButton(for: key)
            button.frame = CGRect(x: x, y: y, width: singleKeyW, height: keyHeight)
            container.addSubview(button)
            x += singleKeyW + gap
        }
    }

    private func drawBottomRow(
        _ row: [KeyModel], in container: UIView, y: CGFloat,
        keyHeight: CGFloat, totalWidth: CGFloat, gap: CGFloat
    ) {
        // , | space | . | return
        let punctW: CGFloat = 52
        let returnW: CGFloat = 90
        let spaceW = totalWidth - punctW * 2 - returnW - gap * 3

        let widths: [CGFloat] = [punctW, spaceW, punctW, returnW]

        var x: CGFloat = 0
        for (index, key) in row.enumerated() {
            let w = index < widths.count ? widths[index] : punctW
            let button = makeButton(for: key)
            button.frame = CGRect(x: x, y: y, width: w, height: keyHeight)
            container.addSubview(button)
            x += w + gap
        }
    }

    // MARK: - Button

    private func makeButton(for key: KeyModel) -> UIButton {
        let button = UIButton(type: .system)

        switch key.type {
        case .character:
            let title = (isUppercase || isCapsLock) ? key.label.uppercased() : key.label.lowercased()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 22)
            button.setTitleColor(.label, for: .normal)
            button.backgroundColor = .white

        case .shift:
            let icon = isCapsLock ? "capslock.fill" : (isUppercase ? "shift.fill" : "shift")
            button.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
            button.tintColor = (isUppercase || isCapsLock) ? .white : .label
            button.backgroundColor = (isUppercase || isCapsLock) ? teal : gray

        case .backspace:
            button.setImage(UIImage(systemName: "delete.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
            button.tintColor = .label
            button.backgroundColor = gray

        case .space:
            button.setTitle("Latynize", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.backgroundColor = .white

        case .returnKey:
            button.setImage(UIImage(systemName: "return", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
            button.tintColor = .white
            button.backgroundColor = teal
        }

        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 0
        button.clipsToBounds = false

        switch key.type {
        case .character:
            button.addAction(UIAction { [weak self] _ in self?.onKey(key.label) }, for: .touchUpInside)
        case .shift:
            button.addAction(UIAction { [weak self] _ in self?.onShift() }, for: .touchUpInside)
        case .backspace:
            button.addAction(UIAction { [weak self] _ in self?.onBackspace() }, for: .touchUpInside)
            button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongBackspace(_:))))
        case .space:
            button.addAction(UIAction { [weak self] _ in self?.onSpace() }, for: .touchUpInside)
        case .returnKey:
            button.addAction(UIAction { [weak self] _ in self?.onReturn() }, for: .touchUpInside)
        }

        return button
    }

    // MARK: - Actions

    private func onKey(_ label: String) {
        // Punctuation passes through directly, no conversion
        if label == "," || label == "." {
            textDocumentProxy.insertText(label)
            haptic()
            return
        }
        
        let cyrillic = (isUppercase || isCapsLock) ? label.uppercased() : label.lowercased()
        let latin = engine.convert(cyrillic, direction: .cyrillicToLatin, mappingID: settings.alphabetVersion).output
        textDocumentProxy.insertText(latin)
        
        if isUppercase && !isCapsLock {
            isUppercase = false
            buildKeys()
        }
        haptic()
    }
    
    private func onShift() {
        let now = Date()
        if let last = lastShiftTap, now.timeIntervalSince(last) < 0.35 {
            isCapsLock = true; isUppercase = true; lastShiftTap = nil
        } else if isCapsLock {
            isCapsLock = false; isUppercase = false; lastShiftTap = nil
        } else {
            isUppercase.toggle(); lastShiftTap = now
        }
        buildKeys()
        haptic()
    }

    private func onBackspace() {
        textDocumentProxy.deleteBackward()
        haptic()
    }

    @objc private func onLongBackspace(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            textDocumentProxy.deleteBackward()
        }
    }

    private func onSpace() {
        textDocumentProxy.insertText(" ")
        haptic()
    }

    private func onReturn() {
        textDocumentProxy.insertText("\n")
        haptic()
    }

    private func haptic() {
        if settings.hapticEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
