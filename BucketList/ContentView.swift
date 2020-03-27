//
//  ContentView.swift
//  BucketList
//
//  Created by dominator on 29/01/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    @State private var mapIsDragging = false
    @State private var centerCordinate = MKPointAnnotation.example.coordinate
    @State private var selectedLocation: MKPointAnnotation?
    @State private var isShowingDetail = false
    @State private var locations: [CodableMKPointAnnotation] = []
    @State private var showEdit = false
    @State private var isUnlocked = false
    
    var body: some View {
        ZStack {
            if isUnlocked{
                MapView(centerCordinate: $centerCordinate, isDragging: $mapIsDragging, selectedLocation: $selectedLocation, isShowingDetail: $isShowingDetail, annotations: locations)
                    .edgesIgnoringSafeArea(.all)
                ZStack {
                    if !mapIsDragging{
                        Button(action: {
                            let location = CodableMKPointAnnotation()
                            location.coordinate = self.centerCordinate
                            self.locations.append(location)
                            self.selectedLocation = location
                            self.showEdit = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Location")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(UIColor.systemBackground)))
                        .foregroundColor(.primary)
                        .offset(x: 0, y: -50)
                        .shadow(radius: 8)
                        
                    }
                    
                    Circle()
                        .fill(Color.blue)
                        .opacity(0.3)
                        .frame(width: 25, height: 25)
                    Circle()
                        .fill(Color.blue)
                        .opacity(0.5)
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 5, height: 5)
                }
            }else{
                Button(action: {
                    self.authenticate()
                }) {
                    VStack {
                        Image(systemName: "faceid")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        Text("Unlock places")
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 8)
            }
        }
        .alert(isPresented: $isShowingDetail) {
            Alert(title: Text(selectedLocation?.title ?? "Unknown"), message: Text(selectedLocation?.subtitle ?? "Place detail not available."), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit"), action: {
                //edit
                self.showEdit = true
            }))
        }
        .sheet(isPresented: $showEdit, onDismiss: saveData) {
            if self.selectedLocation != nil{
                EditView(annotation: self.selectedLocation!)
            }
        }
        .onAppear(perform: loadData)
    }
    
    func getDocumentDirectory() -> URL{
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func loadData(){
        let filename = getDocumentDirectory().appendingPathComponent("SavedPlaces")
        
        do{
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        }catch{
            print("Unable to load location: \(error)")
        }
    }
    
    func saveData(){
        let filename = getDocumentDirectory().appendingPathComponent("SavedPlaces")
        
        do{
            let data = try JSONEncoder().encode(locations)
            try data.write(to: filename, options: [.atomicWrite,.completeFileProtection])
        }catch{
            print("Unable to save locations: \(error)")
        }
    }
    
    func authenticate(){
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "We need to verify it's u before accessing your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success{
                    DispatchQueue.main.async {
                        self.isUnlocked = true
                    }
                }else{
                    //error
                }
            }
        }else{
            //no faceid or finger print
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
