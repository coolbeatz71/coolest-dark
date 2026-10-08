import SwiftUI
import Combine

/// SwiftUI framework tour.
///
/// Covers View protocol, property wrappers, modifiers, bindings,
/// environment values, previews and observable objects.

/// An observable view model.
@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var likeCount: Int
    @Published var isBookmarked = false

    private var cancellables = Set<AnyCancellable>()

    init(likeCount: Int = 0) {
        self.likeCount = likeCount  // inline comment
    }

    /// Increments the like counter.
    /// - Returns: the new total
    @discardableResult
    func like() -> Int {
        likeCount += 1
        return likeCount
    }
}

struct ArticleCard: View {
    let title: String
    var subtitle: String?

    @StateObject private var viewModel = ArticleViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
    @Binding var selectedId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label("\(viewModel.likeCount)", systemImage: "heart.fill")
                    .foregroundStyle(colorScheme == .dark ? .pink : .red)

                Spacer()

                Button {
                    viewModel.like()
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onTapGesture { withAnimation(.spring) { isExpanded.toggle() } }
        .task { await load() }
    }

    private func load() async {
        try? await Task.sleep(for: .milliseconds(200))
    }
}

#Preview("Light") {
    ArticleCard(title: "Hello", subtitle: "World", selectedId: .constant(nil))
}
