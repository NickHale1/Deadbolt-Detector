//
//  ContentView.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 6/20/22.
//

import SwiftUI
import CoreData
import FirebaseAuth
import Foundation

// Class that contains the firebase authentication functions
class AppViewModel: ObservableObject{
    
    let auth = Auth.auth()
    @Published var signedIn = false
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    // Sign in function
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
    // Reset password function
    func resetPassword(email: String){
        auth.sendPasswordReset(withEmail: email){ (error) in
            if let error=error {
                return
            }
     
        }
    }
     
    // Signup function
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
    // Sign out function
    func signOut(){
        try? auth.signOut()
        self.signedIn=false
    }
    
    
}

// Class to handle a lot of the API requests for views
class APIRequestManager: ObservableObject {
    private let key = "54324"
    
    @Published var result = "Unlocked"
    @Published var timeFlag = false
    @Published var resultBool=false
    @Published var imageName = "lock.open.fill"
    @Published var inputURL = "https://deadbolt-detector-default-rtdb.firebaseio.com/Detectors/12345.json"
    // Get the detector status of the user's device
    func getData() {
        guard let url = URL(string: inputURL) else {
            print("invaludURL")
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            (data,response,error) in
            guard let data = data else {
                print("could not get data")
                DispatchQueue.main.async {
                    self.result = "could not get data"
                }
                return
            }
            do {
                let myresult = try JSONDecoder().decode(detector.self, from:data)
                DispatchQueue.main.async {
                    print(myresult)
                    if(myresult.status==true){
                        // Door is locked
                        self.result="Locked"
                        self.imageName="lock.fill"
                    } else {
                        // Door is not locked
                        self.result="Unlocked"
                        self.imageName="lock.open.fill"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("\(error)")
                }
            }
            
        }
        .resume()
    }
}

// Basic data structure to store the boolean value from the API
struct detector: Codable {
    let status:Bool
}
// The Request location view
struct RequestLocationView: View {
    var body: some View {
        ZStack{
            Color(.systemCyan).ignoresSafeArea()
            
            VStack{
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 40)
                
                Button{
                    LocationManager.shared.requestLocation()
                }label: {
                    Text("Allow Location")
                        .padding()
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.horizontal, -32)
                .background(Color.white)
                
            }
        }
        
    }
}
//Main view - Contains logic for sign in view and the functionality for the home screen
struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    let url = "https://deadbolt-detector-default-rtdb.firebaseio.com/Detectors/12345.json"
    @StateObject var apiMan = APIRequestManager()
    @EnvironmentObject var viewModel: AppViewModel
    @State var status = "Locked"
    
    var body: some View {
       
        NavigationView{
            // If the user is signed in
            if viewModel.signedIn {
                // If the user has not allowed location services
                if(locationManager.userLocation==nil){
                    // Show the view asking for location permissions
                    RequestLocationView()
                } else {
                    //The home screen
                
                VStack{
                    Section() {
                        // Lock image
                        Image(systemName: apiMan.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150,height: 150)
                            .padding(.bottom, 40)
                        // Update button
                        Text("Update")
                            .font(.system(size:24))
                        Button(action: {
                            apiMan.result="Checking your lock..."
                            apiMan.getData()
                            // Debug statement to print the user's location
                            // print(LocationManager.shared.userLocation)
                     
                        }, label: {
                            Text("Update").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white).padding()
                        })
                    
                    }
                    // Sign Out button
                    Button(action: {
                        viewModel.signOut()
                    }, label: {
                        Text("Sign Out").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white).padding()
                    })
                }
                }
                // If not signed in
            } else {
                // Show the Sign In view
                SignInView()
            }
        }.onAppear{
            //checks the signed in status
            viewModel.signedIn=viewModel.isSignedIn
        }
    }
}
// Reset password view
struct ResetPasswordView: View {
    
    @State var email=""
    @State var password=""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
        VStack{
            // Logo
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
                .padding(.bottom,40)
                .padding(.top,40)
            VStack {
                // Email text box
                TextField("Email Address", text:$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                Text("").padding()
                // Submit password reset request
                Button(action: {
                    guard !email.isEmpty else{
                        // TODO: update the text to say please enter an email
                        return
                    }
                    // TODO: Update the text field to say request sent
                    viewModel.resetPassword(email: email)
                }, label: {
                    Text("Reset Password").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
                })
                
            }.padding()
            
            Spacer()
            
        }.navigationTitle("Reset Password")
        
    }
}

// Sign In View
struct SignInView: View {
    
    @State var email=""
    @State var password=""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
        VStack{
            // Logo image
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
                .padding(.bottom,40)
                .padding(.top,40)
            VStack {
                // Email text field
                TextField("Email Address", text:$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                // Password text field
                SecureField("Password", text:$password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                // Submit Button
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    // TODO: update a text field for error messages
                   viewModel.signIn(email: email, password: password)
                  //  print(result)
                }, label: {
                    Text("Sign In").frame(width: 200, height: 50).background(Color.blue).cornerRadius(8).foregroundColor(Color.white)
                })
                // Link to create account page
                NavigationLink("Create Account", destination: SignUpView()).padding()
                // Link to reset password page
                NavigationLink("Reset Password", destination: ResetPasswordView()).padding()
                
            }.padding()
            
            Spacer()
            
        }.navigationTitle("Sign In")
        
    }
}

// Sign Up View
struct SignUpView: View {
    
    @State var email=""
    @State var password=""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
        VStack{
            // Logo image
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
                .padding(.bottom,40)
                .padding(.top,40)
            VStack {
                // Email text field
                TextField("Email Address", text:$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                // Password text field
                SecureField("Password", text:$password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                // submit button
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    // TODO: error handling
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
