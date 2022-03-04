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
    private let background: Color = Color.DarkPalette.background
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    private let tertiary: Color = Color.DarkPalette.tertiary
    private let quaternary: Color = Color.DarkPalette.quaternary
    private let surface: Color = Color.DarkPalette.surface
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let onPrimary: Color = Color.DarkPalette.onPrimary

    
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
                        .onAppear {
                            // Fetch items
                            let _ = pvm.getAllItemsInfo()
                            // Request access for notifications if not given already
                            EatByReminderManager.instance.requestAuthorization()
                        }
                        .transition(transition)
                }
            }
            //buttons
            VStack {
                Spacer()
                if onboardingState != .signedIn {
                    bottomButton
                }
            }
            .padding(30)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            
        }
        .background(
            LinearGradient(colors: [background, primary, secondary, tertiary, quaternary], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(onPrimary)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .cornerRadius(25)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 40){
            Spacer()
            HStack(spacing: 15) {
                Image("icon")
                    .frame(width: 50, height: 50)
                    .background(background)
                    .cornerRadius(15)
                    .padding([.top], 7)
                Text("EatThat!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(onPrimary)
                    .overlay(
                        Capsule(style: .continuous)
                            .frame(height: 3)
                            .offset(y: 5)
                            .foregroundColor(onPrimary)
                        , alignment: .bottom
                    )
            }
            Text("Save your groceries by scanning your grocery receipt and get reminded on when to eat your purchased items!\nSwipe to delete from your list once eaten.")
                .fontWeight(.medium)
                .foregroundColor(onPrimary)
                .padding([.leading, .trailing], 10)
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
                .foregroundColor(onPrimary)
                    
            TextField("Your name here...", text: $name)
                .font(.headline)
                .frame(height: 55)
                .padding(.horizontal)
                .background(onPrimary)
                .foregroundColor(background)
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

