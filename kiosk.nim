import
    os,
    buttons,
    cardreader,
    json,
    strutils


type
    TAccount = object
        name: string
        balance: int
        cards: seq[NFCID]
    Account = ref TAccount

    Product = ref TProduct
    TProduct = object
        name: string
        price: int

var accounts: seq[Account]
var products: seq[Product]

var stdinChan: TChannel[string]
var stdinThread: TThread[void]

proc stdinReader() {.thread.} =
    while true:
        var lin = stdin.readLine
        stdinChan.send lin

proc stdinReaderInit() =
    stdinChan.open
    createThread[void](stdinThread, stdinReader)

var timerChan: TChannel[tuple[repeat: bool, period: int]]
var timerThread: TThread[void]

proc renderMenu(message: seq[string], choices: seq[string], info: seq[string]) =
    const
        frameWidth = 90
        frameHeight = 25 
        marginTop = 10 
    var y, x = 0
    var x0  = frameWidth div (5*2)
    var dx = frameWidth div (5)
    for i in (1..marginTop):
        echo ""
        y += 1
    for s in message:
        var x = (frameWidth div 2) - (s.len div 2)
        echo repeatChar(x, ' '), s
        y += 1
    for i in (y..frameHeight-1):
        echo ""
    x = x0
    var optStr = repeatChar(frameWidth, ' ')
    for s in choices:
       var i = 0
       let l2 = s.len div 2
       for c in s:
           optStr[x-l2+i] = c
           i+=1
       x += dx
    echo optStr
    x = x0
    var infoStr = repeatChar(frameWidth, ' ')
    for s in info:
       var i = 0
       let l2 = s.len div 2
       for c in s:
           infoStr[x-l2+i] = c
           i+=1
       x += dx
    echo infoStr    

#renderMenu(@["Hello", "World"], 
#           @["One", "Twoooo", "Frukt", "Sjokkis", "Avbryt"],
#           @["1kr", "2kr"])
#quit()

proc newAccount(name: string): Account =
    new(result)
    result.name = name
    result.cards = newSeq[NFCID](0)
    accounts.add(result)

proc newAccountFromJSON(node: PJsonNode): Account =
    new(result)
    result.name = node["name"].str
    result.balance = cast[int](node["balance"].num)
    result.cards = newSeq[NFCID](0)
    for cid in node["cards"].elems:
        var cid_i = ParseHexInt(cid.str)
        result.cards.add(cast[NFCID](cid_i))

proc toJSON(a: Account): PJsonNode =
    result = newJObject()
    result["name"] = newJString(a.name)
    result["balance"] = newJInt(a.balance)
    var cards = newJArray()
    for cid in a.cards:
        cards.add newJString($cid)
    result["cards"] = cards



proc printAccounts() =
    echo "-- Accounts --"
    for a in accounts:
        echo a.name
        echo "  Balance: ", a.balance
        echo "  Cards:"
        for c in a.cards:
            echo "    ", c

proc findAccountForCard(cardID: NFCID): Account =
    for a in accounts:
        for c in a.cards:
            if c==cardID:
                return a
    return nil

proc newProductFromJSON(node: PJsonNode): Product =
    new(result)
    result.name = node["name"].str
    result.price = cast[int](node["price"].num)

proc toJSON(p: Product): PJsonNode =
    result = newJObject()
    result["name"] = newJString(p.name)
    result["price"] = newJInt(p.price)

proc printProducts() =
    echo "-- Products --"
    for p in products:
        echo p.name
        echo "  Price: ", p.price  

proc readDB() =
    var f: TFile
    if f.open("db.json"):
        finally: f.close
        var json = parseJson(f.readAll())
        accounts = newSeq[Account](0)
        for a in json["accounts"].elems:
            accounts.add(newAccountFromJSON(a))
        products = newSeq[Product](0)
        for p in json["products"].elems:
            products.add(newProductFromJSON(p))

proc writeDB() =

    var db = newJObject()

    var prods = newJArray()
    for p in products:
        prods.elems.add p.toJSON()

    var accnts = newJArray()
    for a in accounts:
        accnts.elems.add(a.toJSON())

    db["products"] = prods
    db["accounts"] = accnts

    var f: TFile
    if f.open("db.json", fmWrite):
        finally: f.close
        f.write(db.pretty)   

proc processNewCard(cardID: NFCID) = 
    var accnt: Account
    echo "No account attached to card"
    echo "Please type name for card:"
    while stdinChan.peek > 0:
        discard stdinChan.recv
    var name = stdinChan.recv
    for a in accounts:
        if a.name == name:
            accnt = a
            break
    if isNil(accnt):
        echo "Create new account? " & name
    else:
        echo "Attach do existing account? " & accnt.name
        echo "Balance: " & $accnt.balance
    stdout.write("[Y/N]: ")
    stdout.flushFile
    var answ = toLower(stdinChan.recv)
    if answ!="y": return
    if isNil(accnt):
        accnt = newAccount(name)
    accnt.cards.add cardID
    printAccounts()


proc addToBalance(accnt: Account) =
    while stdinChan.peek > 0:
        discard stdinChan.recv
    echo "Amount:"
    stdout.write("Kr ")
    stdout.flushFile
    var answ: int
    try:
        answ = parseInt(stdinChan.recv)
    except EInvalidValue:
        echo "No amount"
        return
    accnt.balance += answ
    echo "Your balance is now: ", accnt.balance


proc purchaseProduct(a: Account, p: Product) =
    a.balance -= p.price
    echo "Your balance is now: ", $a.balance


proc selectProduct(accnt: Account) =
    var result: Product
    var i = 0
    
    var msgs = @["Hello "&accnt.name, "Your balance is: " & $accnt.balance]
    var opts = @["","","","","[Deposit]"]
    var info = @["","","","",""]
    for p in products:
       opts[i] = p.name
       info[i] = $p.price & "kr"
       i+=1
    renderMenu(msgs,opts,info)

    #var answ: int
    #try:
    #    answ = parseInt($(stdin.readLine))
    #except EInvalidValue:
    #    echo "No selection"
    #    return
    while buttonsChan.peek > 0:
        discard buttonsChan.recv()
    var evt = buttonsChan.recv()
    var answ = evt.button + 1

    for i in 0..90:
        echo ""
     
    if answ == 5:
        addToBalance(accnt)
        return
    if answ < 1 or answ > products.len:
        echo "Invalid selection"
        return
    result = products[answ-1]
    echo "You selected: ", result.name
    purchaseProduct(accnt, result)


readDB()
#printAccounts()
#printProducts()

initButtons()
startCardReader()
stdinReaderInit()

while true:
    var crMsg = crTX.recv

    case crMsg.kind
    of crCardConnected:
        #echo "Card connected: ", crMsg.cardID

        var accnt = findAccountForCard(crMsg.cardID)
        if isNil(accnt):
            # crRX.send(crBlinkUnknown)
            processNewCard(crMsg.cardID)
        else:
            # crRX.send(crBlinkOK)
            #echo "Hello ", accnt.name, "!"
            #echo "Your balance is: ", accnt.balance, "\n\n"
            selectProduct(accnt)
            echo "\n\n"
                
        writeDB()

    of crCardDisconnected:
        # echo "Card disconnected"
        # echo crMsg.cardID
    else:
        raise newException(E_Base, "Illegal message")
