//
//  MapView.swift
//  MapKitInSwiftUI
//
//  Created by dominator on 19/02/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var centerCordinate: CLLocationCoordinate2D
    @Binding var isDragging: Bool
    @Binding var selectedLocation: MKPointAnnotation?
    @Binding var isShowingDetail: Bool
    var annotations: [MKPointAnnotation]
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var parent: MapView
        init(_ parent: MapView){
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            self.parent.centerCordinate = mapView.centerCoordinate
        }


        
        @objc func didDragMap(_ sender: UIGestureRecognizer) {
            switch sender.state {
            case .began:
                self.parent.isDragging = true
            default: break;
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if animated == false{
                self.parent.isDragging = false
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }else{
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let place = view.annotation as? MKPointAnnotation else {return}
            self.parent.selectedLocation = place
            self.parent.isShowingDetail = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let view = mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers where recognizer is UIPanGestureRecognizer{
                recognizer.addTarget(context.coordinator, action: #selector(context.coordinator.didDragMap(_:)))
            }
        }
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if annotations.count != uiView.annotations.count{
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerCordinate: .constant(MKPointAnnotation.example.coordinate), isDragging: .constant(false), selectedLocation: .constant(MKPointAnnotation.example), isShowingDetail: .constant(false), annotations: [MKPointAnnotation.example])
            .padding()
            .cornerRadius(10)
            .shadow(radius: 8)
    }
}
extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}
