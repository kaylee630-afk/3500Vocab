import SwiftUI

struct RandomThirtyView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    @State private var entries: [VocabularyEntry] = []
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
            } else {
                ProgressView()
            }
        }
        .navigationTitle("随机 30 词")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if entries.isEmpty {
                startNewRound()
            }
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
        let total = vocabularyStore.entries.count
        let percent = total == 0 ? 0 : Int((Double(progressStore.knownCount) / Double(total)) * 100)

        return VStack(spacing: 8) {
            HStack {
                Text("3500 词总体进度")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(progressStore.knownCount) / \(total) · \(percent)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(
                value: Double(progressStore.knownCount),
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
        entries = vocabularyStore.randomEntries(count: 30)
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
            }
        }
    }
}
