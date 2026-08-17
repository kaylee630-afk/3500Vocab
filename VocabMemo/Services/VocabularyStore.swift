import Foundation

final class VocabularyStore: ObservableObject {
    static let shared = VocabularyStore()

    @Published private(set) var entries: [VocabularyEntry] = []

    init() {
        load()
    }

    func entry(id: Int) -> VocabularyEntry? {
        entries.first { $0.id == id }
    }

    func randomEntries(count: Int) -> [VocabularyEntry] {
        Array(entries.shuffled().prefix(count))
    }

    func randomEntry(excluding excludedIDs: Set<Int> = []) -> VocabularyEntry? {
        let candidates = entries.filter { !excludedIDs.contains($0.id) }
        return candidates.randomElement() ?? entries.randomElement()
    }

    func groupedEntries() -> [(letter: String, entries: [VocabularyEntry])] {
        let groups = Dictionary(grouping: entries, by: { $0.sectionLetter })
        return groups
            .map { (letter: $0.key, entries: $0.value.sorted { $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending }) }
            .sorted { $0.letter < $1.letter }
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            entries = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([VocabularyEntry].self, from: data)
            entries = decoded.sorted {
                $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending
            }
        } catch {
            entries = []
        }
    }
}
