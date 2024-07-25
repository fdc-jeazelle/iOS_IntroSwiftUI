//
//  JokesView.swift
//  iOS_IntroSwiftUI
//
//  Created by FDC.JEAZELLE-NC-WEB on 7/24/24.
//

import SwiftUI
import Foundation

struct RandomJoke: Decodable {
    let type: String
    let setup: String
    let punchline: String
    let id: Int
}

class RandomJokeClass: ObservableObject {
   @Published var randomJoke: RandomJoke?
//    @Published var author: String
    init() {
           fetchRandomJoke()
       }
    
    func fetchRandomJoke() {
        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else { return }
        
    // Create a data task to fetch the joke
       URLSession.shared.dataTask(with: url) { data, response, error in
           // Ensure data is not nil
           if let data = data {
               // Try to decode the data into a RandomJoke object
               if let joke = try? JSONDecoder().decode(RandomJoke.self, from: data) {
                   // Update the randomJoke property on the main thread
                   DispatchQueue.main.async {
                       self.randomJoke = joke
                   }
               }
           }
       }.resume() // Start the data task
    }
}

struct JokesView: View {
    @StateObject private var viewModel = RandomJokeClass()
    @State var isPresentingSecondView  = false
//    let viewModel = RandomJokeClass()
    var body: some View {
        
        VStack {
           // Display the joke if it's available
           if let joke = viewModel.randomJoke {
               Text(joke.setup)
                   .font(.title)
                   .padding()
               Text(joke.punchline)
                   .font(.title2)
                   .padding()
           } else {
               // Display a loading message while fetching the joke
               Text("Fetching joke...")
                   .font(.title)
                   .padding()
           }

           // Button to fetch another joke
           Button(action: {
               viewModel.fetchRandomJoke()
           }) {
               Text("Give me another joke")
                   .font(.title)
                   .padding()
                   .background(Color.blue)
                   .foregroundColor(.white)
                   .cornerRadius(10)
           }
           .padding()
            
            Button(action: {
                isPresentingSecondView = true
            }){
               Text("Second View")
            }
            
            Button(action: {
               
            }){
               Text("isPresented")
            }
            
       }
       // Fetch a joke when the view appears
       .onAppear {
           viewModel.fetchRandomJoke()
       }
       .sheet(isPresented: $isPresentingSecondView, content: {
           SecondView(viewModel: viewModel)
       })
    }
}

struct SecondView: View {
     var viewModel: RandomJokeClass
    @State private var author = ""
    var body: some View {
        VStack {
            // Display the joke if it's available
            if let joke = viewModel.randomJoke {
                Text(joke.setup)
                    .font(.title)
                    .padding()
                Text(joke.punchline)
                    .font(.title2)
                    .padding()
                TextField("Author", text: $author)
            } else {
                // Display a loading message while fetching the joke
                Text("Fetching joke...")
                    .font(.title)
                    .padding()
            }
            
            // Button to fetch another joke
            Button(action: {
                viewModel.fetchRandomJoke()
            }) {
                Text("Give me another joke")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
#Preview {
    JokesView()
}
