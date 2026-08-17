import SwiftUI

struct AlphabeticalView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @State private var category: VocabularyCategory
    @State private var searchText = ""

    init(initialCategory: VocabularyCategory = .all) {
        _category = State(initialValue: initialCategory)
    }

    private var filteredEntries: [VocabularyEntry] {
        let categoryEntries = vocabularyStore.entries(for: category)
        guard !searchText.isEmpty else { return categoryEntries }
        return categoryEntries.filter {
            $0.term.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groups: [(letter: String, entries: [VocabularyEntry])] {
        let grouped = Dictionary(grouping: filteredEntries, by: { $0.sectionLetter })
        return grouped
            .map { (letter: $0.key, entries: $0.value.sorted {
                $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending
            }) }
            .sorted { $0.letter < $1.letter }
    }

    var body: some View {
        VStack(spacing: 12) {
            CategoryPicker(selection: $category)
                .padding(.horizontal, 20)

            List {
                ForEach(groups, id: \.letter) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            NavigationLink {
                                WordDetailView(entry: entry)
                            } label: {
                                wordRow(entry)
                            }
                            .listRowBackground(Color.white)
                        }
                    } header: {
                        Text(group.letter)
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索单词或短语")
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("按字母背单词")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func wordRow(_ entry: VocabularyEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.term)
                .font(.body)
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            Text("#\(entry.id)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}

struct WordDetailView: View {
    let entry: VocabularyEntry

    @EnvironmentObject private var mistakeStore: MistakeStore
    @State private var justMarked = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    termCard
                    meaningCard
                    actionButton
                }
                .padding(22)
            }
        }
        .navigationTitle("单词详情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var termCard: some View {
        VStack(spacing: 16) {
            Text(entry.term)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .lineLimit(4)
                .padding(.horizontal, 20)

            Text("词条编号 #\(entry.id)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 230)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 18, x: 0, y: 10)
    }

    private var meaningCard: some View {
        VStack(spacing: 12) {
            Text("中文释义")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TranslatedMeaningView(text: entry.term)
                .padding(.horizontal, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var actionButton: some View {
        Button {
            mistakeStore.recordWrong(entry)
            justMarked = true
        } label: {
            Label(justMarked ? "已加入错题本" : "加入错题本", systemImage: justMarked ? "checkmark.circle.fill" : "xmark.circle")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ActionButtonStyle(color: Color(red: 0.88, green: 0.22, blue: 0.28)))
        .disabled(justMarked)
    }
}
