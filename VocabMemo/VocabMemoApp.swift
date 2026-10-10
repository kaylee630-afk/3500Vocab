import SwiftUI

@main
struct VocabMemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(VocabularyStore.shared)
                .environmentObject(MistakeStore.shared)
                .environmentObject(StudyProgressStore.shared)
                .environmentObject(DailyStudyStore.shared)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }

            NavigationStack {
                LearningHubView()
            }
            .tabItem {
                Label("学习", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                ErrorBookView()
            }
            .tabItem {
                Label("错题本", systemImage: "xmark.circle.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("我的", systemImage: "person.crop.circle.fill")
            }
        }
        .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
    }
}
