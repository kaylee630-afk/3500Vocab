import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    overallProgressCard
                    stats
                    featureCards
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("3500 单词")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)

            Text("高考核心词汇默写本")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 18)
    }

    private var overallProgressCard: some View {
        let total = vocabularyStore.entries.count
        let percent = total == 0 ? 0 : Int((Double(progressStore.knownCount) / Double(total)) * 100)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("3500 词总体进度")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text("已掌握 \(progressStore.knownCount) / \(total) 个词条")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(percent)%")
                    .font(.title3.bold())
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(
                value: Double(progressStore.knownCount),
                total: Double(max(total, 1))
            )
            .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.055), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 16, x: 0, y: 9)
    }

    private var stats: some View {
        HStack(spacing: 12) {
            NavigationLink {
                AlphabeticalView()
            } label: {
                statPill(
                    value: "\(vocabularyStore.entries.count)",
                    label: "总词条",
                    color: Color(red: 0.16, green: 0.44, blue: 0.96)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView()
            } label: {
                statPill(
                    value: "\(mistakeStore.entries.count)",
                    label: "错题数",
                    color: Color(red: 0.88, green: 0.22, blue: 0.28)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
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

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.18))
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

    private var featureCards: some View {
        VStack(spacing: 14) {
            NavigationLink {
                RandomThirtyView()
            } label: {
                FeatureCard(
                    title: "随机 30 词",
                    subtitle: "像百词斩一样，先看英文，再对照中文",
                    icon: "shuffle",
                    tint: Color(red: 0.16, green: 0.44, blue: 0.96)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                AlphabeticalView()
            } label: {
                FeatureCard(
                    title: "按字母背单词",
                    subtitle: "从 A 到 Z 系统浏览全部词条",
                    icon: "textformat.abc",
                    tint: Color(red: 0.28, green: 0.68, blue: 0.42)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                EndlessModeView()
            } label: {
                FeatureCard(
                    title: "无尽模式",
                    subtitle: "随机单词连续出现，想背多久背多久",
                    icon: "infinity",
                    tint: Color(red: 0.66, green: 0.36, blue: 0.90)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView()
            } label: {
                FeatureCard(
                    title: "错题本",
                    subtitle: "答错的词按错误次数自动分级",
                    icon: "xmark.circle.fill",
                    tint: Color(red: 0.88, green: 0.22, blue: 0.28)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}
