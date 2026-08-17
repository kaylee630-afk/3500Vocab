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

    func entries(for category: VocabularyCategory) -> [VocabularyEntry] {
        switch category {
        case .all:
            return entries
        case .word:
            return entries.filter { !$0.isPhrase }
        case .phrase:
            return entries.filter { $0.isPhrase }
        }
    }

    func randomEntries(count: Int, category: VocabularyCategory) -> [VocabularyEntry] {
        Array(entries(for: category).shuffled().prefix(count))
    }

    func dailyEntries(
        count: Int,
        category: VocabularyCategory,
        dayKey: String
    ) -> [VocabularyEntry] {
        let candidates = entries(for: category)
        let seed = stableSeed("\(dayKey)|\(category.rawValue)")
        var generator = StableRandomNumberGenerator(seed: seed)
        return Array(candidates.shuffled(using: &generator).prefix(count))
    }

    func randomEntry(
        excluding excludedIDs: Set<Int> = [],
        category: VocabularyCategory
    ) -> VocabularyEntry? {
        let candidates = entries(for: category).filter { !excludedIDs.contains($0.id) }
        return candidates.randomElement() ?? entries(for: category).randomElement()
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

private func stableSeed(_ string: String) -> UInt64 {
    var hash: UInt64 = 14695981039346656037

    for byte in string.utf8 {
        hash = (hash ^ UInt64(byte)) &* 1099511628211
    }

    return hash
}

private struct StableRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &+ 0x9E37_79B9_7F4A_7C15
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15

        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB

        return value ^ (value >> 31)
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

    func isKnown(_ entry: VocabularyEntry) -> Bool {
        knownIDs.contains(entry.id)
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

final class DailyStudyStore: ObservableObject {
    static let shared = DailyStudyStore()

    @Published private(set) var completedDates: Set<String> = []

    private let fileURL: URL

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("vocab-daily-checkin.json")
        load()
    }

    var todayKey: String {
        key(for: Date())
    }

    var isCompletedToday: Bool {
        completedDates.contains(todayKey)
    }

    var totalCheckIns: Int {
        completedDates.count
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var cursor = calendar.startOfDay(for: Date())

        if !completedDates.contains(key(for: cursor)) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = yesterday
        }

        var streak = 0
        while completedDates.contains(key(for: cursor)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }

        return streak
    }

    func markCompletedToday() {
        completedDates.insert(todayKey)
        save()
    }

    private func key(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        completedDates = Set((try? JSONDecoder().decode([String].self, from: data)) ?? [])
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(completedDates.sorted())
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Check-in persistence should not interrupt studying.
        }
    }
}
