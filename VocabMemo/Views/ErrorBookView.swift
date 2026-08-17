import SwiftUI

struct ErrorBookView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore

    private var sortedMistakes: [MistakeEntry] {
        mistakeStore.entries.sorted {
            if $0.level != $1.level {
                return $0.level.rawValue > $1.level.rawValue
            }
            return $0.wrongCount > $1.wrongCount
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if mistakeStore.entries.isEmpty {
                emptyState
            } else {
                mistakeList
            }
        }
        .navigationTitle("错题本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !mistakeStore.entries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清空") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            mistakeStore.reset()
                        }
                    }
                }
            }
        }
    }

    private var mistakeList: some View {
        List {
            ForEach(MistakeLevel.allCases) { level in
                let items = sortedMistakes.filter { $0.level == level }

                if !items.isEmpty {
                    Section {
                        ForEach(items) { mistake in
                            NavigationLink {
                                WordDetailView(entry: entry(for: mistake))
                            } label: {
                                mistakeRow(mistake)
                            }
                            .listRowBackground(Color.white)
                        }
                    } header: {
                        HStack {
                            Label(level.rawValue, systemImage: level.icon)
                                .font(.headline)
                                .foregroundStyle(level.color)

                            Spacer()

                            Text("\(items.count) 个")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func mistakeRow(_ mistake: MistakeEntry) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(mistake.level.color.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: mistake.level.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(mistake.level.color)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(mistake.term)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)

                Text("错误 \(mistake.wrongCount) 次 · \(mistake.level.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 6)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.16))
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 58))
                .foregroundStyle(Color(red: 0.28, green: 0.68, blue: 0.42))

            Text("还没有错题")
                .font(.title3.bold())

            Text("在随机 30 词或无尽模式中答错后，单词会自动出现在这里。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
        }
    }

    private func entry(for mistake: MistakeEntry) -> VocabularyEntry {
        vocabularyStore.entry(id: mistake.wordID)
            ?? VocabularyEntry(id: mistake.wordID, term: mistake.term)
    }
}
