# vim:fileencoding=utf-8:foldmethod=marker


def setup(c):
    palette = {
        "theme_background": "#000000",
        "theme_red": "#bc3f3c",
        "theme_green": "#6a9955",
        "theme_yellow": "#e6e6aa",
        "theme_blue": "#47a2ed",
        "theme_purple": "#3181a7",
        "theme_magenta": "#bc3f3c",
        "theme_cyan": "#47ccb1",
        "theme_white": "#d4d4d4",
        "theme_bright_background": "#3a3a3a",
        "theme_bright_dark": "#72737a",
        "theme_bright_red": "#ff0000",
        "theme_bright_blue": "#8cd7ff",
        "theme_bright_white": "#ffffff",
        "theme_bright_yellow": "#ffc66d",
    }

    # background
    c.colors.webpage.bg = palette["theme_background"];
    c.colors.webpage.preferred_color_scheme = 'dark'
    c.colors.webpage.darkmode.enabled = True
    c.colors.webpage.darkmode.policy.images = 'never'

    # completion {{{
    c.colors.completion.category.bg = palette["theme_background"]
    c.colors.completion.category.border.bottom = palette["theme_bright_white"]
    c.colors.completion.category.border.top = palette["theme_bright_white"]
    c.colors.completion.category.fg = palette["theme_yellow"]
    c.colors.completion.even.bg = palette["theme_background"]
    c.colors.completion.odd.bg = palette["theme_background"]
    c.colors.completion.fg = palette["theme_bright_white"]

    # completion selected item
    c.colors.completion.item.selected.bg = palette["theme_bright_background"]
    c.colors.completion.item.selected.border.bottom = palette["theme_bright_background"]
    c.colors.completion.item.selected.border.top = palette["theme_bright_background"]
    c.colors.completion.item.selected.fg = palette["theme_bright_white"]
    c.colors.completion.item.selected.match.fg = palette["theme_bright_yellow"]
    c.colors.completion.match.fg = palette["theme_yellow"]

    c.colors.completion.scrollbar.bg = palette["theme_background"]
    c.colors.completion.scrollbar.fg = palette["theme_bright_dark"]


    # downloads
    c.colors.downloads.bar.bg = palette["theme_background"]
    c.colors.downloads.error.bg = palette["theme_background"]
    c.colors.downloads.start.bg = palette["theme_background"]
    c.colors.downloads.stop.bg = palette["theme_background"]

    c.colors.downloads.error.fg = palette["theme_bright_red"]
    c.colors.downloads.start.fg = palette["theme_blue"]
    c.colors.downloads.stop.fg = palette["theme_green"]


    # hints
    c.colors.hints.bg = palette["theme_background"]
    c.colors.hints.fg = palette["theme_bright_white"]
    c.hints.border = "1px solid " + palette["theme_bright_white"]
    c.colors.hints.match.fg = palette["theme_bright_yellow"]


    # keyhints
    c.colors.keyhint.bg = palette["theme_background"]
    c.colors.keyhint.fg = palette["theme_white"]
    c.colors.keyhint.suffix.fg = palette["theme_bright_dark"]


    # messages
    c.colors.messages.error.bg = palette["theme_background"]
    c.colors.messages.info.bg = palette["theme_background"]
    c.colors.messages.warning.bg = palette["theme_background"]

    c.colors.messages.error.border = palette["theme_bright_dark"]
    c.colors.messages.info.border = palette["theme_bright_dark"]
    c.colors.messages.warning.border = palette["theme_bright_dark"]

    c.colors.messages.error.fg = palette["theme_bright_red"]
    c.colors.messages.info.fg = palette["theme_white"]
    c.colors.messages.warning.fg = palette["theme_yellow"]


    # prompts
    c.colors.prompts.bg = palette["theme_background"]
    c.colors.prompts.border = "1px solid " + palette["theme_bright_dark"]
    c.colors.prompts.fg = palette["theme_white"]
    c.colors.prompts.selected.bg = palette["theme_bright_background"]
    c.colors.prompts.selected.fg = palette["theme_bright_yellow"]


    # statusbar
    c.colors.statusbar.normal.bg = palette["theme_background"]
    c.colors.statusbar.insert.bg = palette["theme_green"]
    c.colors.statusbar.command.bg = palette["theme_background"]
    c.colors.statusbar.caret.bg = palette["theme_background"]
    c.colors.statusbar.caret.selection.bg = palette["theme_background"]
    c.colors.statusbar.progress.bg = palette["theme_background"]
    c.colors.statusbar.passthrough.bg = palette["theme_background"]

    c.colors.statusbar.normal.fg = palette["theme_white"]
    c.colors.statusbar.insert.fg = palette["theme_background"]
    c.colors.statusbar.command.fg = palette["theme_white"]
    c.colors.statusbar.passthrough.fg = palette["theme_yellow"]
    c.colors.statusbar.caret.fg = palette["theme_yellow"]
    c.colors.statusbar.caret.selection.fg = palette["theme_yellow"]

    c.colors.statusbar.url.error.fg = palette["theme_bright_red"]
    c.colors.statusbar.url.fg = palette["theme_white"]
    c.colors.statusbar.url.hover.fg = palette["theme_blue"]
    c.colors.statusbar.url.success.http.fg = palette["theme_cyan"]
    c.colors.statusbar.url.success.https.fg = palette["theme_green"]
    c.colors.statusbar.url.warn.fg = palette["theme_yellow"]

    c.colors.statusbar.private.bg = palette["theme_background"]
    c.colors.statusbar.private.fg = palette["theme_bright_dark"]
    c.colors.statusbar.command.private.bg = palette["theme_background"]
    c.colors.statusbar.command.private.fg = palette["theme_bright_dark"]


    # tabs
    c.colors.tabs.bar.bg = palette["theme_background"]
    c.colors.tabs.even.bg = palette["theme_background"]
    c.colors.tabs.odd.bg = palette["theme_background"]

    c.colors.tabs.even.fg = palette["theme_bright_dark"]
    c.colors.tabs.odd.fg = palette["theme_bright_dark"]

    c.colors.tabs.indicator.error = palette["theme_bright_red"]
    c.colors.tabs.indicator.system = "none"

    c.colors.tabs.selected.even.bg = palette["theme_bright_background"]
    c.colors.tabs.selected.odd.bg = palette["theme_bright_background"]

    c.colors.tabs.selected.even.fg = palette["theme_white"]
    c.colors.tabs.selected.odd.fg = palette["theme_white"]

    c.colors.tabs.pinned.even.bg = palette["theme_green"]
    c.colors.tabs.pinned.odd.bg = palette["theme_green"]
    c.colors.tabs.pinned.even.fg = palette["theme_background"]
    c.colors.tabs.pinned.odd.fg = palette["theme_background"]

    c.colors.tabs.pinned.selected.even.bg = palette["theme_bright_background"]
    c.colors.tabs.pinned.selected.odd.bg = palette["theme_bright_background"]
    c.colors.tabs.pinned.selected.even.fg = palette["theme_white"]
    c.colors.tabs.pinned.selected.odd.fg = palette["theme_white"]


    # context menu
    c.colors.contextmenu.menu.bg = palette["theme_background"]
    c.colors.contextmenu.menu.fg = palette["theme_white"]

    c.colors.contextmenu.disabled.bg = palette["theme_background"]
    c.colors.contextmenu.disabled.fg = palette["theme_bright_dark"]

    c.colors.contextmenu.selected.bg = palette["theme_bright_background"]
    c.colors.contextmenu.selected.fg = palette["theme_bright_yellow"]

    # }}}
