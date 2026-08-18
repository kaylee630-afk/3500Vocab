import SwiftUI

struct EndlessModeView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    @State private var category: VocabularyCategory = .all
    @State private var current: VocabularyEntry?
    @State private var studiedCount = 0
    @State private var excludedIDs: Set<Int> = []

    var body: some View {
        VStack(spacing: 12) {
            CategoryPicker(selection: $category)
                .padding(.horizontal, 20)

            ZStack {
                Color.white.ignoresSafeArea()

                if let current {
                    VStack(spacing: 18) {
                        header

                        FlashcardView(
                            entry: current,
                            onKnown: markKnown,
                            onUnknown: markUnknown
                        )
                        .id(current.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                        Button {
                            nextWord(countAsStudied: false)
                        } label: {
                            Label("换一个", systemImage: "arrow.triangle.2.circlepath")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                } else {
                    ProgressView()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("无尽模式")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if current == nil {
                nextWord(countAsStudied: false)
            }
        }
        .onChange(of: category) { _, _ in
            excludedIDs.removeAll()
            current = nil
            studiedCount = 0
            nextWord(countAsStudied: false)
        }
    }

    private var header: some View {
        let total = vocabularyStore.entries(for: category).count
        let known = vocabularyStore.entries(for: category).filter { progressStore.isKnown($0) }.count
        let title = category == .all ? "全部词条总体进度" : "\(category.rawValue)总体进度"

        return VStack(spacing: 10) {
            HStack {
                Text("已学 \(studiedCount) 词")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("错题 \(mistakeCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(known) / \(total)")
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

    private var mistakeCount: Int {
        guard category != .all else { return mistakeStore.entries.count }
        return mistakeStore.entries.filter { $0.category == category }.count
    }

    private func markKnown() {
        if let current {
            progressStore.markKnown(current)
        }
        nextWord(countAsStudied: true)
    }

    private func markUnknown() {
        if let current {
            mistakeStore.recordWrong(current)
        }
        nextWord(countAsStudied: true)
    }

    private func nextWord(countAsStudied: Bool) {
        let next = vocabularyStore.randomEntry(excluding: excludedIDs, category: category)
            ?? vocabularyStore.randomEntry(excluding: [], category: category)

        withAnimation(.easeInOut(duration: 0.24)) {
            current = next
            if countAsStudied {
                studiedCount += 1
            }
        }

        if let next {
            excludedIDs.insert(next.id)
            if excludedIDs.count > 30 {
                excludedIDs.removeAll()
            }
        }
    }
}
