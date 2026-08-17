import Foundation

final class MistakeStore: ObservableObject {
    static let shared = MistakeStore()

    @Published private(set) var entries: [MistakeEntry] = []

    private let fileURL: URL

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("vocab-mistakes.json")
        load()
    }

    func entry(wordID: Int) -> MistakeEntry? {
        entries.first { $0.wordID == wordID }
    }

    func recordWrong(_ entry: VocabularyEntry) {
        if let index = entries.firstIndex(where: { $0.wordID == entry.id }) {
            entries[index].wrongCount += 1
            entries[index].lastWrongAt = Date()
        } else {
            let mistake = MistakeEntry(
                wordID: entry.id,
                term: entry.term,
                wrongCount: 1,
                lastWrongAt: Date()
            )
            entries.insert(mistake, at: 0)
        }
        save()
    }

    func markCorrect(_ mistake: MistakeEntry) {
        guard let index = entries.firstIndex(where: { $0.wordID == mistake.wordID }) else { return }

        if entries[index].wrongCount <= 1 {
            entries.remove(at: index)
        } else {
            entries[index].wrongCount -= 1
            entries[index].lastWrongAt = Date()
        }

        save()
    }

    func remove(_ mistake: MistakeEntry) {
        entries.removeAll { $0.wordID == mistake.wordID }
        save()
    }

    func reset() {
        entries.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        entries = (try? JSONDecoder().decode([MistakeEntry].self, from: data)) ?? []
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Persistence failure should not interrupt studying.
        }
    }
}
