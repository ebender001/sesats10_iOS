//
//  DatabaseHelper.swift
//  SESATS10
//
//  Created by Edward Bender on 1/2/26.
//

import SwiftData

func deleteAll<T: PersistentModel>(
    of type: T.Type,
    in context: ModelContext
) throws {
    let descriptor = FetchDescriptor<T>()
    try context.delete(model: T.self, where: descriptor.predicate)
}
