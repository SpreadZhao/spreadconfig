#!/usr/bin/env python3
"""Restore the declared IDE preferences without replacing unrelated user state."""

import argparse
import json
import os
from pathlib import Path
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", required=True, type=Path)
    args = parser.parse_args()
    settings = json.loads(args.config.read_text())
    for ide in settings["ides"]:
        directory = Path(ide["configDirectory"])
        # Prevent startup UI selection from resetting the configured theme.
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


if __name__ == "__main__":
    main()
