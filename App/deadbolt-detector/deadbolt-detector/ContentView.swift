//
//  ContentView.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 6/20/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var email=""
    
    var body: some View {
        NavigationView{
            VStack{
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150,height: 150)
                VStack {
                    TextField("Email Address", text:$email).padding().background(Color(.secondarySystemBackground))
                    SecureField("Email Address", text:$email).padding().background(Color(.secondarySystemBackground))
                    
                    Button(action: {
                        
                    }, label: {
                        Text("Sign In").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
                    })
                    
                }.padding()
                
                Spacer()
                
            }.navigationTitle("Sign In")
        }
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
