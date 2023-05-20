import Foundation
import SwiftUI

// `PresetItemView` is a SwiftUI `View` representing a preset item in a list.
// It displays the preset's name and subtitle, with a background that changes
// color when the preset is selected.
struct PresetItemView: View {
    var selected: Bool  // Indicates whether the preset is currently selected.
    var name: String  // The name of the preset.
    var subtitle: String  // The subtitle of the preset.
    
    var body: some View {
        ZStack {
            // The default background of the preset item.
            RoundedRectangle(cornerRadius: 11)
                .frame(height: 78)
                .foregroundColor(.init("PresetBackground"))
            
            // The highlighted background displayed when the preset item is selected.
            // The highlighted background is a linear gradient.
            RoundedRectangle(cornerRadius: 11)
                .fill(LinearGradient(gradient: .init(colors: [Color.init("GradientL"), Color.init("GradientR")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 78)
                .animation(nil)
                .opacity(selected ? 1 : 0)  // Only visible when the preset is selected.
                .animation(.easeInOut(duration: 0.4))  // The visibility change has a smooth animation.
            
            // The vertical stack contains the name and subtitle of the preset.
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.init("PresetSecondary"))
            }.padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)  // The text is aligned to the left.
        }
    }
}

// The `CustomizeView` is a SwiftUI `View` providing an interface for customization options.
// It allows the user to choose the format of the GPA display, select a preset, and modify preset options.
struct CustomizeView: View {
    @ObservedObject var appSingleton: AppSingleton  // The shared application data.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass  // The current size class of the device.

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Picker for the name format
                VStack(alignment: .leading, spacing: 11) {
                    Text("Format")
                        .font(.title)
                        .bold()
                    
                    // Picker allows selection between "Percentage" and "Letter" modes.
                    Picker(selection: .init(get: {
                        appSingleton.nameMode
                    }, set: { val in
                        vibrate(.light)
                        appSingleton.nameMode = val  // The name mode is updated whenever a new selection is made.
                    })) {
                        Text("Percentage").tag(NameMode.percentage)
                        Text("Letter").tag(NameMode.letter)
                    } label: {
                        EmptyView()
                    }.pickerStyle(SegmentedPickerStyle())
                }.padding(.bottom, 23)
                
                // Presets
                VStack(alignment: .leading, spacing: 11) {
                    Text("Presets")
                        .font(.title)
                        .bold()
                    
                    // Grid view of presets. When a preset is selected, the current preset index is updated,
                    // and the preset options are initialized.
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 151))], spacing: 10) {
                        ForEach((0..<presets.count), id: \.self) { index in
                            Button {
                                vibrate(.medium)
                                appSingleton.currentPresetIndex = index
                                appSingleton.initializePresetOptionsForCurrentPresetIndex()
                            } label: {
                                PresetItemView(selected: appSingleton.currentPresetIndex == index, name: presets[index].name, subtitle: presets[index].subtitle)
                            }.buttonStyle(nilButtonStyle())
                        }
                    }
                }.padding(.bottom, 25)
                
                // Preset options
                // These options are only shown if there are any preset options.
                if appSingleton.presetOptionsCount != 0 {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Preset Options")
                            .font(.title)
                            .bold()
                        
                        // Each preset option is shown with a picker.
                        // The selected value of the picker is stored in `alternativeNamePreferenceIndex`.
                        VStack(spacing: 12) {
                            ForEach((0..<appSingleton.presetOptionsCount), id:\.self) { index in
                                // This horizontal stack represents a single preset option.
                                HStack(alignment: .center, spacing: 0) {
                                    // The title of the option is fetched from the `presetOptions` array in `appSingleton`.
                                    let optionTitle = appSingleton.presetOptions[index].name
                                    // The title's display text changes based on the horizontal size class of the device.
                                    Text(horizontalSizeClass == .regular ? optionTitle.regular : optionTitle.compact)
                                        .font(.title2)
                                        .bold()
                                    Spacer()  // Pushes the following content to the right.

                                    // The picker and its rounded rectangle background are placed in a ZStack.
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9)
                                            .frame(width: 166, height: 37)
                                            .foregroundColor(.init("PresetOptionsBackground"))

                                        // A picker is used to provide selection among available choices for the option.
                                        Picker(selection: .init(get: { () -> Int in
                                            // The current selection is stored in the `userNameChoiceIndex` array in `appSingleton`.
                                            appSingleton.alternativeNamePreferenceIndex[appSingleton.currentPresetIndex][appSingleton.presetOptions[index].correspondingIndex]
                                        }, set: { x in
                                            vibrate(.light)
                                            // When a new selection is made, the corresponding value in `userNameChoiceIndex` is updated.
                                            appSingleton.alternativeNamePreferenceIndex[appSingleton.currentPresetIndex][appSingleton.presetOptions[index].correspondingIndex] = x
                                            // An update is triggered in `appSingleton` to reflect this change.
                                            appSingleton.update()
                                        })) {
                                            // The base name text of the picker and additional choices are fetched from `presetOptions` and displayed.
                                            let baseNameText = appSingleton.presetOptions[index].name
                                            Text(horizontalSizeClass == .regular ? baseNameText.regular : baseNameText.compact).tag(-1)
                                            ForEach((0..<appSingleton.presetOptions[index].additionalChoicesSize), id:\.self) { index2 in
                                                let choiceText = appSingleton.presetOptions[index].additionalChoices[index2]
                                                Text(horizontalSizeClass == .regular ? choiceText.regular : choiceText.compact).tag(index2)
                                            }
                                        } label: {
                                            EmptyView()
                                        }.pickerStyle(MenuPickerStyle())
                                        .onTapGesture(perform: {
                                            vibrate(.light)  // Vibration feedback is given when the picker is tapped.
                                        })
                                        .fixedSize()
                                    }
                                }
                            }
                        }
                    }.id(String(appSingleton.currentPresetIndex)+"Prefs")
                }
            }.padding(.horizontal, 16)
            .padding(.bottom, 40)
        }.navigationTitle("Customize")
            .background(Color.init("AntiPrimary"))
            .onDisappear(perform: {
                // When the view disappears, the current state of the appSingleton is saved.
                appSingleton.saveData()
            })
    }
}

struct CustomizeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeView(appSingleton: .init(loadSave: false))
    }
}
