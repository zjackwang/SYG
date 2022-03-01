//
//  ProgressDialog.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct ProgressDialog: View {
    @Binding var show: Bool
    @Binding var message: String
    
    var body: some View {
        ZStack {
            if show {
                Rectangle().foregroundColor(Color.black.opacity(0.6))
                
                HStack(spacing: 10) {
                    if #available(iOS 14.0, *) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ActivityIndicator(isAnimating: true)
                    }
                    Text(message)
                }
                .padding()
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
  public typealias UIView = UIActivityIndicatorView
  public var isAnimating: Bool = true
  public var configuration = { (indicator: UIView) in }

  public init(isAnimating: Bool, configuration: ((UIView) -> Void)? = nil) {
    self.isAnimating = isAnimating
    if let configuration = configuration {
       self.configuration = configuration
    }
  }

  public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
    UIView()
  }

  public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    configuration(uiView)
  }
}
