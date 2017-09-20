let carting = Carting()

do {
    try carting.runTest()
}
catch {
    print("❌ \(error.localizedDescription)")
}

