//
//  CustomizeView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/5.
//

import Foundation
import SwiftUI

struct PresetOptionView: View {
    var selected: Bool
    var name: String
    var subtitle: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11)
                .frame(height: 78)
                .foregroundColor(.init("PresetBackground"))
            RoundedRectangle(cornerRadius: 11)
                .fill(LinearGradient(gradient: .init(colors: [Color.init("GradientL"), Color.init("GradientR")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 78)
                .animation(nil)
                .opacity(selected ? 1 : 0)
                .animation(.easeInOut(duration: 0.4))
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.init("PresetSecondary"))
            }.padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CustomizeView: View {
    @Binding var nameMode: NameMode
    @ObservedObject var appSingleton: AppSingleton
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 11) {
                    Text("Format")
                        .font(.title)
                        .bold()
                    Picker(selection: .init(get: {
                        nameMode
                    }, set: { x in
                        vibrate(.light)
                        nameMode=x
                    })) {
                        Text("Percentage").tag(NameMode.percentage)
                        Text("Letter").tag(NameMode.letter)
                    } label: {
                        EmptyView()
                    }.pickerStyle(SegmentedPickerStyle())
                }.padding(.bottom, 23)
                VStack(alignment: .leading, spacing: 11) {
                    Text("Presets")
                        .font(.title)
                        .bold()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 151))], spacing: 10) {
                        ForEach((0..<presets.count), id: \.self) { index in
                            Button {
                                vibrate(.medium)
                                appSingleton.appliedPresetIndex=index
                                appSingleton.prepareDraftForIndex()
                            } label: {
                                PresetOptionView(selected: appSingleton.appliedPresetIndex == index, name: presets[index].name, subtitle: presets[index].computedSubtitle)
                            }.buttonStyle(nilButtonStyle())
                        }
                    }
                }.padding(.bottom, 25)
                if appSingleton.presetOptionsCount != 0 {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Preset Options")
                            .font(.title)
                            .bold()
                        VStack(spacing: 12) {
                            ForEach((0..<appSingleton.presetOptionsCount), id:\.self) { index in
                                HStack(alignment: .center, spacing: 0) {
                                    let optionTitle = appSingleton.presetOptions[index].name
                                    Text(horizontalSizeClass == .regular ? optionTitle.regular : optionTitle.compact)
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9)
                                            .frame(width: 166, height: 37)
                                            .foregroundColor(.init("PresetOptionsBackground"))
                                        Picker(selection: .init(get: { () -> Int in
                                            appSingleton.userNameChoiceIndex[appSingleton.appliedPresetIndex][appSingleton.presetOptions[index].correspondingIndex]
                                        }, set: { x in
                                            vibrate(.light)
                                            appSingleton.userNameChoiceIndex[appSingleton.appliedPresetIndex][appSingleton.presetOptions[index].correspondingIndex]=x
                                        })) {
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
                                            vibrate(.light)
                                        })
                                        .fixedSize()
                                    }
                                }
                            }
                        }
                    }.id(String(appSingleton.appliedPresetIndex)+"Prefs")
                }
            }.padding(.horizontal, 16)
            .padding(.bottom, 40)
        }.navigationTitle("Customize")
            .background(Color.init("AntiPrimary"))
            .onDisappear(perform: {
                appSingleton.saveData()
            })
    }
}

struct CustomizeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeView(nameMode: .constant(.letter), appSingleton: .init(loadSave: true))
    }
}
