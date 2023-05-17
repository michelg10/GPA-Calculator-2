//
//  WelcomeView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/13.
//

import SwiftUI

struct WelcomeView: View {
    @State var navAction:Int? = 0
    var appSingleton: AppSingleton
    
    var body: some View {
        NavigationView {
            VStack(spacing:0) {
                NavigationLink(
                    destination: PresetSetupView(appSingleton: appSingleton),tag: 1,selection: $navAction,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
                VStack(spacing:0) {
                    Image("Icon")
                        .resizable()
                        .frame(width:123, height: 123)
                        .shadow(color: .init("WelcomeShadow"), radius: 13, x: 0, y: 0)
                        .padding(.bottom, 25)
                    Text("Welcome To GPA Calculator")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 19)
                        .padding(.horizontal, 57)
                    Text("Compute SHSID GPAs instantly and accurately")
                        .font(.system(size: 22, weight: .medium, design: .default))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
                Spacer()
                Button {
                    vibrate(.medium)
                    navAction=1
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 31)
                            .foregroundColor(.init("ContinueButtonBackground"))
                        Text("Continue")
                            .font(.system(size: 24, weight: .medium, design: .default))
                            .foregroundColor(.init("ContinueButtonText"))
                    }.frame(width: 196, height: 62)
                }.padding(.bottom, 72)
                .buttonStyle(nilButtonStyle())
            }.navigationBarHidden(true)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .background(Color.init("AntiPrimary"))
        }.navigationViewStyle(.stack)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(appSingleton: .init(loadSave: false))
    }
}
