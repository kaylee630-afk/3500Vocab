import SwiftUI
import Translation

@MainActor
final class TranslationCache {
    static let shared = TranslationCache()

    private var values: [String: String] = [:]

    func translation(for text: String) -> String? {
        values[text]
    }

    func set(_ text: String, translation: String) {
        values[text] = translation
    }
}

struct TranslatedMeaningView: View {
    let text: String
    var compact = false

    @State private var output: String?
    @State private var failed = false

    var body: some View {
        Group {
            if let output, !output.isEmpty {
                Text(output)
                    .font(compact ? .subheadline : .title2)
                    .fontWeight(compact ? .regular : .medium)
                    .multilineTextAlignment(compact ? .leading : .center)
                    .foregroundStyle(compact ? Color.secondary : Color.primary)
                    .lineLimit(compact ? 2 : nil)
            } else if failed {
                if compact {
                    Text("中文释义暂不可用")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.title2)
                        Text("中文释义暂不可用")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: compact ? 5 : 10) {
                    ProgressView()
                    Text(compact ? "翻译中…" : "正在获取中文释义")
                        .font(compact ? .caption : .subheadline)
                }
                .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: compact ? 0 : 52)
        .translationTask(
            source: Locale.Language(identifier: "en"),
            target: Locale.Language(identifier: "zh-Hans")
        ) { session in
            await Task { @MainActor in
                await translate(session: session)
            }.value
        }
    }

    @MainActor
    private func translate(session: TranslationSession) async {
        if let cached = TranslationCache.shared.translation(for: text) {
            output = cached
            failed = false
            return
        }

        do {
            let response = try await session.translate(text)
            TranslationCache.shared.set(text, translation: response.targetText)
            output = response.targetText
            failed = false
        } catch {
            failed = true
        }
    }
}
