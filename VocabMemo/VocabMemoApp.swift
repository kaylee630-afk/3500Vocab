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
        NavigationStack {
            HomeView()
        }
        .tint(Color(red: 0.16, green: 0.44, blue: 0.96))
    }
}
