import SwiftUI

struct WrapChips: View {
    let items: [String]

    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 120), spacing: 8)
        ]

        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item.capitalized)
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppTheme.danger.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}
