import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore
    @EnvironmentObject private var dailyStudyStore: DailyStudyStore

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    dailyCheckInCard
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

    private var dailyCheckInCard: some View {
        NavigationLink {
            DailyStudyView()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill((dailyStudyStore.isCompletedToday
                            ? Color(red: 0.28, green: 0.68, blue: 0.42)
                            : Color(red: 0.16, green: 0.44, blue: 0.96)).opacity(0.12))
                        .frame(width: 58, height: 58)

                    Image(systemName: dailyStudyStore.isCompletedToday
                        ? "checkmark.seal.fill"
                        : "calendar.badge.checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(dailyStudyStore.isCompletedToday
                            ? Color(red: 0.28, green: 0.68, blue: 0.42)
                            : Color(red: 0.16, green: 0.44, blue: 0.96))
                }

                VStack(alignment: .leading, spacing: 7) {
                    Text(dailyStudyStore.isCompletedToday ? "今日已打卡" : "今日打卡")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text("每天完成 50 个随机单词")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 5) {
                    Text("连续 \(dailyStudyStore.currentStreak) 天")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primary)

                    Text(dailyStudyStore.isCompletedToday ? "已完成" : "开始")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.18))
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.black.opacity(0.055), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.055), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle())
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
        VStack(alignment: .leading, spacing: 16) {
            Text("学习进度")
                .font(.headline)
                .foregroundStyle(Color.primary)

            progressRow(
                label: "单词",
                icon: "textformat.abc",
                known: wordKnownCount,
                total: wordEntries.count,
                color: Color(red: 0.16, green: 0.44, blue: 0.96)
            )

            Divider()

            progressRow(
                label: "短语",
                icon: "quote.bubble",
                known: phraseKnownCount,
                total: phraseEntries.count,
                color: Color(red: 0.28, green: 0.68, blue: 0.42)
            )
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

    private func progressRow(
        label: String,
        icon: String,
        known: Int,
        total: Int,
        color: Color
    ) -> some View {
        let percent = total == 0 ? 0 : Int((Double(known) / Double(total)) * 100)

        return VStack(spacing: 9) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)

                Spacer()

                Text("\(known) / \(total) · \(percent)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(known), total: Double(max(total, 1)))
                .tint(color)
        }
    }

    private var stats: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            NavigationLink {
                AlphabeticalView(initialCategory: .word)
            } label: {
                statPill(
                    value: "\(wordEntries.count)",
                    label: "总单词",
                    color: Color(red: 0.16, green: 0.44, blue: 0.96)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                AlphabeticalView(initialCategory: .phrase)
            } label: {
                statPill(
                    value: "\(phraseEntries.count)",
                    label: "总短语",
                    color: Color(red: 0.28, green: 0.68, blue: 0.42)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView(initialCategory: .word)
            } label: {
                statPill(
                    value: "\(wordMistakeCount)",
                    label: "单词错题",
                    color: Color(red: 0.88, green: 0.22, blue: 0.28)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView(initialCategory: .phrase)
            } label: {
                statPill(
                    value: "\(phraseMistakeCount)",
                    label: "短语错题",
                    color: Color(red: 0.95, green: 0.48, blue: 0.22)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    private var wordEntries: [VocabularyEntry] {
        vocabularyStore.entries(for: .word)
    }

    private var phraseEntries: [VocabularyEntry] {
        vocabularyStore.entries(for: .phrase)
    }

    private var wordKnownCount: Int {
        wordEntries.filter { progressStore.isKnown($0) }.count
    }

    private var phraseKnownCount: Int {
        phraseEntries.filter { progressStore.isKnown($0) }.count
    }

    private var wordMistakeCount: Int {
        mistakeStore.entries.filter { $0.category == .word }.count
    }

    private var phraseMistakeCount: Int {
        mistakeStore.entries.filter { $0.category == .phrase }.count
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
                    title: "随机 50 词",
                    subtitle: "随机抽取 50 个词，像百词斩一样先看英文再对照中文",
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
