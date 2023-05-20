import SwiftUI

@main
struct GPA_CalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            if AppSingleton.currentPresetInSaveIsValid() {
                ContentView(appSingleton: .init(loadSave: true))
                    .navigationTitle("GPA Calculator")
            } else {
                WelcomeView(appSingleton: .init(loadSave: false))
            }
        }
    }
}
