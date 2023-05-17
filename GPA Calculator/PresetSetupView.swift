//
//  PresetSetupView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/13.
//

import SwiftUI

struct PresetSetupView: View {
    @State var navAction: Int? = 0
    var appSingleton: AppSingleton
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(
                    destination: ContentView(appSingleton: appSingleton),tag: 1,selection: $navAction,
                    label: {
                        EmptyView()
                    })
                ZStack {
                    Rectangle()
                        .ignoresSafeArea(.all, edges: .top)
                        .foregroundColor(.init("PresetSetupTop"))
                    Rectangle()
                        .foregroundColor(.init("AntiPrimary"))
                }
                VStack(spacing:0) {
                    HStack(spacing:0) {
                        Spacer()
                        Text("Choose Your Grade")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.top, 27)
                            .padding(.bottom, 18)
                        Spacer()
                    }.background(Color.init("PresetSetupTop"))
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 151))], spacing: 10) {
                            ForEach((0..<presets.count), id: \.self) { index in
                                Button {
                                    navAction=1
                                    vibrate(.medium)
                                    let defaults = UserDefaults.standard
                                    defaults.setValue(presets[index].id, forKey: "PresetId")
                                    defaults.synchronize()
                                    appSingleton.reloadFromSave()
                                } label: {
                                    PresetOptionView(selected: false, name: presets[index].name, subtitle: presets[index].getComputedSubtitle())
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

struct PresetSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PresetSetupView(appSingleton: .init(loadSave: false))
    }
}
