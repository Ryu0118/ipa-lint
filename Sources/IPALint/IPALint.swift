import IPALintCLI

@main
enum IPALint {
    static func main() async {
        await IPALintCommand.main()
    }
}
