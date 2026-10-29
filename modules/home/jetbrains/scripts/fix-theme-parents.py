import sys
import zipfile

parents = {
    "TrueBlackIslands.xml": (b'parent_scheme="Islands Dark"', b'parent_scheme="Darcula"'),
    "TrueDarkIslands.xml": (b'parent_scheme="Islands Dark"', b'parent_scheme="Darcula"'),
    "TrueLightIslands.xml": (b'parent_scheme="Islands Light"', b'parent_scheme="Default"'),
}
with zipfile.ZipFile(sys.argv[1]) as source, zipfile.ZipFile(sys.argv[2], "w") as target:
    for entry in source.infolist():
        data = source.read(entry)
        if entry.filename in parents:
            old, new = parents.pop(entry.filename)
            assert data.count(old) == 1, entry.filename
            data = data.replace(old, new)
        target.writestr(entry, data)
assert not parents, parents
