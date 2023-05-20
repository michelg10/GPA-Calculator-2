import SwiftUI

// PresetSetupView provides a screen for the user to choose their grade preset.
struct PresetSetupView: View {
    // `navAction` determines the destination view for the navigation link.
    // A value of 1 triggers a navigation to the `ContentView`.
    @State var navAction: Int? = 0

    // `appSingleton` holds the shared application data and methods used across different views.
    var appSingleton: AppSingleton
    
    var body: some View {
        // A NavigationView encapsulates the entire view, allowing navigations between views.
        NavigationView {
            ZStack {
                // The NavigationLink is set up to navigate to the `ContentView` when `navAction` is 1.
                // It's wrapped in an EmptyView as its activation is controlled programmatically, not by user interaction.
                NavigationLink(
                    destination: ContentView(appSingleton: appSingleton),
                    tag: 1,
                    selection: $navAction,
                    label: {
                        EmptyView()
                    }
                )
                
                // The ZStack here creates the background using two overlaid rectangles.
                ZStack {
                    Rectangle()
                        .ignoresSafeArea(.all, edges: .top)
                        .foregroundColor(.init("PresetSetupTop"))
                    Rectangle()
                        .foregroundColor(.init("AntiPrimary"))
                }
                
                // This VStack contains the title and the grade preset selection grid.
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer() // Creates empty space
                        Text("Choose Your Grade")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.top, 27)
                            .padding(.bottom, 18)
                        Spacer() // Creates empty space
                    }.background(Color.init("PresetSetupTop"))
                    
                    // A ScrollView that hosts a grid of grade presets buttons for user to select.
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 151))], spacing: 10) {
                            // Iterates over all the presets and generates a button for each.
                            // On button press, it saves the selected preset ID, reloads the singleton from the saved state, and triggers navigation to the next view.
                            ForEach((0..<presets.count), id: \.self) { index in
                                Button {
                                    navAction = 1
                                    vibrate(.medium)
                                    let defaults = UserDefaults.standard
                                    defaults.setValue(presets[index].id, forKey: "PresetId")
                                    defaults.synchronize()
                                    appSingleton.reloadFromSave()
                                } label: {
                                    PresetItemView(selected: false, name: presets[index].name, subtitle: presets[index].subtitle)
                                }.buttonStyle(nilButtonStyle())
                            }
                        }.padding(.horizontal, 16)
                        .padding(.top, 13)
                        .padding(.bottom, 40)
                    }
                }
            }.navigationBarHidden(true)
            .navigationViewStyle(.stack)
        }.navigationBarHidden(true)
        .navigationViewStyle(.stack)
    }
}

// This struct provides a preview of the `PresetSetupView` in Xcode's design canvas.
struct PresetSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PresetSetupView(appSingleton: .init(loadSave: false))
    }
}
