import Foundation

enum TeaType: String, Codable, Hashable {
    case single = "单品茶饮"
    case compound = "复方食养茶"
}

struct TeaIngredient: Codable, Hashable, Identifiable {
    let name: String
    let amount: String

    var id: String { "\(name)-\(amount)" }
}

struct Tea: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let type: TeaType
    let kind: String
    let category: String
    let categories: [String]
    let tags: [String]
    let ingredients: [TeaIngredient]
    let benefit: String
    let recipe: String
    let evidenceLabel: String
    let evidenceSummary: String
    let sourceTitle: String
    let sourceURL: String?
    let officialContext: String
    let cautions: [String]
    let seasonRecommendable: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, type, kind, category, categories, tags, ingredients
        case benefit, recipe, evidenceLabel, evidenceSummary, sourceTitle
        case sourceURL = "sourceUrl"
        case officialContext, cautions, seasonRecommendable
    }

    var searchDocument: String {
        ([name, kind, category, benefit, recipe, evidenceLabel, evidenceSummary,
          sourceTitle, officialContext] + categories + tags + ingredients.map(\.name))
            .joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }
}

struct TeaCategory: Identifiable, Hashable {
    let name: String
    let symbol: String
    let subtitle: String

    var id: String { name }

    static let all: [TeaCategory] = [
        .init(name: "血压管理", symbol: "heart.text.square", subtitle: "日常饮品与相关研究"),
        .init(name: "血脂管理", symbol: "drop", subtitle: "饮食与心代谢研究"),
        .init(name: "血糖代谢", symbol: "waveform.path.ecg", subtitle: "研究结果因人群而异"),
        .init(name: "提神与认知", symbol: "brain.head.profile", subtitle: "留意咖啡因与饮用时间"),
        .init(name: "睡眠与情绪", symbol: "moon.zzz", subtitle: "证据范围以原研究为准"),
        .init(name: "胃肠 / 恶心", symbol: "fork.knife", subtitle: "日常饮品与研究信息"),
        .init(name: "咳嗽 / 咽喉", symbol: "wind", subtitle: "注意特定人群限制"),
        .init(name: "女性健康", symbol: "figure.stand", subtitle: "研究人群与条件有限"),
        .init(name: "体重管理", symbol: "scalemass", subtitle: "食养参考不等于减重治疗"),
        .init(name: "高尿酸 / 痛风食养", symbol: "cross.case", subtitle: "指南食养参考"),
        .init(name: "脑卒中恢复期食养", symbol: "figure.walk", subtitle: "适用阶段请查看详情"),
        .init(name: "少糖饮品替代", symbol: "cup.and.saucer", subtitle: "关注添加糖摄入"),
        .init(name: "循环 / 水肿相关", symbol: "water.waves", subtitle: "查看原始资料与注意事项")
    ]
}
