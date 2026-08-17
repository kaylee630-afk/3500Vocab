import Foundation

enum MistakeLevel: String, Codable, CaseIterable, Identifiable, Hashable {
    case light = "偶尔出错"
    case moderate = "容易出错"
    case high = "高频易错"
    case stubborn = "顽固词汇"

    var id: String { rawValue }

    static func level(for wrongCount: Int) -> MistakeLevel {
        switch wrongCount {
        case 1:
            return .light
        case 2...3:
            return .moderate
        case 4...6:
            return .high
        default:
            return .stubborn
        }
    }
}

struct MistakeEntry: Codable, Identifiable, Hashable {
    let wordID: Int
    var term: String
    var wrongCount: Int
    var lastWrongAt: Date

    var id: Int { wordID }
    var level: MistakeLevel { MistakeLevel.level(for: wrongCount) }

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
