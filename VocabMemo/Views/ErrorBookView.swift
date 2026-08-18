import SwiftUI

struct ErrorBookView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore

    @State private var category: VocabularyCategory
    @State private var expandedLevels = Set(MistakeLevel.allCases)

    init(initialCategory: VocabularyCategory = .all) {
        _category = State(initialValue: initialCategory)
    }

    private var filteredMistakes: [MistakeEntry] {
        switch category {
        case .all:
            return mistakeStore.entries
        case .word:
            return mistakeStore.entries.filter { $0.category == .word }
        case .phrase:
            return mistakeStore.entries.filter { $0.category == .phrase }
        }
    }

    private var sortedMistakes: [MistakeEntry] {
        filteredMistakes.sorted {
            if $0.level != $1.level {
                return $0.level.rawValue > $1.level.rawValue
            }
            return $0.wrongCount > $1.wrongCount
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            CategoryPicker(selection: $category)
                .padding(.horizontal, 20)

            ZStack {
                Color.white.ignoresSafeArea()

                if mistakeStore.entries.isEmpty {
                    emptyState
                } else {
                    mistakeList
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
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
            reviewSection

            ForEach(MistakeLevel.allCases) { level in
                let items = sortedMistakes.filter { $0.level == level }

                if !items.isEmpty {
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedLevels.contains(level) },
                            set: { isExpanded in
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    if isExpanded {
                                        expandedLevels.insert(level)
                                    } else {
                                        expandedLevels.remove(level)
                                    }
                                }
                            }
                        )
                    ) {
                        ForEach(items) { mistake in
                            NavigationLink {
                                WordDetailView(entry: entry(for: mistake))
                            } label: {
                                mistakeRow(mistake)
                            }
                            .listRowBackground(Color.white)
                        }
                    } label: {
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
                    .listRowBackground(Color.white)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var reviewSection: some View {
        Section {
            NavigationLink {
                MistakeReviewView()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.12))
                            .frame(width: 42, height: 42)

                        Image(systemName: "shuffle")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("随机复习错题")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)

                        Text("打乱顺序复习，答对会降低易错等级")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.16))
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.white)
        } header: {
            Text("复习模式")
                .font(.headline)
                .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
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

                TranslatedMeaningView(text: mistake.term, compact: true)

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

struct MistakeReviewView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    @State private var queue: [MistakeEntry] = []
    @State private var index = 0
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if isFinished {
                summary
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else if let current {
                studyContent(current)
                    .id(current.id)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if mistakeStore.entries.isEmpty {
                emptyState
            } else {
                ProgressView()
            }
        }
        .navigationTitle("错题随机复习")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if queue.isEmpty, !mistakeStore.entries.isEmpty {
                startReview()
            }
        }
    }

    private var current: MistakeEntry? {
        guard queue.indices.contains(index) else { return nil }
        return queue[index]
    }

    private func studyContent(_ mistake: MistakeEntry) -> some View {
        VStack(spacing: 18) {
            reviewHeader

            FlashcardView(
                entry: VocabularyEntry(id: mistake.wordID, term: mistake.term),
                onKnown: markKnown,
                onUnknown: markUnknown
            )

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var reviewHeader: some View {
        VStack(spacing: 10) {
            ProgressView(value: Double(index), total: Double(max(queue.count, 1)))
                .tint(Color(red: 0.16, green: 0.44, blue: 0.96))

            HStack {
                Text("第 \(index + 1) / \(queue.count) 个")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("认识 \(knownCount) · 待强化 \(unknownCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var summary: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color(red: 0.28, green: 0.68, blue: 0.42))

            Text("错题复习完成")
                .font(.largeTitle.bold())

            Text("本轮认识 \(knownCount) 个，\(unknownCount) 个需要继续强化。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)

            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    startReview()
                }
            } label: {
                Text("再来一轮")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.16, green: 0.44, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 28)
        }
        .padding(24)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 58))
                .foregroundStyle(Color(red: 0.28, green: 0.68, blue: 0.42))

            Text("错题本已经清空")
                .font(.title3.bold())

            Text("继续在随机 50 词或无尽模式中学习，答错后会自动进入这里。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
        }
    }

    private func startReview() {
        queue = mistakeStore.entries.shuffled()
        index = 0
        knownCount = 0
        unknownCount = 0
        isFinished = false
    }

    private func markKnown() {
        if let current {
            mistakeStore.markCorrect(current)
            if let entry = vocabularyStore.entry(id: current.wordID) {
                progressStore.markKnown(entry)
            }
        }
        knownCount += 1
        advance()
    }

    private func markUnknown() {
        if let current {
            mistakeStore.recordWrong(
                VocabularyEntry(id: current.wordID, term: current.term)
            )
        }
        unknownCount += 1
        advance()
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.24)) {
            if index + 1 < queue.count {
                index += 1
            } else {
                isFinished = true
            }
        }
    }
}
