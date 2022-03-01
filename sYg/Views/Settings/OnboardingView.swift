//
//  OnboardingView.swift
//  sYg
//
//  Created by Jack Wang on 12/23/21.
//

import SwiftUI

struct OnboardingView: View {

    // Onboarding states
    @State var onboardingState: OnboardingStates = .welcome
    let transition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading))
    
    // Onboarding inputs
    @State var name: String = ""
    
    // Unused
    @State var age: Double = 50.0
    @State var gender: String = ""
    
    // For the alert
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    // UI
    private var buttonColor: Color = .brown
    private var mangoBackground: [Color] = [.green, .pink]
    
    // App storage
    @AppStorage("name") var currentUserName: String?
    @AppStorage("signed_in") var currentUserSignedIn: Bool = false
    
    // View models
    @StateObject var pvm = ProduceViewModel.shared
    
    var body: some View {
        ZStack {
            // content
            ZStack {
                switch onboardingState {
                case .welcome:
                    welcomeSection
                        .transition(transition)
                case .addName:
                    addNameSection
                        .transition(transition)
                case .signedIn:
                    MainUserView()
                        // Our core data managed object context into env.
                        .environment(\.managedObjectContext, ScannedItemViewModel.shared.container.viewContext)
                        // Log
                        .onAppear {
                            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                            
                            // TODO: make async
                            //  show spinning loading when fetching
                            // fetch items
                            let _ = pvm.getAllItemsInfo()
                            
                            // request access for notifications if not given already
                            EatByReminderManager.instance.requestAuthorization()
                            
                            // MARK: DEV TESTING
                            ScannedItemViewModel.shared.resetContainer()
                            EatByReminderManager.instance.cancelAllNotifications()
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }
                        .transition(transition)
                }
            }
            //buttons
            VStack {
                Spacer()
                bottomButton
            }
            .padding(30)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            
        }
        .background(
            LinearGradient(colors: mangoBackground, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
    
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            
    }
}

// MARK: COMPONENTS

extension OnboardingView {
    
    private var bottomButton: some View {
        
        Button {
            handleButtonPressed()
        } label: {
            Text(onboardingState == .welcome ? "Get Started" :
                onboardingState == .addName ? "FINISH" : "NEXT")
                .font(.headline)
                .foregroundColor(buttonColor)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(10)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 40){
            Spacer()
            Image(systemName: "cart.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.white)
            Text("EatThat!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .overlay(
                    Capsule(style: .continuous)
                        .frame(height: 3)
                        .offset(y: 5)
                        .foregroundColor(.white)
                    , alignment: .bottom
                )
            Text("Save your groceries by scanning your grocery receipt and get reminded on when to eat your purchased items!\nSwipe to delete from your list once eaten.")
                .fontWeight(.medium)
                .foregroundColor(.white)
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(30)
    }
    
    private var addNameSection: some View {
        VStack(spacing: 20){
            Spacer()
            
            Text("What's your name?")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                    
            TextField("Your name here...", text: $name)
                .font(.headline)
                .frame(height: 55)
                .padding(.horizontal)
                .background(.white)
                .foregroundColor(buttonColor)
                .cornerRadius(20)
            Spacer()
            Spacer()
        }
        .padding(30)
    }
}

// MARK: ENUMS

extension OnboardingView {
    enum OnboardingStates {
        case welcome
        case addName
        case signedIn
    }
}


// MARK: FUNCTION

extension OnboardingView {
    func handleButtonPressed() {
        withAnimation(.spring()) {
            switch onboardingState {
            case .welcome:
                onboardingState = .addName
            case .addName:
                guard name.count > 3 else {
                    showAlert(title: "Your name must be at least 3 characters long.")
                    return
                }
                onboardingState = .signedIn
            case .signedIn:
                signIn()
            }
        }
    }
    
    func signIn() {
        currentUserName = name
        withAnimation(.spring()) {
            currentUserSignedIn = true
        }
    }
    
    func showAlert(title: String) {
        alertTitle = title
        showAlert.toggle()
    }
}

