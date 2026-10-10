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
                    greetingHeader
                    dailyHero
                    progressCard
                    quickStats
                    featureSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var greetingHeader: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("早上好，Kaylee")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)

                Text("今天也稳稳拿下 50 个词吧")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text("K")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.44, blue: 0.96),
                            Color(red: 0.54, green: 0.45, blue: 0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.22), radius: 12, x: 0, y: 8)
        }
        .padding(.top, 14)
    }

    private var dailyHero: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("连续 \(dailyStudyStore.currentStreak) 天", systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Capsule())

                Spacer()

                NavigationLink {
                    CheckInCalendarView()
                } label: {
                    Text("查看日历")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.86))
                }
            }

            Text(dailyStudyStore.isCompletedToday ? "今日已打卡" : "今日打卡")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("完成今天的 50 个随机单词")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.78))

            NavigationLink {
                RandomThirtyView()
            } label: {
                Label("开始今日 50 词", systemImage: "bolt.fill")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.12, green: 0.37, blue: 0.82))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.44, blue: 0.96),
                    Color(red: 0.45, green: 0.56, blue: 0.96),
                    Color(red: 0.56, green: 0.46, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.25), radius: 20, x: 0, y: 12)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("学习进度")
                    .font(.headline)
                    .foregroundStyle(Color.primary)

                Spacer()

                NavigationLink {
                    ProgressDetailView()
                } label: {
                    HStack(spacing: 3) {
                        Text("查看详情")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }

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
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(color.opacity(0.14))
                        .frame(width: 26, height: 26)

                    Image(systemName: icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)

                Spacer()

                Text("\(known) / \(total) · \(percent)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(known), total: Double(max(total, 1)))
                .tint(color)
        }
    }

    private var quickStats: some View {
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
                statTile(
                    value: "\(wordEntries.count)",
                    label: "总单词",
                    color: Color(red: 0.16, green: 0.44, blue: 0.96)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                AlphabeticalView(initialCategory: .phrase)
            } label: {
                statTile(
                    value: "\(phraseEntries.count)",
                    label: "总短语",
                    color: Color(red: 0.28, green: 0.68, blue: 0.42)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView(initialCategory: .word)
            } label: {
                statTile(
                    value: "\(wordMistakeCount)",
                    label: "单词错题",
                    color: Color(red: 0.88, green: 0.22, blue: 0.28)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                ErrorBookView(initialCategory: .phrase)
            } label: {
                statTile(
                    value: "\(phraseMistakeCount)",
                    label: "短语错题",
                    color: Color(red: 0.95, green: 0.48, blue: 0.22)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    private func statTile(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 8)
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("开始学习")
                .font(.title3.bold())

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                NavigationLink {
                    RandomThirtyView()
                } label: {
                    featureTile(
                        title: "随机 50 词",
                        subtitle: "先看英文，再对照中文",
                        icon: "shuffle",
                        tint: Color(red: 0.16, green: 0.44, blue: 0.96)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                NavigationLink {
                    AlphabeticalView()
                } label: {
                    featureTile(
                        title: "按字母背单词",
                        subtitle: "从 A 到 Z 系统浏览",
                        icon: "textformat.abc",
                        tint: Color(red: 0.28, green: 0.68, blue: 0.42)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                NavigationLink {
                    EndlessModeView()
                } label: {
                    featureTile(
                        title: "无尽模式",
                        subtitle: "随机单词连续出现",
                        icon: "infinity",
                        tint: Color(red: 0.62, green: 0.36, blue: 0.90)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                NavigationLink {
                    ErrorBookView()
                } label: {
                    featureTile(
                        title: "错题本",
                        subtitle: "按错误次数自动分级",
                        icon: "xmark.circle.fill",
                        tint: Color(red: 0.88, green: 0.22, blue: 0.28)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private func featureTile(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 152, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.055), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 8)
    }

    private var dailyCheckInCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            NavigationLink {
                CheckInCalendarView()
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

                        Text(dailyStudyStore.isCompletedToday ? "已完成" : "查看")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.18))
                }
            }
            .buttonStyle(ScaleButtonStyle())

            NavigationLink {
                RandomThirtyView()
            } label: {
                Label(
                    "快捷打卡",
                    systemImage: "bolt.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.16, green: 0.44, blue: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
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
        NavigationLink {
            ProgressDetailView()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("学习进度")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.18))
                }

                legacyProgressRow(
                    label: "单词",
                    icon: "textformat.abc",
                    known: wordKnownCount,
                    total: wordEntries.count,
                    color: Color(red: 0.16, green: 0.44, blue: 0.96)
                )

                Divider()

                legacyProgressRow(
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
        .buttonStyle(ScaleButtonStyle())
    }

    private func legacyProgressRow(
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

struct CheckInCalendarView: View {
    @EnvironmentObject private var dailyStudyStore: DailyStudyStore

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    stats
                    calendarCard
                    recentSection
                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("打卡日历")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var stats: some View {
        HStack(spacing: 12) {
            statPill(
                value: "\(dailyStudyStore.currentStreak)",
                label: "连续打卡",
                color: Color(red: 0.16, green: 0.44, blue: 0.96)
            )

            statPill(
                value: "\(dailyStudyStore.totalCheckIns)",
                label: "累计打卡",
                color: Color(red: 0.28, green: 0.68, blue: 0.42)
            )

            statPill(
                value: "\(monthCompletedCount)",
                label: "本月打卡",
                color: Color(red: 0.95, green: 0.68, blue: 0.18)
            )
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
                        .frame(width: 36, height: 36)
                }

                Spacer()

                Text(monthTitle)
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
                        .frame(width: 36, height: 36)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                    dayCell(date)
                }
            }
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

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近打卡详情")
                .font(.headline)
                .foregroundStyle(Color.primary)

            if recentKeys.isEmpty {
                Text("还没有打卡记录，完成今天的 50 个单词后就会出现在这里。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
            } else {
                ForEach(recentKeys, id: \.self) { key in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.28, green: 0.68, blue: 0.42))

                        Text(displayDate(key))
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.primary)

                        Spacer()

                        Text("已打卡")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 7)
                }
            }
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

    private var startButton: some View {
        NavigationLink {
            DailyStudyView()
        } label: {
            Text(dailyStudyStore.isCompletedToday ? "复习今日 50 词" : "开始今日 50 词")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.16, green: 0.44, blue: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: displayedMonth)
    }

    private var monthCompletedCount: Int {
        dailyStudyStore.completedCount(inMonthContaining: displayedMonth)
    }

    private var recentKeys: [String] {
        dailyStudyStore.recentCompletedKeys(limit: 10)
    }

    private var monthDays: [Date?] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }

        let leadingEmpty = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: leadingEmpty)

        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }

        let trailingEmpty = (7 - days.count % 7) % 7
        days.append(contentsOf: Array(repeating: Date?.none, count: trailingEmpty))
        return days
    }

    private func dayCell(_ date: Date?) -> some View {
        Group {
            if let date {
                let completed = dailyStudyStore.isCompleted(on: date)
                let isToday = calendar.isDate(date, inSameDayAs: Date())

                VStack(spacing: 4) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.subheadline.weight(isToday ? .bold : .regular))
                        .foregroundStyle(completed ? Color.white : Color.primary)

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.white)
                    } else if isToday {
                        Circle()
                            .fill(Color(red: 0.16, green: 0.44, blue: 0.96))
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(completed
                    ? Color(red: 0.28, green: 0.68, blue: 0.42)
                    : (isToday ? Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.08) : Color.clear))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(
                            isToday && !completed
                                ? Color(red: 0.16, green: 0.44, blue: 0.96)
                                : Color.clear,
                            lineWidth: 1.5
                        )
                )
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
        }
    }

    private func statPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 7) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 8)
    }

    private func displayDate(_ key: String) -> String {
        let pieces = key.split(separator: "-").compactMap { Int($0) }
        guard pieces.count == 3,
              let date = calendar.date(from: DateComponents(year: pieces[0], month: pieces[1], day: pieces[2])) else {
            return key
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

struct ProgressDetailView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var progressStore: StudyProgressStore

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    progressCard(
                        category: .word,
                        icon: "textformat.abc",
                        color: Color(red: 0.16, green: 0.44, blue: 0.96)
                    )
                    progressCard(
                        category: .phrase,
                        icon: "quote.bubble",
                        color: Color(red: 0.28, green: 0.68, blue: 0.42)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("学习进度")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        let total = vocabularyStore.entries.count
        let known = vocabularyStore.entries.filter { progressStore.isKnown($0) }.count
        let percent = total == 0 ? 0 : Int((Double(known) / Double(total)) * 100)

        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text("总学习进度")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text("已掌握 \(known) / \(total) 个词条")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(percent)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
            }

            ProgressView(value: Double(known), total: Double(max(total, 1)))
                .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.055), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 16, x: 0, y: 9)
    }

    private func progressCard(
        category: VocabularyCategory,
        icon: String,
        color: Color
    ) -> some View {
        let entries = vocabularyStore.entries(for: category)
        let known = entries.filter { progressStore.isKnown($0) }.count
        let total = entries.count
        let remaining = max(total - known, 0)
        let percent = total == 0 ? 0 : Int((Double(known) / Double(total)) * 100)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 46, height: 46)

                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text("\(known) / \(total) · \(percent)%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(percent)%")
                    .font(.title3.bold())
                    .foregroundStyle(color)
            }

            ProgressView(value: Double(known), total: Double(max(total, 1)))
                .tint(color)

            HStack {
                Label("已掌握 \(known)", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(color)

                Spacer()

                Label("待学习 \(remaining)", systemImage: "circle.dotted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.055), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 16, x: 0, y: 9)
    }
}

struct LearningHubView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("开始学习")
                            .font(.system(size: 30, weight: .bold, design: .rounded))

                        Text("选一个适合你的模式，慢慢积累")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 14)

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
                            tint: Color(red: 0.62, green: 0.36, blue: 0.90)
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
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("学习")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var vocabularyStore: VocabularyStore
    @EnvironmentObject private var mistakeStore: MistakeStore
    @EnvironmentObject private var progressStore: StudyProgressStore
    @EnvironmentObject private var dailyStudyStore: DailyStudyStore

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 12) {
                        Text("K")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 84, height: 84)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.16, green: 0.44, blue: 0.96),
                                        Color(red: 0.56, green: 0.46, blue: 0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                        Text("Kaylee")
                            .font(.title2.bold())

                        Text("3500 高考核心词汇默写本")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 22)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        profileStat(
                            value: "\(dailyStudyStore.currentStreak)",
                            label: "连续打卡",
                            color: Color(red: 0.16, green: 0.44, blue: 0.96)
                        )
                        profileStat(
                            value: "\(dailyStudyStore.totalCheckIns)",
                            label: "累计打卡",
                            color: Color(red: 0.28, green: 0.68, blue: 0.42)
                        )
                        profileStat(
                            value: "\(mistakeStore.entries.count)",
                            label: "错题总数",
                            color: Color(red: 0.88, green: 0.22, blue: 0.28)
                        )
                        profileStat(
                            value: "\(vocabularyStore.entries.count)",
                            label: "词条总数",
                            color: Color(red: 0.95, green: 0.48, blue: 0.22)
                        )
                    }
                    .padding(.horizontal, 20)

                    NavigationLink {
                        CheckInCalendarView()
                    } label: {
                        Label("查看打卡日历", systemImage: "calendar")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.16, green: 0.44, blue: 0.96))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.16, green: 0.44, blue: 0.96).opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
            }
        }
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func profileStat(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 8)
    }
}
