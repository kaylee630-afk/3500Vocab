import Foundation

enum VocabularyCategory: String, CaseIterable, Identifiable {
    case all = "全部"
    case word = "单词"
    case phrase = "短语"

    var id: String { rawValue }
}

struct VocabularyEntry: Codable, Identifiable, Hashable {
    let id: Int
    let term: String

    var sectionLetter: String {
        guard let first = term.first else { return "#" }
        let normalized = String(first)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US"))
            .uppercased()

        guard let letter = normalized.first, letter.isLetter else { return "#" }
        return String(letter)
    }

    var isPhrase: Bool {
        term.contains(" ")
            || term.contains("/")
            || term.contains("…")
            || term.contains("+")
    }

    var category: VocabularyCategory {
        isPhrase ? .phrase : .word
    }
}
