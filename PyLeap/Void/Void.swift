//
//Void.swift
//PyLeap
//
//Created by Trevor Beaton on 8/12/21.
//
//
//

//
//MARK:- List Of Directories
//List {
//    Section(header: Text("On Device")) {
//        ForEach(fvmodel.fileArray) {
//            file in
//            ContentFileRow(title: file.title)
//
//        }
//    }
//
//}
//
//FileChooserView(directory: $filename, fileTransferClient: fvmodel.fileTransferClient)


//NavigationLink(destination: ProjectCardView(fileTransferClient: AppState.shared.fileTransferClient),tag: .fileTransfer, selection: $model.destination) { EmptyView() }




// Project card view


// MARK:- Download Progress UI *Do not delete
//                //  value 0  beginning
//                if value == 0 {
//                    Section(header:Text("Files required")
//                                .foregroundColor(.red)
//                    ){
//
//                        Button(action: {
//                            value = 1
//                        }, label: {
//                            VStack(alignment: .leading) {
//                                Text("neopixel.py")
//                                    .foregroundColor(.black)
//                                Text("Download In Rainbows Project Bundle")
//                                    .padding(.top, 8)
//                            }
//                        })
//                    }
//                }
//
//                //Value 1
//
//                if value == 1 {
//                    ProgressView("Downloading…", value: downloadAmount, total: 100)
//                        .onReceive(timer) { _ in
//                            if downloadAmount < 100 {
//                                downloadAmount += 5
//                            }
//                            if downloadAmount == 100 {
//                                enabled = false
//                                value = 2
//
//                            }
//
//                        }
//                }
//
//                if value == 2 {
//                    Section(header:Text("")){
//
//                        Text("Download Complete")
//
//                    }
//                }


//MARK:- List Of Directories
//            List {
//                Section(header: Text("On Device")) {
//                    ForEach(model.fileArray) { file in
//                        //    ContentFileRow(title: file.title)
//                        Text(file.title)
//                    }
//                }
//
//            }
