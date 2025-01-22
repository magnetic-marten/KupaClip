//
//  ToolModule.swift
//  KupaClip
//
//  Created by Bohdan Danyliuk on 22/01/2025.
//

struct ToolModule: Module {
    let name = "Tool"
    let moduleDetails: ModuleDetails
    let storage: ModuleStorage
    let actionHandler: ModuleActionHandler
    
    init(_ appContext: AppContext) {
        moduleDetails = ModuleDetails(iconSystemName: "wrench.and.screwdriver", color: .blue)
        storage = ToolStorage()
        actionHandler = ClipboardActionHandler()
        appContext.set(self)
    }
}
