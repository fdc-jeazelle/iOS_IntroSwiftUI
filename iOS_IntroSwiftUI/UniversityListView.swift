//
//  UniversityListView.swift
//  iOS_IntroSwiftUI
//
//  Created by FDC.JEAZELLE-NC-WEB on 7/24/24.
//

import SwiftUI
import UIKit
import WebKit

struct University: Decodable, Identifiable{
    let id = UUID()
    let alphaTwoCode: String
    let webPages: [String]
    let country: String
    let domains: [String]
    let name: String
    let stateProvince: String?

}
class UniversityViewModel: ObservableObject{
    @Published var universities: [University] = []
    @Published var errorMessage: String?
    
    func fetchUniversities(){
        let urlString = "http://universities.hipolabs.com/search?country=United+Kingdom"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let universities = try decoder.decode([University].self, from: data)
                DispatchQueue.main.async {
                    self.universities = universities
                    print("Fetched universities: \(universities)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
struct UniversityListView: View {
    class URLState: ObservableObject{
        @Published var selectedURL: URL?
        @Published var isPresentingView  = false
    }
    
   @StateObject private var viewModel = UniversityViewModel()
   @StateObject private var urlState = URLState()
    @State private var cart: [UUID] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                    SearchBar(text: $searchText)
                    List(filteredUniversities) { university in
                        if let webPage = university.webPages.first, let url = URL(string: webPage)  {
                            HStack {
                                Button(action: {
                                    print(url)
                                    urlState.selectedURL = url
                                    urlState.isPresentingView = true
                                   
                                })
                                {
                                    HStack{
                                        Image(systemName: "graduationcap.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundStyle(.blue)
                                        Spacer()
                                            .frame(width: 20)
                                        VStack(alignment: .leading) {
                                            Text(university.name)
                                                .frame(alignment: .leading)
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                            Text(university.country)
                                                .font(.subheadline)
                                        }
                                        
                                    }
                                    .frame(width: 250, alignment: .leading)
                                }
                                
                                .buttonStyle(HoverButtonStyle())
                                .listRowBackground(Color(.systemGray6))
                                
                                Spacer()
                                Button(action: {
                                    if cart.contains(university.id){
                                        cart.removeAll{$0 == university.id}
                                        alertMessage = "\(university.name) removed from Favorites!"
                                    } else {
                                        cart.append(university.id)
                                        print(cart)
                                        alertMessage = "\(university.name) added to Favorites!"
                                        
                                    }
                                    showAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showAlert = false
                                        }
                                    }
                                })
                                {
                                    Image(systemName: cart.contains(university.id) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .navigationTitle("Universities")
                    .onAppear {
                        viewModel.fetchUniversities()
                    }
                    .fullScreenCover(isPresented: $urlState.isPresentingView){
                        if let url = urlState.selectedURL {
                            WebViewContainer(url: url, isPresented: $urlState.isPresentingView)
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Favorite!"), message: Text(alertMessage), dismissButton: nil)
                    }
                }
               
                
                // Favorites button at the bottom-right
               VStack {
                   Spacer()
                   HStack {
                       Spacer()
                       Button(action: {
                           // Add action for Favorites button
                           print(cart)
                       }) {
                           Image(systemName: "heart.circle.fill")
                               .resizable()
                               .frame(width: 50, height: 50)
                               .foregroundColor(.red)
                               .padding()
                       }
                       .background(Color.red.opacity(0.7))
                       .clipShape(Circle())
                       .padding()
                   }
               }
            }
       }
//        UniversityList(
    }
    var filteredUniversities: [University]{
        if searchText.isEmpty{
            return viewModel.universities
        }else {
            return viewModel.universities.filter{
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
}


struct WebViewContainer: View {
    let url: URL
    @Binding var isPresented: Bool
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: url, isLoading: $isLoading)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5, anchor: .center)
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                           isPresented = false
            })
        }
    }
}

struct WebView: UIViewRepresentable{
    let url: URL
    @Binding var isLoading: Bool
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            parent.isLoading = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    func makeUIView(context: Context) -> WKWebView{
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
// Custom button style to simulate hover effect
struct HoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(8)
    }
}
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate{
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
            text = searchText
        }
           
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

#Preview {
    UniversityListView()
}
