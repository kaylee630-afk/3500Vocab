import SwiftUI

extension VocabularyCategory {
    var color: Color {
        switch self {
        case .all:
            return Color(red: 0.16, green: 0.44, blue: 0.96)
        case .word:
            return Color(red: 0.16, green: 0.44, blue: 0.96)
        case .phrase:
            return Color(red: 0.28, green: 0.68, blue: 0.42)
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "square.stack.3d.up"
        case .word:
            return "textformat.abc"
        case .phrase:
            return "quote.bubble"
        }
    }
}

extension MistakeLevel {
    var color: Color {
        switch self {
        case .light:
            return Color(red: 0.55, green: 0.58, blue: 0.64)
        case .moderate:
            return Color(red: 0.95, green: 0.68, blue: 0.18)
        case .high:
            return Color(red: 0.96, green: 0.42, blue: 0.20)
        case .stubborn:
            return Color(red: 0.88, green: 0.22, blue: 0.28)
        }
    }

    var icon: String {
        switch self {
        case .light:
            return "circle.dotted"
        case .moderate:
            return "exclamationmark.circle"
        case .high:
            return "flame"
        case .stubborn:
            return "flame.fill"
        }
    }
}

struct CategoryPicker: View {
    @Binding var selection: VocabularyCategory

    var body: some View {
        Picker("分类", selection: $selection) {
            ForEach(VocabularyCategory.allCases) { category in
                Text(category.rawValue)
                    .tag(category)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 58, height: 58)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

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
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(configuration.isPressed ? Color.white : color)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? color : color.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.26, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
