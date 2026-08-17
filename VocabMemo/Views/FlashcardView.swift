import SwiftUI

struct FlashcardView: View {
    let entry: VocabularyEntry
    let onKnown: () -> Void
    let onUnknown: () -> Void

    @State private var revealed = false

    var body: some View {
        VStack(spacing: 22) {
            card

            if revealed {
                actionButtons
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Text("轻点卡片查看中文释义")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
    }

    private var card: some View {
        ZStack {
            front
                .opacity(revealed ? 0 : 1)
                .rotation3DEffect(
                    .degrees(revealed ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.65
                )

            back
                .opacity(revealed ? 1 : 0)
                .rotation3DEffect(
                    .degrees(revealed ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.65
                )
        }
        .frame(maxWidth: .infinity, minHeight: 440)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 22, x: 0, y: 13)
        .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .onTapGesture {
            withAnimation(.spring(response: 0.58, dampingFraction: 0.78)) {
                revealed.toggle()
            }
        }
    }

    private var front: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("ENGLISH")
                .font(.caption.weight(.semibold))
                .kerning(1.4)
                .foregroundStyle(.secondary)

            Text(entry.term)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .lineLimit(4)
                .padding(.horizontal, 24)

            Text("点击卡片查看中文释义")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(28)
    }

    private var back: some View {
        VStack(spacing: 18) {
            Spacer()

            Text(entry.term)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.65)
                .lineLimit(3)
                .padding(.horizontal, 20)
                .foregroundStyle(.secondary)

            Text("中文释义")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TranslatedMeaningView(text: entry.term)
                .padding(.horizontal, 20)

            Text("点击卡片返回")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(28)
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button {
                onUnknown()
            } label: {
                Label("不认识", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ActionButtonStyle(color: Color(red: 0.88, green: 0.22, blue: 0.28)))

            Button {
                onKnown()
            } label: {
                Label("认识", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ActionButtonStyle(color: Color(red: 0.28, green: 0.68, blue: 0.42)))
        }
    }
}
