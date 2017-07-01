import CartingCore

let carting = Carting()

do {
    try carting.run()
}
catch {
    print(error)
}
