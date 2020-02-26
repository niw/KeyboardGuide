//
//  SwiftUIView.swift
//  Example
//
//  Created by Yoshimasa Niwa on 2/23/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Combine
import SwiftUI

@available(iOS 13.0, *)
struct SwiftUIView: View {
    final class Model: ObservableObject {
        let didTapDone = PassthroughSubject<Void, Never>()
    }

    @ObservedObject
    var model: Model

    var body: some View {
        NavigationView {
            Text("Sorry, not implemented yet.")
                .navigationBarTitle(Text("Example"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.model.didTapDone.send()
                }, label: {
                    Text("Done")
                        .bold()
                }))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 13.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView(model: SwiftUIView.Model())
    }
}
