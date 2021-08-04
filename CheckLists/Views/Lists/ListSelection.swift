//
//  ListSelection.swift
//  CheckLists
//
//  Created by Shivoy Arora on 14/06/21.
//

import SwiftUI

struct ListSelection: View {
	@EnvironmentObject var modelData: ModelData
	@State private var addSheet: Bool = false
    @State private var editSheet: Bool = false
    @State private var draftList: CheckList = CheckList.default
	
	var body: some View {
        
        let filteredList = modelData.checkLists.filter{ $0.isPinned } + modelData.checkLists.filter{ !$0.isPinned }
        
        NavigationView {
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 0){
                    
                    ///Showing all the available list after filtering
                    ForEach(filteredList){ checkList in
                        NavigationLink(
                            destination: ItemList(checkList: checkList).environmentObject(modelData),
                            tag: checkList.id,
                            selection: $modelData.listSelector
                        ){
                            ListRow(checkList: checkList)
                                .addButtonActions(leadingButtons: [.pin], trailingButtons: [.info, .delete], onClick: { button in
                                    sendSwipeButtonClick(Button: button, checkList: checkList)
                                })
                                .sheet(isPresented: $editSheet) {
                                    ListInfo(showInfo: $editSheet, draftList: $draftList)
                                        .environmentObject(modelData)
                                }
                        }
                    }
                    
                    ///adding list button
                    Button{
                        addSheet.toggle()
                        draftList = CheckList.default
                        
                    }label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .leading)
                            .foregroundColor(.accentColor)
                            .padding(.leading)
                    }
                    .sheet(isPresented: $addSheet, content: {
                        ListInfo(showInfo: $addSheet, draftList: $draftList)
                            .environmentObject(modelData)
                    })
                }
            }
            .navigationTitle("Lists")
        }
    }
    
    
    func sendSwipeButtonClick(Button: SwipeButton, checkList: CheckList) -> Void {
        
        let indexList: Int = modelData.checkLists.firstIndex(where: { $0.id == checkList.id })!
        
        switch Button {
        case .pin:
            modelData.checkLists[indexList].isPinned.toggle()
        case .delete:
            
            /// To remove notification of all the items in the list
            for item in checkList.items {
                AppNotification().remove(ID: item.id)
            }
            
            modelData.checkLists.remove(at: indexList)
        case .info:
            editSheet.toggle()
            draftList = checkList
        }
    }
}



struct ListSelection_Previews: PreviewProvider {
	static var previews: some View {
        ListSelection()
			.preferredColorScheme(.dark)
			.environmentObject(ModelData())
    }
}
