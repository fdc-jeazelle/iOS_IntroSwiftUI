//
//  UniversityListView.swift
//  iOS_IntroSwiftUI
//
//  Created by FDC.JEAZELLE-NC-WEB on 7/24/24.
//

import SwiftUI
import UIKit
import WebKit

struct University: Decodable, Identifiable, Equatable{
    let id = UUID()
    let alphaTwoCode: String
    let webPages: [String]
    let country: String
    let domains: [String]
    let name: String
    let stateProvince: String?

}

struct UniversityLogoView: View {
    let universityName: String
    @State private var logoURL: URL?
    
    var body: some View {
        VStack {
            if let logoURL = logoURL {
                AsyncImage(url: logoURL) { phase in
                    if let image = phase.image {
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 50, height:50)
                    } else if phase.error != nil {
                        Text("Error loading logo")
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 100, height: 100)
            } else {
                ProgressView()
                    .onAppear {
                        fetchLogo()
                    }
            }
        }
    }
    
    private func fetchLogo() {
        guard let encodedName = universityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let logoAPI = "https://logo.clearbit.com/\(encodedName)"
        
        guard let url = URL(string: logoAPI) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.logoURL = url
                }
            } else {
                print("Error fetching logo: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
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
//                    print("Fetched universities: \(universities)")
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
    @State private var longPressedUniversity: University?
    @State private var showDeleteConfirmation = false
    @State private var universityToDelete: University?
    @State private var isShowActions = false
    @State private var expandedUniversityId: UUID?
//    @State private var showBlinkingIcon = false
    var body: some View {
        NavigationView {
            ZStack{
            // Set the background color here
                VStack{
                    SearchBar(text: $searchText, backgroundColor: UIColor(red:250/255, green:250/255, blue: 237/255, alpha: 1))
                       
                    List(filteredUniversities) { university in
                        if let webPage = university.webPages.first, let url = URL(string: webPage)  {
                            HStack {
                                // University icon and details
                                var domain = university.domains.first ?? ""
                                
                                UniversityLogoView(universityName: domain)
//                                Image(logo)
//                                    .resizable()
//                                    .frame(width: 50, height: 50)
//                                    .foregroundStyle(.blue)
                                Spacer()
                                    .frame(width: 30)
                                VStack(alignment: .leading) {
                                    Button(action: {
                                        urlState.selectedURL = url
                                        urlState.isPresentingView = true
                                    }) {
                                        Text(university.name)
                                            .font(.headline)
                                            .foregroundStyle(.black)
                                    }
                                    .buttonStyle(HoverButtonStyle())
                                    
                                    Text(university.country)
                                        .font(.subheadline)
                                }
                                Spacer()
                                VStack {
                                    // Favorite button
                                    Button(action: {
                                        if cart.contains(university.id) {
                                            cart.removeAll { $0 == university.id }
                                            alertMessage = "Removed from Favorites!"
                                        } else {
                                            cart.append(university.id)
                                            alertMessage = "Added to Favorites!"
                                        }
                                        showAlert = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showAlert = false
                                            }
                                        }
                                    }) {
                                        Image(systemName: cart.contains(university.id) ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                            .frame(width: 40, height: 40)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {}.onLongPressGesture(minimumDuration: 0.2) {
                                if expandedUniversityId == university.id {
                                    expandedUniversityId = nil // Collapse if already expanded
                                } else {
                                    expandedUniversityId = university.id // Expand the selected university
                                }
                            }

                            if expandedUniversityId == university.id {
                                HStack(alignment: .center){
                                    Spacer()
                                    Button(action: {
                                        universityToDelete = university
                                        showDeleteConfirmation = true
                                    }) {
                                        Text("Remove")
                                            .foregroundColor(.red)
                                            .frame(width: 100, height: 40)
                                    }
                                    .frame(alignment: .center)
                                    .buttonStyle(BorderlessButtonStyle())
                                    Spacer()
                                }
                               
                            }
//                                if isShowActions {
//                                    HStack{
//                                        Spacer()
//                                        Button(action: {
//                                            universityToDelete = university
//                                            showDeleteConfirmation = true
//                                        }) {
//                                           Text("Remove")
//                                        }
//                                      
//                                         .buttonStyle(BorderlessButtonStyle())
//                                }
//                                .background(.clear)
//                                .frame(maxHeight: isShowActions ? nil : 0, alignment: .top)
//                                .clipped()}
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .navigationTitle("Universities")
                    .onAppear {
                        viewModel.fetchUniversities()
                    }
                    .fullScreenCover(isPresented: $urlState.isPresentingView){
                        if let url = urlState.selectedURL {
                            WebViewContainer(url: url, isPresented: $urlState.isPresentingView)
                        }
                    }
                    
                    .onTapGesture {
                        // Hide delete button when tapping outside the list
                        if expandedUniversityId != nil {
                            withAnimation {
                                expandedUniversityId = nil
                            }
                        }
                    }
                    .overlay(
                       Group {
                           if showAlert {
                               VStack{
                                   Image(systemName: "checkmark")
                                       .resizable()
                                       .frame(width: 100, height: 100)
                                       .foregroundColor(.red)
                                       .opacity(showAlert ? 1 : 0)
                                       .transition(.scale(scale: 0.5, anchor: .center).combined(with: .opacity))
                                       .zIndex(1)
                                       .animation(Animation.easeInOut(duration: 1.5), value: showAlert)
                                   Text(alertMessage)
                                       .foregroundColor(.white)
                               }
                               .padding(20)
                               .background(Color.gray.opacity(0.5))
                               
                           }
                       }
                   )
                }
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
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this university?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let university = universityToDelete,
                           let index = viewModel.universities.firstIndex(where: { $0.id == university.id }) {
                            viewModel.universities.remove(at: index)
                            alertMessage = "\(university.name) removed from the list!"
                            showAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showAlert = false
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
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
    //delete
    private func deleteItems(at offsets: IndexSet) {
           // Remove items from the universities array based on the index set
           viewModel.universities.remove(atOffsets: offsets)
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
//            .padding(20)
            .background(configuration.isPressed ? .gray.opacity(0.3) : .clear)
//            .cornerRadius(8)
    }
}
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var backgroundColor: UIColor
    
    
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
        uiView.backgroundColor = backgroundColor
    }
}



#Preview {
    UniversityListView()
}
