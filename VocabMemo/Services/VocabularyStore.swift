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

final class StudyProgressStore: ObservableObject {
    static let shared = StudyProgressStore()

    @Published private(set) var knownCount = 0

    private var knownIDs: Set<Int> = []
    private let fileURL: URL

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("vocab-study-progress.json")
        load()
    }

    func markKnown(_ entry: VocabularyEntry) {
        guard !knownIDs.contains(entry.id) else { return }
        knownIDs.insert(entry.id)
        knownCount = knownIDs.count
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let ids = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        knownIDs = Set(ids)
        knownCount = knownIDs.count
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(knownIDs.sorted())
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Progress persistence should not interrupt studying.
        }
    }
}
