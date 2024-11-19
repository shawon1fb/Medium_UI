//
//  ContentView.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    @State var count: Int = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("count -> \(count)")
        }
        .padding()
        .background(Color.teal)
        .onTapGesture {
            Task{
                if let rs =   try?  await MediumRepository().getPost(){
                    count = rs.count
                }
                
                
            }
        }
    }
}

#Preview {
    ContentView()
}
