import Foundation

struct KeyModel {
    let label: String
    let type: KeyType
    let tag: Int
    
    enum KeyType {
        case character
        case shift
        case backspace
        case space
        case returnKey
    }
}

// MARK: - Kazakh Cyrillic → Latin (auto-convert)

let kazakhLayout: [[KeyModel]] = [
    // Row 1: Kazakh special letters (9)
    [
        KeyModel(label: "ә", type: .character, tag: 1),
        KeyModel(label: "і", type: .character, tag: 2),
        KeyModel(label: "ң", type: .character, tag: 3),
        KeyModel(label: "ғ", type: .character, tag: 4),
        KeyModel(label: "ү", type: .character, tag: 5),
        KeyModel(label: "ұ", type: .character, tag: 6),
        KeyModel(label: "қ", type: .character, tag: 7),
        KeyModel(label: "ө", type: .character, tag: 8),
        KeyModel(label: "һ", type: .character, tag: 9),
    ],
    // Row 2: ЙЦУКЕНГШЩЗХ (11)
    [
        KeyModel(label: "й", type: .character, tag: 10),
        KeyModel(label: "ц", type: .character, tag: 11),
        KeyModel(label: "у", type: .character, tag: 12),
        KeyModel(label: "к", type: .character, tag: 13),
        KeyModel(label: "е", type: .character, tag: 14),
        KeyModel(label: "н", type: .character, tag: 15),
        KeyModel(label: "г", type: .character, tag: 16),
        KeyModel(label: "ш", type: .character, tag: 17),
        KeyModel(label: "щ", type: .character, tag: 18),
        KeyModel(label: "з", type: .character, tag: 19),
        KeyModel(label: "х", type: .character, tag: 20),
    ],
    // Row 3: ФЫВАПРОЛДЖЭ (11)
    [
        KeyModel(label: "ф", type: .character, tag: 21),
        KeyModel(label: "ы", type: .character, tag: 22),
        KeyModel(label: "в", type: .character, tag: 23),
        KeyModel(label: "а", type: .character, tag: 24),
        KeyModel(label: "п", type: .character, tag: 25),
        KeyModel(label: "р", type: .character, tag: 26),
        KeyModel(label: "о", type: .character, tag: 27),
        KeyModel(label: "л", type: .character, tag: 28),
        KeyModel(label: "д", type: .character, tag: 29),
        KeyModel(label: "ж", type: .character, tag: 30),
        KeyModel(label: "э", type: .character, tag: 31),
    ],
    // Row 4: shift + ЯЧСМИТЬБЮ + backspace (11)
    [
        KeyModel(label: "", type: .shift, tag: 100),
        KeyModel(label: "я", type: .character, tag: 32),
        KeyModel(label: "ч", type: .character, tag: 33),
        KeyModel(label: "с", type: .character, tag: 34),
        KeyModel(label: "м", type: .character, tag: 35),
        KeyModel(label: "и", type: .character, tag: 36),
        KeyModel(label: "т", type: .character, tag: 37),
        KeyModel(label: "ь", type: .character, tag: 38),
        KeyModel(label: "б", type: .character, tag: 39),
        KeyModel(label: "ю", type: .character, tag: 40),
        KeyModel(label: "", type: .backspace, tag: 101),
    ],
    // Row 5: space + return
    [
        KeyModel(label: ",", type: .character, tag: 102),
        KeyModel(label: "", type: .space, tag: 103),
        KeyModel(label: ".", type: .character, tag: 105),
        KeyModel(label: "", type: .returnKey, tag: 104),
    ],
]
