//
//  ContentView.swift
//  SwiftUIGoogleSignInSample
//
//  Created by shinichi teshirogi on 2021/07/15.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: userData.avatorImage)
                VStack {
                    Text("\(userData.userName)").padding()
                    Text("\(userData.email)").padding()
                }
            }
            HStack {
                Button("Sign out", action: {
                    GIDSignIn.sharedInstance.signOut()
                    print("Sign out")
                    userData.signIn(user: GIDSignIn.sharedInstance.currentUser)
                }).disabled(!userData.isSignedIn).padding()
                Spacer()
                Button("Disconnect", action: {
                    GIDSignIn.sharedInstance.disconnect(callback: {error in
                        if let error = error {
                            print("disconnect error: \(error.localizedDescription)")
                        }
                        else {
                            print("disconnected")
                            userData.signIn(user: GIDSignIn.sharedInstance.currentUser)
                        }
                    })
                }).disabled(!userData.isSignedIn).padding()
            }.padding()
            GoogleSignInBtn(userData).padding().disabled(userData.isSignedIn)
            Spacer()
        }
    }
}

struct GoogleSignInBtn: UIViewRepresentable {
    var userData: UserData
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    typealias UIViewType = GIDSignInButton
    
    init(_ userData: UserData) {
        self.userData = userData
    }

    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        
        switch colorScheme {
        case .light:
            button.colorScheme = .light
        case .dark:
            button.colorScheme = .dark
        default:
            button.colorScheme = .light
        }
        
        button.addAction(.init(handler: { _ in
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
            
            GIDSignIn.sharedInstance.signIn(
                with: self.userData.signInConfig,
                presenting: presentingViewController,
                callback: { user, error in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                    }
                    else if let user = user {
                        self.userData.signIn(user: user)
                    }
                })
        }), for: .touchUpInside)
        button.isEnabled = false
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static let userData = UserData()
    static var previews: some View {
        ContentView().environmentObject(userData)
    }
}
