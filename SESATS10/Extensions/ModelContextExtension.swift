//
//  ModelContextExtension.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import Foundation
import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
    
    /*
    then print(modelContext.sqliteCommand)
     Once you have the command, copy all of it – from sqlite3 all the way through to the ending quote mark, and run it from your Mac's Terminal app. You should see the version number of your SQLite program, followed by sqlite>, which is the prompt where you can enter commands.

     If you're new to SQLite, here are some basics:

     Type .sch and press return to show your database schema, which will list the SQL commands to create all the tables (data stores) and indexes (fast lookups) for your SwiftData work.
     Type .tab and press return to just show the names of tables.
     Type SELECT * FROM xxx; and press return to show all the objects inside the table "xxx". Core Data (and therefore Swift Data) use table names that are the letter "Z" followed by your model name. So, to show all User model objects, you'd use SELECT * FROM ZUSER;
     Press Ctrl+D to exit SQLite when you're done.
     */
}
