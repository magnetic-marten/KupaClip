import SwiftUI


struct Popup: View {
    var dismiss: () -> ()
    @State var state = PopupState()
    
    var body: some View {
            ZStack {
                VStack {
                    PopupHeader(query: $state.query, activeMode: $state.activeMode)
            
                    if (state.isClipboard()) {
                        list(viewModel: state.clipboard)
                        .transition(.asymmetric (
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                    }
                    
                    if (state.isSnippets()) {
                        list(viewModel: state.snippets)
                        .transition(.asymmetric (
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                    
                    if (state.isTools()) {
                        list(viewModel: state.tools)
                        .transition(.asymmetric (
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                    }
                    Spacer()
                }
                .frame(width: 350, height: 245)
                .background(.thinMaterial)
                .cornerRadius(10)
                .onAppear {
                   addKeyEventListener()
               }
            }
    }
    
    private func list(viewModel: PopupListViewModel) -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView([.vertical]) {
                ForEach(viewModel.filteredItems, id:\.id) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        if let index = item.shortcut {
                            Text("⌘\(index)")
                                .opacity(0.6)
                                .monospaced()
                        }
                    }
                    .id(item.id)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 1)
                    .foregroundStyle(viewModel.isSelected(item: item) ? Color.white : .primary)
                    .background(viewModel.isSelected(item: item) ? Color.accentColor.opacity(0.8) : .clear)
                    .contentShape(Rectangle())
                    .clipShape(.rect(cornerRadius: 2))
                    .onTapGesture {
                        viewModel.selectedItem = item
                        withAnimation {
                            scrollProxy.scrollTo(item.id)
                        }
                    }
                }
            }.padding(.bottom, 3)
            .transition(.asymmetric (
                insertion: .move(edge: .leading),
                removal: .move(edge: .leading)
            ))
            .onChange(of: viewModel.selectedItem) {
                if let selectedItem = viewModel.selectedItem {
                    withAnimation {
                        scrollProxy.scrollTo(selectedItem.id)
                    }
                }
            }
        }
    }
    
    private func addKeyEventListener() {
       NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
           handleKeyEvent(event)
           return event
       }
   }
   
   private func handleKeyEvent(_ event: NSEvent) {
       switch event.keyCode {
       case 126:
           state.selectPrevious()
       case 125:
           state.selectNext()
       case 53:
           if (state.query.isEmpty) {
               dismiss()
           } else {
               state.query = ""
           }
       default:
           break
       }
   }
}

#Preview() {
    AppContext.set(ClipboardStorage(maxLimit: 5, data: DummyData.clipboard))
    AppContext.set(SnippetStorage(data: DummyData.snippets))
    AppContext.set(ToolStorage(data: DummyData.tools))
    return Popup() {
        print("Close")
    }
}
