//
//  WelcomeView.swift
//
//
//  Created by Jayden Irwin on 2020-04-29.
//

import SwiftUI

public struct WelcomeView: View {
    
    public static let continueNotification = Notification.Name("WelcomeKit.continue")
    
    #if targetEnvironment(macCatalyst)
    let isCatalyst = true
    #else
    let isCatalyst = false
    #endif
    public let isFirstLaunch: Bool
    public let appName: String
    public let features: [WelcomeFeature]
    
    @Environment(\.dismiss) var dismiss
    
    #if os(visionOS)
    @State var generalAnimationCompleted = false
    @State var featureVisibilities: [WelcomeFeature: Bool] = [:]
    @State var continueButtonVisible = false
    #else
    @State var animationCompleted = false
    #endif
    
    public var body: some View {
        #if os(visionOS)
        // visionOS uses a non-GeometryReader approach, since it cannot measure the size of a sheet
        ZStack {
            VStack(spacing: 28) {
                Text(isFirstLaunch ? "Welcome to \(appName)" : "What's New in \(appName)")
                    .font(Font.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: generalAnimationCompleted ? 28 : 150) {
                    ForEach(features) { feature in
                        ZStack {
                            // Transparent view to take up space
                            WelcomeFeatureView(feature: feature)
                                .opacity(0)
                            
                            if featureVisibilities[feature] == true {
                                WelcomeFeatureView(feature: feature)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                }
                .frame(idealWidth: 400, maxWidth: 400)
                
                Spacer()
                
                Button {
                    dismiss()
                    NotificationCenter.default.post(name: WelcomeView.continueNotification, object: nil)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(idealWidth: 340, maxWidth: 340)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .padding(.vertical, 64)
            .padding(.horizontal, 32)
            .offset(x: 0, y: generalAnimationCompleted ? 0 : 75)
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 0.6)) {
                generalAnimationCompleted = true
            }
            for (index, feature) in features.enumerated() {
                withAnimation(Animation.easeOut(duration: 0.6).delay(0.1 * Double(index))) {
                    featureVisibilities[feature] = true
                }
            }
            withAnimation(Animation.easeOut(duration: 0.6).delay(0.5)) {
                continueButtonVisible = true
            }
        }
        #else
        GeometryReader { geometry in
            VStack(spacing: 28) {
                Text(isFirstLaunch ? "Welcome to \(appName)" : "What's New in \(appName)")
                    .font(Font.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                
                #if targetEnvironment(macCatalyst)
                Divider()
                #endif
                
                Spacer()
                
                VStack(alignment: .leading, spacing: animationCompleted ? 28 : 150) {
                    ForEach(features) { feature in
                        WelcomeFeatureView(feature: feature)
                    }
                }
                .frame(idealWidth: isCatalyst ? 500 : 400, maxWidth: isCatalyst ? 500 : 400)
                
                Spacer()
                
                Button {
                    dismiss()
                    NotificationCenter.default.post(name: WelcomeView.continueNotification, object: nil)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(idealWidth: 340, maxWidth: 340)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.vertical, 64)
            .padding(.horizontal, 32)
            .frame(width: geometry.size.width, height: animationCompleted ? nil : geometry.size.height * 2)
            .opacity(animationCompleted ? 1 : 0)
            .offset(x: 0, y: animationCompleted ? 0 : 75)
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 0.6)) {
                animationCompleted = true
            }
        }
        #endif
    }
    
    public init(isFirstLaunch: Bool, appName: String, features: [WelcomeFeature]) {
        self.isFirstLaunch = isFirstLaunch
        self.appName = appName.replacingOccurrences(of: " ", with: "\u{00a0}") // Use non-breaking spaces
        self.features = features
        #if os(visionOS)
        self.featureVisibilities = Dictionary(uniqueKeysWithValues: features.map({ ($0, false) }))
        #endif
    }
}

#Preview {
    let features = [
        WelcomeFeature(image: Image(systemName: "app.fill"), title: "Feature", body: "This feature is good."),
        WelcomeFeature(image: Image(systemName: "app.fill"), title: "Feature", body: "This feature is good."),
        WelcomeFeature(image: Image(systemName: "app.fill"), title: "Feature", body: "This feature is good.")
    ]
    return WelcomeView(isFirstLaunch: false, appName: "My App", features: features)
}
