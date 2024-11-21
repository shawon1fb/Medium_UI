//
//  ContentView.swift
//  Medium_UI
//
//  Created by shahanul on 11/18/24.
//

import SwiftUI
import EasyX
import XSwiftUI

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



struct ContentView2: View {
    
    
    var body: some View {
        VStack{
            PostContentView()
        }
        .background(Color(hex: "#1F2A37"))
        
    }
}

#Preview {
    ContentView()
}
