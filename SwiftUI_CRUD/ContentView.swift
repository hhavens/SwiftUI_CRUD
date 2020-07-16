//
//  ContentView.swift
//  SwiftUI_CRUD
//
//  Created by Henry Havens on 7/2/20.
//  Copyright © 2020 Henry Havens. All rights reserved.
//

//CRUD = Create, Read, Update, Delete

import SwiftUI
import Firebase
import FirebaseFirestore

struct Restaurant: Identifiable {
    var id = UUID()
    var name:String
    var rating:String
}

struct ContentView: View {
    
    @State var rating_id = ""
    @State var restaurantName = ""
    @State var restaurantRating = ""
    
    @State var reviewedRestaurants:[Restaurant]
    @State var showSheet = false
    @State var showActionSheet = false
    
    var body: some View {
        VStack{
            TextField("Add a restaurant", text: $restaurantName).padding()
            TextField("Rate this restaurant", text: $restaurantRating)
                .keyboardType(.numberPad)
                .padding()
            
            ScrollView{
                if reviewedRestaurants.count > 0 {
                    ForEach(reviewedRestaurants, id: \.id) { thisRestaurant in
                        Button(action: {
                            self.rating_id = thisRestaurant.id.uuidString
                            self.restaurantName = thisRestaurant.name
                            self.restaurantRating = thisRestaurant.rating
                            self.showSheet = true
                        }) {
                        HStack {
                            
                        Text("\(thisRestaurant.name) || \(thisRestaurant.rating))")
                            .frame(maxWidth: UIScreen.main.bounds.size.width)
                            .foregroundColor(.white)
                        }.background(Color.blue)
                        }.sheet(isPresented: self.$showSheet) {
                            VStack{
                                Text("Modify rating - \(thisRestaurant.id)")
                                TextField("Add a restaurant", text: self.$restaurantName).padding()
                                TextField("Rate this restaurant", text: self.$restaurantRating)
                                    .keyboardType(.numberPad)
                                HStack {
                                Button(action: {
                                    let ratingDictionary = [
                                        "name":self.restaurantName,
                                        "rating":self.restaurantRating
                                    ]
                                    let docRef = Firestore.firestore().document("ratings/\(self.rating_id)")
                                    print("setting data")
                                    docRef.setData(ratingDictionary, merge: true){ (error) in
                                        if let error = error {
                                            print("error = \(error)")
                                        } else {
                                            print("data updated successfully")
                                            self.showSheet = false
                                            self.restaurantName = ""
                                            self.restaurantRating = ""
                                           
                                        }
                                    }

                                    self.restaurantName = ""
                                    self.restaurantRating = ""
                                    self.showSheet = false
                                }){
                                   Text("Update")
                                    .padding()
                                    .background(Color.init(red: 0.92, green: 0.92, blue: 0.92))
                                    .foregroundColor(.black)
                                    .cornerRadius(5)
                                    }.padding()
                                    Button(action: {
                                        self.showActionSheet = true
                                    }){
                                        Text("Delete")
                                        .padding()
                                        .background(Color.init(red: 1, green: 0.9, blue: 0.9))
                                        .foregroundColor(.red)
                                        .cornerRadius(5)
                                    }.padding()
                                        .actionSheet(isPresented: self.$showActionSheet) {
                                            ActionSheet(title: Text("Delete"), message: Text("Are you sure you want to delete this item?"), buttons: [
                                                .default(Text("Yes"), action: {Firestore.firestore().collection("ratings").document("\(self.rating_id)").delete() { err in
                                                    if let err = err {
                                                        print("Error removing item: \(err)")
                                                    } else {
                                                        self.showSheet = false
                                                        print("Item successfully removed!")
                                                    }
                                                    }}),
                                                .cancel()])
                                    }                                }
                            }
                        }
                        
                    }
                } else {
                    Text("Submit a review")
                }
            }.frame(width: UIScreen.main.bounds.size.width)
                .background(Color.red)
            
            Button(action: {
                let ratingDictionary = [
                    "name":self.restaurantName,
                    "rating":self.restaurantRating
                ]
                let docRef = Firestore.firestore().document("ratings/\(self.rating_id)")
                print("setting data")
                docRef.setData(ratingDictionary){ (error) in
                    if let error = error {
                        print("error = \(error)")
                    } else {
                        print("data updated successfully")
                        self.showSheet = false
                        self.restaurantName = ""
                        self.restaurantRating = ""
                       
                    }
                }
            }){
                Text("Add Rating")
            }
        }.onAppear() {
            Firestore.firestore().collection("ratings")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let names = documents.map { $0["name"]! }
                let ratings = documents.map { $0["rating"]! }
                print(names)
                print(ratings)
                self.reviewedRestaurants.removeAll()
                for i in 0..<names.count {
                    self.reviewedRestaurants.append(Restaurant(
                        id: UUID(uuidString: documents[i].documentID) ?? UUID(),
                        name: names[i] as? String ?? "Failed to get name",
                        rating: ratings[i] as? String ?? "Failed to get rating"))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(reviewedRestaurants: [])
    }
}
