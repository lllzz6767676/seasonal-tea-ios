import Foundation

struct TeaRepository {
    static let shared = TeaRepository()

    let teas: [Tea]
    let loadError: String?

    private init() {
        guard let url = Bundle.main.url(forResource: "tea_data", withExtension: "json") else {
            teas = []
            loadError = "找不到本地茶饮数据文件。"
            return
        }

        do {
            let data = try Data(contentsOf: url)
            teas = try JSONDecoder().decode([Tea].self, from: data)
            loadError = nil
        } catch {
            teas = []
            loadError = "茶饮数据读取失败：\(error.localizedDescription)"
        }
    }

    func tea(id: String) -> Tea? {
        teas.first { $0.id == id }
    }
}
