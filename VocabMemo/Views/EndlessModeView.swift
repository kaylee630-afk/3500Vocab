import SwiftUI

struct EndlessModeView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore

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
        HStack {
            Text("已学 \(studiedCount) 词")
                .font(.subheadline.weight(.medium))

            Spacer()

            Text("错题 \(mistakeStore.entries.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func markKnown() {
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
