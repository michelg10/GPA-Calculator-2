//
//  common.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation
import SwiftUI

struct nilButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}
func isEqual(_ a: Float, _ b: Float) -> Bool {
    return abs(a-b)<0.000001
}
