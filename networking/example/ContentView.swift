//
//  ContentView.swift
//  networking
//
//  Created by Harutyun Shamyan on 14.02.23.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Text("Hello, world!")
        }
        .padding()
        .onAppear(perform: {
            viewModel.fetchImage()
        })
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(viewModel: .preview)
    }

}
