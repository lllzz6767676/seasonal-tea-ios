import SwiftUI

struct TeaCategoryView: View {
    let category: TeaCategory
    let teas: [Tea]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("以下内容包括人体研究茶饮与国家卫生健康委食养指南中的食养方。指南收录属于食养参考，不代表该精确复方经过大型随机对照试验验证。")
                    .font(.subheadline)
                    .foregroundStyle(TeaPalette.secondaryInk)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(TeaPalette.sage.opacity(0.72), in: RoundedRectangle(cornerRadius: 19, style: .continuous))

                if teas.isEmpty {
                    ContentUnavailableView(
                        "此分类暂无茶饮",
                        systemImage: "leaf",
                        description: Text("可以返回茶库搜索茶名、原料或指南关键词。")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(teas) { tea in
                            TeaCard(tea: tea)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 28)
            .frame(maxWidth: 660)
            .frame(maxWidth: .infinity)
        }
        .background(TeaPalette.background.ignoresSafeArea())
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
