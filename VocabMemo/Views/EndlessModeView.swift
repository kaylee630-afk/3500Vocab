import SwiftUI

struct EndlessModeView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    @State private var current: VocabularyEntry?
    @State private var studiedCount = 0
    @State private var excludedIDs: Set<Int> = []

    var body: some View {
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
                        nextWord()
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
        .navigationTitle("无尽模式")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if current == nil {
                nextWord()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("已学 \(studiedCount) 词")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("错题 \(mistakeStore.entries.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("3500 词总体进度")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(progressStore.knownCount) / \(vocabularyStore.entries.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(
                value: Double(progressStore.knownCount),
                total: Double(max(vocabularyStore.entries.count, 1))
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

    private func markKnown() {
        if let current {
            progressStore.markKnown(current)
        }
        nextWord()
    }

    private func markUnknown() {
        if let current {
            mistakeStore.recordWrong(current)
        }
        nextWord()
    }

    private func nextWord() {
        let next = vocabularyStore.randomEntry(excluding: excludedIDs)
            ?? vocabularyStore.randomEntry()

        withAnimation(.easeInOut(duration: 0.24)) {
            current = next
            studiedCount += 1
        }

        if let next {
            excludedIDs.insert(next.id)
            if excludedIDs.count > 30 {
                excludedIDs.removeAll()
            }
        }
    }
}
