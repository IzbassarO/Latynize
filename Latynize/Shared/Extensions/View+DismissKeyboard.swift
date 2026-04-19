//
//  View+DismissKeyboard.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.04.2026.
//

import Foundation
import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
