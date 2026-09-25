import SwiftUI

@main
struct TeaHealthApp: App {
    private let repository = TeaRepository.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if let error = repository.loadError {
                        ContentUnavailableView(
                            "茶饮资料暂不可用",
                            systemImage: "exclamationmark.triangle",
                            description: Text(error)
                        )
                    } else {
                        HomeView(teas: repository.teas)
                    }
                }
                .navigationDestination(for: Tea.self) { tea in
                    TeaDetailView(tea: tea)
                }
            }
            .tint(TeaPalette.green)
            .preferredColorScheme(.light)
        }
    }
}
