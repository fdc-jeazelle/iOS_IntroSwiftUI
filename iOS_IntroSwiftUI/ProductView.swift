//
//  ProductView.swift
//  iOS_IntroSwiftUI
//
//  Created by FDC.JEAZELLE-NC-WEB on 7/23/24.
//

import SwiftUI




struct ProductView: View {
    
    class ProductState: ObservableObject {
        @Published var selectedProduct: Product?
        @Published var showModal = false
    }
    
    @State var selectedImageIndex: Int = 0
    @State var isGrid = true
    @StateObject private var productState = ProductState()

 
    let products: [Product] = [
        Product(title: "Apple", description: "A juicy red apple", price: "$0.99", image:"https://i.pinimg.com/564x/c4/e6/d2/c4e6d2b8a24cc901e1eb19f68bc39b10.jpg"),
        Product(title: "Banana", description: "A ripe yellow banana", price: "$0.59", image: "https://i.pinimg.com/564x/c3/db/68/c3db682efe4b64609c4d8ea6ddb2ee8c.jpg"),
        Product(title: "Carrot", description: "A fresh orange carrot", price: "$0.89", image: "https://i.pinimg.com/564x/24/36/38/2436388eebba95074d3d9753fb327899.jpg"),
        Product(title: "Tomato", description: "A ripe red tomato", price: "$1.29", image: "https://i.pinimg.com/564x/7e/4c/54/7e4c54cac1152c377b3908e8eb687d4d.jpg"),
        Product(title: "Broccoli", description: "A fresh bunch of broccoli", price: "$2.99", image: "https://i.pinimg.com/564x/45/da/74/45da74018c89fdc65f8ebf64d2b0eb99.jpg"),
        Product(title: "Strawberry", description: "A box of fresh strawberries", price: "$3.99", image: "https://i.pinimg.com/564x/4c/ea/4c/4cea4cf6382afe2fd00b084a3a08fc76.jpg"),
        Product(title: "Blueberry", description: "A box of fresh blueberries", price: "$4.99", image: "https://i.pinimg.com/564x/d1/5f/4c/d15f4ca4d6681524e26c378b72446265.jpg"),
        Product(title: "Spinach", description: "A bunch of fresh spinach", price: "$2.49", image: "https://i.pinimg.com/564x/af/6e/e4/af6ee45dd4bc110383e92e79c6852325.jpg"),
        Product(title: "Potato", description: "A fresh potato", price: "$0.79", image: "https://i.pinimg.com/564x/60/a2/12/60a2124033a39728807b86fee3186339.jpg"),
        Product(title: "Orange", description: "A juicy orange", price: "$1.19", image: "https://i.pinimg.com/564x/99/b0/0a/99b00abfb5d26fee529f7c48624c0fee.jpg")
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 150),spacing: 16)
    ]
    
    
//    @State var selectedProduct: Product?
//    @State var showModal = false
    var body: some View {
        VStack {
            headerView
            bannerView
            Divider()
            HStack{
                Text("For you")
                    .font(.system(size: 24))
                Spacer()
                
                HStack{
                    Button(action: {
                        isGrid = true
                        // Action to perform when button is tapped
                    }) {
                        
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 24))
                            .opacity(!isGrid ? 0.5 : 1.0)
                            .foregroundStyle(!isGrid ? .blue : .gray)
                           
                    }
                    .disabled(isGrid ? true : false)// Adjust the size if needed
                     
                    
                    Button(action: {
                        isGrid = false
                        // Action to perform when button is tapped
                    }) {
                        
                        Image(systemName: "list.bullet")
                            .font(.system(size: 24))
                            .opacity(isGrid ? 0.5 : 1.0)
                            .foregroundStyle(isGrid ? .blue : .gray)
                           
                    }
                    .disabled(!isGrid ? true : false)// Adjust the size if needed
                   
                }
            }
            .padding(10)
           
            
            if isGrid {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(products) { product in
                            ProductItemView(product: product)
                                .onTapGesture {
                                    productState.selectedProduct = product
//                                    showModal.toggle()
                                    productState.showModal = true
                                }
                        }
                    }
                    .padding(15)
                    .sheet(isPresented: $productState.showModal, content: {
                        if let selectedProduct = productState.selectedProduct {
                            ProductDetailView(product: selectedProduct)
                                .frame(width: 300, height: 400)
                        }
                    })
                }
                .background(Color(red: 240/255, green: 230/255, blue:205/255))
//                .background(.yellow)
            }
            else {
                List {
                    ForEach(products) { product in
                        ProductRowView(product: product)
                            .onTapGesture {
                                productState.selectedProduct = product
                                productState.showModal = true
                            }
                    }
                }
                .sheet(isPresented: $productState.showModal, content: {
                    if let selectedProduct =  productState.selectedProduct {
                        ProductDetailView(product: selectedProduct)
                            .frame(width: 300, height: 400)
                    }
                })
            }
            
        }
//        .background(.beige)
    }
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Your Balance")
                Text("$1,700.00")
                    .font(.system(size: 24))
            }
            Spacer()
            Image(.profilePfp)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
        .padding(20)
//        .background(.red)
    }
    
    private var bannerView: some View {
       let carouselpics = [ "carousel1", "carousel2", "carousel3" ]
        
        
        return ZStack(alignment: .bottomLeading) {
            TabView(selection: $selectedImageIndex){
                ForEach(0..<carouselpics.count, id: \.self) { index in
                   Image(carouselpics[index]) // Display each image
                       .resizable() // Make the image resizable
                       .scaledToFill() // Scale the image to fill its frame
                       .frame(height: 300) // Set the height of the image
                       .clipShape(RoundedRectangle(cornerRadius:50.0)) // Clip the image to a rounded rectangle shape
                       .tag(index) // Tag the image with its index for selection
               }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear{
                selectedImageIndex = 0
            }
        
            Text("Buy Orange 10 Kg\nGet discount 25%")
                .padding(20)
                .shadow(radius: 25)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white)
            
            HStack{
                ForEach(0..<carouselpics.count, id: \.self) { index in
                    Capsule()
                        .fill(Color.white.opacity(selectedImageIndex == index ? 1 : 0.33))
                        .frame(width: 35, height:9)
                        .onTapGesture {
                            withAnimation{
                                selectedImageIndex = index
                            }
                        }
                        .padding(10)
                }
                .offset(x:100)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius:25.0))
        .padding(10)
//        .background(.red)
        .frame(height: 200)
        
    }
}

struct Product: Identifiable {
    let id = UUID() // set of randomized strings
    let title: String
    let description: String
    let price: String
    let image: String
}

struct ProductItemView: View {
    let product: Product

    var body: some View {
        VStack{
            AsyncImage(url: URL(string: product.image)) { image in
                image.image?.resizable()
            } // This assumes you have image assets with these names
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius:50.0))
            
            VStack(alignment: .center){
                Text(product.title)
                    .font(.headline)
//                Text(product.description)
//                    .font(.subheadline)
//                    .frame(alignment: .leading)
                Text(product.price)
                    .font(.caption)
            }
        }
        .frame(width:100, height: 100)
        .padding(40)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius:50.0))
        
    }
}

struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack{
            AsyncImage(url: URL(string: product.image)) { image in
                image.image?.resizable()
            } // This assumes you have image assets with these names
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius:50.0))
                
            Spacer()
                .frame(width: 20)
            VStack(alignment: .leading){
                Text(product.title)
                    .font(.headline)
    //                Text(product.description)
    //                    .font(.subheadline)
    //                    .frame(alignment: .leading)
                Text(product.price)
                    .font(.caption)
            }
            .padding(10)
            .frame(width: 250)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius:20.0))
        }
        .clipShape(RoundedRectangle(cornerRadius:20.0))
   
    }
}

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack{
            AsyncImage(url: URL(string: product.image)) { image in
                image.image?.resizable()
            } // This assumes you have image assets with these names
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius:50.0))
                .padding(20)
            Spacer()
                .frame(height: 20)
            VStack(alignment: .leading){
                Text(product.title)
                    .font(.system(size: 50))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Text(product.description)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                Spacer()
                HStack{
                    Text(product.price)
                        .padding(20)
                       
                        .font(.system(size: 40))
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius:50.0))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                    Button(action: {
                        print("Added to cart!")
                        // Action to perform when button is tapped
                    }) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)// Adjust the size if needed
                    }
                 
                }
                .padding(20)
                
            }
        }
//        .padding(.top, 20)
        .clipShape(RoundedRectangle(cornerRadius:20.0))
   
    }
}
#Preview {
    ProductView()
}
