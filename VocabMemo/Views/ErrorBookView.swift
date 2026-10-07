import SwiftUI
import Translation
import UIKit

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

    private var weekMistakes: [MistakeEntry] {
        mistakeStore.entries.filter {
            Calendar.current.isDate($0.lastWrongAt, equalTo: Date(), toGranularity: .weekOfYear)
        }
    }

    private var totalMistakeCount: Int {
        mistakeStore.entries.count
    }

    private var weekMistakeCount: Int {
        weekMistakes.count
    }

    var body: some View {
        VStack(spacing: 12) {
            mistakeStats

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

    private var mistakeStats: some View {
        HStack(spacing: 12) {
            statPill(
                value: "\(totalMistakeCount)",
                label: "总体错词",
                color: Color(red: 0.88, green: 0.22, blue: 0.28)
            )

            statPill(
                value: "\(weekMistakeCount)",
                label: "本周错词",
                color: Color(red: 0.95, green: 0.48, blue: 0.22)
            )
        }
        .padding(.horizontal, 20)
    }

    private func statPill(value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)

            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 8)
    }

    private var mistakeList: some View {
        List {
            if !mistakeStore.entries.isEmpty {
                exportSection
            }

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

    private var exportSection: some View {
        Section {
            NavigationLink {
                MistakePDFExportView(
                    entries: mistakeStore.entries,
                    rangeTitle: "全部错词"
                )
            } label: {
                exportRow(
                    title: "导出全部错词",
                    subtitle: "导出所有错词的中英文对照 PDF",
                    icon: "doc.richtext"
                )
            }
            .listRowBackground(Color.white)

            if !weekMistakes.isEmpty {
                NavigationLink {
                    MistakePDFExportView(
                        entries: weekMistakes,
                        rangeTitle: "本周错词"
                    )
                } label: {
                    exportRow(
                        title: "导出本周错词",
                        subtitle: "导出本周错误过的词条",
                        icon: "calendar.badge.clock"
                    )
                }
                .listRowBackground(Color.white)
            }
        } header: {
            Text("导出 PDF")
                .font(.headline)
                .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
    }

    private func exportRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)

                Text(subtitle)
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
                onUnknown: markUnknown,
                onPrevious: goPrevious,
                onNext: goNext,
                canGoPrevious: index > 0,
                canGoNext: index + 1 < queue.count
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

    private func goPrevious() {
        guard index > 0 else { return }
        withAnimation(.easeInOut(duration: 0.24)) {
            index -= 1
        }
    }

    private func goNext() {
        guard index + 1 < queue.count else { return }
        withAnimation(.easeInOut(duration: 0.24)) {
            index += 1
        }
    }
}

struct MistakePDFExportView: View {
    let entries: [MistakeEntry]
    let rangeTitle: String

    @State private var pdfURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if let pdfURL {
                VStack(spacing: 24) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 66))
                        .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))

                    VStack(spacing: 8) {
                        Text("PDF 已生成")
                            .font(.largeTitle.bold())

                        Text("\(entries.count) 个错词 · \(rangeTitle)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    ShareLink(item: pdfURL) {
                        Label("分享 PDF", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.16, green: 0.44, blue: 0.96))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 24)
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 54))
                        .foregroundStyle(Color(red: 0.88, green: 0.22, blue: 0.28))

                    Text("生成失败")
                        .font(.title3.bold())

                    Text(errorMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 28)
                }
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("正在翻译并生成中英文对照 PDF…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("导出\(rangeTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .translationTask(
            source: Locale.Language(identifier: "en"),
            target: Locale.Language(identifier: "zh-Hans")
        ) { session in
            guard !Task.isCancelled, pdfURL == nil, errorMessage == nil else { return }

            do {
                let requests = entries.enumerated().map { index, entry in
                    TranslationSession.Request(
                        sourceText: entry.term,
                        clientIdentifier: String(index)
                    )
                }
                let responses = try await session.translations(from: requests)
                var meanings: [String: String] = [:]

                for response in responses {
                    if let identifier = response.clientIdentifier {
                        meanings[identifier] = response.targetText
                    }
                }

                let pairs = entries.enumerated().map { index, entry in
                    (term: entry.term, meaning: meanings[String(index)] ?? entry.term)
                }

                let url = try MistakePDFRenderer.makePDF(
                    title: rangeTitle,
                    pairs: pairs
                )

                await MainActor.run {
                    pdfURL = url
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

enum MistakePDFRenderer {
    static func makePDF(
        title: String,
        pairs: [(term: String, meaning: String)]
    ) throws -> URL {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let leftWidth: CGFloat = 250
        let rightWidth: CGFloat = 222
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("VocabMemo-\(Date().timeIntervalSince1970).pdf")

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        try renderer.writePDF(to: url) { context in
            var y: CGFloat = 0

            func beginPage() {
                context.beginPage()
                y = margin

                Self.draw(
                    "错题本导出",
                    x: margin,
                    y: y,
                    width: pageWidth - margin * 2,
                    font: .systemFont(ofSize: 23, weight: .bold)
                )
                y += 34

                Self.draw(
                    "范围：\(title)",
                    x: margin,
                    y: y,
                    width: pageWidth - margin * 2,
                    font: .systemFont(ofSize: 13, weight: .medium)
                )
                y += 22

                Self.draw(
                    "生成时间：\(Self.dateString())",
                    x: margin,
                    y: y,
                    width: pageWidth - margin * 2,
                    font: .systemFont(ofSize: 11)
                )
                y += 20

                Self.draw(
                    "共 \(pairs.count) 个词条",
                    x: margin,
                    y: y,
                    width: pageWidth - margin * 2,
                    font: .systemFont(ofSize: 11)
                )
                y += 34

                Self.draw(
                    "英文",
                    x: margin,
                    y: y,
                    width: leftWidth,
                    font: .systemFont(ofSize: 13, weight: .semibold)
                )
                Self.draw(
                    "中文释义",
                    x: margin + leftWidth + 16,
                    y: y,
                    width: rightWidth,
                    font: .systemFont(ofSize: 13, weight: .semibold)
                )
                y += 28
            }

            func ensureSpace(_ needed: CGFloat) {
                if y + needed > pageHeight - margin {
                    beginPage()
                }
            }

            beginPage()

            for pair in pairs {
                let leftHeight = Self.height(
                    for: pair.term,
                    width: leftWidth,
                    font: .systemFont(ofSize: 13, weight: .medium)
                )
                let rightHeight = Self.height(
                    for: pair.meaning,
                    width: rightWidth,
                    font: .systemFont(ofSize: 12)
                )
                let rowHeight = max(leftHeight, rightHeight) + 14

                ensureSpace(rowHeight)

                Self.draw(
                    pair.term,
                    x: margin,
                    y: y,
                    width: leftWidth,
                    font: .systemFont(ofSize: 13, weight: .medium)
                )
                Self.draw(
                    pair.meaning,
                    x: margin + leftWidth + 16,
                    y: y,
                    width: rightWidth,
                    font: .systemFont(ofSize: 12)
                )

                y += rowHeight

                UIColor(white: 0.86, alpha: 1).setFill()
                UIRectFill(CGRect(
                    x: margin,
                    y: y - 6,
                    width: pageWidth - margin * 2,
                    height: 0.5
                ))
            }
        }

        return url
    }

    private static func draw(
        _ text: String,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        font: UIFont
    ) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle()
        ]
        (text as NSString).draw(
            in: CGRect(x: x, y: y, width: width, height: .greatestFiniteMagnitude),
            withAttributes: attributes
        )
    }

    private static func height(
        for text: String,
        width: CGFloat,
        font: UIFont
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle()
        ]
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return ceil(bounds.height)
    }

    private static func paragraphStyle() -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .left
        return style
    }

    private static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: Date())
    }
}
