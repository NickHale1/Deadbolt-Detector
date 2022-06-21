//
//  ContentView.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 6/20/22.
//

import SwiftUI
import CoreData
import FirebaseAuth


class AppViewModel: ObservableObject{
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email, password: password) { [weak self]
            result, error in
            guard result != nil, error == nil else {
                return
            }
            //success
            DispatchQueue.main.async {
                self?.signedIn = true
            }

        }
    }
    
    func signUp(email: String, password: String){
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            //success
            DispatchQueue.main.async {
                self?.signedIn = true
            }
            
        }
        
    }
    
    func signOut(){
        try? auth.signOut()
        self.signedIn=false
    }
    
    
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView{
            if viewModel.signedIn {
                VStack{
                    Text("You are Signed in").padding()
                    Button(action: {
                        viewModel.signOut()
                    }, label: {
                        Text("Sign Out").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white).padding()
                    })
                }
            } else {
                SignInView()
            }
        }.onAppear{
            viewModel.signedIn=viewModel.isSignedIn
        }
    }
}


struct SignInView: View {
    
    @State var email=""
    @State var password=""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
        VStack{
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
            VStack {
                TextField("Email Address", text:$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                SecureField("Password", text:$password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    viewModel.signIn(email: email, password: password)
                }, label: {
                    Text("Sign In").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
                })
                
                NavigationLink("Create Account", destination: SignUpView()).padding()
                
            }.padding()
            
            Spacer()
            
        }.navigationTitle("Sign In")
        
    }
}

struct MainMenuView: View {
    var body: some View{
        VStack{
            Text("You are Signed in")
            Button(action: {
                //viewModel.out()
            }, label: {
                Text("Sign Out").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
            })
        }
    }
}

struct SignUpView: View {
    
    @State var email=""
    @State var password=""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
        VStack{
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
            VStack {
                TextField("Email Address", text:$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                SecureField("Password", text:$password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    viewModel.signUp(email: email, password: password)
                }, label: {
                    Text("Create Account").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
                })
                
            }.padding()
            
            Spacer()
            
        }.navigationTitle("Create Account")
        
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
