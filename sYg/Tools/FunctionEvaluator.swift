//
//  FunctionEvaluator.swift
//  sYg
//
//  Created by Jack Wang on 2/22/22.
//

import Foundation


class FunctionEvaluator {
  
    func evaluate() {
        let start = DispatchTime.now() // <<<<<<<<<< Start time
        
        // Closure goes here
        
        let end = DispatchTime.now()   // <<<<<<<<<<   end time

        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests

        print("Time to run function: \(timeInterval) seconds")
    }
    
}
