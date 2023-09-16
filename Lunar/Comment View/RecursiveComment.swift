//
//  RecursiveComment.swift
//  Lunar
//
//  Created by Mani on 16/09/2023.
//

import Foundation
import SwiftUI
import SFSafeSymbols

struct RecursiveComment: View {
  @AppStorage("commentMetadataPosition")
  var commentMetadataPosition = Settings.commentMetadataPosition
  
  @State private var isExpanded = true
  @State var showingCommentPopover = false
//  @State var commentText: String = ""
  @EnvironmentObject var commentsFetcher: CommentsFetcher
  
  let commentHierarchyColors: [Color] = [
    .clear,
    .red,
    .orange,
    .yellow,
    .green,
    .cyan,
    .blue,
    .indigo,
    .purple,
  ]
  
  let nestedComment: NestedComment
  let post: Post
  let dateTimeParser = DateTimeParser()
  
  let haptics = UIImpactFeedbackGenerator(style: .soft)
  
  var body: some View {
    if isExpanded {
      let indentLevel = min(nestedComment.indentLevel, commentHierarchyColors.count - 1)
      let color = commentHierarchyColors[indentLevel]
      HStack {
        if nestedComment.indentLevel > 1 {
          Rectangle()
            .foregroundColor(color)
            .frame(width: 2)
            .padding(.vertical, 5)
        }
        commentRow
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        isExpanded.toggle()
        haptics.impactOccurred(intensity: 0.5)
      }
      .swipeActions(edge: .trailing, allowsFullSwipe: true) {
        swipeActions
      }
      
      ForEach(nestedComment.subComments, id: \.id) { subComment in
        RecursiveComment(nestedComment: subComment, post: post)
          .id(UUID())
          .padding(.leading, 10) // Add indentation
      }
      .sheet(
        isPresented: $showingCommentPopover,
        onDismiss: {
          Task {
            print("COMMENT SHEET DISMISSED")
            showingCommentPopover = false
          }
        }
      ) {
        CommentPopoverView(
          showingCommentPopover: $showingCommentPopover,
          post: post,
          comment: nestedComment.commentViewData.comment
        ).environmentObject(commentsFetcher)
      }
    } else {
      HStack {
        Text(try! AttributedString(markdown: "\(nestedComment.commentViewData.comment.content)"))
          .italic()
          .lineLimit(1)
          .foregroundStyle(.gray)
          .font(.caption)
        Spacer()
        if countSubcomments(nestedComment.subComments) > 0 {
          Text(String(countSubcomments(nestedComment.subComments)))
            .bold()
            .font(.caption)
            .fixedSize()
            .foregroundStyle(.gray)
          Spacer().frame(width: 10)
        }
        Image(systemSymbol: .chevronForward)
          .foregroundStyle(.blue)
      }
      .contentShape(Rectangle())
      .onTapGesture {
        isExpanded.toggle()
        haptics.impactOccurred(intensity: 0.5)
      }
    }
  }
  
  var commentRow: some View {
    VStack(alignment: .leading) {
      if commentMetadataPosition == "Top" {
        commentMetadata
      }
      
//      HStack {
//        Text(nestedComment.commentViewData.creator.name.uppercased())
//          .bold()
//          .foregroundStyle(.gray)
//        Text(dateTimeParser.timeAgoString(from: nestedComment.commentViewData.comment.published))
//          .foregroundStyle(.gray)
//        Spacer()
//        
////        Label(String(nestedComment.commentViewData.counts.upvotes ?? 0), systemSymbol: .arrowUp)
////          .foregroundStyle(.green)
////        Label(String(nestedComment.commentViewData.counts.downvotes ?? 0), systemSymbol: .arrowUp)
////          .foregroundStyle(.red)
//      }
//      .font(.caption)
      Text(try! AttributedString(markdown: nestedComment.commentViewData.comment.content))
      if commentMetadataPosition == "Bottom" {
        commentMetadata
      }
    }
  }
  
    var commentMetadata: some View {
      CommentMetadataView(comment: nestedComment.commentViewData)
      .environmentObject(commentsFetcher)
    }
  
  var swipeActions: some View {
    return Group {
      Button {
        isExpanded.toggle()
        haptics.impactOccurred(intensity: 0.5)
      } label: {
        Label("collapse", systemImage: "arrow.up.to.line.circle.fill")
      }
      .tint(.blue)
      Button {
        showingCommentPopover = true
      } label: {
        Label("reply", systemImage: "arrowshape.turn.up.left.circle.fill")
      }
      .tint(.orange)
    }
  }
  
  func countSubcomments(_ nestedComments: [NestedComment]) -> Int {
    var count = 0
    
    for comment in nestedComments {
      count += 1 // Count the current comment
      count += countSubcomments(comment.subComments)
    }
    
    return count
  }
}
