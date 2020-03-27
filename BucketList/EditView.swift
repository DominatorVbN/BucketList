//
//  EditView.swift
//  MapKitInSwiftUI
//
//  Created by dominator on 23/02/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct EditView: View {
    
    enum LoadingState{
        case loading, loaded, error
    }
    
    @State private var loadingState = LoadingState.loading
    @State  private var pages = [Page]()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var annotation: MKPointAnnotation
    @State var request: AnyCancellable? = nil
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("Title", text: $annotation.wrappedTitle)
                    TextField("Description", text: $annotation.wrappedSubtitle)
                }
                Section(header: Text("Nearby...")) {
                    if loadingState == .loaded{
                        List(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                                + Text(": ") +
                                Text(page.description)
                                    .italic()
                        }
                    }else if loadingState == .loading{
                        Text("Loading...")
                    }else if loadingState == .error{
                        Text("Please try again later.")
                    }
                }
            }
            .navigationBarTitle("Edit Location")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            }))
                .onAppear(perform: fetchNearby)
        }
    }
    
    func fetchNearby() {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(annotation.coordinate.latitude)%7C\(annotation.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else{
            print("Bad url: \(urlString)")
            return
        }
        
        request = URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .map{$0.data}
            .tryMap{ data in
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(Result.self, from: data)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.loadingState = .loaded
            case .failure:
                self.loadingState = .error
            }
        }) { (result: Result) in
            self.pages = Array(result.query.pages.values).sorted()
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(annotation: MKPointAnnotation.example)
    }
}
