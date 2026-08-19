import SwiftUI

struct RandomThirtyView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore
    @EnvironmentObject private var dailyStudyStore: DailyStudyStore

    @State private var category: VocabularyCategory = .all
    @State private var hasStarted = false
    @State private var entries: [VocabularyEntry] = []
    @State private var index = 0
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false

    var body: some View {
        VStack(spacing: 12) {
            if hasStarted {
                CategoryPicker(selection: $category)
                    .padding(.horizontal, 20)

                studyArea
            } else {
                categorySelection
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("随机 50 词")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if hasStarted && entries.isEmpty {
                startNewRound()
            }
        }
        .onChange(of: category) { _, _ in
            if hasStarted {
                startNewRound()
            }
        }
    }

    private var studyArea: some View {
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
            } else {
                ProgressView()
            }
        }
    }

    private var current: VocabularyEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }

    private var categorySelection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("随机 50 词")
                    .font(.largeTitle.bold())

                Text("先选择本次学习范围，避免选错")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(VocabularyCategory.allCases) { option in
                    Button {
                        category = option
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(option.color.opacity(0.12))
                                    .frame(width: 46, height: 46)

                                Image(systemName: option.icon)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(option.color)
                            }

                            Text(option.rawValue)
                                .font(.headline)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            if category == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(option.color)
                            } else {
                                Image(systemName: "circle")
                                    .font(.title3)
                                    .foregroundStyle(Color.black.opacity(0.16))
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(category == option ? option.color : Color.black.opacity(0.05), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }

            Button {
                hasStarted = true
                startNewRound()
            } label: {
                Text("开始 50 词")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.16, green: 0.44, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private func studyContent(_ entry: VocabularyEntry) -> some View {
        VStack(spacing: 18) {
            progressHeader
            overallProgressHeader

            FlashcardView(
                entry: entry,
                onKnown: markKnown,
                onUnknown: markUnknown
            )

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            ProgressView(value: Double(index), total: Double(entries.count))
                .tint(Color(red: 0.16, green: 0.44, blue: 0.96))

            HStack {
                Text("第 \(index + 1) / \(entries.count) 个")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("认识 \(knownCount) · 待复习 \(unknownCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var overallProgressHeader: some View {
        let total = vocabularyStore.entries(for: category).count
        let known = vocabularyStore.entries(for: category).filter { progressStore.isKnown($0) }.count
        let percent = total == 0 ? 0 : Int((Double(known) / Double(total)) * 100)
        let title = category == .all ? "全部词条总体进度" : "\(category.rawValue)总体进度"

        return VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(known) / \(total) · \(percent)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(
                value: Double(known),
                total: Double(max(total, 1))
            )
            .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 6)
    }

    private var summary: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color(red: 0.28, green: 0.68, blue: 0.42))

            Text("本轮完成")
                .font(.largeTitle.bold())

            Text("你认识了 \(knownCount) 个词，\(unknownCount) 个词已加入错题本。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)

            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    startNewRound()
                }
            } label: {
                Text("再来一组")
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

    private func startNewRound() {
        entries = vocabularyStore.randomEntries(count: 50, category: category)
        index = 0
        knownCount = 0
        unknownCount = 0
        isFinished = false
    }

    private func markKnown() {
        if let current {
            progressStore.markKnown(current)
        }
        knownCount += 1
        advance()
    }

    private func markUnknown() {
        if let current {
            mistakeStore.recordWrong(current)
        }
        unknownCount += 1
        advance()
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.24)) {
            if index + 1 < entries.count {
                index += 1
            } else {
                isFinished = true
                dailyStudyStore.markCompletedToday()
            }
        }
    }
}

struct DailyStudyView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore
    @EnvironmentObject private var dailyStudyStore: DailyStudyStore

    @State private var category: VocabularyCategory = .word
    @State private var entries: [VocabularyEntry] = []
    @State private var index = 0
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false

    var body: some View {
        VStack(spacing: 12) {
            CategoryPicker(selection: $category)
                .padding(.horizontal, 20)

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
                } else {
                    ProgressView()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("今日 50 词")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if entries.isEmpty {
                startNewRound()
            }
        }
        .onChange(of: category) { _, _ in
            startNewRound()
        }
    }

    private var current: VocabularyEntry? {
        guard entries.indices.contains(index) else { return nil }
        return entries[index]
    }

    private func studyContent(_ entry: VocabularyEntry) -> some View {
        VStack(spacing: 18) {
            progressHeader
            overallProgressHeader

            FlashcardView(
                entry: entry,
                onKnown: markKnown,
                onUnknown: markUnknown
            )

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            ProgressView(value: Double(index), total: Double(entries.count))
                .tint(Color(red: 0.16, green: 0.44, blue: 0.96))

            HStack {
                Text("第 \(index + 1) / \(entries.count) 个")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("认识 \(knownCount) · 待复习 \(unknownCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var overallProgressHeader: some View {
        let total = vocabularyStore.entries(for: category).count
        let known = vocabularyStore.entries(for: category).filter { progressStore.isKnown($0) }.count
        let percent = total == 0 ? 0 : Int((Double(known) / Double(total)) * 100)
        let title = category == .all ? "全部词条总体进度" : "\(category.rawValue)总体进度"

        return VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(known) / \(total) · \(percent)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(
                value: Double(known),
                total: Double(max(total, 1))
            )
            .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 6)
    }

    private var summary: some View {
        VStack(spacing: 28) {
            Image(systemName: dailyStudyStore.isCompletedToday ? "checkmark.seal.fill" : "flag.checkered")
                .font(.system(size: 64))
                .foregroundStyle(dailyStudyStore.isCompletedToday
                    ? Color(red: 0.28, green: 0.68, blue: 0.42)
                    : Color(red: 0.16, green: 0.44, blue: 0.96))

            Text(dailyStudyStore.isCompletedToday ? "今日已打卡" : "今日完成")
                .font(.largeTitle.bold())

            Text("认识了 \(knownCount) 个词，\(unknownCount) 个词已加入错题本。连续打卡 \(dailyStudyStore.currentStreak) 天。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)

            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    startNewRound()
                }
            } label: {
                Text("再练一次今日 50 词")
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

    private func startNewRound() {
        entries = vocabularyStore.dailyEntries(
            count: 50,
            category: category,
            dayKey: dailyStudyStore.todayKey
        )
        index = 0
        knownCount = 0
        unknownCount = 0
        isFinished = false
    }

    private func markKnown() {
        if let current {
            progressStore.markKnown(current)
        }
        knownCount += 1
        advance()
    }

    private func markUnknown() {
        if let current {
            mistakeStore.recordWrong(current)
        }
        unknownCount += 1
        advance()
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.24)) {
            if index + 1 < entries.count {
                index += 1
            } else {
                isFinished = true
                dailyStudyStore.markCompletedToday()
            }
        }
    }
}
