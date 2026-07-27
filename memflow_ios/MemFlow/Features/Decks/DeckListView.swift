import SwiftUI
import SwiftData

/// 卡组列表页面
///
/// "卡组" Tab 主页，展示所有卡组，支持创建、搜索、归档和导出操作。
struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = DeckViewModel()
    @State private var showCreateAlert = false
    @State private var newDeckName = ""
    @State private var newDeckDesc = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.decks.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "还没有卡组",
                        systemImage: "folder",
                        description: Text("点击右上角按钮创建第一个卡组，\n或导入已有的卡组文件")
                    )
                } else {
                    List {
                        Section("活跃卡组") {
                            ForEach(viewModel.decks.filter { !$0.isArchived }, id: \.persistentModelID) { deck in
                                NavigationLink(value: deck) {
                                    deckRow(deck)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteDeck(deck, modelContext: modelContext)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }

                        let archivedDecks = viewModel.decks.filter(\.isArchived)
                        if !archivedDecks.isEmpty {
                            Section("已归档") {
                                ForEach(archivedDecks, id: \.persistentModelID) { deck in
                                    NavigationLink(value: deck) {
                                        deckRow(deck)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("卡组")
            .navigationDestination(for: Deck.self) { deck in
                DeckDetailView(deck: deck)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("新建卡组", isPresented: $showCreateAlert) {
                TextField("名称", text: $newDeckName)
                TextField("描述（可选）", text: $newDeckDesc)
                Button("取消", role: .cancel) {}
                Button("创建") {
                    viewModel.createDeck(name: newDeckName, description: newDeckDesc, modelContext: modelContext)
                    newDeckName = ""
                    newDeckDesc = ""
                }
                .disabled(newDeckName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .task {
                viewModel.loadDecks(modelContext: modelContext)
            }
            .refreshable {
                viewModel.loadDecks(modelContext: modelContext)
            }
        }
    }

    private func deckRow(_ deck: Deck) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(rgb: deck.color))
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if !deck.deckDescription.isEmpty {
                    Text(deck.deckDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("\(deck.cardCount) 张卡片")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .contextMenu {
            Button {
                viewModel.toggleArchive(deck, modelContext: modelContext)
            } label: {
                Label(deck.isArchived ? "取消归档" : "归档", systemImage: "archivebox")
            }
        }
    }
}

// MARK: - 卡组详情页

struct DeckDetailView: View {
    let deck: Deck
    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet = false
    @State private var showAIGenerate = false

    var body: some View {
        List {
            ForEach(deck.cards, id: \.persistentModelID) { card in
                cardRow(card)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(deck.cards[index])
                }
                try? modelContext.save()
            }
        }
        .overlay {
            if deck.cards.isEmpty {
                ContentUnavailableView(
                    "还没有卡片",
                    systemImage: "rectangle.stack",
                    description: Text("点击 + 按钮添加第一张卡片")
                )
            }
        }
        .navigationTitle(deck.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("添加卡片", isPresented: $showAddSheet) {
            NavigationLink("手动添加") {
                CardEditView(deck: deck)
            }
            Button("AI 生成") {
                showAIGenerate = true
            }
        }
        .navigationDestination(isPresented: $showAIGenerate) {
            AIGenerateView(deck: deck)
        }
    }

    private func cardRow(_ card: Card) -> some View {
        NavigationLink {
            CardEditView(deck: deck, existingCard: card)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(card.question)
                    .font(.subheadline)
                    .lineLimit(2)
                if !card.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(card.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 卡片编辑页

struct CardEditView: View {
    let deck: Deck
    var existingCard: Card? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var question = ""
    @State private var answer = ""
    @State private var cardType = "basic"
    @State private var tagText = ""
    @State private var tags: [String] = []

    private let cardTypes = [
        ("basic", "基本"),
        ("cloz", "填空"),
        ("comparison", "对比"),
        ("code", "代码"),
    ]

    var body: some View {
        Form {
            Section("卡片类型") {
                Picker("类型", selection: $cardType) {
                    ForEach(cardTypes, id: \.0) { type in
                        Text(type.1).tag(type.0)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("问题") {
                TextEditor(text: $question)
                    .frame(minHeight: 100)
                    .overlay(alignment: .topLeading) {
                        if question.isEmpty {
                            Text("请输入问题（支持 Markdown）")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }

            Section("答案") {
                TextEditor(text: $answer)
                    .frame(minHeight: 140)
                    .overlay(alignment: .topLeading) {
                        if answer.isEmpty {
                            Text("请输入答案（支持 Markdown 和代码块）")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }

            Section("标签") {
                HStack {
                    TextField("添加标签", text: $tagText)
                        .onSubmit {
                            let trimmed = tagText.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty && !tags.contains(trimmed) {
                                tags.append(trimmed)
                            }
                            tagText = ""
                        }
                }

                if !tags.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 2) {
                                    Text(tag)
                                    Button {
                                        tags.removeAll { $0 == tag }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(existingCard != nil ? "编辑卡片" : "新建卡片")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("保存") {
                    saveCard()
                }
                .disabled(question.isEmpty || answer.isEmpty)
            }
        }
        .onAppear {
            if let card = existingCard {
                question = card.question
                answer = card.answer
                cardType = card.cardType
                tags = card.tags
            }
        }
    }

    private func saveCard() {
        if let card = existingCard {
            card.question = question
            card.answer = answer
            card.cardType = cardType
            card.tags = tags
            card.updatedAt = Date()
        } else {
            let card = Card(
                question: question,
                answer: answer,
                cardType: cardType,
                tags: tags
            )
            card.deck = deck
            modelContext.insert(card)
        }

        try? modelContext.save()
        dismiss()
    }
}
