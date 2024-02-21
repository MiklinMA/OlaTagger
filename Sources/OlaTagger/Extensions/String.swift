//
//  File.swift
//  
//
//  Created by Mike Miklin on 21.02.2024.
//

import Foundation


extension String {
    var chars: [UInt8] {
        self.utf8.map { UInt8($0) }
    }
}
