import Foundation

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
}
