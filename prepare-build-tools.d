#!/usr/bin/env rdmd
/**
 * Simple script that just compiles this project's build system to an executable.
 * Run this before building: `./prepare-build-tools.d`
 */
module prepare_build_tools;

import std.process;
import std.array;
import std.file;
import std.algorithm;

int main() {
    auto sourceApp = appender!(string[]);
    foreach (DirEntry entry; dirEntries("build-tools", SpanMode.shallow, false)) {
        if (entry.isFile && endsWith(entry.name, ".d")) {
            sourceApp ~= entry.name;
        }
    }
    string[] sources = sourceApp[];
    string sourcesStr = join(sources, " ");
    Pid pid = spawnShell("dmd -O " ~ sourcesStr ~ " -release -of=build");
    scope (exit) {
        if (exists("build.o")) {
            std.file.remove("build.o");
        }
    }
    return wait(pid);
}
