module util;

/** 
 * Runs the given shell command.
 * Params:
 *   shellCommand = The command to run.
 * Returns: The exit code of the command.
 */
int run(string shellCommand) {
    import std.process : Pid, spawnShell, wait;
    Pid pid = spawnShell(shellCommand);
    return wait(pid);
}

/** 
 * Runs the given command, and exits if an unsatisfactory exit code is returned.
 * Params:
 *   shellCommand = The command to run.
 *   successExitCodes = The list of exit codes which are considered success.
 */
void runOrQuit(string shellCommand, int[] successExitCodes = [0]) {
    import core.stdc.stdlib : exit;
    import std.algorithm : canFind;
    int result = run(shellCommand);
    if (!canFind(successExitCodes, result)) exit(result);
}

/** 
 * Exits the program if the given number is non-zero.
 * Params:
 *   n = The number to check.
 */
void quitIfNonZero(int n) {
    import core.stdc.stdlib : exit;
    if (n != 0) exit(n);
}

/** 
 * Finds a list of files in a directory which match a given suffix.
 * Params:
 *   path = The path to look in.
 *   suffix = The suffix to match.
 * Returns: The list of paths to files that match.
 */
string[] findFiles(string path, string suffix = null) {
    import std.array;
    import std.algorithm;
    import std.file;
    auto app = appender!(string[]);
    foreach (DirEntry entry; dirEntries(path, SpanMode.breadth, false)) {
        if (entry.isFile && (suffix is null || entry.name.endsWith(suffix))) {
            app ~= entry.name;
        }
    }
    return app[];
}