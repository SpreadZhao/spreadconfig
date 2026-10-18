#!/usr/bin/env python3
"""Restore the declared IDE preferences without replacing unrelated user state."""

import argparse
import json
import os
from pathlib import Path
import re
import xml.etree.ElementTree as ET


def write_file(path, data, mode=0o644):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and not path.is_symlink() and path.read_bytes() == data:
        path.chmod(mode)
        return
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    temporary.write_bytes(data)
    temporary.chmod(mode)
    temporary.replace(path)


def update_component(path, name, update):
    root = ET.parse(path).getroot() if path.exists() else ET.Element("application")
    component = root.find(f"component[@name='{name}']")
    if component is None:
        component = ET.SubElement(root, "component", name=name)
    update(component)
    ET.indent(root, space="  ")
    write_file(path, ET.tostring(root, encoding="utf-8") + b"\n")


def replace_child(component, tag, attributes):
    for child in component.findall(tag):
        component.remove(child)
    ET.SubElement(component, tag, attributes)


def migrate_gradle_java_home(home, state_directory, legacy_java_home):
    marker = state_directory / "migrations/gradle-java-home-v1"
    if marker.exists():
        return

    gradle = home / ".gradle/gradle.properties"
    # The old activation created a regular file. Leave user-managed symlinks
    # alone, and preserve unrelated bytes (including comments and line endings).
    if gradle.is_file() and not gradle.is_symlink():
        original = gradle.read_bytes()
        legacy_line = re.compile(
            rb"[ \t\f]*org\.gradle\.java\.home[ \t\f]*[:=][ \t\f]*"
            + re.escape(legacy_java_home.encode())
            + rb"[ \t\f]*(?:\r\n|\n|\r)?\Z"
        )
        migrated = b"".join(
            line for line in original.splitlines(keepends=True)
            if not legacy_line.fullmatch(line)
        )
        if migrated != original:
            write_file(gradle, migrated, mode=gradle.stat().st_mode & 0o777)

    write_file(marker, b"completed\n", mode=0o600)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", required=True, type=Path)
    args = parser.parse_args()
    settings = json.loads(args.config.read_text())
    home = Path(settings["homeDirectory"])

    for ide in settings["ides"]:
        directory = Path(ide["configDirectory"])
        # Otherwise a fresh IDE migrates to the new UI and resets our theme.
        registry = directory / "early-access-registry.txt"
        lines = registry.read_text().splitlines() if registry.exists() else []
        if len(lines) % 2:
            raise ValueError(f"Invalid early access registry: {registry}")
        values = dict(zip(lines[::2], lines[1::2]))
        values["ide.experimental.ui"] = "true"
        values["switched.from.classic.to.islands"] = "false"
        write_file(registry, "".join(f"{key}\n{value}\n" for key, value in values.items()).encode())

        def update_laf(component):
            component.set("autodetect", "false")
            replace_child(component, "laf", {
                "class-name": "com.intellij.ide.ui.laf.darcula.DarculaLaf",
                "themeId": settings["themeId"],
            })

        update_component(directory / "options/laf.xml", "LafManager", update_laf)
        update_component(
            directory / "options/colors.scheme.xml", "EditorColorsManagerImpl",
            lambda component: replace_child(component, "global_color_scheme", {"name": settings["schemeName"]}),
        )
        write_file(directory / "colors/SpreadZhao_Dark.icls", Path(settings["themeSource"]).read_bytes())

        if ide["id"] == "android-studio":
            sdk_path = Path(settings["androidSdkPath"])

            def update_sdk(component):
                for child in component.findall("option[@name='androidSdkAbsolutePath']"):
                    component.remove(child)
                ET.SubElement(component, "option", name="androidSdkAbsolutePath", value=str(sdk_path))

            update_component(directory / "options/android.sdk.path.xml", "AndroidSdkPathStore", update_sdk)

        if ide["id"] == "clion":
            tools = settings["toolchain"]

            def update_toolchains(component):
                component.set("version", "10")
                toolchains = component.find("toolchains")
                if toolchains is None:
                    toolchains = ET.SubElement(component, "toolchains")
                for child in toolchains.findall("toolchain[@name='Nix']"):
                    toolchains.remove(child)
                # CLion uses the first entry as its default local toolchain.
                toolchains.insert(0, ET.Element("toolchain", {
                    "name": "Nix",
                    "toolSetKind": "SYSTEM_UNIX_TOOLSET",
                    "customCMakePath": tools["cmake"],
                    "customMakePath": tools["ninja"],
                    "customCCompilerPath": tools["cc"],
                    "customCXXCompilerPath": tools["cxx"],
                    "debuggerKind": "CUSTOM_GDB",
                    "customGDBPath": tools["gdb"],
                }))

            update_component(directory / "options/cpp.toolchains.xml", "CPPToolchains", update_toolchains)

    state_directory = Path(settings["stateDirectory"])
    migrate_gradle_java_home(home, state_directory, settings["legacyGradleJavaHome"])


if __name__ == "__main__":
    main()
